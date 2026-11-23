# aliases and small helpers

alias ls='eza'
alias ll='eza -lah --icons'
alias la='eza -a --icons'
alias cat='bat'
alias v='nvim .'
alias dbtf="$HOME/.local/bin/dbt"
alias kc='docker run --rm --network container:3406fb12674c curlimages/curl -s'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# yazi: cd to the directory you quit in
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"

    yazi "$@" --cwd-file="$tmp"

    if [[ -r "$tmp" ]]; then
        local cwd="$(cat -- "$tmp")"
        if [[ -n "$cwd" && "$cwd" != "$PWD" && -d "$cwd" ]]; then
            builtin cd -- "$cwd"
        fi
    fi

    rm -f -- "$tmp"
}
