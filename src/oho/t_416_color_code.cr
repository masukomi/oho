require "./escape_code"
module Oho
  # Note: this is only concerned with escape codes
  # related to text formatting
  # ESC[ … 38:<0-5>:<Color-Space-ID>:<r|c|table index>:<g|m>:<b|y>:<unused|k>:<OPTIONAL CS tolerance>:<OPTIONAL Color-Space: 0="CIELUV"; 1="CIELAB">; … m
  # ESC[ … 48:<0-5>:<Color-Space-ID>:<r|c|table index>:<g|m>:<b|y>:<unused|k>:<OPTIONAL CS tolerance>:<OPTIONAL Color-Space: 0="CIELUV"; 1="CIELAB">; … m
  # 38 means hey, we're doing a background color
  # 48 means hey, we're doing a foreground colo
  # # colors are 30-37 and 40-47 like normal ANSI colors
  # IF 38 or 48 (not 30-37 or 40-47) THEN
  # next param is Color-Space-Id
  #   0 implementation defined
  #     this implementation defines it as
  #     reset like ANSI
  #     (only applicable for the character foreground colour)
  #   1 transparent;
  #     This seems to correspond to the
  #     ansi option of invisible text
  #   2 direct colour in RGB space;
  #   3 direct colour in CMY space;
  #   4 direct colour in CMYK space;
  #   5 indexed colour.
  #
  # SO
  # if 0-1 no additional parameter elements
  # if 5 then 2nd param specifies key into CONTENT_COLOR_TABLE_LOOKUP
  # if 2
  #   elements 3-5 are r,g, and b respectively
  #   and 6 is unused
  # if 3
  #   elements 3-5 are cyan, magenta, yellow
  #   and 6 is unused
  # if 4
  #   elements 3-6 are cyan, magenta, yellow, and black
  # if 2-4
  #   element 7 MAY be used to specify a tolerance value (an integer)
  #   In some instances, the originator of a colour description may specify some
  #   tolerance or permit some variability in the interpretation of colour values.
  #   An example is the traditional usage within CGM of RGB values which do not
  #   refer to any particular set of RGB primaries or to any particular reference
  #   white. (See H.3.1 and H.3.2). Therefore, this Recommendation | International
  #   standard uses the attribute “colour tolerance” to allow the originator to
  #   specify colour differences, the amount by which colour values can vary during
  #   presentation (or processing) and still satisfy the original intent. The colour
  #   differences are specified using one of the two CIE-recommended uniform colour
  #   spaces – CIELUV and CIELAB (see Annex H and CIE Publication, 15.2,
  #   2nd Edition, 1986).

  #   and param 8 MAY be used to specify a color space
  #   associated with the tolerance
  #   0 for CIELUV 1 for CIELAB
  # NOTE:
  # An empty parameter element represents a default value for this parameter
  # element. Empty parameter elements at the end of the parameter substring
  # need not be included.
  # putting this all together
  # <ESC>[ followed by
  #   (38|48):([0-1]
              # |2:[0-1](:[0-9]{1,3}){3})  # rgb
              # |3:[0-1](:[0-9]{1,3}){3}:  # cmy followed by empty
              # |4:[0-1](:[0-9]{1,3}){4}   # cmyk
              # |5:[0-7])                  # index in color table
              # (:[0-9]*:[0-1]
              # |::
              # |:
              # |$)
                                         # tolerance. IF 2-4
                                         #  Only know that it will be
                                         #  an integer *if* present
                                         # followed by color space
                                         #   maybe
                                         # both can be blank
                                         # both can be missing
                                         # last can be missing
                                         #
  # i'm guessing that 0-1 is what follows 2-4
  # it's not explicit about what color space ids are allowed
  # or why you'd use a different one for the tolerance
  # than you'd use here.
  #
  # (:[0-9]{1,3}){3})
  # for rgb (2) is really :0-255 3 times but regexp doesn't allow you to
  # say that easily
  # for cmy(k) (3 and 4) that's :0-100 (percent)
  #
  # NOTE:
  # none of this accounts for Select Graphics Rendering (SGR)
  # which allows you to specific standard reset & formatting codes
  # as well as ANSI colors and fonts!
  # see the T.416 document for details

  class T416ColorCode < EscapeCode

    CONTENT_COLOR_TABLE_LOOKUP = {
      # left side is from
      # ITU-T Rec. T.412 | ISO/IEC 8613-2
      # right side is the id of
      # a standard ansi color number
      # technically it applies to the paired
      # 40's too but they're thes same color
      # and there's a different param to specify
      # foreground or background so we can just
      # add 10 if background
      1 => 30,
      2 => 31,
      3 => 32,
      4 => 33,
      5 => 34,
      6 => 35,
      7 => 36,
      0 => 37
    }
    BASIC_FOREGROUND_COLOR_LOOKUP={
      # foregrounds
      30 => "dimgray",
      31 => "red",
      32 => "lime",
      33 => "yellow",
      34 => "#3333FF",
      35 => "fuchsia",
      36 => "aqua",
      37 => "white"
    }

    FOREGROUND_COLOR_INTS=\
      BASIC_FOREGROUND_COLOR_LOOKUP.keys


    getter foreground_color
    getter background_color
    getter string
    getter styles

    @foreground_color : String?
    @background_color : String?
    @elements         : Array(Int32?)
    @styles           : Array(Int32)

    def initialize(@string : String, @options : Hash(Symbol, String))
      if @string.includes?(";")
        raise InvalidEscapeCode.new("T.426 escape sequences can't contain semicolons")
      end
      if @string.size < 6
        raise InvalidEscapeCode.new("T.416 escape sequences must be >= 6 chars: #{@string} is not")
      end
      @elements=@string[1..-2].split(":").map{|e| e == "" ? nil : e.to_i}
      if @elements.size < 2
        raise InvalidEscapeCode.new("not enough T.416 parameters")
      end
      @background_color = extract_background_color(@elements)
      @foreground_color = extract_foreground_color(@elements)
      @styles = [] of Int32
      # T.416 only supports styling in SBR
      # which thisdoesn't currently support
    end

    def affects_display?() : Bool
      true
    end
    # we take in the last escap_code
    # in part to know we have to end the prior code
    # and in part to know what needs to be continued
    # if it is ended.
    # if we we to simply nest them and tack a pile of
    # end spans at the end of the document we'd
    # give the headaches to the  browser and anyone
    # reading the source. Headaches are bad.
    def to_span(escape_code : EscapeCode?) : String
      span = String.build do |str|
        if ! escape_code.nil? && escape_code.as(EscapeCode).affects_display?
          str << "</span>"
        end
        str << "<span style=\""
        if ! is_transparency_style?
          str << generate_background_string(escape_code)
          str << generate_foreground_string(escape_code)
        else
          str << generate_transparent_color_string(@elements, @options)
        end
        str << "\">"
      end
      span
    end

    # TODO refactor this into EscapeCode
    def generate_background_string(escape_code : EscapeCode?) : String
      bcs = background_color.to_s
      if bcs != ""
        return "background-color: #{bcs}; "
      elsif !escape_code.nil?
        if ! is_background_zero_style?
          ec = escape_code.as(EscapeCode)
          if ec.background_color.to_s != ""
            return "background-color: #{ec.background_color}; "
          end
        end
      end
      ""
    end

    private def generate_foreground_string(escape_code : EscapeCode?) : String
      fcs = foreground_color.to_s
      if fcs != ""
        return "color: #{fcs}; "
      elsif ! escape_code.nil?
        if ! is_foreground_zero_style?
          ec = escape_code.as(EscapeCode)
          if ec.foreground_color.to_s != ""
            return "color: #{ec.foreground_color}; "
          end
        end
      end
      ""
    end
    private def is_transparency_style?() : Bool
      # we're guaranteed to have at least 2 elements in array
      # via the initialize method
      @elements[1] == 1
    end
    private def is_foreground_zero_style?() : Bool
      # we're guaranteed to have at least 2 elements in array
      # via the initialize method
      @elements[0] == 38 && @elements[1] == 0
    end
    private def is_background_zero_style?() : Bool
      raise InvalidEscapeCode.new("must contain at least 2 elements") if @elements.size < 2
      @elements[0] == 48 && @elements[1] == 0
    end

    private def get_css_for_rgb(r : Int32, g : Int32, b : Int32) : String
      "rgb(#{r},#{g},#{b})"
    end

    private def extract_foreground_color(elements : Array(Int32?)) : String
      return "" if elements[0] != 38
      extract_color(elements)
    end
    private def extract_background_color(elements : Array(Int32?)) : String
      return "" if elements[0] != 48
      extract_color(elements)
    end
    private def extract_color(elements : Array(Int32?)) : String
      color_string = ""
      # if [1] is 2-5 then [2] is color space id
      # TODO confirm array size is big enough to match expectations
      # we have to handle transparent [1] == 1 separately
      if elements[1] == 2 # rgb
        color_string = extract_rgb_color(elements)
      elsif elements[1] == 3 # cmy
        color_string = extract_cmy_color(elements)
      elsif elements[1] == 4 # cmyk
        color_string = extract_cmyk_color(elements)
      elsif elements[1] == 5 # lookup
        color_string = extract_lookup_color(elements)
      else
        if elements[1] != 0 && elements[1] != 1
          raise InvalidEscapeCode.new("2nd element of #{@string} must be 0-5")
        end
      end
      # it's technically possible we got here without
      # hitting any of those, but what then? raise exception?
      # saying what?
      color_string
    end

    private def generate_transparent_color_string(elements : Array(Int32?), options : Hash(Symbol, String)) : String
      # normally options contains a foreground color
      # and background color
      # we're going to set the foreground to equal the background
      # this technique will maintain the sizing
      choices = {
        :background_color => "white",
        :foreground_color => "black"
      }.merge(options)
      if elements[0] == 38
        "color: #{choices[:background_color]}; background-color: #{choices[:background_color]}; "
      elsif elements[0] == 48
        "color: #{choices[:foreground_color]}; background-color: #{choices[:foreground_color]}; "
      else
        ""
      end
      # specifying the background color is redundant BUT
      # I figure better safe than sorry
    end

    private def extract_rgb_color(elements : Array(Int32?)) : String
      raise InvalidEscapeCode.new("not enough parameters") if elements.size < 6
      begin
        r,g,b = [elements[3], elements[4], elements[5]].compact.map{|x|x.as(Int32)}

        return get_css_for_rgb(r,g,b)
      rescue IndexError
        # happens if r,g,b assignment fails
        raise InvalidEscapeCode.new("red, green, and blue must all be specified")
      end
    end

    private def extract_cmy_color(elements : Array(Int32?)) : String
      raise InvalidEscapeCode.new("not enough parameters") if elements.size < 6
      raw_cmy = [
                 elements[3],
                 elements[4],
                 elements[5]
                ]

      raise InvalidEscapeCode.new("c, m, and y must be specified") if raw_cmy.any?{|x| x.nil? || x.as(Int32) > 100}

      begin
        c,m,y = raw_cmy.map{|x|x.as(Int32)}
        r,g,b = convert_cmy_to_rgb(c,m,y)
        return get_css_for_rgb(r,g,b)
      rescue IndexError
        # happens if c,m,y assignment fails
        raise InvalidEscapeCode.new("cyan, magenta, and yellow must all be specified")
      end
    end

    private def extract_cmyk_color(elements : Array(Int32?)) : String
      raise InvalidEscapeCode.new("not enough parameters") if elements.size < 7
      raw_cmyk = [
                 elements[3],
                 elements[4],
                 elements[5],
                 elements[6]
                ]

      raise InvalidEscapeCode.new("c, m, y and k must be specified") if raw_cmyk.any?{|x| x.nil? || x.as(Int32) > 100}
      begin
        c,m,y,k = raw_cmyk.map{|x|x.as(Int32)}
        r,g,b = convert_cmyk_to_rgb(c,m,y,k)
        return get_css_for_rgb(r,g,b)
      rescue IndexError
        # happens if c,m,y,k assignment fails
        raise InvalidEscapeCode.new("cyan, magenta, yellow, and black must all be specified")
      end
    end

    private def extract_lookup_color(elements : Array(Int32?)) : String
      raise InvalidEscapeCode.new("not enough parameters") if elements.size < 3
      raise InvalidEscapeCode.new("colour table index not specified") if elements[2].nil?
      idx = elements[2].as(Int32)
      if ! CONTENT_COLOR_TABLE_LOOKUP.has_key? idx
        raise InvalidEscapeCode.new("invalid colour table index")
        # spec has British spelling.
      end
      return BASIC_FOREGROUND_COLOR_LOOKUP[
                CONTENT_COLOR_TABLE_LOOKUP[
                  idx
                ]
             ]
    end

    # The CMY color space is subtractive. Therefore, white is at (0.0, 0.0, 0.0)
    # and black is at (1.0, 1.0, 1.0). If you start with white and subtract no
    # colors, you get white. If you start with white and subtract all colors
    # equally, you get black.
    #
    # The CMYK color space is a variation on the CMY model. It adds black (Cyan,
    # Magenta, Yellow, and blacK). The CMYK color space closes the gap between
    # theory and practice. In theory, the extra black component is not needed.
    # However, experience with various types of inks and papers has shown that
    # when equal components of cyan, magenta, and yellow inks are mixed, the
    # result is usually a dark brown, not black. Adding black ink to the mix
    # solves this problem.
    #
    # The CMY and CMYK colors spaces can be device independent, but most often
    # they are used in reference to a specific device.
    # from https://msdn.microsoft.com/en-us/library/windows/desktop/dd371926(v=vs.85).aspx
    private def convert_cmyk_to_rgb(cyan    : Int32,
                            magenta : Int32,
                            yellow  : Int32,
                            black   : Int32) : Tuple(Int32,
                                                     Int32,
                                                     Int32)
        cyan    = cyan    * 0.01 if cyan    > 1
        magenta = magenta * 0.01 if magenta > 1
        yellow  = yellow  * 0.01 if yellow  > 1
        black   = black   * 0.01 if black   > 1

        red   = 255 * ( 1 - cyan )    * ( 1 - black  )
        green = 255 * ( 1 - magenta ) * ( 1 - black )
        blue  = 255 * ( 1 - yellow )  * ( 1 - black )
        {red.round(0).to_i, green.round(0).to_i, blue.round(0).to_i}
    end

    def convert_cmy_to_rgb(cyan    : Int32,
                           magenta : Int32,
                           yellow  : Int32) : Tuple(Int32,
                                                    Int32,
                                                    Int32)
      cyan    = cyan    * 0.01 if cyan > 1
      magenta = magenta * 0.01 if magenta > 1
      yellow  = yellow  * 0.01 if yellow > 1
      red   = (1 - cyan)    * 255.0
      green = (1 - magenta) * 255.0
      blue  = (1 - yellow)  * 255.0
      {red.round(0).to_i, green.round(0).to_i, blue.round(0).to_i}

    end



  end

end
