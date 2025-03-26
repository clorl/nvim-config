# My Nvim Config

README TODO

## To Fix

## To Improve

## Ideas
- Helper plugin for :make that prompts you for errorformat, efile, makeprg etc.
    - Can easily build defaults for lots of languages
    - Saves this to a custom location for later use
    - Keybind to prepare the "make foo" command and asks you to press enter to validate
    - Make this as a pull request to mini.nvim
        - mini.build
        - Leverages :make
        - First searches the cwd for some file patterns like Makefile, make.ps1, etc
        - If not found, use internal lua module
- store.nvim to store persistent data for your nvim config
    - support packing and fast loading but the user has to define for each type the encoding
    - support encoding for default lua fts
