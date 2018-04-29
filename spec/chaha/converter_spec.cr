require "../spec_helper"

describe Chaha::Converter do
  # TODO: Write tests

  it "creates inline styles" do
    options = {} of Symbol => Int8|String
    options[:stylesheet] = "true"
    c = Chaha::Converter.new(options)
    STDERR.puts("\\033[0;31mhi\\033[0m")
    test_string = "\033[0;31mhi\033[0m"
    c.process(test_string).should(eq("<span class=\"red\">hi</span>"))
    # c.process("bullshit").should(eq("<span class=\"red\">hi</span>"))
  end
end

