import sys, json, subprocess, os
SP=os.environ["SP"]
KC=f"{SP}/kdlcheck/target/debug/kdlcheck"
try:
    import yaml
except Exception as e:
    yaml=None
EXPECTED=[
 "stringByAppendingString:","setObject:forKey:","writeToURL:atomically:encoding:error:",
 "replaceCharactersInRange:withString:","sortedArrayUsingComparator:",
 "addObserverForName:object:queue:usingBlock:","data(for:delegate:)","combineLatest(_:_:_:_:)",
 "makeKeyAndOrderFront:","contentsOfDirectoryAtURL:includingPropertiesForKeys:options:error:",
 "valueForKeyPath:","scanString:intoString:","colorWithRed:green:blue:alpha:",
 "enumerateMatchesInString:options:range:usingBlock:","async(execute:)","writeObjects:",
 "addSubview:","dataTaskWithRequest:completionHandler:","writeToFile:atomically:encoding:error:",
 "stringFromDate:"]
EXP=set(EXPECTED)

def check_loaded(name, doc):
    issues=[]
    methods=doc.get("methods") if isinstance(doc,dict) else None
    if methods is None: return ["no 'methods' list at top level"]
    if len(methods)!=20: issues.append(f"method count={len(methods)} (want 20)")
    sels=[]
    for m in methods:
        s=m.get("selector")
        if not isinstance(s,str): issues.append(f"selector not a string: {s!r} (type {type(s).__name__})"); continue
        sels.append(s)
        ii=m.get("is_instance")
        if ii is not None and not isinstance(ii,bool): issues.append(f"is_instance not bool for {s!r}: {ii!r}")
        src=m.get("source")
        if src is not None and src!="llm": issues.append(f"source coerced for {s!r}: {src!r} (type {type(src).__name__})")
        # type-coercion scan: any string field that became non-str
        for k in ("returns_ownership","threading","error_pattern","rationale","doc_ref"):
            v=m.get(k)
            if v is not None and not isinstance(v,str):
                issues.append(f"{k} coerced to {type(v).__name__} for {s!r}: {v!r}")
    missing=EXP-set(sels); extra=set(sels)-EXP
    if missing: issues.append(f"missing/altered selectors: {sorted(missing)}")
    if extra: issues.append(f"unexpected selectors (likely mangled): {sorted(extra)}")
    return issues

def report(name, status, issues):
    tag="WELL-FORMED" if status else "PARSE-FAIL"
    print(f"\n=== {name}: {tag} ===")
    if status:
        print("  fidelity:", "CLEAN" if not issues else f"{len(issues)} issue(s)")
        for i in issues: print("   -",i)

for fmt,ext,loader in [("yaml","yaml","yaml"),("json","json","json")]:
    for n in (1,2):
        f=f"{SP}/eval/out/{fmt}-{n}.{ext}"
        if not os.path.exists(f): print(f"MISSING {f}"); continue
        txt=open(f).read()
        try:
            doc=yaml.safe_load(txt) if loader=="yaml" else json.loads(txt)
            report(f"{fmt}-{n}", True, check_loaded(f"{fmt}-{n}",doc))
        except Exception as e:
            print(f"\n=== {fmt}-{n}: PARSE-FAIL ===\n   {type(e).__name__}: {str(e)[:300]}")

# KDL: parse via kdlcheck, extract selectors
for n in (1,2):
    f=f"{SP}/eval/out/kdl-{n}.kdl"
    if not os.path.exists(f): print(f"MISSING {f}"); continue
    r=subprocess.run([KC],stdin=open(f),capture_output=True,text=True)
    if r.returncode!=0:
        print(f"\n=== kdl-{n}: PARSE-FAIL ===\n   {r.stderr[:300]}"); continue
    sels=[l[4:] for l in r.stdout.splitlines() if l.startswith("SEL ")]
    issues=[]
    if len(sels)!=20: issues.append(f"method count={len(sels)} (want 20)")
    missing=EXP-set(sels); extra=set(sels)-EXP
    if missing: issues.append(f"missing/altered selectors: {sorted(missing)}")
    if extra: issues.append(f"unexpected selectors: {sorted(extra)}")
    report(f"kdl-{n}", True, issues)
