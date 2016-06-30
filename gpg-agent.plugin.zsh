local GPG_DIR="${HOME}/.gnupg"
local GPG_ENV="${GPG_DIR}/gpg-agent.env"

local SSH_SOCK="${GPG_DIR}/$(basename ${SSH_AUTH_SOCK})"
local GPG_SOCK="${GPG_DIR}/$(basename ${GPG_AGENT_INFO} | cut -d : -f1)"

if [[ ! ( -f "${GPG_ENV}" && -S "${SSH_SOCK}" && -S "${GPG_SOCK}" ) ]]; then
    # clear possibly stale things
    rm  2> /dev/null
    rm  2> /dev/null
    pkill -TERM gpg-agent 2> /dev/null
    pkill -TERM ssh-agent 2> /dev/null
    # start and source the script
    eval "$(/usr/bin/env gpg-agent \
            --quiet \
            --daemon \
            --enable-ssh-support \
            --use-standard-socket \
            --write-env-file ${GPG_ENV} \
            2> /dev/null)"
    chmod 600 "${GPG_ENV}"
fi

source "${GPG_ENV}" 2> /dev/null

export GPG_AGENT_INFO
export SSH_AUTH_SOCK
export SSH_AGENT_PID

GPG_TTY=$(tty)
export GPG_TTY
