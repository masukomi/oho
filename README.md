# oho
Takes your colorful terminal output and converts it to HTML for sharing.
(only html output)


![screenshot example](https://github.com/masukomi/oho/blob/master/docs/screenshot.jpg?raw=true)

That's just a sample. oho supports ANSI 3/4 bit (basic and high intensity), 8 bit, 
& 24 bit color codes as well as ITU's T.416 / 8613-6  color codes! 
That's 16,777,216 possible colors. Make your terminal
output beautiful. oho will handle it just fine.

## Usage

Simply pipe your colorful terminal output to oho and it will spit out HTML.

I've included a test script in the docs directory for you to try it out with.

Run `docs/colortest.sh` to see what the output looks like in your terminal. 

Then pipe it to `oho` to see the html: `docs/colortest.sh | oho`

Now, save it to a file so that you can open it with your browser: 

`docs/colortest.sh | oho > colotest.html`

Does your terminal have a dark background? Pass the `-d` option to turn on "dark
mode" (a black background with white foreground text). Want to get even more
specific? You can use any valid css color for the foreground and background
colors. See the usage output below.

```text
Usage: <some command> | oho [-d][-v] [-b <background color>] [-f <foreground color>] [-t <page title>] > html_output.html
    -d, --dark                       Dark mode
    -b background, --background=background
                                     Sets the background color. Any CSS color will work.
    -f foreground, --foreground=foreground
                                     Sets the foreground color. Any CSS color will work.
    -s styling, --styling=styling    Additional CSS styling. Will be stuck in a style block.
    -t title, --title=title_string   Sets the html page title.
    -v, --version                    Show the version number
    -h, --help                       Show this help
```

### Note
Many command line tools can detect if the tool they are piping data to is a "tty"
or not. For example `git log --stat` has many colors, but if you pipe it to
another script like `cat` they'll all disappear. If the script you're trying to
convert to HTML do this detection then oho won't ever receive the colors you
want converted. Fortunately there is an easy way to trick it. Most Unix
based systems have a tool called `script` installed on them.

So, if I wanted to convert my fancy `git log` output on my mac I might say:

```
script -q /dev/null "git log --stat -n 4" | oho
      # | |         |                       ^ this great tool
      # | |         ^ the command to run 
      # | ^ we don't want the file it writes
      # ^ don't add status messages
```

Run `man script` to learn what the various options are on your system. Linux and
macOS/BSD tend to have different versions of `script`.

#### Mac Users Bonus
Saving it to a file and then opening that file in a browser is annoying. There
are some hacks you can do to get around it, but
[Fenestro](https://fenestro.xyz) is happy to save you that trouble.

```sh
docs/colortest.sh | oho -d | fenestro 
```

Voilà a window opens with your pretty HTML loaded into it. 


## Installation

### macOS via Homebrew
```sh
brew tap masukomi/homebrew-apps
brew install oho
```

### Building from source

oho is written in [Crystal](https://crystal-lang.org/) so you'll need to install
the crystal compiler. After that you just clone down this repository, `cd` into it and run 

```bash
crystal build src/oho.cr
```

An `oho` executable will be created in the current directory. Just move that
into your PATH and follow the Usage instructions.

## Development

If you're adding new functionality or fixing a bug in existing functionality
please include a unit test that exercises the new/changed code.

## Contributing

1. Fork it ( https://github.com/masukomi/oho/fork )
2. Create your feature branch (git checkout -b my_new_feature)
3. Make some changes
4. Confirm all the old and new unit tests still pass (crystal spec)
5. Commit your changes (git commit -am 'Add some feature')
6. Push to the branch (git push origin my_new_feature)
7. Create a new Pull Request

## Contributors

- [masukomi](https://github.com/masukomi) masukomi - creator, maintainer
- You!
