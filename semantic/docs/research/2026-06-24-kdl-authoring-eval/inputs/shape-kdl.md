# Target format: KDL 2.0  (output extension .kdl)

## KDL 2.0 syntax rules (follow exactly)
- A node is: `name arg1 arg2 key=value { children }`. Positional args first, then
  key=value properties, then optional `{ ... }` children block.
- Booleans are `#true` / `#false`. Null is `#null`. (Bare `true`/`false` are INVALID.)
- Strings: `"double-quoted"` with backslash escapes for `"` and `\`. For text that
  contains quotes/backslashes you MAY use a raw string `#"...no escaping needed..."#`
  (add more `#` than occur inside). Numbers are bare: `0`, `1.5`.
- Node names and property keys may be bare identifiers if simple, else quoted.

## Shape: one `framework` node; one `method` child per method; fields as child nodes.

Worked example — method #1 (simple) and #5 (with a list):

```kdl
framework "Foundation" {
  method "stringByAppendingString:" is-instance=#true {
    returns-ownership "owned"
    threading "any"
    param-ownership 0 ownership="copied"
    rationale "Returns a new string the caller owns; the argument isn't retained."
    doc-ref "https://developer.apple.com/documentation/foundation/nsstring"
    source "llm"
  }
  method "sortedArrayUsingComparator:" is-instance=#true {
    returns-ownership "owned"
    threading "any"
    block-parameters {
      param 0 invocation="sync"
    }
    rationale #"The comparator is invoked synchronously during the call — it does not "escape"."#
    source "llm"
  }
}
```

Now author all 20 methods in this exact KDL shape. Output ONLY the KDL document.
