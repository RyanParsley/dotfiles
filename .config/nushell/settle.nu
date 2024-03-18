module completions {

  # CLI tool to manage a digital Zettelkasten
  export extern settle [
    --help(-h)                # Print help
    --version(-V)             # Print version
  ]

  # sync the database
  export extern "settle sync" [
    --project(-p): string     # helper option to --create and --move; specify working project
    --create(-c): string      # create a new Zettel
    --update(-u): string      # update a note's metadata, given its path
    --generate(-g)            # (re)generate the database
    --move(-m): string        # move the matching Zettel to a project; requires --project
    --rename(-n): string      # rename a note, preserving project and updating backlinks
    --help(-h)                # Print help
  ]

  # query the database
  export extern "settle query" [
    --title(-t): string       # keep Zettel with a matching title
    --project(-p): string     # keep Zettel that are in the matching projects
    --tag(-g): string         # keep Zettel that have a matching tag name
    --text(-x): string        # keep Zettel that contain some text
    --links(-l): string       # keep Zettel that have links to the matching Zettel
    --backlinks(-b): string   # keep Zettel that have links from the matching Zettel
    --loners(-o)              # keep Zettel that don't have any links to and fro
    --format(-f): string      # print formatted
    --link_sep(-s): string    # specify separator for links and backlinks in formatted output
    --graph: string           # turn the query results into a graph: 'dot', 'json' or 'vizk'
    --exact(-e)               # match everything exactly, disabling regex
    --help(-h)                # Print help
  ]

  # list things not related to notes
  export extern "settle ls" [
    OBJECT: string            # object to list (tags, projects, ghosts, path)
    --help(-h)                # Print help
  ]

  # generate completion file for a given shell
  export extern "settle compl" [
    SHELL: string
    --help(-h)                # Print help
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "settle help" [
  ]

  # sync the database
  export extern "settle help sync" [
  ]

  # query the database
  export extern "settle help query" [
  ]

  # list things not related to notes
  export extern "settle help ls" [
  ]

  # generate completion file for a given shell
  export extern "settle help compl" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "settle help help" [
  ]

}

export use completions *
