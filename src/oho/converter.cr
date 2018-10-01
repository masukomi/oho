require "./escape_code"
require "./color_escape_code"
require "./non_display_escape_code"
require "./t_416_color_escape_code"
require "html"
module Oho
  class UnexpectedEndOfReader < Exception

  end
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
              escape_code, reader = handle_left_square_bracket( str, char, reader, escape_code )
              next
            elsif char == ']' # Operating System Command (OSC), ignoring for now
              char, reader = handle_right_square_bracket(char, reader)
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
              handle_non_escape_chars(str, char, reader)
            end # end if not backspace
          end # END if char == '\e' || char.hash == 27
        end
        str << "</span>" if ! escape_code.nil? && escape_code.as(EscapeCode).affects_display?
      end

      # get rid of the [0m spans
      {response.gsub("<span style=\"\"></span>", ""), escape_code}
    end
    def extract_next_escape_code(char    : Char,
                                 reader  : Char::Reader) : Tuple(EscapeCode?,
                                                           Char::Reader)
      # CSI code, see https://en.wikipedia.org/wiki/ANSI_escape_code#Colors
      first_char = char
      counter = Int8.new(1)
      raw_escape_seq = String.build do | str2 |
        str2 << char.to_s # this is [ most of the time
        # if first_char == [
        #   then
        while ! last_char_in_escape?( first_char, char, counter)
          begin
            char, reader = get_next_char(reader)
            break if char.ord == 0
            str2 << char # this will be m for the end of color codes
            counter += 1
            break if counter > 1022
          rescue UnexpectedEndOfReader
            break
          end
        end
        # buffer[counter -1] = 0 # '\u{0}' not needed here
      end # end constructing escape_seq
      begin
        if raw_escape_seq.starts_with?("[") && raw_escape_seq.ends_with?("m")
          if ! raw_escape_seq.includes? ":"
            return {ColorEscapeCode.new(raw_escape_seq, @options), reader}
          else
            return {T416ColorEscapeCode.new(raw_escape_seq, @options), reader}
          end
        else
          # known things from http://ascii-table.com/ansi-escape-sequences.php
          # [H & [f               - cursor position
          # [<val>A               - cursor up (val is num lines)
          # [<val>B               - cursor down (val is num lines)
          # [<val>C               - cursor forwards (val is num columns)
          # [<val>D               - cursor backwards (val is num columns)
          # [s & [u               - save and restore cursor position
          # [2j                   - erase display & move cursor to 0,0
          # [K                    - erase line
          # [=<val>h [=<val>l     - set & reset mode
          # [<code>;<string>;...p - redefine keyboard key to specified string
          # AND more from http://ascii-table.com/ansi-escape-sequences-vt-100.php
          # [20h - set new line mode
          # [?1h - set cursor key to application
          # no [?2h
          # [?3h - set number of columns to 132 (duh!)
          # [?4h - set smooth scrolling
          # [?5h - set reverse video on screen
          # [?6h - set origin to relative
          # [?7h - set auto-wrap mode
          # [?8h - set auto-repeat mode
          # [?9h - set interlacing mode
          # [20l - set line feed mode
          # [?1l - set cursor key to cursor
          # [?2l - set VT52 (versus ANSI)
          # [?3l - set number of columns to 80
          # [?4l - set jump scrolling
          # [?5l - set normal video on screen
          # [?6l - set origin to absolute
          # [?7l - reset auto-wrap mode
          # [?8l - reset auto-repeat mode
          # [?9l - reset interlacing mode
          # =    - set alternate keypad mode
          # >    - set numeric keypad mode
          # (A   - set United Kingdom G0 character set
          # )A   - set United Kingdom G1 character set
          # (B   - Set United States G0 character set
          # )B   - Set United States G1 character set
          # (0   - Set G0 special chars. & line set
          # )0   - Set G1 special chars. & line set
          # (1   - Set G0 alt char ROM and spec. graphics
          # )1   - Set G1 alt char ROM and spec. graphics
          # N    - Set single shift 2
          # O    - Set single shift 3
          # [m   - Turn off character attributes
          #      ^ equivalent to [0m
          #TODO: handle & test these
          # http://www.ecma-international.org/publications/standards/Ecma-048.htm
          # X    - start of string
          # ^    - privacy message
          # _    - application program command
          # c    - reset to initial state

          return {NonDisplayEscapeCode.new(raw_escape_seq, @options), reader}
        end
      rescue InvalidEscapeCode
        # we're going to pretend that didn't exist
        return {nil, reader}
      end
    end

    # -------------------------------------------------------------------------
    # shhhh. private.
    private def last_char_in_escape?(first_char : Char,
                                     current_char : Char,
                                    seq_length : Int8) : Bool
      if seq_length == 1
        # fail fast. limited set of options
        if ['=','>','N', 'O'].includes? current_char
          return true
        else
          return false
        end
      end

      if first_char == '['
        zero_val_enders = ['H', 'f', 's', 'u', 'K']
        val_enders = ['A', 'B', 'C', 'D', 's', 'h', 'l', 'p', 'm']
        if seq_length == 2
          return true if zero_val_enders.includes? current_char
        elsif seq_length == 3
          return true if ['j', 'm'].includes? current_char 
          # if j assuming prior was '2'
        else # must be > 3
          return true if val_enders.includes? current_char
        end
      elsif first_char == '(' || first_char == ')'
        if seq_length == 2
          if ['A', 'B', '0', '1'].includes? current_char
            return true
          else
            raise InvalidEscapeCode.new("( & ) must be followed by A, B, 0, or 1")
          end
        end
      end
      false
    end
    private def handle_non_escape_chars(str    : String::Builder,
                                char   : Char,
                                reader : Char::Reader) : Tuple(Char, Char::Reader)
      str << escape_html_chars(char)
      if @options.has_key?(:iso) && @options[:iso]
        char, reader = handle_iso_chars(str, char, reader)
      end
      {char, reader}
    end

    private def handle_iso_chars(str    : String::Builder,
                         char   : Char,
                         reader : Char::Reader) : Tuple(Char, Char::Reader)
      if (char.hash & 128) == 128 # first bit set => there must be followbytes
        bits = 2
        if (char.hash & 32) == 32
          bits+=1
        end
        if (char.hash & 16) == 16
          bits +=1
        end
        bit_counter = 1
        while bit_counter < bits
          char, reader = get_next_char(reader)
          str << char.to_s
          bit_counter+=1
        end
      end
      {char, reader}
    end

    private def get_next_char(reader) : Tuple(Char, Char::Reader)
      response : Char
      if reader.has_next?
        response = reader.next_char
      else #can't happen never called when no more
        raise UnexpectedEndOfReader.new("eep")
      end
      {response, reader}
    end

    private def handle_right_square_bracket(char : Char, reader : Char::Reader) : Tuple(Char, Char::Reader)
      while (char.hash != 2 && char.hash != 7 ) # STX and BEL end an OSC.
        char, reader = get_next_char(reader)
      end
      {char, reader}
    end

    private def handle_left_square_bracket(str         : String::Builder,
                                           char        : Char,
                                           reader      : Char::Reader,
                                           escape_code : EscapeCode?) : Tuple(EscapeCode?, Char::Reader)
      new_escape_code, reader = extract_next_escape_code(char, reader)
      unless new_escape_code.nil?
        str << new_escape_code.to_span(escape_code)
        escape_code = new_escape_code
      # otherwise, pretend that that bogus escape code didn't happen
      end
      return {escape_code, reader}
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
