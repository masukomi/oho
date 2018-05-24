# Handle ^C gracefully
Signal::INT.trap do
  exit 0
end
# END Handle ^C

require "option_parser"
require "./chaha/*"


background_color="white"
foreground_color="black"

if File.basename(PROGRAM_NAME) != "crystal-run-spec.tmp"
  parser = OptionParser.parse! do |parser|
    parser.banner = "Usage: <some command> | chaha [-b black] > html_output.html"
    parser.on("-b background", "--background=background", "sets the background color") { |color| background_color = color }
    parser.on("-f foreground", "--foreground=foreground", "sets the foreground color") { |color| foreground_color = color }
    parser.on("-d", "--dark", "dark mode") { foreground_color = "white"
                                             background_color = "black"}
    parser.on("-h", "--help", "Show this help") { puts parser }
  end






  last_escape_code = nil.as(Chaha::EscapeCode?)
  c = Chaha::Converter.new({:bullshit=>true})
  puts "<html><head><style>"
  puts "body{background-color: #{background_color};
  color: #{foreground_color};}"
  puts "</style></head><body><pre>"

  line_count = 0
  while (line = ARGF.gets) != nil
  # while line = STDIN.raw &.gets
  # STDIN.each_line do |line|
  # while line = STDIN.gets
    break if line.nil?
    response, escape_code = c.process(line.as(String), last_escape_code)
    puts response
    last_escape_code = escape_code
    line_count += 1
    # printf "%s", "."
  end
  puts "</pre></body></html>"

  if line_count == 0
    STDERR.puts "No input encountered."
    STDERR.puts parser
  end

  # STDIN.raw do |stdin|
  #   stdin.each_line do |line|
  #     puts line
  #   end
  # end
  # ARGF.each_line do |line|
  #   puts line if line.chomp =~ /^9+$/
  # end
  # STDIN.each_line do |line|
  #   puts line
  # end

  # puts ARGF.read
  # converter = Chaha::Converter.new(ARGF.read)
  # module Chaha
  #
  # end

end
