# ~/.bashrc
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias yay='yay --color=auto'
# alias pacman='yay --color=auto'
PS1='[\u@\h \W]\$ '

# Automatically start tmux if not already in a tmux session
if [[ -z "$TMUX" ]]; then
    # Check if there's an existing tmux session
    if tmux has-session 2>/dev/null; then
        # Attach to the existing session
        tmux attach-session
    else
        # Start a new tmux session
        tmux new-session 
    fi
fi

eval "$(oh-my-posh init bash --config ~/.config/poshthemes/emodipt-extend.omp.json)"

. "$HOME/.cargo/env"

fastfetch
