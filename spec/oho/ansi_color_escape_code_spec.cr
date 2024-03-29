require "../spec_helper"

describe Oho::AnsiColorEscapeCode do
  default_options = {:background_color => "white",
                     :foreground_color => "black"}
  it "should extract simple background color" do
   ec = Oho::AnsiColorEscapeCode.new("[44m", default_options)
   ec.background_color.should(eq("#3333FF"))
  end

  it "should extract high intensity background color" do
   ec = Oho::AnsiColorEscapeCode.new("[0;100m", default_options)
   ec.background_color.should(eq("#000000"))
  end

  it "should handle bold, italic, underline" do
   escape_code_string = "[1;3;4;33m" # the \033 or \e will be stripped before
   ec = Oho::AnsiColorEscapeCode.new(escape_code_string, default_options)
   ec.to_span(nil).should(eq(
     "<span style=\"font-weight: bold; font-style: italic; text-decoration: underline; color: yellow; \">"))
  end

  it "should continue foreground colors" do
    ec = Oho::AnsiColorEscapeCode.new("[33m", default_options) # foreground
    prior_ec = Oho::AnsiColorEscapeCode.new("[43m", default_options) #background
    ec.to_span(prior_ec).should(eq(
      "</span><span style=\"background-color: yellow; color: yellow; \">"))
  end

  it "should not continue superceeded foreground colors" do
    ec = Oho::AnsiColorEscapeCode.new("[36m", default_options) # foreground
    prior_ec = Oho::AnsiColorEscapeCode.new("[33m", default_options) #foreground
    ec.to_span(prior_ec).should(eq(
      "</span><span style=\"color: aqua; \">"))
  end

  it "should continue background colors" do
    ec = Oho::AnsiColorEscapeCode.new("[43m", default_options) #background
    prior_ec = Oho::AnsiColorEscapeCode.new("[33m", default_options) # foreground
    ec.to_span(prior_ec).should(eq(
      "</span><span style=\"background-color: yellow; color: yellow; \">"))
  end

  it "should not continue superceeded background colors" do
    ec = Oho::AnsiColorEscapeCode.new("[46m", default_options) #background
    prior_ec = Oho::AnsiColorEscapeCode.new("[43m", default_options) # background
    ec.to_span(prior_ec).should(eq(
      "</span><span style=\"background-color: aqua; \">"))
  end

  it "should continue styles" do
    ec = Oho::AnsiColorEscapeCode.new("[46m", default_options) #background
    prior_ec = Oho::AnsiColorEscapeCode.new("[1;2;3;4;5;8m", default_options) # background
    ec.to_span(prior_ec).should(eq(
      "</span><span style=\"font-weight: bold; opacity: 0.5; font-style: italic; text-decoration: underline; display: none; background-color: aqua; \">"))

  end

  it "should not continue superceeded styles" do
    ec = Oho::AnsiColorEscapeCode.new("[46m", default_options) #background
    prior_ec = Oho::AnsiColorEscapeCode.new("[1;2;3;4;8m", default_options) # background
    ec.to_span(prior_ec).should(eq(
      "</span><span style=\"font-weight: bold; opacity: 0.5; font-style: italic; text-decoration: underline; display: none; background-color: aqua; \">"))
  end

  it "should not blow up when it encounters private use codes" do
    ec = Oho::AnsiColorEscapeCode.new("[?1h", default_options) #background
    ec.to_span(nil).should(eq(""))
  end

  it "should not blow up when it encounters ? screen mode codes" do
    ec = Oho::AnsiColorEscapeCode.new("[?7h", default_options) #background
    ec.to_span(nil).should(eq(""))
  end

  it "should not blow up when it encounters = screen mode codes" do
    ec = Oho::AnsiColorEscapeCode.new("[=1;7h", default_options) #background
    ec.to_span(nil).should(eq(""))
  end

  it "should not blow up when it encounters = screen mode codes 2" do
    ec = Oho::AnsiColorEscapeCode.new("[=0h", default_options) #background
    ec.to_span(nil).should(eq(""))
  end

  it "should not blow up when it encounters ? screen mode reset codes" do
    ec = Oho::AnsiColorEscapeCode.new("[?7l", default_options) #background
    ec.to_span(nil).should(eq(""))
  end

  it "should not blow up when it encounters = screen mode reset codes" do
    ec = Oho::AnsiColorEscapeCode.new("[=1;7l", default_options) #background
    ec.to_span(nil).should(eq(""))
  end

  it "should not blow up when it encounters = screen mode reset codes 2" do
    ec = Oho::AnsiColorEscapeCode.new("[=0l", default_options) #background
    ec.to_span(nil).should(eq(""))
  end

  it "0 resets all" do
    ec = Oho::AnsiColorEscapeCode.new("[0m", default_options) #reset all the things
    prior_ec = Oho::AnsiColorEscapeCode.new("[1;2;3;4;8;36;46m", default_options)
    ec.to_span(prior_ec).should(eq( "</span><span style=\"\">"))
      # "</span><span style=\"background-color: initial; color: initial; font-weight: normal; opacity: 1.0; font-style: normal; text-decoration: none; display: inline; background-color: none; color: none; \">"))

  end

  it "0 resets all and can be trumped" do
    ec = Oho::AnsiColorEscapeCode.new("[0;46m", default_options) #reset all the things
    prior_ec = Oho::AnsiColorEscapeCode.new("[1;2;3;4;8m", default_options) # background
    ec.to_span(prior_ec).should(eq( "</span><span style=\"background-color: aqua; \">"))
      # "</span><span style=\"background-color: initial; color: initial; font-weight: normal; opacity: 1.0; font-style: normal; text-decoration: none; display: inline; background-color: aqua; \">"))

  end

  it "isn't expected to support blink or reverse" do
    ec = Oho::AnsiColorEscapeCode.new("[5;7;46m", default_options)
    ec.to_span(nil).should(eq("<span style=\"background-color: aqua; \">"))
  end

  it "should recognize high intensity foreground colors" do
   ec = Oho::AnsiColorEscapeCode.new("[0;90m", default_options)
   ec.foreground_color.should(eq("#000000"))
   ec.background_color.should(eq(""))
  end

  it "should recognize simple foreground colors" do
   ec = Oho::AnsiColorEscapeCode.new("[0;30m", default_options)
   ec.foreground_color.should(eq("dimgray"))
   ec.background_color.should(eq(""))
  end

  it "should know about default foreground color" do
   ec = Oho::AnsiColorEscapeCode.new("[39m", default_options)
   ec.foreground_color.should(eq("black"))
   ec.background_color.should(eq(""))
  end

  it "should handle provided background and foreground defaults" do
   ec = Oho::AnsiColorEscapeCode.new("[39m", {:background_color => "black",
                                     :foreground_color => "white"})
   # 39 is default foreground
   ec.foreground_color.should(eq("white"))
   ec.background_color.should(eq(""))

  end

  it "should know 256 color 39 isn't default foreground" do
   ec = Oho::AnsiColorEscapeCode.new("[38;5;39m", default_options)
   ec.foreground_color.should(eq("#00afff"))
   ec.background_color.should(eq(""))
  end

  it "should know about default background color" do
   ec = Oho::AnsiColorEscapeCode.new("[49m", default_options)
   ec.foreground_color.should(eq(""))
   ec.background_color.should(eq("white"))
  end

  it "should know 256 color 49 isn't default foreground" do
   ec = Oho::AnsiColorEscapeCode.new("[38;5;49m", default_options)
   ec.foreground_color.should(eq("#00ffaf"))
   ec.background_color.should(eq(""))
  end

  it "should recognize bold foreground colors" do
   ec = Oho::AnsiColorEscapeCode.new("[1;36m", default_options)
   ec.styles.should(eq([1]))
   ec.foreground_color.should(eq("aqua"))
   ec.background_color.should(eq(""))
  end

  it "should recognize bold high intensity foreground colors" do
   ec = Oho::AnsiColorEscapeCode.new("[1;90m", default_options)
   ec.styles.should(eq([1]))
   ec.background_color.should(eq(""))
  end

  it "should recognize underlined foreground colors" do
   ec = Oho::AnsiColorEscapeCode.new("[4;36m", default_options)
   ec.styles.should(eq([4]))
   ec.foreground_color.should(eq("aqua"))
  end

  it "should recognize underlined high intestity foreground colors" do
   ec = Oho::AnsiColorEscapeCode.new("[4;96m", default_options)
   ec.styles.should(eq([4]))
   ec.foreground_color.should(eq("#00AAAA"))
   ec.background_color.should(eq(""))
  end

  describe "rgb colors" do

    it "should recognize rgb foreground colors" do
      # breakdown
      # normal foreground color codes go from 37 to 39 skipping 38
      # 38 is bug unless followed by 5 or 2
      # 38;2 -> indicates rgb color is about to follow
      # thus rgb should be 252, 0, 37
      escape_code_string = "[38;2;252;0;37m" # the \033 or \e will be stripped before
      ec = Oho::AnsiColorEscapeCode.new(escape_code_string, default_options)
      ec.to_span(nil).should(eq(
       "<span style=\"color: rgb(252,0,37); \">"))
    end

    it "should recognize rgb background colors" do
      # breakdown
      # normal background color codes go from 47 to 49 skipping 38
      # 48 is bug unless followed by 5 or 2
      # 48;2 -> indicates rgb color is about to follow
      # thus rgb should be 252, 0, 37
      escape_code_string = "[48;2;252;0;37m" # the \033 or \e will be stripped before
      ec = Oho::AnsiColorEscapeCode.new(escape_code_string, default_options)
      ec.to_span(nil).should(eq(
       "<span style=\"background-color: rgb(252,0,37); \">"))
    end
  end
end
