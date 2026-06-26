---
name: ratatui
description: Expert Ratatui 0.30+ TUI development patterns, idioms, and best practices. Use when building terminal UIs, working with Crossterm, creating components, handling events, or rendering widgets in Rust.
---

# Ratatui Skill

You are an expert Ratatui developer. This skill grounds you in Ratatui 0.30+ patterns, idioms, and best practices. Always apply these principles when building or modifying TUI code.

## Core Philosophy

- **Immediate mode rendering**: UI is redrawn every frame from application state. No persistent widget objects.
- **Use `ratatui::run()` for simple apps** (v0.30+), or the Component Architecture for complex apps.
- **Crossterm** is the standard backend. Use `crossterm` feature (enabled by default). Avoid pulling in multiple semver-incompatible crossterm versions.
- **stderr** is preferred over stdout for the terminal backend (see Ratatui FAQ).

## Application Patterns

### Simple Apps: `ratatui::run()` (v0.30+)

For simple apps, use the simplified bootstrap:

```rust
use ratatui::{DefaultTerminal, Frame};

fn main() -> color_eyre::Result<()> {
    color_eyre::install()?;
    ratatui::run(app)?;
    Ok(())
}

fn app(terminal: &mut DefaultTerminal) -> std::io::Result<()> {
    loop {
        terminal.draw(render)?;
        if crossterm::event::read()?.is_key_press() {
            break Ok(());
        }
    }
}

fn render(frame: &mut Frame) {
    frame.render_widget("hello world", frame.area());
}
```

### Component Architecture (Recommended for Complex Apps)

The Component trait pattern encapsulates state, event handling, and rendering per-component:

```rust
pub trait Component {
    fn init(&mut self, area: Size) -> Result<()> { Ok(()) }
    fn handle_events(&mut self, event: Option<Event>) -> Result<Option<Action>> {
        // dispatches to handle_key_event / handle_mouse_event
    }
    fn handle_key_event(&mut self, key: KeyEvent) -> Result<Option<Action>> { Ok(None) }
    fn handle_mouse_event(&mut self, mouse: MouseEvent) -> Result<Option<Action>> { Ok(None) }
    fn update(&mut self, action: Action) -> Result<Option<Action>> { Ok(None) }
    fn draw(&mut self, frame: &mut Frame, area: Rect) -> Result<()>;
}
```

Components can return `Option<Action>` from `update()` and `handle_events()` to propagate actions to other components via a central `mpsc::UnboundedSender<Action>`.

### Action Pattern (Reified Method Calls)

```rust
#[derive(Debug, Clone, PartialEq, Eq, Display, Serialize, Deserialize)]
pub enum Action {
    Tick,
    Render,
    Resize(u16, u16),
    Suspend,
    Resume,
    Quit,
    ClearScreen,
    Error(String),
    Help,
    // app-specific actions...
}
```

Actions decouple event sources from state mutations. Components produce actions; the app loop consumes them and dispatches to all components' `update()` methods.

### The Elm Architecture (TEA) Alternative

For simpler state machines: Model + Message enum + update() + view(). Good for apps where a single global state suffices.

## Standard Project Structure

```
src/
├── main.rs          # Entry point: parse CLI, create App, call run()
├── action.rs        # Action enum definition
├── app.rs           # App struct: state, run loop, handle_events, handle_actions, render
├── cli.rs           # clap CLI argument parsing
├── config.rs        # Config + keybindings (Mode -> keymap -> Action)
├── tui.rs           # Tui struct: Terminal wrapper, event loop, enter/exit raw mode
├── errors.rs        # color_eyre setup, panic hooks
├── logging.rs       # tracing setup
└── components/
    ├── mod.rs       # Component trait definition
    ├── home.rs      # Main screen component
    └── fps.rs       # FPS counter component
```

Files outside `components/` are boilerplate that rarely changes. New features go in `components/`.

## App Run Loop

```rust
pub async fn run(&mut self) -> Result<()> {
    let mut tui = Tui::new()?
        .tick_rate(self.tick_rate)
        .frame_rate(self.frame_rate);
    tui.enter()?;

    for c in self.components.iter_mut() {
        c.register_action_handler(self.action_tx.clone())?;
    }

    loop {
        self.handle_events(&mut tui).await?;
        self.handle_actions(&mut tui)?;
        if self.should_quit {
            tui.exit()?;
            break;
        }
    }
    Ok(())
}
```

## Layout

### Layout Struct

```rust
let layout = Layout::vertical([
    Constraint::Length(1),  // header
    Constraint::Min(0),     // content (fills remaining)
    Constraint::Length(3),  // footer
]).split(frame.area());
```

### Constraints

- `Length(n)` — fixed size, not responsive
- `Percentage(n)` — relative to parent
- `Ratio(n, d)` — fractional (e.g., `Ratio(1, 3)`)
- `Min(n)` — minimum size (can combine with Percentage)
- `Max(n)` — maximum size
- `Fill(n)` — fills excess space proportionally

**Caution**: `Ratio` and `Percentage` are defined relative to the **parent's size**, not remaining space. Mixing fixed and flexible constraints in the same layout can produce unexpected results. Use nested layouts or `Min(0)` as a trailing constraint to absorb leftover space.

### Flex Alignment

```rust
Layout::horizontal([Length(10), Length(10)])
    .flex(Flex::Center)
    .spacing(2)
    .split(area)
```

Flex variants: `Legacy` (default, fills last element), `Start`, `End`, `Center`, `SpaceBetween`, `SpaceAround`.

## Event Handling

### KeyEvent

```rust
match key.code {
    KeyCode::Char(c) => ...,
    KeyCode::Enter => ...,
    KeyCode::Esc => ...,
    KeyCode::Tab => ...,
    KeyCode::BackTab => ...,
    KeyCode::Backspace => ...,
    KeyCode::Up | Down | Left | Right => ...,
    KeyCode::Home | End | PageUp | PageDown => ...,
    KeyCode::Insert | Delete => ...,
    KeyCode::F(n) => ...,
    _ => ...,
}
```

Check `key.modifiers` for `KeyModifiers::CONTROL`, `KeyModifiers::SHIFT`, `KeyModifiers::ALT`.

Check `key.kind == KeyEventKind::Press` to ignore release/repeat events.

### Event Loop Patterns

1. **Centralized**: Single match on `event::read()` — simple, doesn't scale
2. **Centralized catch + message passing**: Poll events centrally, send Actions — recommended
3. **Distributed**: Each component has its own event loop — no central dispatch needed

## Rendering

### Frame Methods

```rust
frame.render_widget(widget, area);
frame.render_stateful_widget(widget, area, &mut state);
```

### Immediate Mode Implications

- UI redrawn every frame — no need to "invalidate" or "update" widgets
- Conditional rendering: just don't draw a widget based on state
- Performance: if `draw` is slow, flush buffered events to avoid input lag

### Widget Composition

Common pattern: only pass a single root widget to `Frame::render_widget()`, then compose internally:

```rust
impl Widget for &App {
    fn render(self, area: Rect, buf: &mut Buffer) {
        Block::new().borders(Borders::ALL).render(area, buf);
        let inner = area.inner(Margin::new(1, 1));
        Paragraph::new(self.content).render(inner, buf);
    }
}
```

### Block as Container

`Block` is the primary visual container. Use `.borders()`, `.title()`, `.style()`, `.border_type()`:

```rust
Block::new()
    .borders(Borders::ALL)
    .title("Projects")
    .title_alignment(Alignment::Center)
    .border_type(BorderType::Rounded)
    .style(Style::new().fg(Color::Cyan))
```

## Panic Hooks

Always install a panic hook that restores the terminal:

```rust
use ratatui::crossterm::{
    terminal::{disable_raw_mode, LeaveAlternateScreen},
    ExecutableCommand,
};
use std::io::stdout;

pub fn install_panic_hook() {
    let original_hook = panic::take_hook();
    panic::set_hook(Box::new(move |panic_info| {
        stdout().execute(LeaveAlternateScreen).unwrap();
        disable_raw_mode().unwrap();
        original_hook(panic_info);
    }));
}
```

## Common Pitfalls

1. **Crossterm version conflicts**: Use `cargo tree -p crossterm` to check. Ratatui 0.30+ supports `crossterm_0_28` and `crossterm_0_29` feature flags.
2. **Out-of-range buffer panics**: Always ensure widget areas are within terminal bounds. Use `Rect::intersection()` and `area.inner(Margin::new(1, 1))` safely.
3. **Constraint solver non-determinism**: When Cassowary can't satisfy all constraints, results are non-deterministic. Avoid conflicting constraints.
4. **Raw mode not restored on panic**: Always install panic hooks.
5. **Event buffering during slow renders**: Flush events if draw takes >20ms to avoid input lag.
6. **String as Widget**: `&str` and `String` implement `Widget` but render without styling. Prefer `Paragraph` for control over wrapping, alignment, and style.
7. **Layout leftover space**: By default, `split()` allocates remaining space to the last rect. Add `Min(0)` as trailing constraint to avoid this.

## Keybindings Convention

Use vim-like navigation by default:
- `j/k` — down/up
- `h/l` — left/right
- `g/G` — top/bottom
- `Enter` — select/confirm
- `Esc` — cancel/back
- `q` — quit
- `?` or `F1` — help
- `Ctrl+c` — quit (fallback)

## Reference Files

- [Widgets, text system, testing, and dependencies](references/widgets-and-testing.md) — load when you need widget details, text styling, test patterns, or typical dependency versions.

## Gotchas

- **Multiple semver-incompatible `crossterm` versions cause compilation failure.** There must be exactly one version in the dependency tree. If builds fail with crossterm type errors, run `cargo tree -d crossterm` to find duplicates.
- **`ratatui::run()` is v0.30+ only.** Don't use it in projects pinned to older Ratatui versions — use the manual terminal setup instead.
- **Immediate mode means no persistent widget state between frames.** Widget objects are created fresh every draw call. If you find yourself storing a widget struct across frames, that's a design error.
- **Prefer `stderr` for the terminal backend** (see Ratatui FAQ). Using `stdout` breaks pipe-based workflows.
