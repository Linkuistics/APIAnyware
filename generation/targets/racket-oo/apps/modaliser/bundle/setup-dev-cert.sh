#!/bin/bash
set -euo pipefail

# setup-dev-cert.sh — Create the "Modaliser Dev" self-signed codesigning
# identity used by bundle/build.sh.
#
# Why this exists: macOS TCC keys Accessibility / Screen Recording grants
# by CDHash. With a stable signing identity the CDHash stays constant
# across rebuilds, so grants persist. Without it (ad-hoc signing), every
# bundle/build.sh run produces a new CDHash and TCC silently invalidates
# existing grants.
#
# The Keychain Access GUI equivalent is documented in README
# "Codesigning & TCC permissions"; this script automates the same steps
# non-interactively, except for the login password, which the security
# tool requires to set the key's partition list (without it, codesign
# would prompt "allow access" on every invocation).
#
# Usage:
#   bundle/setup-dev-cert.sh          # no-op if cert already installed
#   bundle/setup-dev-cert.sh --force  # delete any existing cert and recreate

CERT_CN="Modaliser Dev"
KEYCHAIN="${HOME}/Library/Keychains/login.keychain-db"
FORCE=0

for arg in "$@"; do
    case "$arg" in
        --force) FORCE=1 ;;
        -h|--help)
            sed -n '3,22p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *) echo "unknown arg: $arg" >&2; exit 2 ;;
    esac
done

# --- Idempotence: skip if already present (unless --force) ---
if security find-identity -v -p codesigning | grep -q "\"${CERT_CN}\""; then
    if [ "$FORCE" -eq 0 ]; then
        echo "\"${CERT_CN}\" codesigning identity already present — nothing to do."
        echo "Use --force to remove and recreate."
        exit 0
    fi
    echo "Removing existing \"${CERT_CN}\" identity (--force)..."
    # Delete every matching cert (there may be more than one if previous
    # runs failed halfway).
    while security find-certificate -c "${CERT_CN}" "${KEYCHAIN}" >/dev/null 2>&1; do
        security delete-certificate -c "${CERT_CN}" "${KEYCHAIN}"
    done
fi

# --- Prompt for login password once (needed for set-key-partition-list) ---
echo "Creating \"${CERT_CN}\" self-signed codesigning identity."
echo "Your login password is required so codesign can use the key"
echo "non-interactively (no \"allow access\" prompt on every build)."
echo
read -r -s -p "Login password: " LOGIN_PW
echo

# --- Scratch space (cleaned up on exit) ---
WORKDIR="$(mktemp -d)"
trap 'rm -rf "${WORKDIR}"' EXIT

KEY="${WORKDIR}/modaliser-dev.key"
CERT="${WORKDIR}/modaliser-dev.crt"
P12="${WORKDIR}/modaliser-dev.p12"
OPENSSL_CONF="${WORKDIR}/openssl.cnf"

# --- OpenSSL config: self-signed root with code-signing EKU ---
cat > "${OPENSSL_CONF}" << EOF
[ req ]
distinguished_name = req_dn
prompt             = no
x509_extensions    = v3_ext

[ req_dn ]
CN = ${CERT_CN}

[ v3_ext ]
basicConstraints     = critical, CA:FALSE
keyUsage             = critical, digitalSignature
extendedKeyUsage     = critical, codeSigning
subjectKeyIdentifier = hash
EOF

# --- Generate self-signed cert (10 years) ---
openssl req -x509 -newkey rsa:2048 -keyout "${KEY}" -out "${CERT}" \
    -days 3650 -nodes -config "${OPENSSL_CONF}" >/dev/null 2>&1

# Throwaway passphrase — only used to hand the key+cert pair to `security
# import` in one blob; never stored anywhere else.
P12_PW="$(openssl rand -hex 16)"

openssl pkcs12 -export -out "${P12}" \
    -inkey "${KEY}" -in "${CERT}" \
    -name "${CERT_CN}" \
    -password "pass:${P12_PW}" >/dev/null 2>&1

# --- Import into login keychain ---
# -T codesign grants the codesign binary access; -T /usr/bin/security
# lets the partition-list command itself touch the key.
security import "${P12}" -k "${KEYCHAIN}" \
    -P "${P12_PW}" \
    -T /usr/bin/codesign \
    -T /usr/bin/security >/dev/null

# --- Allow codesign to use the key without GUI prompts ---
security set-key-partition-list \
    -S "apple-tool:,apple:,codesign:" \
    -s \
    -k "${LOGIN_PW}" \
    "${KEYCHAIN}" >/dev/null

unset LOGIN_PW

# --- Verify ---
if security find-identity -v -p codesigning | grep -q "\"${CERT_CN}\""; then
    echo
    echo "Success. \"${CERT_CN}\" is ready. Run bundle/build.sh to sign with it."
else
    echo "ERROR: identity not visible after import. Inspect Keychain Access." >&2
    exit 1
fi
