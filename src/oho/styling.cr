module Oho
  class Styling
    property old_foreground_color
    property foreground_color
    property background_color
    property old_background_color
    property underline
    property old_underline
    property old_bold
    property bold
    property old_blink
    property blink
    property negative
    property special_char
    property line_break

    def initialize()
      @old_foreground_color = Int8.new(-1)
      @foreground_color     = Int8.new(-1)
      @background_color     = Int8.new(-1)
      @old_background_color = Int8.new(-1)
      @old_underline        = Int8.new(0)
      @underline            = Int8.new(0)
      @old_bold             = Int8.new(0)
      @bold                 = Int8.new(0)
      @old_blink            = Int8.new(0)
      @blink                = Int8.new(0)
      @negative             = Int8.new(0)
      @special_char         = false
      @line_break           = false

    end

    def changed?() : Bool
      (@foreground_color     != @old_foreground_color) ||
      (@old_background_color != @old_background_color) ||
      (@underline            != old_underline) ||
      (@bold                 != @old_bold) ||
      (@blink                != @old_blink)
    end
    def time_to_start_span?() : Bool
      (@foreground_color     !=-1) ||
      (@old_background_color !=-1) ||
      (@underline            !=0) ||
      (@bold                 !=0) ||
      (@blink                !=0)
    end
    def time_to_end_span?() : Bool
      (@old_foreground_color !=-1) ||
      (@old_background_color !=-1) ||
      (old_underline         !=0) ||
      (@old_bold             !=0) ||
      (@old_blink            !=0)
    end

    def zero_out
      @bold                 = Int8.new(0)
      @underline            = Int8.new(0)
      @blink                = Int8.new(0)
      negative              = Int8.new(0)
      special_char          = false
      @foreground_color     = Int8.new(-1)
      @old_background_color = Int8.new(-1)
    end
    def reset_inverted
      @old_background_color = Int8.new(8) if @old_background_color == -1
      @foreground_color     = Int8.new(9) if @foreground_color     == -1
      temp                  = @old_background_color
      @old_background_color = @foreground_color
      @foreground_color     = temp
      negative              = Int8.new(0)
    end
    def seven_x_dance
      @old_background_color = Int8.new(8) if @old_background_color == -1
      @foreground_color     = Int8.new(9) if @foreground_color     == -1
      temp                  = @old_background_color
      @old_background_color = @foreground_color
      @foreground_color     = temp
      @negative             = Int8.new(1) - @negative
    end
    def save_old_values
      @old_foreground_color = @foreground_color
      @old_background_color = @background_color
      old_underline         = @underline
      @old_bold             = @bold
      @old_blink            = @blink
    end
  end
end
