# Add the bin directory in user home to path
export PATH="$HOME/bin:$PATH"

# Aliases
alias ll='ls -alF'
alias a='git add .'
alias s='git status'
alias p='git push'
alias b='git branch'

# Functions
help() {
    echo
    echo "Utilities functions"
    echo "  help: Display this help message"
    echo "  hello: Display the welcome message"
    echo "  week: Week of the year"
    echo "  title: Set the title of the terminal"
    echo "  genpwd: Generate a password"
    echo "  quote: Display a random quote (if have quote file)"
    echo "  psv: Display the PowerShell version"
    echo
    echo "Functions of use when developing this profile (run in dir with profile file)"
    echo "  pub: Copy the profile to the current profile"
    echo "  propath: Display the profile path"
    echo "  propaths: Display the profile paths"
    echo
    echo "Directory and file functions:"
    echo "  csln: Clean the dotnet solution"
    echo "  mcd: Create a directory and change to it"
    echo "  killdir: Remove a directory recursively using force"
    echo "  dirastitle: Set the title of the terminal to the current directory"
    echo "  go: Change to a directory and set the title of the terminal to the directory name"
    echo "  dllfullname: Get the full name of a DLL file"
    echo "  crf: Create a file if it does not exist"
    echo "  c: Clear the terminal"
    echo
    echo "Git functions for every hour git work"
    echo "  clonecd: Clone a git repository and change working directory to it"
    echo "  a: 'git add .'"
    echo "  s: 'git status'"
    echo "  co: 'git commit -m args[0]' (if no message given message will be 'wip')"
    echo "  p: 'git push'"
    echo "  b: 'git branch'"
    echo "  gurl: shows the git remote urls"
    echo
    echo "Prompt functions:"
    echo "  short: Toggle if the prompt to display the current directory only or complete path"
    echo "  bshort: Set the prompt to display the current branch name truncated"
    echo "  time: Toggle if displaying the time in the prompt"
    echo "  btrunc: Truncate the branch name to the given length"
    echo "  branch: Toggle displaying the branch in the prompt"
    echo "  remote: Toggle if to indicate with * branch not remote (it is a bit sluggish, default is on)"
    echo "  naken: Only > prompt"
    echo "  default: Set the prompt to display the time and branch"
    echo "  pc: Set the number of path components to display in the prompt when short_prompt is true"
    echo "  bdots: Toggle if to display ... after the truncated branch name in the prompt when short_bprompt is true"
    echo "  unix: Toggle if to use / as path separator in the prompt"
    echo
    echo "Tips:"
    echo "  The prompt can be customized using the prompt functions"
    echo "  The ^ symbol (after branch name in the prompt) indicates that the branch is ahead of the remote branch"
    echo "  explorer . : If on windows open the current directory in the file explorer"
    echo
}

csln() {
    find . -type d -name "obj" -exec rm -rf {} +
    find . -type d -name "bin" -exec rm -rf {} +
}

mcd() {
    if [ -z "$1" ]; then
        echo "No arguments provided."
    else
        mkdir -p "$1" && cd "$1"
    fi
}

killdir() {
    if [ -z "$1" ]; then
        echo "No arguments provided."
    else
        rm -rf "$1"
    fi
}

go() {
    if [ -z "$1" ]; then
        echo "No arguments provided."
    else
        cd "$1" && dtitle
    fi
}

dtitle() {
    local dir=$(basename "$PWD")
    echo -ne "\033]0;$dir\007"
}

crf() {
    if [ ! -f "$1" ]; then
        touch "$1"
    fi
}

clonecd() {
    if [ -z "$1" ]; then
        echo "No arguments provided."
    else
        git clone "$1"
        local dir=$(basename "$1" .git)
        cd "$dir" && dtitle
    fi
}

co() {
    local cm="wip"
    if [ -n "$1" ]; then
        cm="$1"
    fi
    git commit -m "$cm"
}

gurl() {
    git remote -v
}

pub() {
    cp ./bash_profile.sh ~/.bashrc
}

propath() {
    echo "$HOME/.bashrc"
}

propaths() {
    echo "$HOME/.bashrc"
}

week() {
    date +%V
}

title() {
    if [ -z "$1" ]; then
        echo "No arguments provided."
    else
        echo -ne "\033]0;$1\007"
    fi
}

genpwd() {
    local length=16
    local chars="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
    local password=$(cat /dev/urandom | tr -dc "$chars" | fold -w $length | head -n 1)
    echo "$password"
}

psv() {
    echo "Bash version ${BASH_VERSION}"
}

quote() {
    local quotesFile="$HOME/quotes.txt"
    if [ -f "$quotesFile" ]; then
        shuf -n 1 "$quotesFile"
    fi
}

hello() {
    clear
    quote
    _promptheader
}

c() {
    clear
    _promptheader
}

_promptheader() {
    local date=$(date +%d.%m.%y)
    local week=$(week)
    local wday=$(date +%A)
    local user=$(whoami)
    echo "[$date][$week][$wday] ($user)"
}

# Prompt customizations
prompt_time=true
prompt_branch=true
prompt_wd=true
short_prompt=false
short_bprompt=false
prompt_remote=true
prompt_btruncate=10
prompt_bdots=true
prompt_path_component_count=3
unix_path_separator=true

_prompt_path() {
    if [ "$short_prompt" = "false" ]; then
        echo "$PWD"
        return
    fi

    local dir="$PWD"
    IFS='/' read -r -a path <<< "$dir"
    local count=${#path[@]}
    if [ $count -le $prompt_path_component_count ]; then
        echo "$dir"
        return
    fi

    local start=$((count - prompt_path_component_count))
    echo "${path[@]:$start}"
}

unix() {
    if [ "$unix_path_separator" = "false" ]; then
        unix_path_separator=true
    else
        unix_path_separator=false
    fi
}

pc() {
    if [ "$1" -lt 1 ]; then
        echo "Count must be greater than 0."
        return
    fi

    prompt_path_component_count="$1"
    short_prompt=true
}

short() {
    if [ "$short_prompt" = "false" ]; then
        short_prompt=true
    else
        short_prompt=false
    fi
}

bshort() {
    if [ "$short_bprompt" = "false" ]; then
        short_bprompt=true
    else
        short_bprompt=false
    fi
}

btrunc() {
    if [ "$1" -lt 1 ]; then
        echo "Length must be greater than 0."
        return
    fi
    prompt_btruncate="$1"
    prompt_branch=true
    short_bprompt=true
}

use_time() {
    if [ "$prompt_time" = "false" ]; then
        prompt_time=true
    else
        prompt_time=false
    fi
}

branch() {
    if [ "$prompt_branch" = "false" ]; then
        prompt_branch=true
    else
        prompt_branch=false
    fi
}

bdots() {
    if [ "$prompt_bdots" = "false" ]; then
        prompt_bdots=true
    else
        prompt_bdots=false
    fi
}

remote() {
    if [ "$prompt_remote" = "false" ]; then
        prompt_remote=true
    else
        prompt_remote=false
    fi
}

default() {
    prompt_time=true
    prompt_branch=true
    prompt_wd=true
    short_prompt=false
    short_bprompt=false
    prompt_remote=true
}

naken() {
    prompt_time=false
    prompt_branch=false
    prompt_wd=false
}

_branch() {
    local branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
    if [ -n "$branch" ]; then
        local ahead=$(git status -sb 2> /dev/null | grep -q "ahead" && echo "^" || echo "")
        local remote=""
        if [ "$prompt_remote" = "true" ]; then
            remote=$(git ls-remote --heads origin "$branch" 2> /dev/null)
            if [ -z "$remote" ]; then
                remote="*"
            fi
        fi

        if [ "$short_bprompt" = "true" ]; then
            if [ ${#branch} -gt $prompt_btruncate ]; then
                branch="${branch:0:$prompt_btruncate}"
                [ "$prompt_bdots" = "true" ] && branch="$branch..."
            fi
        fi
        echo "${branch}${ahead}${remote}"
    fi
}

PROMPT_COMMAND=_prompt

_prompt() {
    local prompt=""
    [ "$prompt_time" = "true" ] && prompt+="[$(date +%T)]"
    if [ "$prompt_branch" = "true" ]; then
        local branch=$(_branch)
        [ -n "$branch" ] && prompt+="{${branch}}"
    fi
    [ "$prompt_wd" = "true" ] && prompt+="[$(_prompt_path)]"
    prompt+="> "
    PS1="$prompt"
}

# PROMPT_COMMAND=_prompt


# _prompt() {
#     local prompt=""
#     [ "$prompt_time" = "true" ] && prompt+="[$(date +%T)]"
#     if [ "$prompt_branch" = "true" ]; then
#         local branch=$(_branch)
#         [ -n "$branch" ] && prompt+="{${branch}}"
#     fi
#     [ "$prompt_wd" = "true" ] && prompt+="[$(_prompt_path)]"
#     prompt+=">"
#     PS1="$prompt "
# }

hello  # Display the welcome message on session start
