autocmd BufNewFile,BufRead *.markdown,*.md,*.mdown,*.mkd,*.mkdn
      \ if &ft ==# 'conf' | set ft=markdown | else | setf markdown | endif
