# Vim Markdown runtime files

This is the development version of Vim's included syntax highlighting and
filetype plugins for Markdown.  Generally you don't need to install these if
you are running a recent version of Vim.

If you want to enable fenced code block syntax highlighting in your markdown
documents you can enable it in your `.vimrc` like so:

    let g:markdown_fenced_languages = ['html', 'python', 'bash=sh']

To disable markdown syntax concealing add the following to your vimrc:

    let g:markdown_syntax_conceal = 0

Syntax highlight is synchronized in 50 lines. It may cause collapsed
highlighting at large fenced code block.
In the case, please set larger value in your vimrc:

    let g:markdown_minlines = 100

Note that setting too large value may cause bad performance on highlighting.

## License

Copyright © Tim Pope.  Distributed under the same terms as Vim itself.
See `:help license`.
