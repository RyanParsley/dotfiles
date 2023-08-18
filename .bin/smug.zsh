_smug() {
  local commands projects
  commands=(${(f)"$(smug commands zsh)"})
  list=(${(f)"$(smug completions start)"})

  if (( CURRENT == 2 )); then
    _alternative \
      'commands:: _describe -t commands "smug subcommands" commands' \
      'list:: _describe -t list "smug list" projects'
  elif (( CURRENT == 3)); then
    case $words[2] in
      list|edit|new|start|stop|print)
        _arguments '*:projects:($projects)'
      ;;
    esac
  fi

  return
}

compdef _smug smug mux
alias mux="smug"

# Local Variables:
# mode: Shell-Script
# sh-indentation: 2
# indent-tabs-mode: nil
# sh-basic-offset: 2
# End:
# vim: ft=zsh sw=2 ts=2 et
