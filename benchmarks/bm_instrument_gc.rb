#!/usr/bin/env ucbruby
# Exercise the GC NUM_GC_RUNS times
NUM_GC_RUNS = 10000

def profile_step(start_count)
  obj_count = 0
  benchmark_start_time = Time.now
  iteration_start_time = 0
  iteration_end_time = 0
  last_iteration_start_time = 0
  last_iteration_end_time = 0
  
  while(GC.count == start_count) do
    last_iteration_start_time = iteration_start_time
    iteration_start_time = Time.now
    obj_count += 1
    Object.new
  
    # Save
    last_iteration_end_time = iteration_end_time
    iteration_end_time = Time.now
  end
  
#  puts "Iteration #{start_count}"
#  puts "ObjectSpace.count_objects: #{ObjectSpace.count_objects}"
#  puts "Object count:              #{obj_count}"
#  puts "Total loop time:           #{(iteration_end_time - benchmark_start_time) * 1000}ms"
#  puts "Final loop time:           #{(iteration_end_time - iteration_start_time) * 1000}ms"
#  puts "Second-to-last loop time:  #{(last_iteration_end_time - last_iteration_start_time) * 1000}ms"
#  puts
end

(1..NUM_GC_RUNS).each do |i|
  profile_step(i)
end
