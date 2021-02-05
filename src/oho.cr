# Handle ^C gracefully
Signal::INT.trap do
  exit 0
end
# END Handle ^C
STDIN.read_timeout = 0.1

require "option_parser"
require "./oho/*"

version_number="VERSION_NUMBER_HERE" # replaced by the build script
background_color="white"
foreground_color="black"
title="terminal output"
help_requested = false
additional_styling = ""
if File.basename(PROGRAM_NAME) !~ /crystal-run.*\.tmp/
  parser = OptionParser.parse do |parser|
    parser.banner = "oho #{version_number}\nUsage: <some command> | oho [-d][-v] \
                            [-b <background color>] \
                            [-f <foreground color>] \
                            [-t <page title>] > html_output.html"
    parser.on("-d", "--dark", "Dark mode") { foreground_color = "white"
                                             background_color = "black"}
    parser.on("-b background", "--background=background", "Sets the background color. Any CSS color will work.") { |color| background_color = color }
    parser.on("-f foreground", "--foreground=foreground", "Sets the foreground color. Any CSS color will work.") { |color| foreground_color = color }
    parser.on("-s styling", "--styling=styling", "Additional CSS styling. Will be stuck in a style block. ") { |styling| additional_styling = styling }
    parser.on("-t title", "--title=title_string", "Sets the html page title."){|title_string| title=title_string}
    parser.on("-v", "--version", "Show the version number"){
      puts "oho version #{version_number}" 
      exit(0)
    }
    parser.on("-h", "--help", "Show this help") {
      help_requested = true
      puts parser 
    }
    parser.invalid_option do |flag|
      STDERR.puts("#{flag} is not a valid option")
      STDERR.puts parser
      exit(1)
    end
  end

  #============================================================================

  last_escape_code = nil.as(Oho::EscapeCode?)
  defaults=Hash(Symbol, String).new()
  defaults[:background_color] = background_color
  defaults[:foreground_color] = foreground_color
  c = Oho::Converter.new(defaults)
                        # ^^^  so, i want to be able to tell the converter which
                        # ISO format the code is in. aha had to deal with this
                        # but i don't fully understand the requirements so

  line_count = 0
    begin
    while (line = ARGF.gets) != nil
      break if line.nil?
      if line_count == 0
        puts "<html><head><title>#{title}</title>"
        puts "<!-- generated by oho #{version_number} \
        https://github.com/masukomi/oho -->"

        puts "<style>"
        puts "body{background-color: #{background_color};
        color: #{foreground_color};}
        @media print {
          @page { margin: 0; }
          body { margin: 1.6cm; }
        }"
        puts additional_styling unless additional_styling == ""
        puts "</style></head><body><pre>"
      end
      response, escape_code = c.process(line.as(String), last_escape_code)
      puts response
      last_escape_code = escape_code
      line_count += 1
    end
  rescue IO::TimeoutError
    STDERR.puts parser unless help_requested
    exit(1)
  end
  puts "</pre></body></html>" unless line_count == 0

  if line_count == 0 && ! help_requested
    STDERR.puts "No input encountered."
    STDERR.puts parser
  end

end

