# Handle ^C gracefully
Signal::INT.trap do
  exit 0
end
# END Handle ^C
STDIN.read_timeout = 0.1

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

  line_count = 0
  begin
    while (line = ARGF.gets) != nil
      break if line.nil?
      if line_count == 0
        puts "<html><head><style>"
        puts "body{background-color: #{background_color};
        color: #{foreground_color};}"
        puts "</style></head><body><pre>"
      end
      response, escape_code = c.process(line.as(String), last_escape_code)
      puts response
      last_escape_code = escape_code
      line_count += 1
      # printf "%s", "."
    end
  rescue IO::Timeout
    STDERR.puts parser
    exit(1)
  end
  puts "</pre></body></html>" unless line_count == 0

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
