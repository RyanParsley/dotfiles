### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
set --export --prepend PATH "/Users/ryan/.rd/bin"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

starship init fish | source

if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /Users/ryan/.lmstudio/bin
# End of LM Studio CLI section

