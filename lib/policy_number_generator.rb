module PolicyOcr

  # PolicyNumberGenerator is responsible for converting three lines of text,
  # representing a "digital" 7-segment style display (using '_', '|', and ' '),
  # into the corresponding 9-digit policy number string.
  # 
  # ' ' -> 0 '|' -> 1 '_' -> 2
  # It processes each 3x3 character block per digit, maps these arrangements
  # to the correct numerical digit, and constructs the full policy number.
  #
  # If an unrecognized pattern is encountered, it substitutes '?' for that digit.
class PolicyNumberGenerator

    attr_reader :converted_line_list
    def initialize(lines)
        @converted_line_list = Array.new(3) { Array.new{9} }
        9.times do
            3.times do |j|
                @converted_line_list[j] << []
            end
        end
        @policy_number_lines = lines
    end

    def policy_number
        @policy_number_lines.each_with_index do |line, index| 
            read_characters(line, index)
        end

        generate_policy_number
    end 

    # Converts each character line to specific digit list.
    def read_characters(line, line_index)
      # Add an index counter for each character (needed for /3 logic)
      char_index = 0
      line.each_char do |char|
        section_index = char_index / 3
  
        value =
          if char == ' '
            0
          elsif char == '|'
            1
          elsif char == '_'
            2
          else
            -1
          end
        @converted_line_list[line_index][section_index] << value
        char_index += 1
      end
    end
    
    # Matches the 3X3 grid for each digit to get policy number
    def generate_policy_number
      stringBuilder = ""
      for index in 0..8
        if @converted_line_list[0][index] == [0, 0, 0] && @converted_line_list[1][index] == [0, 0, 1] && @converted_line_list[2][index] == [0, 0, 1]
            stringBuilder += "1"
        elsif @converted_line_list[0][index] == [0, 2, 0] && @converted_line_list[1][index] == [0, 2, 1] && @converted_line_list[2][index] == [1, 2, 0]
            stringBuilder += "2"
        elsif @converted_line_list[0][index] == [0,2, 0] && @converted_line_list[1][index] == [0, 2, 1] && @converted_line_list[2][index] == [0, 2, 1]
            stringBuilder += "3"
        elsif @converted_line_list[0][index] == [0, 0, 0] && @converted_line_list[1][index] == [1, 2, 1] && @converted_line_list[2][index] == [0, 0, 1]
            stringBuilder += "4"
        elsif @converted_line_list[0][index] == [0, 2, 0] && @converted_line_list[1][index] == [1, 2, 0] && @converted_line_list[2][index] == [0, 2, 1]
            stringBuilder += "5" 
        elsif @converted_line_list[0][index] == [0, 2, 0] && @converted_line_list[1][index] == [1, 2, 0] && @converted_line_list[2][index] == [1, 2, 1]
            stringBuilder += "6"
        elsif @converted_line_list[0][index] == [0, 2, 0] && @converted_line_list[1][index] == [0, 0, 1] && @converted_line_list[2][index] == [0, 0, 1]
            stringBuilder += "7"
        elsif @converted_line_list[0][index] == [0, 2, 0] && @converted_line_list[1][index] == [1, 2, 1] && @converted_line_list[2][index] == [1, 2, 1]
            stringBuilder += "8"
        elsif @converted_line_list[0][index] == [0, 2, 0] && @converted_line_list[1][index] == [1, 0, 1] && @converted_line_list[2][index] == [1, 2, 1]
            stringBuilder += "0"
        elsif @converted_line_list[0][index] == [0, 2, 0] && @converted_line_list[1][index] == [1, 2, 1] && @converted_line_list[2][index] == [0, 2, 1]
            stringBuilder += "9"
        else
          stringBuilder += "?"
        end
      end
      stringBuilder.to_s
    end
end
end