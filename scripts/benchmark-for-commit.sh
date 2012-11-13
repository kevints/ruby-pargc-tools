#!/bin/bash
set -u

usage() {
  cat <<EOF
Usage: $0 COMMIT

Compiles and collects benchmarks for COMMIT.
EOF
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

: "${GIT_REPO_ROOT:="$HOME/workspace/ruby"}"

rsync -av --stats $HOME/workspace/ruby/ ruby-clone
pushd ruby-clone
git checkout "$1"
make -j16 CC="ccache gcc" CFLAGS="-O2 -fPIC -g"
mkdir -p ../benchmark-logs

ulimit -s 16384 # To prevent stack overflow
ruby benchmark/driver.rb -e './ruby' -q -o ../benchmark-logs/ruby-bm-"$1".log -d benchmark -p 'bm_'
popd
rm -fr ruby-clone
