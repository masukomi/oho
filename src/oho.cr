# Handle ^C gracefully
Signal::INT.trap do
  exit 0
end
# END Handle ^C
STDIN.read_timeout = 0.1

require "option_parser"
require "./oho/*"


background_color="white"
foreground_color="black"
title="terminal output"

if File.basename(PROGRAM_NAME) != "crystal-run-spec.tmp"
  parser = OptionParser.parse! do |parser|
    parser.banner = "Usage: <some command> | oho [-d] \
                            [-b <background color>] \
                            [-f <foreground color>] \
                            [-t <page title>] > html_output.html"
    parser.on("-d", "--dark", "Dark mode") { foreground_color = "white"
                                             background_color = "black"}
    parser.on("-b background", "--background=background", "Sets the background color. Any CSS color will work.") { |color| background_color = color }
    parser.on("-f foreground", "--foreground=foreground", "Sets the foreground color. Any CSS color will work.") { |color| foreground_color = color }
    parser.on("-t title", "--title=title_string", "Sets the html page title."){|title_string| title=title_string}
    parser.on("-h", "--help", "Show this help") { puts parser }
    parser.invalid_option do |flag|
      STDERR.puts("#{flag} is not a valid option")
      STDERR.puts parser
      exit(1)
    end
  end

  #============================================================================

  last_escape_code = nil.as(Oho::EscapeCode?)
  c = Oho::Converter.new({:bullshit=>true})
                        # ^^^  so, i want to be able to tell the converter which
                        # ISO format the code is in. aha had to deal with this
                        # but i don't fully understand the requirements so
                        # for now this is just a placeholder with some code 
                        # in converter that's just waiting to use it.

  line_count = 0
  begin
    while (line = ARGF.gets) != nil
      break if line.nil?
      if line_count == 0
        puts "<html><head><title>#{title}</title><style>"
        puts "body{background-color: #{background_color};
        color: #{foreground_color};}"
        puts "</style></head><body><pre>"
      end
      response, escape_code = c.process(line.as(String), last_escape_code)
      puts response
      last_escape_code = escape_code
      line_count += 1
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

end

