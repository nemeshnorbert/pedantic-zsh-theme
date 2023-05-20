#  Configuration
#
#  Set these variables in your .zshrc file
#  before including this theme file, e.g.:
#
#      PEDANTIC_SHOW_HOSTNAME=false
#      PEDANTIC_CURRENT_DIR_COLOUR=yellow

PEDANTIC_SHOW_BLANK_LINE="${PEDANTIC_SHOW_BLANK_LINE:-false}"
PEDANTIC_SHOW_TIMESTAMP="${PEDANTIC_SHOW_TIMESTAMP:-true}"
PEDANTIC_SHOW_USER="${PEDANTIC_SHOW_USER:-true}"
PEDANTIC_SHOW_HOSTNAME="${PEDANTIC_SHOW_HOSTNAME:-true}"
PEDANTIC_SHOW_CURRENT_DIR="${PEDANTIC_SHOW_CURRENT_DIR:-true}"
PEDANTIC_SHOW_GIT="${PEDANTIC_SHOW_GIT:-true}"
PEDANTIC_SHOW_PYTHON_ENVIRONMENT="${PEDANTIC_SHOW_PYTHON_ENVIRONMENT:-false}"

PEDANTIC_TIMESTAMP_COLOUR="${PEDANTIC_TIMESTAMP_COLOUR:-reset}"
PEDANTIC_USER_COLOUR="${PEDANTIC_USER_COLOUR:-blue}"
PEDANTIC_ROOT_USER_COLOUR="${PEDANTIC_ROOT_USER_COLOUR:-red}"
PEDANTIC_HOSTNAME_COLOUR="${PEDANTIC_HOSTNAME_COLOUR:-green}"
PEDANTIC_CURRENT_DIR_COLOUR="${PEDANTIC_CURRENT_DIR_COLOUR:-cyan}"
PEDANTIC_GIT_COLOUR="${PEDANTIC_GIT_COLOUR:-magenta}"
PEDANTIC_PYTHON_ENVIRONMENT_COLOUR="${PEDANTIC_PYTHON_ENVIRONMENT_COLOUR:-yellow}"

PEDANTIC_TIMESTAMP_BOLD="${PEDANTIC_TIMESTAMP_BOLD:-false}"
PEDANTIC_USER_BOLD="${PEDANTIC_USER_BOLD:-false}"
PEDANTIC_ROOT_USER_BOLD="${PEDANTIC_ROOT_USER_BOLD:-false}"
PEDANTIC_HOSTNAME_BOLD="${PEDANTIC_HOSTNAME_BOLD:-false}"
PEDANTIC_CURRENT_DIR_BOLD="${PEDANTIC_CURRENT_DIR_BOLD:-false}"
PEDANTIC_GIT_BOLD="${PEDANTIC_GIT_BOLD:-false}"
PEDANTIC_PYTHON_ENVIRONMENT_BOLD="${PEDANTIC_PYTHON_ENVIRONMENT_BOLD:-false}"

PEDANTIC_TIMESTAMP_FORMAT="${PEDANTIC_TIMESTAMP_FORMAT:-%H:%M:%S}" # see man strftime

PEDANTIC_PROMPT="${PEDANTIC_PROMPT:-$}"

PEDANTIC_GIT_SYMBOL_UNTRACKED="${PEDANTIC_GIT_SYMBOL_UNTRACKED:-?}"
PEDANTIC_GIT_SYMBOL_ADDED="${PEDANTIC_GIT_SYMBOL_ADDED:-+}"
PEDANTIC_GIT_SYMBOL_MODIFIED="${PEDANTIC_GIT_SYMBOL_MODIFIED:-!}"
PEDANTIC_GIT_SYMBOL_RENAMED="${PEDANTIC_GIT_SYMBOL_RENAMED:-!}"
PEDANTIC_GIT_SYMBOL_DELETED="${PEDANTIC_GIT_SYMBOL_DELETED:-!}"
PEDANTIC_GIT_SYMBOL_STASHED="${PEDANTIC_GIT_SYMBOL_STASHED:-*}"
PEDANTIC_GIT_SYMBOL_UNMERGED="${PEDANTIC_GIT_SYMBOL_UNMERGED:-M}"
PEDANTIC_GIT_SYMBOL_AHEAD="${PEDANTIC_GIT_SYMBOL_AHEAD:-↑}"
PEDANTIC_GIT_SYMBOL_BEHIND="${PEDANTIC_GIT_SYMBOL_BEHIND:-↓}"
PEDANTIC_GIT_SYMBOL_DIVERGED="${PEDANTIC_GIT_SYMBOL_DIVERGED:-~}"

# --

ZSH_THEME_GIT_PROMPT_UNTRACKED="${ZSH_THEME_GIT_PROMPT_UNTRACKED:-${PEDANTIC_GIT_SYMBOL_UNTRACKED}}"
ZSH_THEME_GIT_PROMPT_ADDED="${ZSH_THEME_GIT_PROMPT_ADDED:-${PEDANTIC_GIT_SYMBOL_ADDED}}"
ZSH_THEME_GIT_PROMPT_MODIFIED="${ZSH_THEME_GIT_PROMPT_MODIFIED:-${PEDANTIC_GIT_SYMBOL_MODIFIED}}"
ZSH_THEME_GIT_PROMPT_RENAMED="${ZSH_THEME_GIT_PROMPT_RENAMED:-${PEDANTIC_GIT_SYMBOL_RENAMED}}"
ZSH_THEME_GIT_PROMPT_DELETED="${ZSH_THEME_GIT_PROMPT_DELETED:-${PEDANTIC_GIT_SYMBOL_DELETED}}"
ZSH_THEME_GIT_PROMPT_STASHED="${ZSH_THEME_GIT_PROMPT_STASHED:-${PEDANTIC_GIT_SYMBOL_STASHED}}"
ZSH_THEME_GIT_PROMPT_UNMERGED="${ZSH_THEME_GIT_PROMPT_UNMERGED:-${PEDANTIC_GIT_SYMBOL_UNMERGED}}"
ZSH_THEME_GIT_PROMPT_AHEAD="${ZSH_THEME_GIT_PROMPT_AHEAD:-${PEDANTIC_GIT_SYMBOL_AHEAD}}"
ZSH_THEME_GIT_PROMPT_BEHIND="${ZSH_THEME_GIT_PROMPT_BEHIND:-${PEDANTIC_GIT_SYMBOL_BEHIND}}"
ZSH_THEME_GIT_PROMPT_DIVERGED="${ZSH_THEME_GIT_PROMPT_DIVERGED:-${PEDANTIC_GIT_SYMBOL_DIVERGED}}"


function __pedantic_new_line () {
    echo ''
}

function __pedantic_decorate() {
    if [[ $2 == 'reset' ]]; then
        echo -n "%{$reset_color%}"
    else
        echo -n "%{$fg[$2]%}"
    fi

    if [[ $3 = true ]]; then
        echo -n "%{$terminfo[bold]%}"
    fi

    echo -n ${1}
    echo -n "%{$reset_color%}"
}


function __pedantic_user() {
    echo -n 'as'
    echo -n ' '
    if [[ $USER == 'root' ]];  then
        __pedantic_decorate '%n' "${PEDANTIC_ROOT_USER_COLOUR}" "${PEDANTIC_ROOT_USER_BOLD}"
    else
        __pedantic_decorate '%n' "${PEDANTIC_USER_COLOUR}" "${PEDANTIC_USER_BOLD}"
    fi
}

function __pedantic_host_name () {
    echo -n 'on'
    echo -n ' '
    __pedantic_decorate '%m' "${PEDANTIC_HOSTNAME_COLOUR}" "${PEDANTIC_HOSTNAME_BOLD}"
}

function __pedantic_current_dir() {
    echo -n 'in'
    echo -n ' '
    __pedantic_decorate '%~' "${PEDANTIC_CURRENT_DIR_COLOUR}" "${PEDANTIC_CURRENT_DIR_BOLD}"
}

function __pedantic_git_status () {
    PEDANTIC_GIT_CURRENT_BRANCH=`git_current_branch | xargs echo -n`
    PEDANTIC_GIT_PROMPT_STATUS=`git_prompt_status | sed -E 's/!+/!/g' | xargs echo -n`
    if [[ ! -z "${PEDANTIC_GIT_CURRENT_BRANCH}" ]]; then
        echo -n 'at'
        echo -n ' '
        __pedantic_decorate "${PEDANTIC_GIT_CURRENT_BRANCH}" "${PEDANTIC_GIT_COLOUR}" "${PEDANTIC_GIT_BOLD}"
        if [[ ! -z "${PEDANTIC_GIT_PROMPT_STATUS}" ]]; then
            __pedantic_decorate "(${PEDANTIC_GIT_PROMPT_STATUS})" "${PEDANTIC_GIT_COLOUR}" "${PEDANTIC_GIT_BOLD}"
        fi
    fi
}

function __pedantic_timestamp() {
    __pedantic_decorate "%D{${PEDANTIC_TIMESTAMP_FORMAT}}" "${PEDANTIC_TIMESTAMP_COLOUR}" "${PEDANTIC_TIMESTAMP_BOLD}"
}

function __pedantic_prompt () {
    echo -n "%(?.%{$reset_color%}.%{$fg[red]%})"
    echo -n "${PEDANTIC_PROMPT}"
    echo -n "%{$reset_color%}"
    echo -n ' '
}

function __pedantic_python_environment () {

   if [[ -n $VIRTUAL_ENV ]]; then
       PYTHON_ENVIRONMENT=$VIRTUAL_ENV
   elif [[ -n $CONDA_DEFAULT_ENV ]]; then
       PYTHON_ENVIRONMENT=$CONDA_DEFAULT_ENV
   fi
   if [[ -n $PYTHON_ENVIRONMENT ]]; then
       echo -n "with"
       echo -n " "
       __pedantic_decorate `basename ${PYTHON_ENVIRONMENT}` "${PEDANTIC_PYTHON_ENVIRONMENT_COLOUR}" "${PEDANTIC_PYTHON_ENVIRONMENT_BOLD}"
       echo -n ' '

   fi
}

function __pedantic_build_theme () {
    if [[ ${PEDANTIC_SHOW_BLANK_LINE} = true ]]; then
        __pedantic_new_line
    fi
    if [[ ${PEDANTIC_SHOW_TIMESTAMP} = true ]]; then
        __pedantic_timestamp
        echo -n ' '
    fi
        if [[ ${PEDANTIC_SHOW_PYTHON_ENVIRONMENT} = true ]]; then
        __pedantic_python_environment
    fi
    if [[ ${PEDANTIC_SHOW_USER} = true ]]; then
        __pedantic_user
        echo -n ' '
    fi
    if [[ ${PEDANTIC_SHOW_HOSTNAME} = true ]]; then
        __pedantic_host_name
        echo -n ' '
    fi
    if [[ ${PEDANTIC_SHOW_CURRENT_DIR} = true ]]; then
        __pedantic_current_dir
        echo -n ' '
    fi
    if [[ ${PEDANTIC_SHOW_GIT} = true ]]; then
        __pedantic_git_status
    fi
    __pedantic_new_line
    __pedantic_prompt
}

PROMPT=$(__pedantic_build_theme)
