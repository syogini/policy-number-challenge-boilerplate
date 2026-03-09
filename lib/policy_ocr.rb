require_relative 'policy_number_generator'

module PolicyOcr


    # Scans a policy file in 4-line blocks, 
    # converts the 3-line digits into numeric policy numbers, 
    # validates the policy numbers,
    # Writes the policy number and error message to a timestamped output file.
    class PolicyScanner
        attr_accessor :policy_numbers
        attr_accessor :line_list

        def initialize(file_path)
          @path = File.expand_path(file_path, __dir__)
          @reader = SimpleLineFileReader.new(@path)
          @line_list = Array.new { Array.new(3) }
          @policy_numbers = []
        end

        def self.for(file_path)
            PolicyScanner.new(file_path)
        end

        def process
            scan
            generate_policy_numbers
            print_validated_numbers
        end
      
        #Reads the input file and converts it list of 3 lines block for processing
        def scan
            # define a list to hold 3 lines
            policy_lines = Array.new{3}

            @reader.lines.each_with_index do |line, index|
                # skip every 4th line (e.g. index 3)
                if (((index+1) %  4) == 0)
                  @line_list << policy_lines
                  policy_lines = []
                  next
                end
                policy_lines <<  line
            end
        end
      
        # Generates the policy number from the block of 3 lines.
        def generate_policy_numbers
            @line_list.each do | list_item |
                @policy_numbers << PolicyNumberGenerator.new(list_item).policy_number
            end 
        end

        def print_validated_numbers
            timestamp = Time.now.strftime("%Y%m%d%H%M%S")
            output_path = File.join(File.dirname(@path), "output_#{timestamp}.txt")
            File.open(output_path, "w") do |file|
                @policy_numbers.each do |policy_number|
                    error_message = ""
                    if (policy_number.include?("?"))
                        error_message = "ILL"
                    elsif (!validate_policy_number?(policy_number))
                        error_message = "ERR"
                    end
                    line = policy_number + " " + error_message
                    file.puts line
                end
            end
        end

        def validate_policy_number?(policy_number_str)
            ((calculate_checksum_total(policy_number_str) % 11) == 0) ? true : false
        end
        def calculate_checksum_total(policy_number_str)
            check_sum_total = 0
            policy_number_str.each_char.with_index  do | num, index|
                if (num.match?(/[0-9]/))
                    check_sum_total += num.to_i*(policy_number_str.size - index)
                end
            end
            check_sum_total
        end
    end


    class SimpleLineFileReader
        def initialize(path)
          @file_reader_path = path
        end
      
        # Every line has 27 characters and there are max 480 lines per file
        # reading all lines will not exceed the buffer size.
        def lines
          @lines ||= File.readlines(@file_reader_path, chomp: true)
        end
    end
end
