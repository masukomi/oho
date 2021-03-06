module Oho
  class NonDisplayEscapeCode < EscapeCode
    getter foreground_color
    getter background_color
    getter string
    getter styles : Array(Int32)

    @styles : Array(Int32)
    @foreground_color : String?
    @background_color : String?
    def initialize(@string : String, @options : Hash(Symbol, String))
      # that's nice
      @styles = [] of Int32
      @foreground_color =nil
      @background_color =nil
    end
    def affects_display?() : Bool
      false
    end
    def to_span(escape_code : EscapeCode?) : String
      ""
    end
    def raw : String
      @string
    end
  end
end
