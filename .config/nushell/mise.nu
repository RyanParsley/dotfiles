def "parse vars" [] {
  $in | from csv --noheaders --no-infer | rename 'op' 'name' 'value'
}

def --env "update-env" [] {
  for $var in $in {
    if $var.op == "set" {
      if ($var.name | str upcase) == 'PATH' {
        $env.PATH = ($var.value | split row (char esep))
      } else {
        load-env {($var.name): $var.value}
      }
    } else if $var.op == "hide" and $var.name in $env {
      hide-env $var.name
    }
  }
}
export-env {
  
  'set,JAVA_HOME,/Applications/Android Studio.app/Contents/jbr/Contents/Home
set,PATH,/opt/homebrew/sbin:/opt/homebrew/bin:/usr/local/bin:/Users/ryan/bin/google-cloud-sdk/bin:/Users/ryan/bin:/Users/ryan/.bin:/Users/ryan/.local/bin:/Users/ryan/.local/share/bob/nvim-bin:/Users/ryan/.cargo/bin:/Users/ryan/.opencode/bin:/Users/ryan/google-cloud-sdk/bin:/opt/homebrew/sbin:/opt/homebrew/sbin:/Users/ryan/go/bin:/Users/ryan/local/bin:/Users/ryan/bin:/Users/ryan/.bin:/Users/ryan/.bun/bin:/Users/ryan/.local/share/bob/nvim-bin:/Users/ryan/google-cloud-sdk/bin:/Users/ryan/.rd/bin:/Library/Frameworks/Python.framework/Versions/2.7/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/opt/pmk/env/global/bin:/Library/Apple/usr/bin:/Library/TeX/texbin:/usr/local/go/bin:/Users/ryan/.cargo/bin:/Users/ryan/go/bin:/Applications/Ghostty.app/Contents/MacOS:/Users/ryan/.orbstack/bin:/opt/homebrew/opt/fzf/bin:/opt/homebrew/opt/qt@5/bin:/Users/ryan/.lmstudio/bin
hide,MISE_SHELL,
hide,__MISE_DIFF,
hide,__MISE_DIFF,' | parse vars | update-env
  $env.MISE_SHELL = "nu"
  let mise_hook = {
    condition: { "MISE_SHELL" in $env }
    code: { mise_hook }
  }
  add-hook hooks.pre_prompt $mise_hook
  add-hook hooks.env_change.PWD $mise_hook
}

def --env add-hook [field: cell-path new_hook: any] {
  let field = $field | split cell-path | update optional true | into cell-path
  let old_config = $env.config? | default {}
  let old_hooks = $old_config | get $field | default []
  $env.config = ($old_config | upsert $field ($old_hooks ++ [$new_hook]))
}

export def --env --wrapped main [command?: string, --help, ...rest: string] {
  let commands = ["deactivate", "shell", "sh"]

  if ($command == null) {
    ^"/opt/homebrew/bin/mise"
  } else if ($command == "activate") {
    $env.MISE_SHELL = "nu"
  } else if ($command in $commands) {
    ^"/opt/homebrew/bin/mise" $command ...$rest
    | parse vars
    | update-env
  } else {
    ^"/opt/homebrew/bin/mise" $command ...$rest
  }
}

def --env mise_hook [] {
  ^"/opt/homebrew/bin/mise" hook-env -s nu
    | parse vars
    | update-env
}

