# tree-sitter-razor (Helix-patched fork)

A fork of [tris203/tree-sitter-razor](https://github.com/tris203/tree-sitter-razor)
(which extends [tree-sitter-c-sharp](https://github.com/tree-sitter/tree-sitter-c-sharp))
patched to highlight Razor / Blazor (`.razor`, `.cshtml`) properly in
[Helix](https://helix-editor.com/).

## Why this fork exists

Upstream relies on injecting the `html` language into `element` nodes to color
HTML tags/attributes. Helix does **not** run that injection (it won't inject
into an already-parsed node the way nvim's `combined` injection does), so with
upstream you get C# but no HTML coloring. This fork exposes the HTML pieces as
real named nodes so Helix can color them directly, and fixes a few cases where
a Razor expression's tail was swallowed as text.

## Patches (vs upstream `grammar.js`)

1. **Expose HTML nodes** — un-hid `_tag_name → tag_name`,
   `_html_attribute_name → html_attribute_name`,
   `_html_attribute_value → html_attribute_value`,
   `_boolean_html_attribute → boolean_html_attribute`. These are now named
   nodes, so `highlights.scm` can capture them (no injection needed).

2. **Attribute-value text token** — `/[^"@]+/` → `/[^"@.(\[?][^"@]*/`. A text
   run inside an attribute value may not *start* with `. ( ? [`, so
   `Class="@Foo.Bar"`, `@Foo()`, `@Foo?.Bar`, `@items[0]` keep extending the
   C# expression instead of the tail becoming attribute text. (Such chars are
   still allowed mid-run, so `"10.5px"` / `"a.b.c"` are unaffected.)

3. **Element-content text token** (`_html_text`) — added `?` and `[` to the
   forbidden-start set (upstream already excluded `.` and `(`), so
   `@Foo?.Bar()` and `@items[0]` parse correctly in element content too.

The parser is **regenerated at ABI 14** (`tree-sitter generate --abi 14`) and
`src/` is committed, so `hx --grammar build` needs only a C compiler — no Node
or tree-sitter-cli.

## Helix setup

`languages.toml`:

```toml
[[language]]
name = "razor"
scope = "source.razor"
injection-regex = "razor"
file-types = ["razor", "cshtml"]
roots = ["*.slnx", "*.sln", "*.csproj"]
grammar = "razor"
comment-token = "@*"
block-comment-tokens = { start = "@*", end = "*@" }
indent = { tab-width = 4, unit = "    " }

[[grammar]]
name = "razor"
source = { git = "https://github.com/<you>/tree-sitter-razor", rev = "<commit>" }
```

Copy `helix/queries/razor/*.scm` to your Helix runtime at
`runtime/queries/razor/`. They do `; inherits: c-sharp`, so your
`runtime/queries/c-sharp/` queries must also be present.

Then: `hx --grammar fetch && hx --grammar build` (a C/MSVC toolchain is
required to compile the parser).

## Regenerating after a grammar edit

```sh
npm install
npx tree-sitter generate --abi 14
```

---

Original upstream: a Tree-sitter parser for razor files —
<https://github.com/tris203/tree-sitter-razor>
