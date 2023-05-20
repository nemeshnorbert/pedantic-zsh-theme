#  Configuration
#
#  Set these variables in your .zshrc file
#  before including this theme file, e.g.:
#
#      PEDANTIC_SHOW_HOSTNAME=false
#      PEDANTIC_CURRENT_DIR_COLOUR=yellow

PEDANTIC_SHOW_BLANK_LINE="${PEDANTIC_SHOW_BLANK_LINE:-false}"
PEDANTIC_SHOW_TIMESTAMP="${PEDANTIC_SHOW_TIMESTAMP:-true}"
PEDANTIC_SHOW_ELAPSED_TIME="${PEDANTIC_SHOW_ELAPSED_TIME:-true}"
PEDANTIC_SHOW_USER="${PEDANTIC_SHOW_USER:-true}"
PEDANTIC_SHOW_HOSTNAME="${PEDANTIC_SHOW_HOSTNAME:-true}"
PEDANTIC_SHOW_CURRENT_DIR="${PEDANTIC_SHOW_CURRENT_DIR:-true}"
PEDANTIC_SHOW_GIT="${PEDANTIC_SHOW_GIT:-true}"
PEDANTIC_SHOW_PYTHON_ENVIRONMENT="${PEDANTIC_SHOW_PYTHON_ENVIRONMENT:-false}"

PEDANTIC_TIMESTAMP_COLOUR="${PEDANTIC_TIMESTAMP_COLOUR:-reset}"
PEDANTIC_ELAPSED_TIME_COLOUR="${PEDANTIC_ELAPSED_TIME_COLOUR:-cyan}"
PEDANTIC_USER_COLOUR="${PEDANTIC_USER_COLOUR:-blue}"
PEDANTIC_ROOT_USER_COLOUR="${PEDANTIC_ROOT_USER_COLOUR:-red}"
PEDANTIC_HOSTNAME_COLOUR="${PEDANTIC_HOSTNAME_COLOUR:-green}"
PEDANTIC_CURRENT_DIR_COLOUR="${PEDANTIC_CURRENT_DIR_COLOUR:-cyan}"
PEDANTIC_GIT_COLOUR="${PEDANTIC_GIT_COLOUR:-magenta}"
PEDANTIC_PYTHON_ENVIRONMENT_COLOUR="${PEDANTIC_PYTHON_ENVIRONMENT_COLOUR:-yellow}"

PEDANTIC_TIMESTAMP_BOLD="${PEDANTIC_TIMESTAMP_BOLD:-false}"
PEDANTIC_ELAPSED_TIME_BOLD="${PEDANTIC_ELAPSED_TIME_BOLD:-false}"
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

# Elapsed time calc

zmodload zsh/datetime

prompt_preexec() {
  prompt_prexec_realtime=${EPOCHREALTIME}
}

prompt_precmd() {
    if (( prompt_prexec_realtime )); then
        local -rF elapsed_realtime=$(( EPOCHREALTIME - prompt_prexec_realtime ))
        local -rF s=$(( elapsed_realtime%60 ))
        local -ri elapsed_s=${elapsed_realtime}
        local -ri m=$(( (elapsed_s/60)%60 ))
        local -ri h=$(( elapsed_s/3600 ))
        if (( h > 0 )); then
            printf -v prompt_elapsed_time '%ih%im' ${h} ${m}
        elif (( m > 0 )); then
            printf -v prompt_elapsed_time '%im%is' ${m} ${s}
        elif (( s >= 10 )); then
            printf -v prompt_elapsed_time '%.2fs' ${s} # 12.34s
        elif (( s >= 1 )); then
            printf -v prompt_elapsed_time '%.3fs' ${s} # 1.234s
        else
            printf -v prompt_elapsed_time '%ims' $(( s*1000 ))
        fi
        unset prompt_prexec_realtime
    else
        # Clear previous result when hitting ENTER with no command to execute
        unset prompt_elapsed_time
    fi
}

setopt nopromptbang prompt{cr,percent,sp,subst}

autoload -Uz add-zsh-hook
add-zsh-hook preexec prompt_preexec
add-zsh-hook precmd prompt_precmd

# Prompt design

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
    echo -n 'as '
    if [[ $USER == 'root' ]];  then
        __pedantic_decorate '%n' "${PEDANTIC_ROOT_USER_COLOUR}" "${PEDANTIC_ROOT_USER_BOLD}"
    else
        __pedantic_decorate '%n' "${PEDANTIC_USER_COLOUR}" "${PEDANTIC_USER_BOLD}"
    fi
    echo -n ' '
}

function __pedantic_host_name () {
    echo -n 'on '
    __pedantic_decorate '%m' "${PEDANTIC_HOSTNAME_COLOUR}" "${PEDANTIC_HOSTNAME_BOLD}"
    echo -n ' '
}

function __pedantic_current_dir() {
    echo -n 'in '
    __pedantic_decorate '%~' "${PEDANTIC_CURRENT_DIR_COLOUR}" "${PEDANTIC_CURRENT_DIR_BOLD}"
    echo -n ' '
}

function __pedantic_git_status () {
    PEDANTIC_GIT_CURRENT_BRANCH=`git_current_branch | xargs echo -n`
    PEDANTIC_GIT_PROMPT_STATUS=`git_prompt_status | sed -E 's/!+/!/g' | xargs echo -n`
    if [[ ! -z "${PEDANTIC_GIT_CURRENT_BRANCH}" ]]; then
        echo -n 'at '
        __pedantic_decorate "${PEDANTIC_GIT_CURRENT_BRANCH}" "${PEDANTIC_GIT_COLOUR}" "${PEDANTIC_GIT_BOLD}"
        if [[ ! -z "${PEDANTIC_GIT_PROMPT_STATUS}" ]]; then
            __pedantic_decorate "(${PEDANTIC_GIT_PROMPT_STATUS})" "${PEDANTIC_GIT_COLOUR}" "${PEDANTIC_GIT_BOLD}"
        fi
        echo -n ' '
    fi
}

function __pedantic_prompt () {
    echo -n "%(?.%{$reset_color%}.%{$fg[red]%})${PEDANTIC_PROMPT}%{$reset_color%} "
}

function __pedantic_python_environment () {
   if [[ -n $VIRTUAL_ENV ]]; then
       PYTHON_ENVIRONMENT=$VIRTUAL_ENV
   elif [[ -n $CONDA_DEFAULT_ENV ]]; then
       PYTHON_ENVIRONMENT=$CONDA_DEFAULT_ENV
   fi
   if [[ -n $PYTHON_ENVIRONMENT ]]; then
       echo -n 'with '
       __pedantic_decorate `basename ${PYTHON_ENVIRONMENT}` "${PEDANTIC_PYTHON_ENVIRONMENT_COLOUR}" "${PEDANTIC_PYTHON_ENVIRONMENT_BOLD}"
       echo -n ' '
   fi
}

function __pedantic_timestamp() {
    echo -n 'at '
    __pedantic_decorate "%D{${PEDANTIC_TIMESTAMP_FORMAT}}" "${PEDANTIC_TIMESTAMP_COLOUR}" "${PEDANTIC_TIMESTAMP_BOLD}"
    echo -n ' '
}

function __pedantic_elapsed_time() {
    echo -n 'took '
    __pedantic_decorate "${prompt_elapsed_time:-0s}" "${PEDANTIC_ELAPSED_TIME_COLOUR}" "${PEDANTIC_ELAPSED_TIME_BOLD}"
    echo -n ' '
}

function __pedantic_build_prompt() {
    local command_status=$1
    if [[ ${PEDANTIC_SHOW_BLANK_LINE} = true ]]; then
        __pedantic_new_line
    fi
    if [[ ${PEDANTIC_SHOW_USER} = true ]]; then
        __pedantic_user
    fi
    if [[ ${PEDANTIC_SHOW_HOSTNAME} = true ]]; then
        __pedantic_host_name
    fi
    if [[ ${PEDANTIC_SHOW_CURRENT_DIR} = true ]]; then
        __pedantic_current_dir
    fi
    if [[ ${PEDANTIC_SHOW_GIT} = true ]]; then
        __pedantic_git_status
    fi
    if [[ ${PEDANTIC_SHOW_PYTHON_ENVIRONMENT} = true ]]; then
        __pedantic_python_environment
    fi
    if [[ ${PEDANTIC_SHOW_ELAPSED_TIME} = true ]]; then
        __pedantic_elapsed_time
    fi
    if [[ ${PEDANTIC_SHOW_TIMESTAMP} = true ]]; then
        __pedantic_timestamp
    fi
    __pedantic_new_line
    __pedantic_prompt
}

function __pedantic_build_right_prompt() {
}

PROMPT='$(__pedantic_build_prompt)'
RPROMPT='$(__pedantic_build_right_prompt)'
