require "../spec_helper"

describe Oho::T416ColorCode do
  default_options = {:background_color => "white",
                     :foreground_color => "black"}
  describe "resets" do
    it "should have no colors" do
      codes = [
        "[38:0m",
        "[38:0:::::::m",
        "[38:1m",
        "[38:1:::::::m"]
      codes.each do | code |
        ec = Oho::T416ColorCode.new(code, default_options)
        ec.background_color.should(eq(""))
        ec.foreground_color.should(eq(""))
      end
    end
  end
  describe "rgb colors" do
    it "should extract rgb background color" do
      codes =["[48:2:0:111:222:123m", # simple rgb
       "[48:2:0:111:222:123::m", # pathological rgb
       "[48:2:0:111:222:123::50:0m"]
      codes.each do | code |
        ec = Oho::T416ColorCode.new(code, default_options)
        ec.background_color.should(eq("rgb(111,222,123)"))
      end
    end
    it "should extract rgb foreground color" do
      codes =["[38:2:0:111:222:123m", # simple rgb
       "[38:2:0:111:222:123:::m", # pathological rgb
       "[38:2:0:111:222:123::50:0m"]
      codes.each do | code |
        ec = Oho::T416ColorCode.new(code, default_options)
        ec.foreground_color.should(eq("rgb(111,222,123)"))
      end
    end
  end
  describe "cmy colors" do
    it "should extract cmy background color" do
      codes =["[48:3:0:10:20:40m", # simple cmy
              "[48:3:0:10:20:40::m", # pathological cmy
              "[48:3:0:10:20:40::50:0m"]
      codes.each do | code |
        ec = Oho::T416ColorCode.new(code, default_options)
        ec.background_color.should(eq("rgb(230,204,153)"))
      end
    end
    it "should extract cmy foreground color" do
      codes =["[38:3:0:10:20:40m", # simple cmy
              "[38:3:0:10:20:40::m", # pathological cmy
              "[38:3:0:10:20:40::50:0m"]
      codes.each do | code |
        ec = Oho::T416ColorCode.new(code, default_options)
        ec.foreground_color.should(eq("rgb(230,204,153)"))
      end
    end
  end
  describe "cmyk colors" do
    it "should extract cmyk foreground color" do
      codes =["[38:4:0:33:10:43:6m", # simple cmyk
              "[38:4:0:33:10:43:6:m", # pathological cmyk
              "[38:4:0:33:10:43:6:50:0m"]
      codes.each do | code |
        ec = Oho::T416ColorCode.new(code, default_options)
        ec.foreground_color.should(eq("rgb(161,216,137)"))
      end
    end
    it "should extract cmyk background color" do
      codes =["[48:4:0:33:10:43:6m", # simple cmyk
              "[48:4:0:33:10:43:6:m", # pathological cmyk
              "[48:4:0:33:10:43:6:50:0m"]
      codes.each do | code |
        ec = Oho::T416ColorCode.new(code, default_options)
        ec.background_color.should(eq("rgb(161,216,137)"))
      end
    end
  end
  describe "indexed colors" do
    it "should extract indexed background color" do
      codes =["[48:5:2m", # simple indexed
              "[48:5:2::::::m" # pathological indexed
             ]
      codes.each do | code |
        ec = Oho::T416ColorCode.new(code, default_options)
        ec.background_color.should(eq("red"))
      end
    end
    it "should extract indexed foreground color" do
      codes =["[38:5:2m", # simple indexed
              "[38:5:2::::::m" # pathological indexed
             ]

      codes.each do | code |
        ec = Oho::T416ColorCode.new(code, default_options)
        ec.foreground_color.should(eq("red"))
      end
    end
  end
  describe "span tests" do
    # not being completely thorough here because
    # above we have already proven that each of the types
    # of colors are handled correctly in foreground and background
    # the question here is, regardless of type, is it output
    # correctly
    it "outputs foreground colors correctly" do
      ec = Oho::T416ColorCode.new("[38:5:3m", default_options)
      ec.to_span(nil).should(eq( "<span style=\"color: lime; \">"))
    end
    it "outputs background colors correctly" do
      ec = Oho::T416ColorCode.new("[48:5:3m", default_options)
      ec.to_span(nil).should(eq( "<span style=\"background-color: lime; \">"))

    end
    it "outputs foregorund resets correctly" do
      prior_ec = Oho::ColorEscapeCode.new("[32m", default_options)
      ec = Oho::T416ColorCode.new("[38:0m", default_options)
      ec.to_span(prior_ec).should(eq( "</span><span style=\"\">"))
    end
    it "retains background color on foreground reset" do
      prior_ec = Oho::ColorEscapeCode.new("[42m", default_options)
      ec = Oho::T416ColorCode.new("[38:0m", default_options)
      ec.to_span(prior_ec).should(eq( "</span><span style=\"background-color: lime; \">"))
    end
    it "outputs background resets correctly" do
      prior_ec = Oho::ColorEscapeCode.new("[42m", default_options)
      ec = Oho::T416ColorCode.new("[48:0m", default_options)
      ec.to_span(prior_ec).should(eq( "</span><span style=\"\">"))

    end
    it "retains foreground color on background reset" do
      prior_ec = Oho::ColorEscapeCode.new("[32m", default_options)
      ec = Oho::T416ColorCode.new("[48:0m", default_options)
      ec.to_span(prior_ec).should(eq( "</span><span style=\"color: lime; \">"))
    end
    it "outputs transparents foreground correctly" do
      # make the foreground the same color as background
      ec = Oho::T416ColorCode.new("[38:1m", default_options)
      ec.to_span(nil).should(eq( "<span style=\"color: white; background-color: white; \">"))
    end
    it "outputs transparents background correctly" do
      # make the background the same color as foreground
      # this is ... just a weird request. I'm not sure what a "correct"
      # interpretation of a transparent background is.
      ec = Oho::T416ColorCode.new("[48:1m", default_options)
      ec.to_span(nil).should(eq( "<span style=\"color: black; background-color: black; \">"))
    end
  end

end
