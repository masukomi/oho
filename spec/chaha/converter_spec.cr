require "../spec_helper"

describe Chaha::Converter do
  # TODO: Write tests

  it "creates inline styles" do
    options = {:bullshit => true}
    c = Chaha::Converter.new(options)
    # STDERR.puts("\\033[31mhi\\033[0m")
    test_string = "\033[31mhi\033[0m"
    response, escape_code = c.process(test_string, nil)
    # c.process(test_string).should(eq("<span class=\"red\">hi</span>"))
    response.should(eq("<span style=\"color: red; \">hi</span>"))

  end

  it "handles escape codes that terminate on subsequent lines" do
    options = {:bullshit => true}
    c = Chaha::Converter.new(options)
    test_string = "\033[36mfoo\nbar\033[0m baz"
    response, escape_code = c.process(test_string, nil)
    response.should(eq("<span style=\"color: aqua; \">foo\n<br />bar</span><span style=\"\"> baz</span>"))
  end
end

