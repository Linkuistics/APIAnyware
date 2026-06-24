# Annotation vocabulary (identical for every arm)

For each method, supply ONLY the fields that apply (omit the rest):

- selector            (string; copy the selector EXACTLY incl. ':' and '(_:)' )
- is_instance         (boolean true/false)
- returns_ownership   (one of: owned | autoreleased | borrowed | none)
- threading           (one of: any | main-thread-only | owning-thread-only)
- error_pattern       (one of: nserror_out | null_on_failure | exception | none)
- block_parameters    (list of {param_index:int, invocation: sync|stored|escaping})
- param_ownership     (list of {param_index:int, ownership: copied|retained|borrowed})
- patterns            (list of {stereotype:string, note:string})
- rationale           (FREE TEXT — write a real one-sentence justification; use natural
                       prose incl. apostrophes, colons, quoted "terms", em-dashes —,
                       and arrows -> where natural. Do NOT sanitize the prose.)
- doc_ref             (FREE TEXT citation, e.g. an Apple URL or "Foundation Release Notes: §3")
- source              (always the string: llm)

Annotate all 20. Make the rationale genuinely descriptive (this is where real
annotations carry punctuation that must survive the format).
