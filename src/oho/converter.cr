require "./escape_code"
require "html"
module Oho
  class Converter

    def initialize(@options : Hash(Symbol, String))
      @options[:background_color] = "initial" unless @options.has_key?  :background_color
      @options[:foreground_color] = "initial" unless @options.has_key?  :foreground_color
    end
    def process(string : String, escape_code : EscapeCode?) : Tuple(String, EscapeCode?)
      reader = Char::Reader.new(string)
      first_char = true
      response = String.build do | str |
        if ! escape_code.nil?
          str << escape_code.as(EscapeCode).to_span(nil)
        end
        while reader.has_next?
          # acquire the correct char to work with
          if ! first_char
            char, reader = get_next_char(reader)
          else
            char = reader.current_char
            first_char = false
          end

          # char acquired
          break if char == '\u{0}' # EOL char
          if char == '\e' || char.hash == 27
            # TODO: handle bad input better
            char, reader = get_next_char(reader) # if we're here there should be more following
            if ( char == '[' )
              new_escape_code, reader = handle_left_square_bracket(char, reader)
              unless new_escape_code.nil?
                str << new_escape_code.to_span(escape_code)
                escape_code = new_escape_code
              # otherwise, pretend that that bogus escape code didn't happen
              end
              next
            elsif char == ']' # Operating System Command (OSC), ignoring for now
              while (char.hash != 2 && char.hash != 7 ) # STX and BEL end an OSC.
                char, reader = get_next_char(reader)
              end
            elsif char == ')' # Some VT100 ESC sequences, which should be ignored
              # Reading (and ignoring!) one character should work for "(B"
              # (US ASCII character set), "(A" (UK ASCII character set) and
              # "(0" (Graphic). This whole "standard" is fucked up. Really...
              char, reader = get_next_char(reader)
              # aha did something if char == '0' but i don't really get it
              # so i'm just moving on.
            end
          else # not \e or \033
            if char.hash != 8 # not a backspace
              str << escape_html_chars(char)
              if @options.has_key?(:iso) && @options[:iso]
                if (char.hash & 128) == 128 # first bit set => there must be followbytes
                  bits = 2
                  if (char.hash & 32) == 32
                    bits+=1
                  end
                  if (char.hash & 16) == 16
                    bits +=1
                  end
                  meow = 1 # why "meow"??
                  while meow < bits
                    char, reader = get_next_char(reader)
                    str << char.to_s
                    meow+=1
                  end
                end
              end
            end # end if not backspace
          end # END if char == '\e' || char.hash == 27
        end
        str << "</span>" if ! escape_code.nil?
      end

      # get rid of the [0m spans
      {response.gsub("<span style=\"\"></span>", ""), escape_code}
    end
    private def get_next_char(reader) : Tuple(Char, Char::Reader)
      response : Char
      if reader.has_next?
        response = reader.next_char
      else #can't happen never called when no more
        raise "Unknown Error in File Parsing!\n"
        exit(1)
      end
      {response, reader}
    end
    def handle_left_square_bracket(char    : Char,
                                   reader  : Char::Reader) : Tuple(EscapeCode?,
                                                                   Char::Reader)
      # CSI code, see https://en.wikipedia.org/wiki/ANSI_escape_code#Colors
      counter = Int8.new(1)
      raw_escape_seq = String.build do | str2 |
        str2 << "["
        while ((char<'A') || ((char>'Z') && (char<'a')) || (char>'z'))
          char, reader = get_next_char(reader)
          str2 << char
          break if char == '>'
          counter += 1
          break if counter > 1022
        end
        # buffer[counter -1] = 0 # '\u{0}' not needed here
      end # end constructing escape_seq
      begin
        return {EscapeCode.new(raw_escape_seq, @options), reader}
      rescue InvalidEscapeCode
        # we're going to pretend that didn't exist
        return {nil, reader}
      end
    end
    private def escape_html_chars(char : Char) : String
      if char == '&'
        "&amp;"
      elsif char == '"'
        "&quot;"
      elsif char == '<'
        "&lt;"
      elsif char == '>'
        "&gt;"
      elsif char == '\n' || char.hash == 13
        "\n<br />"
      else
        sprintf "%s",HTML.escape(char.to_s)
      end
    end
  end

end
