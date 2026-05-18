# Ratatui Reference

## Built-in Widgets

| Widget | Purpose |
|--------|---------|
| `Block` | Container with borders, titles, styles |
| `Paragraph` | Styled, optionally wrapped text |
| `List` / `ListItem` | Scrollable list with selection |
| `Table` / `Row` / `Cell` | Tabular data with selection |
| `Tabs` | Tab bar with selection |
| `Gauge` / `LineGauge` | Progress bars |
| `BarChart` | Multiple datasets as bars |
| `Chart` | Line/scatter graphs |
| `Sparkline` | Single dataset sparkline |
| `Scrollbar` | Scrollbar indicator |
| `Canvas` | Arbitrary character drawing |
| `Calendar` | Monthly calendar |
| `Clear` | Clears area (useful for popups) |

## Text System

### Hierarchy

`Span` (styled text segment) → `Line` (collection of Spans) → `Text` (collection of Lines)

```rust
let line = Line::from(vec![
    Span::raw("Hello "),
    Span::styled("world", Style::new().fg(Color::Green).bold()),
    Span::raw("!"),
]);
```

### Style

```rust
Style::new()
    .fg(Color::Rgb(255, 128, 0))  // or Color::Red, Color::Blue, etc.
    .bg(Color::Black)
    .add_modifier(Modifier::BOLD | Modifier::UNDERLINED)
    .remove_modifier(Modifier::DIM)
```

## Third-Party Ecosystem

Common crates worth knowing:
- `ratatui-textarea` — multi-line text input
- `tui-input` / `ratatui-input` — single-line text input
- `ratatui-widgets` — additional community widgets
- `tuirealm` — Elm-style framework built on ratatui
- `tachyonfx` — effects and animations
- `strum` — derive `Display` for Action enum, enum iteration

## Dependencies (Typical)

```toml
[dependencies]
ratatui = "0.30"
crossterm = "0.29"
color-eyre = "0.6"
tokio = { version = "1", features = ["full"] }
tokio-util = "0.7"
futures = "0.3"
tracing = "0.1"
serde = { version = "1", features = ["derive"] }
strum = { version = "0.27", features = ["derive"] }
clap = { version = "4", features = ["derive"] }
```

## Testing

### insta Snapshots

Use `insta` for snapshot testing of rendered UI:

```rust
#[test]
fn renders_correctly() {
    let mut buf = Buffer::empty(Rect::new(0, 0, 20, 5));
    widget.render(buf.area, &mut buf);
    assert_buffer_snapshot!(buf);
}
```

### TestBackend

```rust
let mut terminal = Terminal::new(TestBackend::new(20, 5))?;
terminal.draw(|f| {
    f.render_widget(widget, f.area());
})?;
let buf = terminal.backend().buffer();
// assert on buf cells
```
