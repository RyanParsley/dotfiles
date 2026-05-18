---
name: c4-diagrams
description: "Create software architecture diagrams using the C4 model (Context, Containers, Components, Code). Applies Simon Brown's diagramming principles: titles, legends, directional arrows, explicit text, abstractions-first. Use when user asks for architecture diagrams, system diagrams, C4 diagrams, or wants to document software structure."
license: MIT
metadata:
  author: ryan
  version: "1.0"
  based_on: "Simon Brown C4 Model + Structurizr"
---

# C4 Architecture Diagrams

Create software architecture diagrams following Simon Brown's C4 model and diagramming principles.

## When to Use

- User asks for architecture diagrams, system diagrams, or "how does X work" diagrams
- User wants to document a codebase's structure
- User mentions C4, system context, containers, or components
- Starting a new project and need to map the architecture

## Quick Start

```
1. Identify the C4 level needed (Context → Containers → Components → Code)
2. Apply Simon's notation rules (titles, legends, directional arrows)
3. Generate D2 source using templates from assets/
4. Render with: d2 input.d2 output.svg --layout=dagre
```

## The C4 Model

Four levels of zoom, each telling a different story:

| Level | Name | Audience | Shows |
|-------|------|----------|-------|
| 1 | System Context | Everyone | System + people + external systems |
| 2 | Containers | Technical | Apps, datastores, deployment units |
| 3 | Components | Developers | Internal structure of one container |
| 4 | Code | Developers | Classes/interfaces (DO NOT draw — automate) |

**Rule**: Diagrams can be created in any order. Don't force sequential design.

## Simon Brown's Core Principles

### 1. Abstractions First, Notation Second

The **things** you diagram matter more than how they look. Two maps of the same city use different colors/symbols but show the same places.

### 2. Diagrams Must Stand Alone

A diagram on Confluence with no presenter must be self-explanatory. If someone new joins and reads it, they should understand without asking questions.

### 3. Think Like a Developer, Not an Architect

Diagrams should reflect reality. Another developer should look at it and say "yes, that's exactly what we're building."

### 4. Use Shape and Color to Complement, Not Replace

If you remove all color and shapes, the diagram must still make sense. Text carries the meaning; visuals reinforce it.

## Notation Rules

See [references/simon-checklist.md](references/simon-checklist.md) for the full checklist.

### Required on Every Diagram

- **Title**: "Diagram Type — Scope" (e.g., "Container Diagram — Internet Banking System")
- **Legend/Key**: Explain shapes, colors, line styles
- **Element types**: Every box says what it is (Person, Software System, Container, Component)
- **Directional arrows**: One-way only. Label describes the relationship
- **No unexplained acronyms**: Spell out domain-specific terms

### Arrow Rules

- All arrows point one direction
- Label describes the relationship: "makes HTTPS calls to", "reads from", "sends events to"
- Avoid "uses" — be specific
- If bidirectional but different in nature, show two arrows with different labels
- If bidirectional and same in nature, show one arrow with a summary label

### Box Content

Each box should contain:
1. **Name** — clear, memorable
2. **Type** — [Person], [Software System], [Container], [Component]
3. **Technology** — for technical elements (Java Spring, PostgreSQL, Angular)
4. **Description** — 1 sentence or 3-5 bullet points of responsibilities

## D2 Mapping to C4

See [references/d2-notation.md](references/d2-notation.md) for D2-specific syntax.

| C4 Element | D2 Shape | Style |
|------------|----------|-------|
| Person | default (rectangle) | `style.fill: "#08427b"`, `style.font-color: "#ffffff"` |
| Software System (internal) | default | `style.fill: "#1168bd"`, `style.font-color: "#ffffff"` |
| Software System (external) | default | `style.fill: "#999999"`, `style.font-color: "#ffffff"` |
| Container (app) | default | `style.fill: "#438dd5"`, `style.font-color: "#ffffff"` |
| Container (database) | cylinder | `style.fill: "#438dd5"`, `style.font-color: "#ffffff"` |
| Component | default | `style.fill: "#85bbf0"`, `style.font-color: "#000000"` |
| Relationship | arrow | `style.stroke-width: 2` |

## Workflow

### Step 1: Determine the Level

Ask: "What story are we telling?"

- **Big picture?** → Level 1 (System Context)
- **What runs where?** → Level 2 (Containers)
- **How is this container structured?** → Level 3 (Components)
- **Class-level detail?** → Don't draw. Use IDE or generate from code.

### Step 2: Identify Elements

For the chosen level, list all elements:

**Level 1**: People (roles), the system, external systems it depends on
**Level 2**: People, external systems, containers (apps, databases, services)
**Level 3**: People, external systems, containers, components inside one container

### Step 3: Map Relationships

For each pair of connected elements, define:
- Direction (who initiates)
- Relationship type (calls, reads, sends, depends on)
- Technology/protocol (HTTPS, JDBC, async events)

### Step 4: Apply Notation Rules

- Add title
- Add legend
- Ensure all boxes have type labels
- Ensure all arrows are directional with labels
- Check: would this make sense in black and white?

### Step 5: Read It Out Loud

Read the diagram as sentences: "The [Person] makes [protocol] calls to [Container] which reads from [Database]."

If it sounds like a coherent story, the diagram is good.

## Anti-Patterns to Avoid

| Anti-Pattern | Why It's Bad | Fix |
|-------------|-------------|-----|
| Boxes with no lines | No relationships shown | Add directional arrows with labels |
| Different shapes with no legend | Reader can't decode meaning | Add a key/legend |
| "Uses" as the only label | Too vague | Be specific: "makes REST calls to" |
| Bidirectional arrows everywhere | Cluttered, ambiguous | Use one arrow with summary label |
| Acronyms without explanation | New team members lost | Spell out or add to legend |
| No title | Reader doesn't know scope | Add "Type — Scope" title |
| Level 4 diagrams | Not worth maintaining | Automate from IDE instead |
| Pretty but unreadable | Aesthetics over clarity | Text > color; diagram must work B&W |

## Templates

D2 templates for each C4 level are in `assets/templates/`:

- `assets/templates/context.d2` — Level 1 System Context
- `assets/templates/containers.d2` — Level 2 Containers
- `assets/templates/components.d2` — Level 3 Components

## Rendering

```bash
# Single diagram
d2 input.d2 output.svg --layout=dagre

# Watch mode for live editing
d2 --watch input.d2 output.svg

# Layout options
# dagre  — compact, hierarchical (best for most diagrams)
# elk    — more spacing, layered (good for system context)
```

## Related Skills

- [write-a-skill](../write-a-skill/SKILL.md) — For creating this skill's templates
- [zoom-out](../zoom-out/SKILL.md) — For understanding codebase before diagramming
