# Simon Brown's Notation Checklist

Based on Simon Brown's "Software Architecture Diagrams" talk. Run through this checklist for every diagram.

## Titles

- [ ] Diagram has a title
- [ ] Title includes diagram type (System Context, Container, Component)
- [ ] Title includes scope (the system being described)
- [ ] Example: "Container Diagram — Internet Banking System"

## Elements (Boxes)

- [ ] Every element has a **name**
- [ ] Every element has a **type** label ([Person], [Software System], [Container], [Component])
- [ ] Technical elements include **technology** (Java Spring, PostgreSQL, Angular)
- [ ] Every element has a **description** (1 sentence or 3-5 bullet points)
- [ ] Descriptions explain responsibilities, not just restate the name
- [ ] No element is just a named box with no context

## Relationships (Lines/Arrows)

- [ ] All arrows are **directional** (one-way only)
- [ ] No straight lines without arrowheads
- [ ] No double-headed arrows (unless two very different relationships)
- [ ] Every arrow has a **label** describing the relationship
- [ ] Labels are specific: "makes HTTPS calls to" not "uses"
- [ ] Arrow direction matches the label text
- [ ] Bi-directional relationships are summarized into one arrow with one label
- [ ] Exception: show two arrows if the two directions are fundamentally different

## Readability

- [ ] Diagram makes sense **without color** (text carries the meaning)
- [ ] Diagram makes sense **without shapes** (boxes could all be rectangles)
- [ ] Shape and color **complement** the text, they don't replace it
- [ ] No unexplained acronyms (spell out domain-specific terms)
- [ ] Focus on explaining domain jargon, not technical acronyms devs know

## Legend/Key

- [ ] Diagram has a **legend** or **key**
- [ ] Legend explains all shapes used
- [ ] Legend explains all colors used
- [ ] Legend explains all line styles (solid = sync, dashed = async, etc.)
- [ ] Legend explains any icons used
- [ ] Legend is consistent across all diagrams in the set

## Storytelling

- [ ] You can **read the diagram out loud** as coherent sentences
- [ ] Example: "The Personal Banking Customer makes HTTPS calls to the Single Page App which makes API calls to the API Application which reads from the Database Schema"
- [ ] The diagram tells a **story** about how the system works
- [ ] A new team member could understand the system from this diagram alone

## Level-Specific Checks

### Level 1 (System Context)
- [ ] Shows the system being built/described
- [ ] Shows all people/roles who use the system
- [ ] Shows all external software systems it depends on
- [ ] No technology choices visible (keep it high-level)
- [ ] Good for non-technical audiences

### Level 2 (Containers)
- [ ] Shows all separately deployable units (apps, databases, services)
- [ ] Shows technology choices for each container
- [ ] Shows how containers communicate at runtime
- [ ] Lines represent inter-process communication (network calls)
- [ ] Still shows people and external systems from Level 1

### Level 3 (Components)
- [ ] Zooms into ONE container from Level 2
- [ ] Shows internal structure (modules, packages, namespaces)
- [ ] Maps 1:1 to code organization (you could find these in the codebase)
- [ ] Shows technology choices (Spring Beans, REST Controllers)
- [ ] Still shows people, external systems, and other containers

### Level 4 (Code)
- [ ] **DO NOT DRAW** — automate from IDE instead
- [ ] Only draw if something unusual is happening that needs explanation
- [ ] Use UML class diagrams if needed
- [ ] 99% of the time, skip this level

## Common Mistakes

| Mistake | Why It's Bad | Fix |
|---------|-------------|-----|
| Boxes with no lines | No relationships shown | Add directional arrows with labels |
| "Uses" as the only label | Too vague | Be specific about the relationship |
| Hub-and-spoke hiding the story | Message bus obscures who talks to whom | Show point-to-point relationships, note the mechanism |
| Pretty but unreadable | Aesthetics over clarity | Text > color; diagram must work B&W |
| No legend | Reader can't decode visual language | Add a key explaining shapes/colors |
| Inconsistent notation across levels | Confusing to switch between diagrams | Keep people in same position, same color scheme |
| Too much text in boxes | Essay-length descriptions | Keep to 1 sentence or 3-5 bullets |
| Too little text in boxes | Named boxes with no context | Add type, technology, and description |

## The "Read Out Loud" Test

The ultimate test: read your diagram as a story.

**Good:**
> "The Personal Banking Customer opens their web browser and makes HTTPS calls to the Single Page App (Angular), which makes JSON-over-HTTP API calls to the API Application (Java Spring MVC), which reads user credentials from the Database Schema (PostgreSQL) and makes HTTPS calls to the Mainframe Banking System."

**Bad:**
> "Customer uses App uses API uses Database uses Mainframe."

If your diagram produces the "bad" reading, add more specific labels to your arrows and more description to your boxes.
