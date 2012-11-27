# "Application server handling bursts of concurrent requests"
# Some amount of static data (at least enough to fill first 3 slabs)
# Tunable number of requests - powers of 10 - create ~2000 objects and hold them for request duration
# Repeat until GC pause time is steady state
# Conceptually: while(true) do { (1..NUM_REQUESTS).each {|i| requests = []; requests << (1..200).map { Object.new }; requests = [] }
NUM_CONCURRENT_REQUESTS = (ENV['RUBY_PARGC_TOOLS_NUM_CONCURRENT_REQUESTS'] || 1000).to_i
NUM_ITERATIONS = (ENV['RUBY_PARGC_TOOLS_NUM_ITERATIONS'] || 100).to_i
OBJECTS_PER_REQUEST = (ENV['RUBY_PARGC_TOOLS_OBJECTS_PER_REQUEST'] || 200).to_i
NUM_PERSISTENT_GLOBALS = (ENV['RUBY_PARGC_TOOLS_NUM_PERSISTENT_GLOBALS'] || 5000).to_i

# "Persistent global state"
persistent_global_state = (1..NUM_PERSISTENT_GLOBALS).map {|i| Object.new}

# "Bursty traffic"
(1..NUM_ITERATIONS).each do |i|
  requests = []
  requests << (1..NUM_CONCURRENT_REQUESTS).
    map {|j| (1..OBJECTS_PER_REQUEST).map {|k| Object.new}}
end
