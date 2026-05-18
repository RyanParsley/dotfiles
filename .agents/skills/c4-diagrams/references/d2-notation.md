# D2 Notation for C4 Diagrams

How to express C4 model elements using D2 syntax.

## Element Styles

### Person (C4 stick figure equivalent)

```d2
customer: "Personal Banking Customer\n[Person]" {
  style.fill: "#08427b"
  style.font-color: "#ffffff"
  style.stroke-width: 2
}
```

### Software System — Internal

```d2
banking_system: "Internet Banking System\n[Software System]" {
  style.fill: "#1168bd"
  style.font-color: "#ffffff"
  style.stroke-width: 2
}
```

### Software System — External

```d2
mainframe: "Mainframe Banking System\n[Software System]\nCore banking data" {
  style.fill: "#999999"
  style.font-color: "#ffffff"
}
```

### Container — Application

```d2
api_app: "API Application\n[Container: Java Spring MVC]\nExposes JSON/HTTP API" {
  style.fill: "#438dd5"
  style.font-color: "#ffffff"
}
```

### Container — Database

```d2
database: "Database Schema\n[Container: PostgreSQL]\nStores user credentials" {
  shape: cylinder
  style.fill: "#438dd5"
  style.font-color: "#ffffff"
}
```

### Component

```d2
signin_controller: "Sign In Controller\n[Component: Spring MVC REST]\nHandles authentication" {
  style.fill: "#85bbf0"
  style.font-color: "#000000"
}
```

## Relationship Styles

### Synchronous call (solid line)

```d2
spa -> api_app: "makes JSON/HTTP API calls" {
  style.stroke-width: 2
}
```

### Asynchronous/event (dashed line)

```d2
service_a -> service_b: "sends events via" {
  style.stroke-width: 2
  style.stroke-dash: 3
}
```

### Read relationship

```d2
api_app -> database: "reads/writes using JDBC" {
  style.stroke-width: 2
}
```

## Container Grouping

For Level 2, group containers inside the system boundary:

```d2
direction: right

# External elements
customer: "Personal Banking Customer\n[Person]" {
  style.fill: "#08427b"
  style.font-color: "#ffffff"
}

mainframe: "Mainframe Banking System\n[Software System]" {
  style.fill: "#999999"
  style.font-color: "#ffffff"
}

email_system: "Email System\n[Software System]" {
  style.fill: "#999999"
  style.font-color: "#ffffff"
}

# The system being described
internet_banking: "Internet Banking System\n[Software System]" {
  style.stroke-width: 3

  spa: "Single Page App\n[Container: Angular]\nDelivers UI in browser" {
    style.fill: "#438dd5"
    style.font-color: "#ffffff"
  }

  mobile_app: "Mobile App\n[Container: Xamarin]\nCross-platform mobile UI" {
    style.fill: "#438dd5"
    style.font-color: "#ffffff"
  }

  api_app: "API Application\n[Container: Java Spring MVC]\nExposes JSON/HTTP API" {
    style.fill: "#438dd5"
    style.font-color: "#ffffff"
  }

  database: "Database Schema\n[Container: PostgreSQL]\nStores user credentials" {
    shape: cylinder
    style.fill: "#438dd5"
    style.font-color: "#ffffff"
  }

  # Internal relationships
  spa -> api_app: "makes JSON/HTTP API calls"
  mobile_app -> api_app: "makes JSON/HTTP API calls"
  api_app -> database: "reads/writes using JDBC"
}

# External relationships
customer -> spa: "uses"
customer -> mobile_app: "uses"
api_app -> mainframe: "makes HTTPS calls to"
api_app -> email_system: "sends email using"
```

## Legend/Key

Add a legend as a container at the bottom or side:

```d2
legend: {
  style.stroke-dash: 3
  style.fill: "#fafafa"

  person_example: "[Person]" {
    style.fill: "#08427b"
    style.font-color: "#ffffff"
  }
  system_example: "[Software System]" {
    style.fill: "#1168bd"
    style.font-color: "#ffffff"
  }
  container_example: "[Container]" {
    style.fill: "#438dd5"
    style.font-color: "#ffffff"
  }
  external_example: "[External System]" {
    style.fill: "#999999"
    style.font-color: "#ffffff"
  }
  relationship_example: "relationship" {
    style.stroke-width: 2
  }
}
```

## Title

D2 doesn't have a native title element. Add as a text shape at the top:

```d2
title: {
  shape: text
  label: "Container Diagram — Internet Banking System"
  style.font-size: 20
  style.bold: true
}
```

## Full Template Structure

```d2
# Title
title: {
  shape: text
  label: "Container Diagram — System Name"
  style.font-size: 20
  style.bold: true
}

direction: right

# People
customer: "Customer Name\n[Person]" {
  style.fill: "#08427b"
  style.font-color: "#ffffff"
}

# External systems
external_system: "External System\n[Software System]" {
  style.fill: "#999999"
  style.font-color: "#ffffff"
}

# The system (contains containers)
system: "System Name\n[Software System]" {
  style.stroke-width: 3

  container1: "Container Name\n[Container: Technology]\nDescription" {
    style.fill: "#438dd5"
    style.font-color: "#ffffff"
  }

  container2: "Database Name\n[Container: PostgreSQL]\nDescription" {
    shape: cylinder
    style.fill: "#438dd5"
    style.font-color: "#ffffff"
  }

  container1 -> container2: "reads/writes using"
}

# Relationships
customer -> system.container1: "uses"
system.container1 -> external_system: "makes calls to"

# Legend
legend: {
  style.stroke-dash: 3
  style.fill: "#fafafa"
  # ... legend elements
}
```

## Layout Tips

- `direction: right` — left-to-right flow (default, good for most diagrams)
- `direction: down` — top-to-bottom flow (good for hierarchical data)
- `--layout=dagre` — compact, hierarchical (best for most C4 diagrams)
- `--layout=elk` — more spacing, better for system context with many elements

## Colorblind-Safe Palette

The C4 standard colors are designed to work for colorblind users:

| Element | Hex | Notes |
|---------|-----|-------|
| Person | `#08427b` | Dark blue |
| Internal System | `#1168bd` | Medium blue |
| Container | `#438dd5` | Light blue |
| Component | `#85bbf0` | Very light blue |
| External System | `#999999` | Gray |

These are distinguishable by both color AND position in the hierarchy, so removing color still leaves a readable diagram.
