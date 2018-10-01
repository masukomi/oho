require "../spec_helper"

describe Oho::Converter do
  # TODO: Write tests
  default_options = {:background_color => "white",
                     :foreground_color => "black"}
  it "creates inline styles" do
    c = Oho::Converter.new(default_options)
    # STDERR.puts("\\033[31mhi\\033[0m")
    test_string = "\033[31mhi\033[0m"
    response, escape_code = c.process(test_string, nil)
    # c.process(test_string).should(eq("<span class=\"red\">hi</span>"))
    response.should(eq("<span style=\"color: red; \">hi</span>"))

  end

  it "handles escape codes that terminate on subsequent lines" do
    c = Oho::Converter.new(default_options)
    test_string = "\033[36mfoo\nbar\033[0m baz"
    response, escape_code = c.process(test_string, nil)
    response.should(eq("<span style=\"color: aqua; \">foo\n<br />bar</span><span style=\"\"> baz</span>"))
  end
  describe "#extract_next_escape_code" do
    # there are too damn many options to do a unit test for each one
    # looping over grouped arrays of them to make sure all are tested
    c = Oho::Converter.new(default_options)
    it "returns ColorEscapeCode for styling codes" do
      char = '['
      Oho::ColorEscapeCode::FORMATTING_SEQ_INTS.each do |int|
        str = "[#{int}m"
        reader = Char::Reader.new(str)
        code, ignore = c.extract_next_escape_code(char,
                                   reader)
        code.class.should(eq(Oho::ColorEscapeCode))
      end
    end
    it "stops at end of escape code" do
      # test_string = "\033[31mhi\033[0m"
      reader = Char::Reader.new("[31mhi\033[0m")
      code, reader = c.extract_next_escape_code('[', reader)
      reader.has_next?().should(eq(true))
      reader.next_char.should(eq('h'))
      code.as(Oho::EscapeCode).to_span(nil).should(eq("<span style=\"color: red; \">"))

    end
    it "returs ColorEscapeCode for color codes" do
      seqs = [
       "[m", # same as 0n
       "[0m",# reset styling and colors
       "[30m", # standard colors
       "[0;30m", # reset + standard colors
       "[38;5;190m", # 8 bit colors
       "[0;38;5;190m", # reset + 8 bit colors
       "[38;2;111;222;123m", # rgb
       "[0;38;2;11;22;123m"] # reset + rgb
      seqs.each do | seq |
        reader = Char::Reader.new(seq)
        code, ignore = c.extract_next_escape_code('[',
                                   reader)
        code.class.should(eq(Oho::ColorEscapeCode))
      end
    end
    # The ITU's T.416 Information technology -
    # Open Document Architecture (ODA) and interchange format:
    # Character content architectures[20] uses ':' as separator
    # and has multiple color spaces and and and
    it "handles T.416 / ISO-8613-3 / ISO-8613-6" do
      # all of the following sequences would start with 48 if
      # indicative of a background color
      # this doesn't account for SGR
      seqs = [ # no standard colors
       "[38:5:0m", # last is index of color in lookup table
       "[38:5:0::::::m", # pathological case
       "[38:2:0:111:222:123m", # simple rgb
       "[38:2:0:111:222:123:::m", # pathological rgb
       "[38:2:0:111:222:123::50:0m",
       # with tolerance and color space for tolerance
       "[38:3:0:0:50:100m", # cmy
       "[38:3:0:0:50:100:::m", # pathological cmy
       "[38:3:0:0:50:100::50:1m",
       # with tolerance and color space for tolerance
       "[38:4:0:0:50:100:25m", # cmyk
       "[38:4:0:0:50:100:25::m", # pathological cmyk
       "[38:4:0:0:50:100:25:50:1m"
       # with tolerance and color space for tolerance
      ]
      seqs.each do | seq |
        reader = Char::Reader.new(seq)
        code, ignore = c.extract_next_escape_code('[',
                                   reader)
        code.class.should(eq(Oho::T416ColorEscapeCode))
      end
    end

    it "handles other square bracket codes" do
      seqs = ["[H", "[f", "[1A", "[1B", "[1C", "[1D",
              "[s", "[u", "[2j", "[K", "[=1h", "[=1l",
              "[65;81p", "[20h", "[?1h", "[?3h", "[?4h",
              "[5h", "[?6h", "[?7h", "[?8h", "[?9h", "[20l",
              "[?1l", "[?2l", "[?3l", "[?4l", "[?5l", "[?6l",
              "[?7l", "[?8l", "[?9l" ]

      seqs.each do | seq |
        reader = Char::Reader.new(seq)
        code, ignore = c.extract_next_escape_code('[',
                                   reader)
        code.class.should(eq(Oho::NonDisplayEscapeCode))
      end
    end
    it "handles parethetical escape codes" do
      ["A", "B", "0", "1"].map{|x| ")#{x}"}.each do |seq|
        reader = Char::Reader.new(seq)
        code, ignore = c.extract_next_escape_code(')',
                                   reader)
        code.class.should(eq(Oho::NonDisplayEscapeCode))

      end
      ["A", "B", "0", "1"].map{|x| "(#{x}"}.each do |seq|
        reader = Char::Reader.new(seq)
        code, ignore = c.extract_next_escape_code('(',
                                   reader)
        code.class.should(eq(Oho::NonDisplayEscapeCode))

      end
    end
    it "handles single char escape codes" do
      "=>NO".each_char do |char|
        reader = Char::Reader.new(char.to_s)
        code, ignore = c.extract_next_escape_code(char,
                                   reader)
        code.class.should(eq(Oho::NonDisplayEscapeCode))

      end

    end
  end
end

