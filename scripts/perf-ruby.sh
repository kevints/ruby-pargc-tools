#!/bin/bash
# Run compiled ruby and collects perf data
set -eu

benchmark_name="${2##.rb}"

perf record --call-graph --stat "$@"
mv perf.data "$RUBY_PARGC_BENCHMARK_LOGS_DIR/$RUBY_PARGC_COMMIT-$benchmark_name.perf.data"
