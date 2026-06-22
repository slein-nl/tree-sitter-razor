; HTML tag/attribute coloring is now done directly in highlights.scm (the
; grammar was patched to expose tag_name / html_attribute_* as named nodes),
; so no html injection is needed. Keep c-sharp's injections (string
; interpolation, etc.) for the embedded C#.
; inherits: c-sharp
