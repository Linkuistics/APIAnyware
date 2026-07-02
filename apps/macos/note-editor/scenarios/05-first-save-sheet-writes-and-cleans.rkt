#lang app-spec
;; forward-generated from Note Editor §15 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "first save opens the sheet prefilled untitled.md; completing it writes and cleans"
  #:description
  "When Save… is activated on a dirty Untitled document, then a save sheet slides down prefilled 'untitled.md' (§8.4 — the sheet branch), and completing it keyboard-first (Cmd-Shift-G → the work directory → Return, then Return for the sheet's default Save button) fires [document] saved inside the completion handler (the async re-entry witness), writes the editor text to disk (expect-file/read-file ground truth), cleans the title to 'untitled.md — Note Editor', and sets the status to 'Saved <path>' — which then persists with no timer (§14). The Go-to-Folder-in-sheet choreography is the k123 provisional row (firmed for the open panel, presumed for the sheet); requires a fresh work/ (run-values prep — a leftover untitled.md would raise the replace-confirmation). One save flow in its own launch."

  ;; run: editor-click-x/y, save-button-x/y — click coordinates (framebuffer px); work-dir /
  ;; work-file — the in-VM scratch paths the run stage prepares. Bound at run time from the
  ;; per-app run-values config (ADR-0011).
  (define editor-x (run-value 'editor-click-x))
  (define editor-y (run-value 'editor-click-y))
  (define save-x (run-value 'save-button-x))
  (define save-y (run-value 'save-button-y))
  (define work-dir (run-value 'work-dir))
  (define work-file (run-value 'work-file))

  ;; spec: §15 — Launch diagnostic is emitted. (presentation-settled probe before the click)
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP.
  (wait-for-log #rx"Note Editor")
  ;; spec: §15 — Toolbar is present. (render-settled probe)
  (wait-for-ocr "Undo")

  ;; spec: §15 — First save opens a sheet with the default name. (make the document dirty
  ;; first — the sheet is only reached from an Untitled document)
  (click-at editor-x editor-y)
  (wait 0.5)
  (type "# Hello")
  ;; spec: §15 — First save opens a sheet with the default name. (settle after type before
  ;; the button click — the k121 race; the final rendered line is the settle probe)
  (wait-for-log #px"\\[preview\\] rendered placeholder=false chars=7\\b" #:timeout 10.0)

  ;; spec: §15 — First save opens a sheet with the default name. (activate Save…)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at save-x save-y)
  ;; spec: (to confirm in-VM) — First save opens a sheet with the default name. (the
  ;; prefilled name field — lowercase 'untitled' is case-distinct from the title bar's
  ;; 'Untitled', and matches whether or not the panel hides the .md extension; this read
  ;; also GATES the keyboard drive below — an unavoidable coupling both consensus runs
  ;; flagged: no other contract-stable sheet-up cue exists until live-run firms the sheet's
  ;; AX shape)
  (wait-for-ocr "untitled" #:timeout 10.0)

  ;; spec: §15 — Completing the save writes the file and cleans the document. (keyboard-first
  ;; sheet drive: Cmd-Shift-G opens Go-to-Folder inside the sheet — the k103 fixture rule)
  ;; harness: runner/harness-inputs.rkt — chord takes a LIST of modifier symbols then a key.
  (chord '(cmd shift) 'g)
  (wait 1.0)
  ;; spec: §15 — Completing the save writes the file and cleans the document. (the DIRECTORY
  ;; path — the prefilled name supplies the filename; the panel canonicalizes /tmp to
  ;; /private/tmp, which is why the saved-event match below binds only the basename)
  (type work-dir)
  ;; spec: §15 — Completing the save writes the file and cleans the document. (Return
  ;; confirms Go-to-Folder, navigating the sheet to work/)
  (press 'return)
  (wait 1.0)
  ;; spec: §15 — Completing the save writes the file and cleans the document. (Return fires
  ;; the sheet's default Save button — the §15 driver guidance: press Return for a panel's
  ;; default button, never click)
  (press 'return)

  ;; spec: §15 — Completing the save writes the file and cleans the document. (the saved
  ;; event fires INSIDE the sheet's completion handler — the load-bearing async witness;
  ;; post-state dirty=false; basename-only match, the pdfkit basename rule)
  (wait-for-log #px"\\[document\\] saved path=\"[^\"]*/untitled\\.md\" dirty=false"
                #:timeout 15.0)

  ;; spec: §15 — Completing the save writes the file and cleans the document. (the file
  ;; exists — on-disk ground truth; the /tmp spelling resolves through the symlink in-guest)
  ;; harness: runner/harness-observations.rkt — expect-file checks driver-file-exists?.
  (expect-file work-file)
  ;; spec: §15 — Completing the save writes the file and cleans the document. (content
  ;; equality with what the scenario typed; read-file returns BYTES via in-guest cat)
  ;; harness: runner/harness-state.rkt — (read-file path).
  (let ([content (bytes->string/utf-8 (read-file work-file))])
    (unless (regexp-match? #rx"# Hello" content)
      (error 'saved-content "work file does not contain the typed text: ~v" content)))

  ;; spec: §15 — Completing the save writes the file and cleans the document. (title cleans
  ;; to the §6.1 clean form with the file's name — exact, real U+2014 em dashes)
  ;; harness: runner/harness-observations.rkt — expect-ax #:title is an exact equal? match.
  (expect-ax #:role 'AXWindow #:title "untitled.md — Note Editor")

  ;; spec: §15 — Completing the save writes the file and cleans the document. (the status
  ;; line begins 'Saved ' — the <path> tail is panel-canonicalized (/private/tmp), so the
  ;; stable prefix rides OCR, not an AX exact match; 11-pt small text, the k103 class —
  ;; adjudicate a garble against the saved event above)
  (wait-for-ocr "Saved" #:timeout 10.0)

  ;; spec: §14 — No status timers. (the status persists until the next operation replaces
  ;; it — after a deliberate 2s pause the prefix must still be on screen; a timer clearing
  ;; it would fail this read)
  (wait 2.0)
  (expect-ocr "Saved"))
