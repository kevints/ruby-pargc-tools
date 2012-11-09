#!/bin/bash
set -eu

required_apt_packages=(
  build-essential
  curl
  graphviz
  libc6-dbg
  linux-tools-common
  linux-tools-`uname -r | sed 's/-generic//'`
  python
)

RUBY_PARGC_TOOLS_FORCE_INSTALL="${RUBY_PARGC_TOOLS_FORCE_INSTALL:+0}"

if [[ "$RUBY_PARGC_TOOLS_FORCE_INSTALL" = 0 ]]; then
    lsb_distribution_id=`lsb_release -is`
    lsb_release_short=`lsb_release -rs`
    if [[ "$lsb_distribution_id" != "Ubuntu" ]] || \
            [[ "$lsb_release_short" != "12.04" ]]; then
        cat >&2 <<EOF
This script has only been tested on Ubuntu 12.04

Override this check by exporting RUBY_PARGC_TOOLS_FORCE_INSTALL=1
EOF
        exit 1
    fi
fi

function install_apt_dependencies {
    echo "Installing dependencies from apt" >&2

    if type apt-get 2>/dev/null; then
        set -x
        sudo apt-get install "${required_apt_packages[@]}"
        set +x
    else
        cat >&2 <<EOF
!
! apt-get not found on PATH. Make sure you install dependencies manually
!
! On Ubuntu 12.04 the dependencies are
!   ${required_apt_packages[@]}
!
EOF
    fi
}

function install_gprof2dot {
    if ! type gprof2dot.py 2>/dev/null; then
        echo "*** Installing gprof2dot.py" >&2

        set -x
        mkdir -p "$HOME/bin"
        curl -o ~/bin/gprof2dot.py "http://gprof2dot.jrfonseca.googlecode.com/git/gprof2dot.py"
        chmod +x ~/bin/gprof2dot.py
        set +x

        if ! [[ "${PATH}" =~ "$HOME/bin" ]]; then
            cat >&2 <<EOF
! Make sure you add $HOME/bin to your PATH
!
!   echo 'PATH="\$PATH:\$HOME/bin' >> ~/.bashrc
!
EOF
        fi
    fi
}

function install_rvm {
    if ! type rvm 2>/dev/null; then
        echo "*** Installing RVM" >&2

        set -x
        curl -L https://get.rvm.io | bash -s stable
        set +x
    fi
}

install_apt_dependencies
install_gprof2dot
install_rvm

# vim:ts=4:sw=4:expandtab
