require "./styling"
module Chaha
  class Converter
    def initialize(options = {} of Symbol => Int8|String)
      @options = options
      @options[:colorschema] = Int8.new(0) unless options.has_key? :colorschema
      @options[:iso] = Int8.new(-1)        unless options.has_key? :iso
      # Uses ISO 8859-X instead of utf-8. X must be 1..16
      # eg 6 = ISO-8559-6
    end
    private def get_option_val(option : Symbol) : Int8|Bool|String|Nil
      @options.has_key?(option) ? @options[option] : nil
    end
    private def test_bool_option(option) : Bool
      val = get_option_val(option)
      if val.nil? || val.as(Int8) == 0
        false
      else
        true
      end
    end
    private def test_int_option(option, equals : Int8) : Bool
      val = get_option_val(option)
      if val.nil? || val.as(Int8) != equals
        false
      else
        true
      end
    end
    private def print_color(color : String,
                            str : String::Builder,
                            stylesheet = test_bool_option(:stylesheet),
                           )
      if !stylesheet
        str << "color:#{color};"
      else
        str << "#{color} "
      end
    end
    private def print_bg_color(color : String,
                               str : String::Builder,
                               stylesheet = test_bool_option(:stylesheet))
      if !stylesheet
        str << "background-color:#{color};"
      else
        str << "bg-#{color} "
      end
    end
    private def escape_html_chars(char : Char,
                                  momline : Int64,
                                  line : Int64,
                                  styling : Styling,
                                  str : String::Builder) : Tuple(Int64, Int64)
      if char == '&'
        str << "&amp;"
      elsif char == '"'
        str << "&quot;"
      elsif char == '<'
        str << "&lt;"
      elsif char == '>'
        str << "&gt;"
      elsif char == '\n'
        momline+=1
        line = Int64.new(0)
      elsif char.hash == 13
        momline+=1
        line = Int64.new(0)
      else
        if styling.special_char
          str << sprintf "%s",HTML.escape(char.to_s)
        else
          str << char.to_s
        end
      end
      {momline, line}
    end

    def process(string : String) : String
      reader = Char::Reader.new(string)
      styling = Styling.new()


      momline = line = Int64.new(0)
      newline = Int8.new(-1)
      temp = Int8.new(-1)
      first_char = true
      response = String.build do | str |
        while reader.has_next?
          if ! first_char
           char, reader = get_next_char(reader)
          else
           char = reader.current_char
           first_char = false
          end
          break if char == '\u{0}' # EOL char
          STDERR.puts("1: char.hash: #{char.hash} char: #{char}")
          if char == '\e' || char.hash == 27# \033 == \e
            # Saving old values
            styling.save_old_values

            # searching the end (a letter) and safe the insert
            # TODO: handle bad input better
            char, reader = get_next_char(reader) # if we're here there should be more following
            STDERR.puts("2: char.hash: #{char.hash} char: #{char}")
            if ( char == '[' )
              reader = handle_left_square_bracket(char, reader, styling, str)
            elsif char == ']' # Operating System Command (OSC), ignoring for now
              while (char.hash != 2 && char.hash != 7 ) # STX and BEL end an OSC.
                char, reader = get_next_char(reader)
                STDERR.puts("3: char.hash: #{char.hash} char: #{char}")
              end
            elsif char == ')' # Some VT100 ESC sequences, which should be ignored
              # Reading (and ignoring!) one character should work for "(B"
              # (US ASCII character set), "(A" (UK ASCII character set) and
              # "(0" (Graphic). This whole "standard" is fucked up. Really...
              char, reader = get_next_char(reader);
              STDERR.puts("4: char.hash: #{char.hash} char: #{char}")
              if (char == '0') # we do not ignore ESC(0 ;)
                styling.special_char=true
              else
                styling.special_char=false
              end
            end
          else

            #if (char.hash == 13 && false)
              # more htop fix
            if char.hash != 8
              line+=1
              if styling.line_break == true
                str << "\n"
                line = Int64.new(0)
                styling.line_break = false
                momline+= 1
              end
              if newline >= 0
                while newline > line
                  str << " "
                  line+=1
                end
                newline = Int8.new(-1)
              end
              momline, line = escape_html_chars(char, momline, line, styling, str)

              if @options[:iso].as(Int8) > 0 # only at ISOS
                if (char.hash & 128) == 128 # first bit set => there must be followbytes
                  bits = 2
                  if (char.hash & 32) == 32
                    bits+=1
                  end
                  if (char.hash & 16) == 16
                    bits +=1
                  end
                  meow = 1
                  while meow < bits
                    char, reader = get_next_char(reader)
                    STDERR.puts("5: char.hash: #{char.hash} char: #{char}")
                    str << char.to_s
                    meow+=1
                  end
                end
              end
            end
          end
        end

        if (styling.time_to_start_span?)
          str << "</span\n"
        end
      end # String.build
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

    private def parse_insert(s : String) : Pelem?
      first_elem = nil.as(Pelem?)
      mom_elem   = nil.as(Pelem?)
      temp       = Pelem.new()
      cr         = Char::Reader.new(s)
      while cr.has_next?
        break if cr.pos == 1024
        char = cr.next_char
        next if char == '['
        if char == ';' || char == '\u{0}' # latter shouldn't happen
          if temp.digit_count == Int8.new(0)
            temp.digit[0]    = Int8.new(0)
            temp.digit_count = Int8.new(1)
          end
          new_elem = Pelem.new(temp)
          if mom_elem.nil?
            first_elem = new_elem
          else
            mom_elem.da_next = new_elem
          end
          mom_elem = new_elem
          temp.reset
          break if char == '\u{0}' # shouldn't happen
        elsif temp.digit_count < 8
          temp.digit[temp.digit_count] = Int8.new(char - '0')
          temp.digit_count += 1
        end
      end
      first_elem
    end

    private def set_background_color(styling : Styling,
                                     str : String::Builder)
      colorschema = @options[:colorschema].as(Int8)
      if styling.background_color == 0 # black
        print_bg_color("black", str)
      elsif styling.background_color == 1
        print_bg_color("red", str)
      elsif styling.background_color == 2 # green
          if colorschema == 1
          print_bg_color("lime", str)
        else
          print_bg_color("green", str)
        end
      elsif styling.background_color == 3 # yellow
        if colorschema == 1
          print_bg_color("olive", str)
        else
          print_bg_color("yellow", str)
        end
      elsif styling.background_color == 4 # blue
        if colorschema == 1
          print_bg_color("#3333FF", str)
        else
          print_bg_color("blue", str)
        end
      elsif styling.background_color == 5 # purple
        if colorschema == 1
          print_bg_color("fuchia", str)
        else
          print_bg_color("purple", str)
        end
      elsif styling.background_color == 6 # cyan
        # this is ...wtf?
        if colorschema == 1
          print_bg_color("aqua", str)
        elsif test_bool_option(:stylesheet)
          print_bg_color("cyan", str)
        else
          print_bg_color("teal", str)
        end
      elsif styling.background_color == 7 # white
        if colorschema == 1 || test_bool_option(:stylesheet)
          print_bg_color("white", str)
        else
          print_bg_color("gray", str)
        end
      elsif styling.background_color == 8 # set to background color
        if colorschema == 1
          print_bg_color("black", str)
        elsif colorschema == 2
          print_bg_color("pink", str)
        elsif test_bool_option(:stylesheet)
          print_bg_color("reset", str)
        else
          print_bg_color("white", str)
        end
      elsif styling.background_color == 9 # set to foreground color
        if colorschema == 1
          print_bg_color("white", str)
        elsif test_bool_option(:stylesheet)
          print_bg_color("inverted", str)
        else
          print_bg_color("black", str)
        end
      end

    end

    private def set_foreground_color(styling : Styling,
                                    str : String::Builder)
      case styling.foreground_color
      when 0
        print_color "dimgray", str
      when 1
        print_color "red", str
      when 2
        if test_bool_option(:stylesheet)
          print_color "green", str
        elsif ! test_int_option(:colorschema, Int8.new(1))
          print_color "green", str
        else
          print_color "lime", str
        end
      when 3
        if test_bool_option(:stylesheet)
          print_color "yellow", str
        elsif ! test_int_option(:colorschema, Int8.new(1))
          print_color "olive", str
        else
          print_color "yellow", str
        end
      when 4
        if test_bool_option(:stylesheet) || ! test_int_option(:colorschema, Int8.new(1))
          print_color "blue", str
        else
          print_color "#333FF", str
        end
      when 5
        if test_bool_option(:stylesheet) || ! test_int_option(:colorschema, Int8.new(1))
          print_color "purple", str
        else
          print_color "fuchsia", str
        end
      when 6
        if test_bool_option(:stylesheet)
          print_color "cyan", str
        elsif ! test_int_option(:colorschema, Int8.new(1))
          print_color "teal", str
        else
          print_color "aqua", str
        end
      when 7
          if test_bool_option(:stylesheet) || test_int_option(:colorschema, Int8.new(1))
          print_color "white", str
          elsif ! test_int_option(:colorschema, Int8.new(1))
          print_color "gray", str
        end
      when 8
        if test_bool_option(:stylesheet)
          print_color "inverted", str
        elsif test_int_option(:colorschema, Int8.new(1))
          print_color "black", str
        elsif test_int_option(:colorschema, Int8.new(2))
          print_color "pink", str
        else
          print_color "white", str
        end
      when 9
        if test_bool_option(:stylesheet)
          print_color "reset", str
        elsif test_int_option(:colorschema, Int8.new(1))
          print_color "white", str
        else
          print_color "black", str
        end
      end
    end
    private def underline(stylesheet : Bool,
                          str : String::Builder)
      if (stylesheet)
        str << "underline ";
      else
        str << "text-decoration:underline;";
      end
    end
    private def bold(stylesheet : Bool,
                    str : String::Builder)
      if (stylesheet)
        str << "bold ";
      else
        str << "font-weight:bold;";
      end
    end
    private def blink(stylesheet : Bool,
                     str : String::Builder)
      if (stylesheet)
        str << "blink ";
      else
        str << "text-decoration:blink;";
      end
    end
    def handle_left_square_bracket(char : Char, reader : Char::Reader,
                                  styling : Styling,
                                  str : String::Builder) : Char::Reader
      # CSI code, see https://en.wikipedia.org/wiki/ANSI_escape_code#Colors
      counter = Int8.new(1)
      buff = String.build do | str |
        str << "["
        while ((char<'A') || ((char>'Z') && (char<'a')) || (char>'z'))
          char, reader = get_next_char(reader)
          STDERR.puts("6: char.hash: #{char.hash} char: #{char}")
          str << char
          break if char == '>'
          counter += 1
          break if counter > 1022
        end
        # buffer[counter -1] = 0 # '\u{0}' not needed here
      end # end constructing buff
      case char
      when 'm'
        elem = parse_insert(buff)
        mom_elem = elem.as(Pelem?)
        while ! mom_elem.nil?
          mom_pos = Int8.new(0)
          while mom_pos < mom_elem.digit_count && mom_elem.digit[mom_pos] == 0
            mom_pos += 1
          end
          if mom_pos == mom_elem.digit_count # only zeroes => delete all
            styling.zero_out
          else
            digit = mom_elem.digit[mom_pos]
            if digit == 1 && mom_pos+1 == mom_elem.digit_count
              # 1, 1X not supported
              styling.background_color= Int8.new(1)
            elsif digit == 2 && mom_pos+1 == mom_elem.digit_count
              # 2, 2X not supported
              case mom_elem.digit[mom_pos+1]
              #when 1 # Reset and double underline (which aha doesn't support)
              when 2 # reset bold
                styling.bold = Int8.new(0)
                break
              when 4 # reset underline
                styling.underline= Int8.new(0)
                break
              when 5 # reset blink
                styling.blink = Int8.new(0)
                break
              when 7
                # reset inverted
                styling.reset_inverted
                break
              end
            elsif digit == 3 && mom_pos+1 == mom_elem.digit_count
              if styling.negative == 0
                fc = mom_elem.digit[mom_pos+1]
              else
                bc = mom_elem.digit[mom_pos+1]
              end
              break
            elsif digit == 4 && mom_pos+1 == mom_elem.digit_count # 4
              styling.underline = Int8.new(1)
            elsif digit == 4
              if styling.negative == 0
                styling.background_color = mom_elem.digit[mom_pos+1].as(Int8)
              else
                styling.foreground_color = mom_elem.digit[mom_pos+1].as(Int8)
              end
              break

            elsif digit == 5 && mom_pos+1 == mom_elem.digit_count
              styling.blink = Int8.new(1)
              break
            # 6 and 6X not supported at 8
            elsif digit == 7 # 7, 7x is mot defined (and supported)
              styling.seven_x_dance
              break
            end
            mom_elem = mom_elem.da_next
          end
          # delete_parse(elem)
          # in aha.c i believe deleteParse was just a process for
          # freeing up memory
          break;
        end
      when 'H'
        STDERR.puts("H - Htop not supported")
      end # end case char
      # if htop_fix print 80 whitespaces... or... lines... or something
      if (styling.changed?) # ANY Change
        if (styling.time_to_end_span?)
          str << "</span>";
        end
        if (styling.time_to_start_span?)
          stylesheet = test_bool_option(:stylesheet)
          if stylesheet
            str << "<span class=\""
          else
            str << "<span style=\""
          end
          set_foreground_color(styling, str) # always
          set_background_color(styling, str) if styling.background_color > -1 # set background color
          underline(stylesheet, str)         if styling.underline > 0 # set underline
          bold(stylesheet, str)              if styling.bold > 0
          blink(stylesheet, str)             if styling.blink > 0
          str << "\">"
        end
      end
      reader
    end
  end # END class Converter
end
