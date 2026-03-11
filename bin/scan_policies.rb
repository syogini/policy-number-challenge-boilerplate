#!/usr/bin/env ruby
require_relative "../lib/policy_ocr"

path = ARGV[0] || "../spec/fixtures/sample.txt"
begin
  PolicyOcr::PolicyScanner.for(path).process
rescue => e
  puts "Error processing policies"
  exit 1
end
puts "Output written to #{File.dirname(path)}/output_*.txt"
