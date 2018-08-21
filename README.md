# powershell-basic-command-palette
A basic command palette for Powershell Core

---

This is a port of my [`bash-basic-command-palette`](https://github.com/dom111/bash-basic-command-palette). I'm not really a Powershell user and certainly not proficient in its quirks and nuances, but I've been interested in the syntax for a while so I've used this as a chance to jump in.

This has been tested on Powershell Core on macOS, so results might possibly vary using Windows, please let me know!

Similar to the comment on the `bash` version, this is a very basic idea that might be useful for use as part of a script to help you select options or something similar. I'll add some examples here too once I've added some for the `bash` version.

## Configuration

There are a few options that can be configured at the top of the script, but I do plan on moving this to a config file if it's actually a useful tool.

## Usage

    ./command-palette.ps1 <action> <list option> [<list option>, ...]
    ./command-palette.ps1 "<list options separated by newlines>"

So something like:

    ./command-palette.ps1 "git checkout" "$(git branch)".Trim(" ","*")

would give you a navigable list of git branches to check out when pressing <kbd>Enter</kbd>.

If you provide a string that contains newlines, that item will be split on newlines into individual options, you can also just supply a list of arguments. To preserve spaces in items, use quotes:

    ./command-palette.ps1 echo Item 1 "Item 2" 'Item three' Item 4

produces:

     |    
     * Item   
       Item 2   
       Item three   
       Item   

The default `<action>` is to call `echo`.

## Command-line Options

- `-k` - *k*eeps the command palette open after executing `<action>`.

## Keyboard Shortcuts

When in the command-palette interface, you can use <kbd>Esc</kbd> to quit without executing `<action>`. When navigating the list, the <kbd>↑</kbd> and <kbd>↓</kbd> arrows move up and down the list and <kbd>PgUp</kbd> and <kbd>PgDn</kbd> move up or down half a screen of items.

## TODO

- Sorting
- Add a config file
- Add left/right support for long lines
