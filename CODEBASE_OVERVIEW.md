# Welcome to Oho's code

This document strives to give you a brief introduction to the codebase, what's in it, and what it's attempting to do.

## What
At a high level oho solves the problem of converting colorized terminal output into HTML.

## Why
The existing made output that was unusably small, had alignment issues resulting from not maintaining the visual grid of a terminal, and lacked support for a many escape codes that affected the visuals.

Refactoring the best available tool (Aha) was explored as an option, but Aha's codebase was not designed with extensibility in mind and it was determined that there was no simple refactoring that could be done to achieve the desired goals.

## Goals

-   HTML that looks good
-   easy extensibility
-   easy maintainability
-   complete conversion support for the options of each escape code sequence supported

## Approach

-   separate parsing, escape code processing, and html generation
-   design it in such a way that individual components could be unit tested
-   support the future addition of escape-code sets in addition to the most common ANSI.
-   correctly handle escape codes that don't effect the visuals
-   use a language that, like C, could produce a binary upon install that required no user knowledge of the language's ecosystem. E.g. A Golang geek shouldn't have to know how to use Ruby Version Managers, rubygems, or Bundler in order to use it.
-   create a codebase that was easy to maintain after periods of not touching it.

What's in the codebase: Because the goal is very focused, the codebase has remained very clean.

-   `oho.cr` is the entrypoint and handles combining the generator's output with the default template.
-   `converter.cr` is basically a big loop that iterates through a character stream and undertands that some sequences of characters may constitute a single "escape code". As it loops it builds up a new String Buffer consisting of the characters that are not escape codes, chooses the correct handler for any type of escape code it encounters - that shouldn't obviously be ignored -, and adds the HTML those generate to the string it's constructing.
-   escape code handling The classes that handle an escape code each have a simple job: figure out what HTML should be emitted for the escape code they were just handed. The HTML generated must account for foreground colors, background colors, brightness, and styling like bold and italic.
    -   `escape_code.cr` an abstract class guaranteeing a common set of predefined methods that would be callable on all classes implementing support for a type of escape code. Note that at the time of writing Crystal didn't have anything analogous to Java's Interfaces.
    -   `non_display_escape_code.cr` - there are a variety of escape codes that control cursor movement, scrolling, and other things that would have no bearing on the generated HTML. This class handles those.
    -   `ansi_color_escape_code.cr` - this was written to handle ANSI 3/4, 8-bit, and 16-bit escape codes. ANSI escape codes are the most widely used by a huge margin, and was what the project started with.
    
        Unfortunately there's no good way to get around the fact that specific integer numbers are tied to specific colors in a way that can't be easily calculated. As a result, the class starts off with a lot of lookup tables. This same thing applies to styling effects like bold, underline, dim, etc., so those need lookup tables too.
        
        The next notable bit is the `hell_regexp`. The short explanation is that limitations of Crystal's Regular Expression engine mean that a completely unreadable regular expression needs to be generated. An explanation of the problem + code for regenerating it if necessary can be found in the comment preceeding it. The regexp is an error handler for escape codes with a valid structure that don't correspond to anything in the lookup tables.
    
    -   `t_416_color_escape_code.cr` a handler for escape code adhering to the T.416 specification. Unlike ANSI escape codes, the T.416 engineers spent time designing a thoughtful, predictable, and generally well crafted approach to formatting terminal output. The world would be a slightly better place if it had become the dominant choice.
