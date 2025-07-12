if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -U fish_greeting

# ZVM
export ZVM_INSTALL="$HOME/.zvm/self"
export PATH="$PATH:$HOME/.zvm/bin"
export PATH="$PATH:$ZVM_INSTALL/"

alias g=git
alias c=clear
alias j=just

if command -q zoxide
	zoxide init fish | source
end

if command -q opam && test -e ~/.opam/opam-init/init.fish
    source ~/.opam/opam-init/init.fish > /dev/null 2> /dev/null; or true
end

if command -q rustup && test -e /opt/rust/bin/env.fish
    . /opt/rust/bin/env.fish
end

if test -e /home/xtex/src/aosc/ciel-rs/target/debug/ciel
    alias ciel='sudo /home/xtex/src/aosc/ciel-rs/target/debug/ciel'
end

#if test -e /home/xtex/src/aosc/oma/target/debug/oma
#    alias oma='sudo /home/xtex/src/aosc/oma/target/debug/oma'
#end

# pnpm
set -gx PNPM_HOME "/opt/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end

if test -e /opt/elan
    export PATH="$PATH:/opt/elan/bin"
    export ELAN_HOME="/opt/elan"
end

