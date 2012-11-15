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

# These are used by the perf-ruby.sh wrapper script for perf data
export RUBY_PARGC_BENCHMARK_LOGS_DIR="$(dirname "$0")/../benchmark-logs"
export RUBY_PARGC_COMMIT="$1"

: "${GIT_REPO_ROOT:="$HOME/workspace/ruby"}"

rsync -av --stats $HOME/workspace/ruby/ ruby-clone

pushd ruby-clone
git checkout "$RUBY_PARGC_COMMIT"
make -j16 CC="ccache gcc" CFLAGS="-O2 -fPIC -g"
mkdir -p "$RUBY_PARGC_BENCHMARK_LOGS_DIR"

ulimit -s 16384 # To prevent stack overflow

echo "Benchmarking without perf (raw opaque benchmark)" >&2
ruby benchmark/driver.rb \
  -e './ruby' \
  -q \
  -o "$RUBY_PARGC_BENCHMARK_LOGS_DIR/ruby-bm-$RUBY_PARGC_COMMIT" \
  -d benchmark \
  -p 'bm_'

echo "Benchmarking with perf wrapper" >&2
# Opaque results would include bash runtime so they are discarded.
# perf data is collected by perf-ruby.sh
ruby benchmark/driver.rb \
  -e '../scripts/perf-ruby.sh ./ruby' \
  -q \
  -o /dev/null \
  -d benchmark \
  -p 'bm_'

popd

rm -fr ruby-clone
