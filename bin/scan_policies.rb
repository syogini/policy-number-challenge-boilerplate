#!/usr/bin/env ruby
require_relative "../lib/policy_ocr"

path = ARGV[0] || "../spec/fixtures/sample.txt"
PolicyOcr::PolicyScanner.for(path).process
puts "Output written to #{File.dirname(path)}/output_*.txt"
