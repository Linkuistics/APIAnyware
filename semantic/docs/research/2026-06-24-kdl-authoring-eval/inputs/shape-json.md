# Target format: strict JSON  (output extension .json)

## JSON rules (follow exactly)
- Strict JSON: double-quote ALL keys and string values; escape `"`, `\`, and control
  chars inside strings. No comments. No trailing commas. Booleans true / false.

## Shape: an object with `framework` and a `methods` array of objects.

Worked example — method #1 (simple) and #5 (with a list):

```json
{
  "framework": "Foundation",
  "methods": [
    {
      "selector": "stringByAppendingString:",
      "is_instance": true,
      "returns_ownership": "owned",
      "threading": "any",
      "param_ownership": [{ "param_index": 0, "ownership": "copied" }],
      "rationale": "Returns a new string the caller owns; the argument isn't retained.",
      "doc_ref": "https://developer.apple.com/documentation/foundation/nsstring",
      "source": "llm"
    },
    {
      "selector": "sortedArrayUsingComparator:",
      "is_instance": true,
      "returns_ownership": "owned",
      "threading": "any",
      "block_parameters": [{ "param_index": 0, "invocation": "sync" }],
      "rationale": "The comparator is invoked synchronously during the call — it does not \"escape\".",
      "source": "llm"
    }
  ]
}
```

Now author all 20 methods in this exact JSON shape. Output ONLY the JSON document.
