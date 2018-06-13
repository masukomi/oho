module Oho
  class InvalidEscapeCode < Exception

  end
  abstract class EscapeCode

    abstract def initialize(@string : String, @options : Hash(Symbol, String))
    abstract def affects_display?() : Bool
    abstract def to_span(escape_code : EscapeCode?) : String
    abstract def styles() : Array(Int32)
  end
end
