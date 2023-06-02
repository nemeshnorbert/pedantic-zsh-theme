#  Configuration
#
#  Set these variables in your .zshrc file
#  before including this theme file, e.g.:
#
#      PEDANTIC_SHOW_HOSTNAME=false
#      PEDANTIC_CURRENT_DIR_COLOUR=yellow

PEDANTIC_SHOW_BLANK_LINE="${PEDANTIC_SHOW_BLANK_LINE:-true}"
PEDANTIC_SHOW_TIMESTAMP="${PEDANTIC_SHOW_TIMESTAMP:-true}"
PEDANTIC_SHOW_ELAPSED_TIME="${PEDANTIC_SHOW_ELAPSED_TIME:-true}"
PEDANTIC_SHOW_USER="${PEDANTIC_SHOW_USER:-true}"
PEDANTIC_SHOW_HOSTNAME="${PEDANTIC_SHOW_HOSTNAME:-true}"
PEDANTIC_SHOW_CURRENT_DIR="${PEDANTIC_SHOW_CURRENT_DIR:-true}"
PEDANTIC_SHOW_GIT="${PEDANTIC_SHOW_GIT:-true}"
PEDANTIC_SHOW_PYTHON_ENVIRONMENT="${PEDANTIC_SHOW_PYTHON_ENVIRONMENT:-true}"

PEDANTIC_TIMESTAMP_COLOUR="${PEDANTIC_TIMESTAMP_COLOUR:-magenta}"
PEDANTIC_ELAPSED_TIME_COLOUR="${PEDANTIC_ELAPSED_TIME_COLOUR:-magenta}"
PEDANTIC_USER_COLOUR="${PEDANTIC_USER_COLOUR:-blue}"
PEDANTIC_ROOT_USER_COLOUR="${PEDANTIC_ROOT_USER_COLOUR:-red}"
PEDANTIC_HOSTNAME_COLOUR="${PEDANTIC_HOSTNAME_COLOUR:-green}"
PEDANTIC_CURRENT_DIR_COLOUR="${PEDANTIC_CURRENT_DIR_COLOUR:-cyan}"
PEDANTIC_PYTHON_ENVIRONMENT_COLOUR="${PEDANTIC_PYTHON_ENVIRONMENT_COLOUR:-yellow}"

PEDANTIC_TIMESTAMP_BOLD="${PEDANTIC_TIMESTAMP_BOLD:-true}"
PEDANTIC_ELAPSED_TIME_BOLD="${PEDANTIC_ELAPSED_TIME_BOLD:-false}"
PEDANTIC_USER_BOLD="${PEDANTIC_USER_BOLD:-true}"
PEDANTIC_ROOT_USER_BOLD="${PEDANTIC_ROOT_USER_BOLD:-true}"
PEDANTIC_HOSTNAME_BOLD="${PEDANTIC_HOSTNAME_BOLD:-true}"
PEDANTIC_CURRENT_DIR_BOLD="${PEDANTIC_CURRENT_DIR_BOLD:-true}"
PEDANTIC_PYTHON_ENVIRONMENT_BOLD="${PEDANTIC_PYTHON_ENVIRONMENT_BOLD:-true}"

PEDANTIC_TIMESTAMP_FORMAT="${PEDANTIC_TIMESTAMP_FORMAT:-%H:%M:%S}" # see man strftime

PEDANTIC_PROMPT="${PEDANTIC_PROMPT:-$}"

PEDANTIC_GIT_DISPLAY_BRANCH_BEHIND_AND_AHEAD="${PEDANTIC_GIT_DISPLAY_BRANCH_BEHIND_AND_AHEAD:-true}"
PEDANTIC_GIT_ENABLE_FILE_STATUS="${PEDANTIC_GIT_ENABLE_FILE_STATUS:-true}"
PEDANTIC_GIT_SHOW_STATUS_WHEN_ZERO="${PEDANTIC_GIT_SHOW_STATUS_WHEN_ZERO:-false}"
PEDANTIC_GIT_ENABLE_STASH_STATUS="${PEDANTIC_GIT_ENABLE_STASH_STATUS:-true}"
PEDANTIC_GIT_ENABLE_STATUS_SYMBOL="${PEDANTIC_GIT_ENABLE_STATUS_SYMBOL:-true}"
PEDANTIC_GIT_DESCRIBE_STYLE="${PEDANTIC_GIT_DESCRIBE_STYLE:-}"
PEDANTIC_GIT_SHOW_UPSTREAM="${PEDANTIC_GIT_SHOW_UPSTREAM:-true}"


# Elapsed time calc

__pedantic_preexec() {
    prompt_prexec_realtime=${EPOCHREALTIME}
}

__pedantic_precmd() {
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

# Git status
#
function __pedantic_has_git() {
    local where_git=$(command -v git)
    if [[ -z "${where_git}" ]]; then
        echo "false"
    else
        echo "true"
    fi
}

function __pedantic_get_git_dir() {
    local repo_dir=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ ! -z "${repo_dir}" ]]; then
        echo "${repo_dir}/.git"
    fi
}

function __pedantic_get_git_status() {
    local git_repo=$1

    local red='\033[0;31m'
    local green='\033[0;32m'
    local bright_red='\033[0;91m'
    local bright_green='\033[0;92m'
    local bright_yellow='\033[0;93m'
    local bright_cyan='\033[0;96m'

    local default_foreground_color='\e[m' # Default no color
    local default_background_color=''

    local before_text='[ '
    local before_foreground_color="${bright_yellow}" # Yellow
    local before_background_color=''
    local delim_text=' |'
    local delim_foreground_color="${bright_yellow}" # Yellow
    local delim_background_color=''

    local after_text=' ]'
    local after_foreground_color="${bright_yellow}" # Yellow
    local after_background_color=''

    local branch_foreground_color="${bright_cyan}"  # Cyan
    local branch_background_color=''
    local branch_ahead_foreground_color="${bright_green}" # green
    local branch_ahead_background_color=''
    local branch_behind_foreground_color="${bright_red}" # red
    local branch_behind_background_color=''
    local branch_behind_and_ahead_foreground_color="${bright_yellow}" # Yellow
    local branch_behind_and_ahead_background_color=''

    local index_foreground_color="${green}" # Dark green
    local index_background_color=''

    local working_foreground_color="${red}" # Dark red
    local working_background_color=''

    local stash_foreground_color="${bright_red}" # red
    local stash_background_color=''
    local before_stash='('
    local after_stash=')'

    local local_default_status_symbol=''
    local local_working_status_symbol=' !'
    local local_working_status_color="${red}"
    local local_staged_status_symbol=' ~'
    local local_staged_status_color="${bright_cyan}"

    local rebase_foreground_color='\e[0m' # reset
    local rebase_background_color=''

    local branch_behind_and_ahead_display=''
    if [[ ${PEDANTIC_GIT_DISPLAY_BRANCH_BEHIND_AND_AHEAD} = true ]]; then
        branch_behind_and_ahead_display="full"
    else
        branch_behind_and_ahead_display="compact"
    fi

    local enable_file_status="${PEDANTIC_GIT_ENABLE_FILE_STATUS}"
    local show_status_when_zero="${PEDANTIC_GIT_SHOW_STATUS_WHEN_ZERO}"
    local enable_stash_status="${PEDANTIC_GIT_ENABLE_STASH_STATUS}"
    local enable_status_symbol="${PEDANTIC_GIT_ENABLE_STATUS_SYMBOL}"

    local branch_identical_status_symbol=''
    local branch_ahead_status_symbol=''
    local branch_behind_status_symbol=''
    local branch_behind_and_ahead_status_symbol=''
    local branch_warning_status_symbol=''
    if ${enable_status_symbol}; then
      branch_identical_status_symbol=$' \xE2\x89\xA1' # Three horizontal lines
      branch_ahead_status_symbol=$' \xE2\x86\x91' # Up Arrow
      branch_behind_status_symbol=$' \xE2\x86\x93' # Down Arrow
      branch_behind_and_ahead_status_symbol=$'\xE2\x86\x95' # Up and Down Arrow
      branch_warning_status_symbol=' ?'
    fi

    local rebase=''
    local b=''
    local step=''
    local total=''
    if [ -d "${git_repo}/rebase-merge" ]; then
        b=$(cat "${git_repo}/rebase-merge/head-name" 2>/dev/null)
        step=$(cat "${git_repo}/rebase-merge/msgnum" 2>/dev/null)
        total=$(cat "${git_repo}/rebase-merge/end" 2>/dev/null)
        if [ -f "${git_repo}/rebase-merge/interactive" ]; then
            rebase='|REBASE-i'
        else
            rebase='|REBASE-m'
        fi
    else
        if [ -d "${git_repo}/rebase-apply" ]; then
            step=$(cat "${git_repo}/rebase-apply/next")
            total=$(cat "${git_repo}/rebase-apply/last")
            if [ -f "${git_repo}/rebase-apply/rebasing" ]; then
                rebase='|REBASE'
            elif [ -f "${git_repo}/rebase-apply/applying" ]; then
                rebase='|AM'
            else
                rebase='|AM/REBASE'
            fi
        elif [ -f "${git_repo}/MERGE_HEAD" ]; then
            rebase='|MERGING'
        elif [ -f "${git_repo}/CHERRY_PICK_HEAD" ]; then
            rebase='|CHERRY-PICKING'
        elif [ -f "${git_repo}/REVERT_HEAD" ]; then
            rebase='|REVERTING'
        elif [ -f "${git_repo}/BISECT_LOG" ]; then
            rebase='|BISECTING'
        fi

        b=$(git symbolic-ref HEAD 2>/dev/null) || {
            local output
            output="${PEDANTIC_GIT_DESCRIBE_STYLE}"
            if [ -n "${output}" ]; then
                GIT_PS1_DESCRIBESTYLE=${output}
            fi
            b=$(
            case "${GIT_PS1_DESCRIBESTYLE-}" in
            contains )
                git describe --contains HEAD ;;
            branch )
                git describe --contains --all HEAD ;;
            describe )
                git describe HEAD ;;
            default )
                git describe --tags --exact-match HEAD ;;
            * )
                git describe --tags --exact-match HEAD ;;
            esac 2>/dev/null) ||

            b=$(cut -c1-7 "${git_repo}/HEAD" 2>/dev/null)... ||
            b='unknown'
            b="(${b})"
        }
    fi

    if [ -n "${step}" ] && [ -n "${total}" ]; then
        rebase="${rebase} ${step}/${total}"
    fi

    local has_stash=false
    local stash_count=0
    local is_bare=''

    if [ 'true' = "$(git rev-parse --is-inside-git-dir 2>/dev/null)" ]; then
        if [ 'true' = "$(git rev-parse --is-bare-repository 2>/dev/null)" ]; then
            is_bare='BARE:'
        else
            b='GIT_DIR!'
        fi
    elif [ 'true' = "$(git rev-parse --is-inside-work-tree 2>/dev/null)" ]; then
        if ${enable_stash_status}; then
            git rev-parse --verify refs/stash >/dev/null 2>&1 && has_stash=true
            if ${has_stash}; then
                stash_count=$(git stash list | wc -l | tr -d '[:space:]')
            fi
        fi
        local counters()
        IFS=" " read -r -a counters <<< "$(__pedantic_get_upstream_divergence)"
        local posh_branch_behind_by=$counters[1]
        local posh_branch_ahead_by=$counters[2]
        local divergence_return_code=$?
    fi

    # show index status and working directory status
    if ${enable_file_status}; then
        local index_added=0
        local index_modified=0
        local index_deleted=0
        local index_unmerged=0
        local files_added=0
        local filed_modified=0
        local files_deleted=0
        local files_unmerged=0
        while IFS=$'\n' read -r tag rest
        do
            case "${tag:0:1}" in
                A )
                    (( index_added++ ))
                    ;;
                M )
                    (( index_modified++ ))
                    ;;
                T )
                    (( index_modified++ ))
                    ;;
                R )
                    (( index_modified++ ))
                    ;;
                C )
                    (( index_modified++ ))
                    ;;
                D )
                    (( index_deleted++ ))
                    ;;
                U )
                    (( index_unmerged++ ))
                    ;;
            esac
            case "${tag:1:1}" in
                \? )
                    (( files_added++ ))
                    ;;
                A )
                    (( files_added++ ))
                    ;;
                M )
                    (( filed_modified++ ))
                    ;;
                T )
                    (( filed_modified++ ))
                    ;;
                D )
                    (( files_deleted++ ))
                    ;;
                U )
                    (( files_unmerged++ ))
                    ;;
            esac
        done <<< "$(git status --porcelain 2>/dev/null)"
    fi

    local branch_string="${is_bare}${b##refs/heads/}"

    # before-branch text
    local git_string="${before_background_color}${before_foreground_color}${before_text}"

    # branch
    if (( posh_branch_behind_by > 0 && posh_branch_ahead_by > 0 )); then
        git_string+="${branch_behind_and_ahead_background_color}${branch_behind_and_ahead_foreground_color}${branch_string}"
        if [ "${branch_behind_and_ahead_display}" = "full" ]; then
            git_string+="${branch_behind_status_symbol}${posh_branch_behind_by}${branch_ahead_status_symbol}${posh_branch_ahead_by}"
        elif [ "${branch_behind_and_ahead_display}" = "compact" ]; then
            git_string+=" ${posh_branch_behind_by}${branch_behind_and_ahead_status_symbol}${posh_branch_ahead_by}"
        else
            git_string+=" ${branch_behind_and_ahead_status_symbol}"
        fi
    elif (( posh_branch_behind_by > 0 )); then
        git_string+="${branch_behind_background_color}${branch_behind_foreground_color}${branch_string}"
        if [ "${branch_behind_and_ahead_display}" = "full" ] || [ "${branch_behind_and_ahead_display}" = "compact" ]; then
            git_string+="${branch_behind_status_symbol}${posh_branch_behind_by}"
        else
            git_string+="${branch_behind_status_symbol}"
        fi
    elif (( posh_branch_ahead_by > 0 )); then
        git_string+="${branch_ahead_background_color}${branch_ahead_foreground_color}${branch_string}"
        if [ "${branch_behind_and_ahead_display}" = "full" ] || [ "${branch_behind_and_ahead_display}" = "compact" ]; then
            git_string+="${branch_ahead_status_symbol}${posh_branch_ahead_by}"
        else
            git_string+="${branch_ahead_status_symbol}"
        fi
    elif (( divergence_return_code )); then
        # ahead and behind are both 0, but there was some problem while executing the command.
        git_string+="${branch_background_color}${branch_foreground_color}${branch_string}${branch_warning_status_symbol}"
    else
        # ahead and behind are both 0, and the divergence was determined successfully
        git_string+="${branch_background_color}${branch_foreground_color}${branch_string}${branch_identical_status_symbol}"
    fi

    git_string+="${rebase:+${rebase_foreground_color}${rebase_background_color}${rebase}}"

    # index status
    if ${enable_file_status}; then
        local index_count="$(( index_added + index_modified + index_deleted + index_unmerged ))"
        local working_count="$(( files_added + filed_modified + files_deleted + files_unmerged ))"

        if (( index_count != 0 )) || ${show_status_when_zero}; then
            git_string+="${index_background_color}${index_foreground_color} +${index_added} ~${index_modified} -${index_deleted}"
        fi
        if (( index_unmerged != 0 )); then
            git_string+=" ${index_background_color}${index_foreground_color}!${index_unmerged}"
        fi
        if (( index_count != 0 && (working_count != 0 || show_status_when_zero) )); then
            git_string+="${delim_background_color}${delim_foreground_color}${delim_text}"
        fi
        if (( working_count != 0 )) || ${show_status_when_zero}; then
            git_string+="${working_background_color}${working_foreground_color} +${files_added} ~${filed_modified} -${files_deleted}"
        fi
        if (( files_unmerged != 0 )); then
            git_string+=" ${working_background_color}${working_foreground_color}!${files_unmerged}"
        fi

        local local_status_symbol=${local_default_status_symbol}
        local local_status_color=${default_foreground_color}

        if (( working_count != 0 )); then
            local_status_symbol=${local_working_status_symbol}
            local_status_color=${local_working_status_color}
        elif (( index_count != 0 )); then
            local_status_symbol=${local_staged_status_symbol}
            local_status_color=${local_staged_status_color}
        fi

        git_string+="${default_background_color}${local_status_color}${local_status_symbol}${default_foreground_color}"

        if ${enable_stash_status} && ${has_stash}; then
            git_string+="${default_background_color}${default_foreground_color} ${stash_background_color}${stash_foreground_color}${before_stash}${stash_count}${after_stash}"
        fi
    fi

    # after-branch text
    git_string+="${after_background_color}${after_foreground_color}${after_text}${default_background_color}${default_foreground_color}"
    echo -n "${git_string}"
}

function __pedantic_get_upstream_divergence () {
    if [[ ${PEDANTIC_GIT_SHOW_UPSTREAM} = false ]]; then
        return
    fi

    posh_branch_ahead_by=0
    posh_branch_behind_by=0
    local upstream='@{upstream}'
    local output=$(git rev-list --left-right @{upstream}...HEAD 2>/dev/null)
    local return_code=$?
    # produce equivalent output to --count for older versions of git
    while IFS=$' \t\n' read -r commit; do
        case "${commit}" in
        "<*") (( posh_branch_behind_by++ )) ;;
        ">*") (( posh_branch_ahead_by++ ))  ;;
        esac
    done <<< "${output}"
    echo "${posh_branch_behind_by}" "${posh_branch_ahead_by}"
    return ${return_code}
}

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
    if [[ $(__pedantic_has_git) = true ]]; then
        local git_repo=$(__pedantic_get_git_dir)
        if [ -n "${git_repo}" ]; then
            local GIT_STATUS=$(__pedantic_get_git_status "${git_repo}")
            if [[ -n "${GIT_STATUS}" ]]; then
                echo -n 'at '
                echo -n "${GIT_STATUS}"
                echo -n ' '
            fi
        fi
    fi
}

function __pedantic_prompt () {
    echo -n "%(?.%{$reset_color%}.%{$fg[red]%})${PEDANTIC_PROMPT}%{$reset_color%} "
}

function __pedantic_python_environment () {
    if [[ -n $VIRTUAL_ENV ]]; then
        PEDANTIC_PYTHON_ENVIRONMENT=$VIRTUAL_ENV
    elif [[ -n $CONDA_DEFAULT_ENV ]]; then
        PEDANTIC_PYTHON_ENVIRONMENT=$CONDA_DEFAULT_ENV
    fi
    if [[ -n $PEDANTIC_PYTHON_ENVIRONMENT ]]; then
        echo -n 'with '
        __pedantic_decorate `basename ${PEDANTIC_PYTHON_ENVIRONMENT}` "${PEDANTIC_PYTHON_ENVIRONMENT_COLOUR}" "${PEDANTIC_PYTHON_ENVIRONMENT_BOLD}"
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

zmodload zsh/datetime

setopt nopromptbang prompt{cr,percent,sp,subst}

autoload -Uz add-zsh-hook
add-zsh-hook preexec __pedantic_preexec
add-zsh-hook precmd __pedantic_precmd

if [[ ${PEDANTIC_SHOW_PYTHON_ENVIRONMENT} = true ]]; then
    VIRTUAL_ENV_DISABLE_PROMPT=0
fi

PROMPT='$(__pedantic_build_prompt)'
RPROMPT='$(__pedantic_build_right_prompt)'
