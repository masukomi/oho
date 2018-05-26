require "../spec_helper"

describe Oho::EscapeCode do
  it "should extract simple background color" do
   ec = Oho::EscapeCode.new("[44m")
   ec.background_color.should(eq("#3333FF"))
  end
  it "should extract high intensity background color" do
   ec = Oho::EscapeCode.new("[0;100m")
   ec.background_color.should(eq("#000000"))
  end
  it "should handle bold, italic, underline" do
   escape_code_string = "[1;3;4;33m" # the \033 or \e will be stripped before
   ec = Oho::EscapeCode.new(escape_code_string)
   ec.to_span(nil).should(eq(
     "<span style=\"font-weight: bold; font-style: italic; text-decoration: underline; color: yellow; \">"))
  end

  it "should continue foreground colors" do
    ec = Oho::EscapeCode.new("[33m") # foreground
    prior_ec = Oho::EscapeCode.new("[43m") #background
    ec.to_span(prior_ec).should(eq(
      "</span><span style=\"background-color: yellow; color: yellow; \">"))
  end
  it "should not continue superceeded foreground colors" do
    ec = Oho::EscapeCode.new("[36m") # foreground
    prior_ec = Oho::EscapeCode.new("[33m") #foreground
    ec.to_span(prior_ec).should(eq(
      "</span><span style=\"color: aqua; \">"))
  end
  it "should continue background colors" do
    ec = Oho::EscapeCode.new("[43m") #background
    prior_ec = Oho::EscapeCode.new("[33m") # foreground
    ec.to_span(prior_ec).should(eq(
      "</span><span style=\"background-color: yellow; color: yellow; \">"))
  end
  it "should not continue superceeded background colors" do
    ec = Oho::EscapeCode.new("[46m") #background
    prior_ec = Oho::EscapeCode.new("[43m") # background
    ec.to_span(prior_ec).should(eq(
      "</span><span style=\"background-color: aqua; \">"))
  end
  it "should continue styles" do
    ec = Oho::EscapeCode.new("[46m") #background
    prior_ec = Oho::EscapeCode.new("[1;2;3;4;5;8m") # background
    ec.to_span(prior_ec).should(eq(
      "</span><span style=\"font-weight: bold; opacity: 0.5; font-style: italic; text-decoration: underline; display: none; background-color: aqua; \">"))

  end
  it "should not continue superceeded styles" do
    ec = Oho::EscapeCode.new("[46m") #background
    prior_ec = Oho::EscapeCode.new("[1;2;3;4;8m") # background
    ec.to_span(prior_ec).should(eq(
      "</span><span style=\"font-weight: bold; opacity: 0.5; font-style: italic; text-decoration: underline; display: none; background-color: aqua; \">"))
  end
  it "0 resets all" do
    ec = Oho::EscapeCode.new("[0m") #reset all the things
    prior_ec = Oho::EscapeCode.new("[1;2;3;4;8;36;46m")
    ec.to_span(prior_ec).should(eq( "</span><span style=\"\">"))
      # "</span><span style=\"background-color: initial; color: initial; font-weight: normal; opacity: 1.0; font-style: normal; text-decoration: none; display: inline; background-color: none; color: none; \">"))

  end
  it "0 resets all and can be trumped" do
    ec = Oho::EscapeCode.new("[0;46m") #reset all the things
    prior_ec = Oho::EscapeCode.new("[1;2;3;4;8m") # background
    ec.to_span(prior_ec).should(eq( "</span><span style=\"background-color: aqua; \">"))
      # "</span><span style=\"background-color: initial; color: initial; font-weight: normal; opacity: 1.0; font-style: normal; text-decoration: none; display: inline; background-color: aqua; \">"))

  end

  it "isn't expected to support blink or reverse" do
    ec = Oho::EscapeCode.new("[5;7;46m")
    ec.to_span(nil).should(eq("<span style=\"background-color: aqua; \">"))
  end

  it "should recognize high intensity foreground colors" do
   ec = Oho::EscapeCode.new("[0;90m")
   ec.foreground_color.should(eq("#000000"))
   ec.background_color.should(eq(""))
  end
  it "should recognize simple foreground colors" do
   ec = Oho::EscapeCode.new("[0;30m")
   ec.foreground_color.should(eq("dimgray"))
   ec.background_color.should(eq(""))
  end
  it "should know about default foreground color" do
   ec = Oho::EscapeCode.new("[39m")
   ec.foreground_color.should(eq("initial"))
   ec.background_color.should(eq(""))
  end
  it "should know 256 color 39 isn't default foreground" do
   ec = Oho::EscapeCode.new("[38;5;39m")
   ec.foreground_color.should(eq("#00afff"))
   ec.background_color.should(eq(""))
  end

   it "should know about default background color" do
   ec = Oho::EscapeCode.new("[49m")
   ec.foreground_color.should(eq(""))
   ec.background_color.should(eq("initial"))
  end
  it "should know 256 color 49 isn't default foreground" do
   ec = Oho::EscapeCode.new("[38;5;49m")
   ec.foreground_color.should(eq("#00ffaf"))
   ec.background_color.should(eq(""))
  end
  it "should recognize bold foreground colors" do
   ec = Oho::EscapeCode.new("[1;36m")
   ec.styles.should(eq([1]))
   ec.foreground_color.should(eq("aqua"))
   ec.background_color.should(eq(""))
  end
  it "should recognize bold high intensity foreground colors" do
   ec = Oho::EscapeCode.new("[1;90m")
   ec.styles.should(eq([1]))
   ec.background_color.should(eq(""))
  end
  it "should recognize underlined foreground colors" do
   ec = Oho::EscapeCode.new("[4;36m")
   ec.styles.should(eq([4]))
   ec.foreground_color.should(eq("aqua"))
  end
  it "should recognize underlined high intestity foreground colors" do
   ec = Oho::EscapeCode.new("[4;96m")
   ec.styles.should(eq([4]))
   ec.foreground_color.should(eq("#00AAAA"))
   ec.background_color.should(eq(""))
  end

end