module Chaha
  # Note: this is only concerned with escape codes
  # related to text formatting
  class EscapeCode

    BASIC_FOREGROUND_COLOR_LOOKUP={
      # foregrounds
      30 => "dimgray",
      31 => "red",
      32 => "lime",
      33 => "yellow",
      34 => "#3333FF",
      35 => "fuchsia",
      36 => "aqua",
      37 => "white",
      39 => "initial" # default color
    }
    BASIC_BACKGROUND_COLOR_LOOKUP={
      # backgrounds
      40 => "dimgray",
      41 => "red",
      42 => "lime",
      43 => "yellow",
      44 => "#3333FF",
      45 => "fuchsia",
      46 => "aqua",
      47 => "white",
      49 => "initial", # default background color
    }
    HIGH_INTENSITY_FOREGROUND_COLOR_LOOKUP = {
      90 => "#000000",
      91 => "#AA0000",
      92 => "#00AA00",
      93 => "#AA5500",
      94 => "#0000AA",
      95 => "#AA00AA",
      96 => "#00AAAA",
      97 => "#AAAAAA"
    }
    HIGH_INTENSITY_BACKGROUND_COLOR_LOOKUP = {
      100 => "#000000",
      101 => "#AA0000",
      102 => "#00AA00",
      103 => "#AA5500",
      104 => "#0000AA",
      105 => "#AA00AA",
      106 => "#00AAAA",
      107 => "#AAAAAA"
    }

    FOREGROUND_COLOR_INTS=\
      BASIC_FOREGROUND_COLOR_LOOKUP.keys \
      + HIGH_INTENSITY_FOREGROUND_COLOR_LOOKUP.keys

    BACKGROUND_COLOR_INTS=\
      BASIC_BACKGROUND_COLOR_LOOKUP.keys \
      + HIGH_INTENSITY_BACKGROUND_COLOR_LOOKUP.keys

    SIMPLE_COLOR_LOOKUP =\
      BASIC_FOREGROUND_COLOR_LOOKUP.merge(
      HIGH_INTENSITY_FOREGROUND_COLOR_LOOKUP).merge(
      BASIC_BACKGROUND_COLOR_LOOKUP).merge(
      HIGH_INTENSITY_BACKGROUND_COLOR_LOOKUP)

    EIGHT_BIT_LOOKUP={
      # Primary 3-bit (8 colors). Unique representation!
      "0"  => "#000000",
      "1"  => "#800000",
      "2"  => "#008000",
      "3"  => "#808000",
      "4"  => "#000080",
      "5"  => "#800080",
      "6"  => "#008080",
      "7"  => "#c0c0c0",

      # Equivalent "bright" versions of original 8 colors.
      "8"  => "#808080",
      "9"  => "#ff0000",
      "10" => "#00ff00",
      "11" => "#ffff00",
      "12" => "#0000ff",
      "13" => "#ff00ff",
      "14" => "#00ffff",
      "15" => "#ffffff",

      # Strictly ascending.
      "16"  => "#000000",
      "17"  => "#00005f",
      "18"  => "#000087",
      "19"  => "#0000af",
      "20"  => "#0000d7",
      "21"  => "#0000ff",
      "22"  => "#005f00",
      "23"  => "#005f5f",
      "24"  => "#005f87",
      "25"  => "#005faf",
      "26"  => "#005fd7",
      "27"  => "#005fff",
      "28"  => "#008700",
      "29"  => "#00875f",
      "30"  => "#008787",
      "31"  => "#0087af",
      "32"  => "#0087d7",
      "33"  => "#0087ff",
      "34"  => "#00af00",
      "35"  => "#00af5f",
      "36"  => "#00af87",
      "37"  => "#00afaf",
      "38"  => "#00afd7",
      "39"  => "#00afff",
      "40"  => "#00d700",
      "41"  => "#00d75f",
      "42"  => "#00d787",
      "43"  => "#00d7af",
      "44"  => "#00d7d7",
      "45"  => "#00d7ff",
      "46"  => "#00ff00",
      "47"  => "#00ff5f",
      "48"  => "#00ff87",
      "49"  => "#00ffaf",
      "50"  => "#00ffd7",
      "51"  => "#00ffff",
      "52"  => "#5f0000",
      "53"  => "#5f005f",
      "54"  => "#5f0087",
      "55"  => "#5f00af",
      "56"  => "#5f00d7",
      "57"  => "#5f00ff",
      "58"  => "#5f5f00",
      "59"  => "#5f5f5f",
      "60"  => "#5f5f87",
      "61"  => "#5f5faf",
      "62"  => "#5f5fd7",
      "63"  => "#5f5fff",
      "64"  => "#5f8700",
      "65"  => "#5f875f",
      "66"  => "#5f8787",
      "67"  => "#5f87af",
      "68"  => "#5f87d7",
      "69"  => "#5f87ff",
      "70"  => "#5faf00",
      "71"  => "#5faf5f",
      "72"  => "#5faf87",
      "73"  => "#5fafaf",
      "74"  => "#5fafd7",
      "75"  => "#5fafff",
      "76"  => "#5fd700",
      "77"  => "#5fd75f",
      "78"  => "#5fd787",
      "79"  => "#5fd7af",
      "80"  => "#5fd7d7",
      "81"  => "#5fd7ff",
      "82"  => "#5fff00",
      "83"  => "#5fff5f",
      "84"  => "#5fff87",
      "85"  => "#5fffaf",
      "86"  => "#5fffd7",
      "87"  => "#5fffff",
      "88"  => "#870000",
      "89"  => "#87005f",
      "90"  => "#870087",
      "91"  => "#8700af",
      "92"  => "#8700d7",
      "93"  => "#8700ff",
      "94"  => "#875f00",
      "95"  => "#875f5f",
      "96"  => "#875f87",
      "97"  => "#875faf",
      "98"  => "#875fd7",
      "99"  => "#875fff",
      "100" => "#878700",
      "101" => "#87875f",
      "102" => "#878787",
      "103" => "#8787af",
      "104" => "#8787d7",
      "105" => "#8787ff",
      "106" => "#87af00",
      "107" => "#87af5f",
      "108" => "#87af87",
      "109" => "#87afaf",
      "110" => "#87afd7",
      "111" => "#87afff",
      "112" => "#87d700",
      "113" => "#87d75f",
      "114" => "#87d787",
      "115" => "#87d7af",
      "116" => "#87d7d7",
      "117" => "#87d7ff",
      "118" => "#87ff00",
      "119" => "#87ff5f",
      "120" => "#87ff87",
      "121" => "#87ffaf",
      "122" => "#87ffd7",
      "123" => "#87ffff",
      "124" => "#af0000",
      "125" => "#af005f",
      "126" => "#af0087",
      "127" => "#af00af",
      "128" => "#af00d7",
      "129" => "#af00ff",
      "130" => "#af5f00",
      "131" => "#af5f5f",
      "132" => "#af5f87",
      "133" => "#af5faf",
      "134" => "#af5fd7",
      "135" => "#af5fff",
      "136" => "#af8700",
      "137" => "#af875f",
      "138" => "#af8787",
      "139" => "#af87af",
      "140" => "#af87d7",
      "141" => "#af87ff",
      "142" => "#afaf00",
      "143" => "#afaf5f",
      "144" => "#afaf87",
      "145" => "#afafaf",
      "146" => "#afafd7",
      "147" => "#afafff",
      "148" => "#afd700",
      "149" => "#afd75f",
      "150" => "#afd787",
      "151" => "#afd7af",
      "152" => "#afd7d7",
      "153" => "#afd7ff",
      "154" => "#afff00",
      "155" => "#afff5f",
      "156" => "#afff87",
      "157" => "#afffaf",
      "158" => "#afffd7",
      "159" => "#afffff",
      "160" => "#d70000",
      "161" => "#d7005f",
      "162" => "#d70087",
      "163" => "#d700af",
      "164" => "#d700d7",
      "165" => "#d700ff",
      "166" => "#d75f00",
      "167" => "#d75f5f",
      "168" => "#d75f87",
      "169" => "#d75faf",
      "170" => "#d75fd7",
      "171" => "#d75fff",
      "172" => "#d78700",
      "173" => "#d7875f",
      "174" => "#d78787",
      "175" => "#d787af",
      "176" => "#d787d7",
      "177" => "#d787ff",
      "178" => "#d7af00",
      "179" => "#d7af5f",
      "180" => "#d7af87",
      "181" => "#d7afaf",
      "182" => "#d7afd7",
      "183" => "#d7afff",
      "184" => "#d7d700",
      "185" => "#d7d75f",
      "186" => "#d7d787",
      "187" => "#d7d7af",
      "188" => "#d7d7d7",
      "189" => "#d7d7ff",
      "190" => "#d7ff00",
      "191" => "#d7ff5f",
      "192" => "#d7ff87",
      "193" => "#d7ffaf",
      "194" => "#d7ffd7",
      "195" => "#d7ffff",
      "196" => "#ff0000",
      "197" => "#ff005f",
      "198" => "#ff0087",
      "199" => "#ff00af",
      "200" => "#ff00d7",
      "201" => "#ff00ff",
      "202" => "#ff5f00",
      "203" => "#ff5f5f",
      "204" => "#ff5f87",
      "205" => "#ff5faf",
      "206" => "#ff5fd7",
      "207" => "#ff5fff",
      "208" => "#ff8700",
      "209" => "#ff875f",
      "210" => "#ff8787",
      "211" => "#ff87af",
      "212" => "#ff87d7",
      "213" => "#ff87ff",
      "214" => "#ffaf00",
      "215" => "#ffaf5f",
      "216" => "#ffaf87",
      "217" => "#ffafaf",
      "218" => "#ffafd7",
      "219" => "#ffafff",
      "220" => "#ffd700",
      "221" => "#ffd75f",
      "222" => "#ffd787",
      "223" => "#ffd7af",
      "224" => "#ffd7d7",
      "225" => "#ffd7ff",
      "226" => "#ffff00",
      "227" => "#ffff5f",
      "228" => "#ffff87",
      "229" => "#ffffaf",
      "230" => "#ffffd7",
      "231" => "#ffffff",

      # Gray-scale range.
      "232" => "#080808",
      "233" => "#121212",
      "234" => "#1c1c1c",
      "235" => "#262626",
      "236" => "#303030",
      "237" => "#3a3a3a",
      "238" => "#444444",
      "239" => "#4e4e4e",
      "240" => "#585858",
      "241" => "#626262",
      "242" => "#6c6c6c",
      "243" => "#767676",
      "244" => "#808080",
      "245" => "#8a8a8a",
      "246" => "#949494",
      "247" => "#9e9e9e",
      "248" => "#a8a8a8",
      "249" => "#b2b2b2",
      "250" => "#bcbcbc",
      "251" => "#c6c6c6",
      "252" => "#d0d0d0",
      "253" => "#dadada",
      "254" => "#e4e4e4",
      "255" => "#eeeeee"
    }
    RESET_SEQ_INTS=[
      0,  # reset all
      21, # reset bold/bright
      22, # reset dim
      23, # reset italic
      24, # reset underlined
      25, # reset blink
      27, # reset reverse
      28  # reset hidden
    ]

    FORMATTING_SEQ_INTS=[
      1, # bold / bright
      2, # dim
      3, # italic
      4, # underlined
      5, # blink
      7, # reverse foreground and background
      8, # hidden
    ] + RESET_SEQ_INTS

    FORMATTING_EFFECT_LOOKUP = {
      # int => what it effects
      0  => [:bold, :dim, :underline, :blink, :reverse, :hidden], # reset
      1  => [:bold],
      2  => [:dim],
      3  => [:italic],
      4  => [:underlined],
      5  => [:blink],
      7  => [:reverse],
      8  => [:hidden],
      21 => [:bold],      # reset
      22 => [:dim],       # reset
      24 => [:underline], # reset
      25 => [:blink],     # reset
      27 => [:reverse],   # reset
      28 => [:hidden]     # reset
    }
    getter foreground_color
    getter background_color
    getter styles

    @foreground_color : String?
    @background_color : String?
    @styles           : Array(Int32)

    def initialize(string)
      @styles = [] of Int32 # reset all
      if string == "[0m"
        #TODO FIXME
        # do something useful here
      else # not a reset
        if string.size < 3 || string[0] != '[' || string[-1] != 'm'
          raise "Invalid escape code: #{string.split("").inspect}"
        end
        @background_color = extract_background_color(string)
        @foreground_color = extract_foreground_color(string)
        @styles = extract_styling(string)
      end
    end

    def to_span() : String
      span = String.build do |str|
        str << "<span style=\""
        str << generate_background_string()
        str << generate_foreground_string()
        str << generate_styles_string(styles)
        str << "\">"
      end
    end

    private def generate_background_string() : String
        if ! background_color.nil? && background_color != ""
          "background-color: #{background_color}; "
        else
          ""
        end
    end
    private def generate_foreground_string() : String
      if ! foreground_color.nil? && foreground_color != ""
         "color: #{foreground_color}; "
      else
        ""
      end
    end
    private def generate_styles_string(styles : Array(Int32)) : String
      response = String.build do |str|
        styles.each do |style_int|
          effects = FORMATTING_EFFECT_LOOKUP[style_int]
          is_reset = RESET_SEQ_INTS.includes? style_int
          effects.each do |effect|
            if effect == :bold
              str << "font-weight: #{is_reset ? "normal" : "bold"}; "
            elsif effect == :italic
              str << "font-style: #{is_reset ? "normal" : "italic"}; "
            elsif effect == :underlined
              # not sure "normal" is a valid thing
              # here but not sure what else to do
              str << "text-decoration: #{is_reset ? "normal" : "underline"}; "
            elsif effect == :dim
              str << "opacity: #{is_reset ? "1.0" : "0.5"}; "
            # elsif effect == :reverse
              # unsupported
            # blink
              # unsupported in html
            # hidden
              str << "display: #{is_reset ? "inline" : "none;"}; "
            end
          end
        end
      end
      response
    end

    private def extract_ints(string) : Array(Int32)
      string.split(/\D+/).select{|x| x != ""}.map{|x| x.to_i}
    end

    private def extract_eight_bit_color(m : Regex::MatchData?) : String
      return "" if m.nil?
      string_num = m.as(Regex::MatchData)[1]
      if EIGHT_BIT_LOOKUP.has_key? string_num
        return EIGHT_BIT_LOOKUP[string_num]
      else
        #bad data, best we can do is ignore it
        return ""
      end
    end
    private def extract_rgb_color(m : Regex::MatchData?) : String
        return "" if m.nil?
        rgb = m.as(Regex::MatchData)
        "rgb(#{rgb[0]},#{rgb[1]},#{rgb[2]})"
    end

    private def extract_foreground_color(string : String) : String
      # 38;5;<num> => 8 bit foreground color
      m = string.match(/38;5;(\d+)/)
      return extract_eight_bit_color(m) if ! m.nil?

      m = string.match(/38;2;(\d+);(\d+);(\d+)/)
      return extract_rgb_color(m) if ! m.nil?
      ints = extract_ints(string)
      foreground_ints = FOREGROUND_COLOR_INTS & ints
      if foreground_ints.size > 0
        last = foreground_ints.last

        if ! last.nil? && last != 39
          return SIMPLE_COLOR_LOOKUP[last]
        elsif last == 39 && ! string.includes? "48;5;39"
          return SIMPLE_COLOR_LOOKUP[last]
        else
          # that's actually a background 8 bit lookup
          # which should have already been handled
          # so, in theory this can't happen
          return EIGHT_BIT_LOOKUP[last.to_s]
        end
      end
      ""
    end

    private def extract_background_color(string : String) : String
      # 48;5;<num> => 8 bit background color
      m = string.match(/48;5;(\d+)/)
      return extract_eight_bit_color(m) if ! m.nil?

      m = string.match(/38;2;(\d+);(\d+);(\d+)/)
      return extract_rgb_color(m) if ! m.nil?
      # who knows
      ints = string.split(/\D+/).select{|x| x != ""}.map{|x| x.to_i}
      background_ints = BACKGROUND_COLOR_INTS & ints
      if background_ints.size > 0
        last = background_ints.last
        if ! last.nil? && last != 49
          return SIMPLE_COLOR_LOOKUP[last]
        elsif last == 49 && ! string.includes? "38;5;49"
          return SIMPLE_COLOR_LOOKUP[last]
        # else
          # that's actually a foreground 8 bit lookup
        end
      end
      ""
    end


    private def extract_styling(string) : Array(Int32)
      ints = extract_ints(string)
      (FORMATTING_SEQ_INTS & ints)
    end
  end

end
