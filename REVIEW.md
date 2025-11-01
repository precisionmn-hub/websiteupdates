# CSS Review Notes

1. **Quote multi-word font names**
   - `font-family: system-ui, -apple-system, Segoe UI, Roboto, Inter, Arial, sans-serif;`
   - In CSS, font family names that contain spaces must be quoted. Otherwise, the UA interprets them as two separate identifiers (`Segoe` and `UI`) and the intended face is never selected unless an alias exists. Update this declaration to `font-family: system-ui, -apple-system, 'Segoe UI', Roboto, 'Inter', Arial, sans-serif;` (quote `Inter` as well if it is not globally registered).

2. **Safari support for the sticky header blur**
   - `backdrop-filter` requires the prefixed `-webkit-backdrop-filter` to render in Safari. Without it, Safari users will see a plain opaque header. Add the prefixed property alongside the standard one for robust support.

3. **Ensure a semi-transparent header background**
   - The blur only becomes visible if the element's background has transparency. The rule currently sets `background: #fff;`, which prevents the filter from showing through. Confirm that this was intentional; otherwise consider `background: rgba(255, 255, 255, 0.9);` so the blur effect is perceivable.

4. **Confirm interactive element semantics**
   - `.menu-toggle` looks like a button but the CSS does not make it clear whether the markup uses a `<button>` element. If it is rendered as something else (e.g., a `<div>`), ask for semantic markup so that keyboard users and assistive technologies can operate it reliably.

