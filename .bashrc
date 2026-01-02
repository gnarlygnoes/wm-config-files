# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
# source ~/.config/david-configs/bash/rc

### SHELL LUBRICANTS
# History control
shopt -s histappend
HISTCONTROL=ignoreboth
HISTSIZE=32768
HISTFILESIZE="${HISTSIZE}"

# Autocompletion
if [[ ! -v BASH_COMPLETION_VERSINFO && -f /usr/share/bash-completion/bash_completion ]]; then
  source /usr/share/bash-completion/bash_completion
fi

# Ensure command hashing is off for mise
set +h

# File system
if command -v eza &>/dev/null; then
  alias ls='eza -lh --group-directories-first --icons=auto'
  alias lsa='ls -a'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
fi

alias ff="fzf --preview 'bat --style=numbers --color=always {}'"

if command -v zoxide &>/dev/null; then
  alias cd="zd"
  zd() {
    if [ $# -eq 0 ]; then
      builtin cd ~ && return
    elif [ -d "$1" ]; then
      builtin cd "$1"
    else
      z "$@" && printf "\U000F17A9 " && pwd || echo "Error: Directory not found"
    fi
  }
fi

open() {
  xdg-open "$@" >/dev/null 2>&1 &
}

### ALIASES
# Directories
#alias ..='cd ..'
#alias ...='cd ../..'
#alias ....='cd ../../..'

# List things
alias ll='ls -Fls'
alias la='ls -Alh'
#alias h='history | grep '

# Tools
#alias d='docker'
#alias r='rails'
#n() { if [ "$#" -eq 0 ]; then nvim .; else nvim "$@"; fi; }

# Git
#alias g='git'
#alias gcm='git commit -m'
#alias gcam='git commit -a -m'
#alias gcad='git commit -a --amend'

# Gentoo
alias update='sudo emerge-webrsync && sudo emerge -avuDN --keep-going --autounmask @world'
alias world='sudo emerge -avuDN --keep-going --autounmask @world'

# Other thigns
alias vim='nvim'

# FUNCTIONS
# Compression
compress() { tar -czf "${1%/}.tar.gz" "${1%/}"; }
alias decompress="tar -xzf"

# Transcode a video to a good-balance 1080p that's great for sharing online
transcode-video-1080p() {
  ffmpeg -i $1 -vf scale=1920:1080 -c:v libx264 -preset fast -crf 23 -c:a copy ${1%.*}-1080p.mp4
}

# Transcode a video to a good-balance 4K that's great for sharing online
transcode-video-4K() {
  ffmpeg -i $1 -c:v libx265 -preset slow -crf 24 -c:a aac -b:a 192k ${1%.*}-optimized.mp4
}

# Transcode any image to JPG image that's great for shrinking wallpapers
img2jpg() {
  img="$1"
  shift

  magick "$img" $@ -quality 95 -strip ${img%.*}-optimized.jpg
}

# Transcode any image to JPG image that's great for sharing online without being too big
img2jpg-small() {
  img="$1"
  shift

  magick "$img" $@ -resize 1080x\> -quality 95 -strip ${img%.*}-optimized.jpg
}

# Transcode any image to compressed-but-lossless PNG
img2png() {
  img="$1"
  shift

  magick "$img" $@ -strip -define png:compression-filter=5 \
    -define png:compression-level=9 \
    -define png:compression-strategy=1 \
    -define png:exclude-chunk=all \
    "${img%.*}-optimized.png"
}

extract() {
  for archive in "$@"; do
    if [ -f "$archive" ]; then
      case $archive in
      *.tar.bz2) tar xvjf $archive ;;
      *.tar.gz) tar xvzf $archive ;;
      *.bz2) bunzip2 $archive ;;
      *.rar) rar x $archive ;;
      *.gz) gunzip $archive ;;
      *.tar) tar xvf $archive ;;
      *.tbz2) tar xvjf $archive ;;
      *.tgz) tar xvzf $archive ;;
      *.zip) unzip $archive ;;
      *.Z) uncompress $archive ;;
      *.7z) 7z x $archive ;;
      *) echo "don't know how to extract '$archive'..." ;;
      esac
    else
      echo "'$archive' is not a valid file!"
    fi
  done
}

ftext() {
  # -i case-insensitive
  # -I ignore binary files
  # -H causes filename to be printed
  # -r recursive search
  # -n causes line number to be printed
  # optional: -F treat search term as a literal, not a regular expression
  # optional: -l only print filenames and not the matching lines ex. grep -irl "$1" *
  grep -iIHrn --color=always "$1" . | less -r
}

# Copy and go to the directory
cpg() {
  if [ -d "$2" ]; then
    cp "$1" "$2" && cd "$2"
  else
    cp "$1" "$2"
  fi
}

# Move and go to the directory
mvg() {
  if [ -d "$2" ]; then
    mv "$1" "$2" && cd "$2"
  else
    mv "$1" "$2"
  fi
}

mkdirg() {
  mkdir -p "$1"
  cd "$1"
}

# Goes up a specified number of directories  (i.e. up 4)
up() {
  local d=""
  limit=$1
  for ((i = 1; i <= limit; i++)); do
    d=$d/..
  done
  d=$(echo $d | sed 's/^\///')
  if [ -z "$d" ]; then
    d=..
  fi
  cd $d
}

# Show the current distribution
distribution() {
  local dtype="unknown" # Default to unknown

  # Use /etc/os-release for modern distro identification
  if [ -r /etc/os-release ]; then
    source /etc/os-release
    case $ID in
    fedora | rhel | centos)
      dtype="redhat"
      ;;
    sles | opensuse*)
      dtype="suse"
      ;;
    ubuntu | debian)
      dtype="debian"
      ;;
    gentoo)
      dtype="gentoo"
      ;;
    arch | manjaro)
      dtype="arch"
      ;;
    slackware)
      dtype="slackware"
      ;;
    *)
      # Check ID_LIKE only if dtype is still unknown
      if [ -n "$ID_LIKE" ]; then
        case $ID_LIKE in
        *fedora* | *rhel* | *centos*)
          dtype="redhat"
          ;;
        *sles* | *opensuse*)
          dtype="suse"
          ;;
        *ubuntu* | *debian*)
          dtype="debian"
          ;;
        *gentoo*)
          dtype="gentoo"
          ;;
        *arch*)
          dtype="arch"
          ;;
        *slackware*)
          dtype="slackware"
          ;;
        esac
      fi

      # If ID or ID_LIKE is not recognized, keep dtype as unknown
      ;;
    esac
  fi

  echo $dtype
}

# IP address lookup
alias whatismyip="whatsmyip"
function whatsmyip() {
  # Internal IP Lookup.
  if command -v ip &>/dev/null; then
    echo -n "Internal IP: "
    ip addr show wlan0 | grep "inet " | awk '{print $2}' | cut -d/ -f1
  else
    echo -n "Internal IP: "
    ifconfig wlan0 | grep "inet " | awk '{print $2}'
  fi

  # External IP Lookup
  echo -n "External IP: "
  curl -4 ifconfig.me
}

### INIT
if command -v mise &>/dev/null; then
  eval "$(mise activate bash)"
fi

if command -v starship &>/dev/null; then
  eval "$(starship init bash)"
fi

if command -v zoxide &>/dev/null; then
  eval "$(zoxide init bash)"
fi

if command -v try &>/dev/null; then
  eval "$(try init ~/Work/tries)"
fi

if command -v fzf &>/dev/null; then
  if [[ -f /usr/share/fzf/completion.bash ]]; then
    source /usr/share/fzf/completion.bash
  fi
  if [[ -f /usr/share/fzf/key-bindings.bash ]]; then
    source /usr/share/fzf/key-bindings.bash
  fi
fi

# Editor used by CLI
export SUDO_EDITOR="$EDITOR"
export BAT_THEME=ansi

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'
export PATH=$PATH:$HOME/go/bin

[[ $- == *i* ]] && bind -f ~/.config/david-configs/bash/inputrc

