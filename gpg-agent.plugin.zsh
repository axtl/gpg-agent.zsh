local GPG_DIR="${HOME}/.gnupg"
local GPG_ENV="${GPG_DIR}/gpg-agent.env"
local SSH_SOCK=""
local GPG_SOCK=""

if [[ ! -z "${SSH_AUTH_SOCK}" ]]
then
    SSH_SOCK="${GPG_DIR}/$(basename ${SSH_AUTH_SOCK})"
fi

if [[ ! -z "${GPG_AGENT_INFO}" ]]
then
    GPG_SOCK="${GPG_DIR}/$(basename ${GPG_AGENT_INFO} | cut -d : -f1)"
fi

function _gpg_agent_start() {
    emulate -L zsh
    if [[ ! ( -f "${GPG_ENV}" && -S "${SSH_SOCK}" && -S "${GPG_SOCK}" ) ]]; then
        _gpg_agent_clean
        # start and source the script
        eval "$(/usr/bin/env gpg-agent \
                --quiet \
                --daemon \
                --enable-ssh-support \
                --use-standard-socket \
                --write-env-file ${GPG_ENV} \
                2> /dev/null)"
        [ -f "${GPG_ENV}" ] && chmod 600 "${GPG_ENV}"
    fi

    source "${GPG_ENV}" 2> /dev/null

    export GPG_AGENT_INFO
    export SSH_AUTH_SOCK
    export SSH_AGENT_PID

    GPG_TTY=$(tty)
    export GPG_TTY
}

function _gpg_agent_reset() {
    emulate -L zsh
    _gpg_agent_clean
    _gpg_agent_start 
}

function _gpg_agent_clean () {
    emulate -L zsh
    # clear possibly stale things
    rm "${SSH_SOCK}" 2> /dev/null
    rm "${GPG_SOCK}" 2> /dev/null
    rm "${GPG_ENV}" 2> /dev/null
    killall -9 gpg-agent 2> /dev/null
    killall -9 ssh-agent 2> /dev/null
}


_gpg_agent_start 
