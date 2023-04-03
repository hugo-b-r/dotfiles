if status is-interactive
    # Commands to run in interactive sessions can go here
end

function fish_greeting
    set_color green
    echo -n "W"
    set_color yellow
    echo -n "e"
    set_color cyan
    echo -n "l"
    set_color red
    echo -n "c"
    set_color purple
    echo -n "o"
    set_color blue
    echo -n "m"
    set_color brblue
    echo -n "e"
    set_color normal
    echo " to everyone !"
    echo ""
end

function fish_prompt
    echo -n "[ " 
    set_color purple
    echo -n "$USER"
    set_color normal
    echo "@$(/bin/hostname) ]"
    echo -n "\$ "
end

# convenient alisases
alias gcom="git add --all; git commit -S"
alias hx="helix"
alias yadmcom="yadm commit -S"