#!/usr/bin/env python
"""
Verify that all performance data from CS194 commits has been
collected. Python 2.7-compatible.
"""
from glob import glob
import json
import logging
from os import chdir, getcwd, getenv, path
from subprocess import CalledProcessError, check_call, check_output
import sys
from UserList import UserList

logging.basicConfig(stream=sys.stderr)
log = logging.getLogger(__name__)
log.setLevel(logging.DEBUG)

# Defaults
DEFAULT_RUBY_REPO = path.expanduser('~/workspace/ruby')
DEFAULT_TOOLS_REPO = path.expanduser('~/workspace/ruby-pargc-tools')
DEFAULT_BENCHMARK_LOGS_DIR = path.join(DEFAULT_TOOLS_REPO,
                                       'benchmark-logs')
DEFAULT_COMMIT_DATA_COLLECTOR = path.join(DEFAULT_TOOLS_REPO,
                                          'scripts', 'benchmark-for-commit.sh')
DEFAULT_PERF_DATA_FILE_TEMPLATE = '%s-%s.data' # %(commit_id, benchmark_name)
DEFAULT_RUBY_BENCHMARK_DATA_FILE_TEMPLATE = 'ruby-bm-%s' # %(commit_id)

# Use environment variables over defaults if possible
RUBY_REPO = getenv('RUBY_PARGC_RUBY_REPO',
                   DEFAULT_RUBY_REPO)
TOOLS_REPO = getenv('RUBY_PARGC_TOOLS_REPO',
                    DEFAULT_TOOLS_REPO)
BENCHMARK_LOGS_DIR = getenv('RUBY_PARGC_BENCHMARK_LOGS_DIR',
                            DEFAULT_BENCHMARK_LOGS_DIR)
DATA_COLLECTOR = getenv('RUBY_PARGC_COMMIT_DATA_COLLECTOR',
                        DEFAULT_COMMIT_DATA_COLLECTOR)
PERF_DATA_FILE_TEMPLATE = getenv('RUBY_PARGC_PERF_DATA_FILE_TEMPLATE',
                                 DEFAULT_PERF_DATA_FILE_TEMPLATE)
RUBY_BENCHMARK_DATA_FILE_TEMPLATE = getenv('RUBY_PARGC_RUBY_BENCHMARK_DATA_FILE_TEMPLATE',
                                           DEFAULT_RUBY_BENCHMARK_DATA_FILE_TEMPLATE)

def perf_data_file_exists_for_commit(commit_id, logs_dir=BENCHMARK_LOGS_DIR):
    """Checks the existence of Linux perf data for commit_id."""
    perf_data_files = glob(path.join(logs_dir, PERF_DATA_FILE_TEMPLATE % (commit_id, '*')))
    return len(perf_data_files) != 0

def ruby_benchmark_data_exists_for_commit(commit_id, logs_dir=BENCHMARK_LOGS_DIR):
    """Checks the existence of benchmark.rb data for commit_id."""
    return path.exists(path.join(benchmark_logs_dir, RUBY_BENCHMARK_DATA_FILE_TEMPLATE % commit_id))

def performance_data_exists_for_commit(commit_id, logs_dir=BENCHMARK_LOGS_DIR):
    return (path.isdir(logs_dir) and
            perf_data_exists_for_commit(commit_id) and
            ruby_benchmark_data_exists_for_commit(commit_id))

class BrokenCommits(UserList):

    @classmethod
    def from_json_file_or_empty(cls, filename):
        """
        Reads a serialized BrokenCommits from a JSON file if it exists, otherwise an empty one.
        """
        if path.exists(filename):
            with file(filename, 'r') as f:
                data = json.load(f)
            assert isinstance(data['broken_commits'], list)
            new_broken_commits = cls()
            new_broken_commits.data = data['broken_commits']
            return new_broken_commits
        else:
            return cls()
    
    def to_json_file(self, filename):
        with file(filename, 'w') as f:
            json.dump({'broken_commits': self.data}, f)

def collect_performance_data_for_commit(commit_id,
                                        broken_commits=(),
                                        data_collector=DATA_COLLECTOR):
    """Attempts to collect performance data for commit_id, returns a bool for success."""
    if (commit_id not in broken_commits and
        not performance_data_exists_for_commit(commit_id)):
        try:
            check_call([data_collector, commit_id])
        except CalledProcessError as e:
            log.debug(
                'Performance data collection for commit ID %s with %s exited with code %d' %
                (commit_id, DATA_COLLECTOR, e.returncode))
            broken_commits = broken_commits.union(frozenset([commit_id]))
            return False
        if not performance_data_exists_for_commit(commit_id):
            log.debug(
                'Performance data collection for commit ID %s with %s failed'
                ' , but no error code was raised' % (commit_id, DATA_COLLECTOR))
            return False
        return True
            
def get_commits_for_range(repo_path, from_commit_id, to_commit_id):
    try:
        log.debug('Entering %s' % repo_path)
        git_output = check_output(
            ['git', 'log',
             '--git-dir=%s/.git' % repo_path,
             '--work-tree=%s' % repo_path,
             '--format=%H', # one full commit sha per line
             '--exit-code', # give a nonzero exit so we can throw
             '%s..%s' % (from_commit_id, to_commit_id)])
        return git_output.rsplit()
    except CalledProcessError as e:
        log.debug('git returned error code %d' % (e.returncode))
        log.debug('output was %s' % repr(e.output))
        raise

def main(args=None):
    if args is None:
        args = sys.argv[:]
    broken_commits_json_file = path.join(BENCHMARK_LOGS_DIR, 'broken-commits.json') 
    broken_commits = BrokenCommits.from_json_file_or_empty(broken_commits_json_file)
    for commit_id in get_commits_for_range(RUBY_REPO, 'origin/ruby_1_9_3', 'origin/cs194_master'):
        success = collect_performance_data_for_commit(commit_id, broken_commits)
        if not success:
            broken_commits.append(commit_id)
            broken_commits.to_json_file(broken_commits_json_file)

if __name__ == '__main__':
  main()
