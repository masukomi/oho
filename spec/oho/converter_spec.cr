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
end

