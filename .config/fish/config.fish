if status is-interactive
    # Commands to run in interactive sessions can go here
end

function fish_greeting
    fortune | cowsay
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
alias gcoma="git add --all; git commit"
alias gcom="git commit"
alias prime-run="__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia"
#alias hx="helix"
alias yadmcom="yadm commit -S"
eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)

export PATH="$HOME/.cargo/bin:$HOME/programs:$HOME/.local/bin:$PATH:$HOME/programs/flutter/bin:$HOME/programs/android-studio/bin:$HOME/programs/dart-sdk/bin"
export ANDROID_HOME="/home/hugo/Android/Sdk"
