if status is-interactive
    # Commands to run in interactive sessions can go here
end

function fish_greeting
#     set_color green
#     echo -n "W"
#     set_color yellow
#     echo -n "e"
#     set_color cyan
#     echo -n "l"
#     set_color red
#     echo -n "c"
#     set_color purple
#     echo -n "o"
#     set_color blue
#     echo -n "m"
#     set_color brblue
#     echo -n "e"
#     set_color normal
#     echo " to everyone !"
end

#function fish_prompt
#     echo ""
#     # echo -n "[ " 
#     set_color purple
#     echo -n "$USER"
#     set_color normal
#     echo "@$(/bin/hostname):$(pwd)"
#     echo -n "\$ "
# end

# convenient alisases
alias gcom="git add --all; git commit -S"
alias prime-run="__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia"
#alias hx="helix"
alias yadmcom="yadm commit -S"
#eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)

export PATH="$HOME/.cargo/bin:$PATH"
