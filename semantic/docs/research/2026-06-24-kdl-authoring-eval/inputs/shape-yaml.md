# Target format: YAML  (output extension .yaml; parsed by PyYAML / YAML 1.1)

## YAML rules (follow exactly)
- Booleans: true / false. A mapping is `key: value`; a list is `- item`.
- QUOTE any string that could be misread by YAML 1.1: anything containing a colon+space,
  selectors ending in `:` (e.g. `"setObject:forKey:"`), and values that look like
  booleans (`NO`, `yes`, `on`, `off`) or numbers but are meant as text. When in doubt, quote.
- Use 2-space indentation. Use block style (not flow `{}`/`[]`).

## Shape: top-level `framework`; a `methods:` list; each item carries the fields.

Worked example — method #1 (simple) and #5 (with a list):

```yaml
framework: Foundation
methods:
  - selector: "stringByAppendingString:"
    is_instance: true
    returns_ownership: owned
    threading: any
    param_ownership:
      - param_index: 0
        ownership: copied
    rationale: "Returns a new string the caller owns; the argument isn't retained."
    doc_ref: "https://developer.apple.com/documentation/foundation/nsstring"
    source: llm
  - selector: "sortedArrayUsingComparator:"
    is_instance: true
    returns_ownership: owned
    threading: any
    block_parameters:
      - param_index: 0
        invocation: sync
    rationale: 'The comparator is invoked synchronously during the call — it does not "escape".'
    source: llm
```

Now author all 20 methods in this exact YAML shape. Output ONLY the YAML document.
