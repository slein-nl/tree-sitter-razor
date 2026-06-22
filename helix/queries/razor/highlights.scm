; Pull in Helix's c-sharp highlights for all the real C# AST nodes this
; grammar produces (it extends tree-sitter-c-sharp). Helix resolves
; `inherits` by inlining runtime/queries/c-sharp/highlights.scm.
; inherits: c-sharp

[
  (razor_comment)
  (html_comment)
] @comment

; ==================== HTML (tag/attribute nodes exposed by grammar patch) ====
(tag_name) @tag
(html_attribute_name) @attribute
(boolean_html_attribute) @attribute
(html_attribute_value) @string

; ==================== RAZOR DIRECTIVES ====================
[
  "at_page"
  "at_using"
  "at_model"
  "at_rendermode"
  "at_inject"
  "at_implements"
  "at_layout"
  "at_inherits"
  "at_attribute"
  "at_typeparam"
  "at_namespace"
  "at_preservewhitespace"
  "at_block"
  "at_at_escape"
  "at_colon_transition"
  "at_addtaghelper"
  "at_removetaghelper"
  "at_taghelperprefix"
] @keyword.directive

[
  "at_lock"
  "at_section"
] @keyword

[
  "at_if"
  "at_switch"
] @keyword.control.conditional

[
  "at_for"
  "at_foreach"
  "at_while"
  "at_do"
] @keyword.control.repeat

[
  "at_try"
  "catch"
  "finally"
] @keyword.control.exception

; The @ marker of implicit (@Foo) and explicit (@(...)) expressions — color
; it like every other razor @ so all markers are consistent (matches VS Code).
[
  "at_implicit"
  "at_explicit"
] @keyword.directive

; The ( ) of an explicit expression @(...) are Razor delimiters that belong to
; the @ marker, not C# grouping parens — color them like the marker. (Later
; than the inherited c-sharp bracket rule, so it overrides for these only.)
; @(...) parses as explicit OR implicit (with a parenthesized expression)
; depending on context, so handle both.
(razor_explicit_expression
  (parenthesized_expression
    "(" @keyword.directive
    ")" @keyword.directive))
(razor_implicit_expression
  (parenthesized_expression
    "(" @keyword.directive
    ")" @keyword.directive))

(razor_implicit_expression
  "at_implicit" @keyword.control
  (await_expression
    "await" @keyword.control))

(razor_rendermode) @attribute

; Razor directive attributes (@onclick, @bind, @ref, …) — color the whole
; name like the other razor @ markers.
(razor_attribute_name) @keyword.directive

(taghelper_wildcard) @string.special
