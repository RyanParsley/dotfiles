# The following lines were added by Docker Desktop to add commands to your PATH.
export PATH="$PATH:/Users/ryan/.docker/bin"
# End of Docker Desktop section.

starship init fish | source

if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /Users/ryan/.lmstudio/bin
# End of LM Studio CLI section
