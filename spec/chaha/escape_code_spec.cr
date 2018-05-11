require "../spec_helper"

describe Chaha::EscapeCode do
 it "should extract simple background color" do
   ec = Chaha::EscapeCode.new("[44m")
   ec.background_color.should(eq("#3333FF"))
 end
 it "should extract high intensity background color" do
   ec = Chaha::EscapeCode.new("[0;100m")
   ec.background_color.should(eq("#000000"))
 end
  it "should handle bold, italic, underline" do
    escape_code_string = "[1;3;4;33m" # the \033 or \e will be stripped before
   1
   3
   4

    ec = Chaha::EscapeCode.new(escape_code_string)
    ec.to_span.should(eq(
      "<span style=\"color: yellow; font-weight: bold; font-style: italic; text-decoration: underline; \">"))
  end

 it "should recognize high intensity foreground colors" do
   ec = Chaha::EscapeCode.new("[0;90m")
   ec.foreground_color.should(eq("#000000"))
   ec.background_color.should(eq(""))
 end
 it "should recognize simple foreground colors" do
   ec = Chaha::EscapeCode.new("[0;30m")
   ec.foreground_color.should(eq("dimgray"))
   ec.background_color.should(eq(""))
 end
 it "should know about default foreground color" do
   ec = Chaha::EscapeCode.new("[39m")
   ec.foreground_color.should(eq("initial"))
   ec.background_color.should(eq(""))
 end
 it "should know 256 color 39 isn't default foreground" do
   ec = Chaha::EscapeCode.new("[38;5;39m")
   ec.foreground_color.should(eq("#00afff"))
   ec.background_color.should(eq(""))
 end

   it "should know about default background color" do
   ec = Chaha::EscapeCode.new("[49m")
   ec.foreground_color.should(eq(""))
   ec.background_color.should(eq("initial"))
 end
 it "should know 256 color 49 isn't default foreground" do
   ec = Chaha::EscapeCode.new("[38;5;49m")
   ec.foreground_color.should(eq("#00ffaf"))
   ec.background_color.should(eq(""))
 end
 it "should recognize bold foreground colors" do
   ec = Chaha::EscapeCode.new("[1;36m")
   ec.styles.should(eq([1]))
   ec.foreground_color.should(eq("aqua"))
   ec.background_color.should(eq(""))
 end
 it "should recognize bold high intensity foreground colors" do
   ec = Chaha::EscapeCode.new("[1;90m")
   ec.styles.should(eq([1]))
   ec.background_color.should(eq(""))
 end
 it "should recognize underlined foreground colors" do
   ec = Chaha::EscapeCode.new("[4;36m")
   ec.styles.should(eq([4]))
   ec.foreground_color.should(eq("aqua"))
 end
 it "should recognize underlined high intestity foreground colors" do
   ec = Chaha::EscapeCode.new("[4;96m")
   ec.styles.should(eq([4]))
   ec.foreground_color.should(eq("#00AAAA"))
   ec.background_color.should(eq(""))
 end

end
