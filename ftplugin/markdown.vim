" Vim filetype plugin
" Language:		Markdown
" Maintainer:		Tim Pope <vimNOSPAM@tpope.org>

if exists("b:did_ftplugin")
  finish
endif

runtime! ftplugin/html.vim ftplugin/html_*.vim ftplugin/html/*.vim

setlocal comments=fb:*,fb:-,fb:+,n:> commentstring=>\ %s
setlocal formatoptions+=tcqln formatoptions-=r formatoptions-=o
setlocal formatlistpat=^\\s*\\d\\+\\.\\s\\+\\\|^[-*+]\\s\\+

if exists('b:undo_ftplugin')
  let b:undo_ftplugin .= "|setl cms< com< fo< flp<"
else
  let b:undo_ftplugin = "setl cms< com< fo< flp<"
endif

" Markdown auto lists
" BUG: If the cursor is on a list item at `col('$') - 1`, then a new list item
"      will be added on a new line instead of splitting the line
function! AutoMDList()
  let line=getline('.')

  " Potential unordered list match
  let umatches=matchstr(line, '^[*+-]')

  " Potential ordered list match
  let omatches=matchstr(line, '^\d\+\.')

  if empty(umatches) && empty(omatches)
    " TODO: Handle the case where a list item spans over several lines.
    "
    " In that case, a new list item needs to be added.
    "
    " I don't know (yet) how to do this without going up a line in a loop and
    " checking if it's the first line of the list item (that is a terrible
    " solution!!)

    " If the user is not in a list, use the default behaviour for <CR>
    call feedkeys("\<CR>", "n")
  elseif empty(omatches)
    " The case of an unordered list

    if !empty(matchstr(line, '^[*+-]\s\?$'))
      " If the user is on a blank list item (i.e.: "- ") and presses <CR>, end
      " the list...
      exec ':normal! cc' | call feedkeys("\<CR>", "n")
    elseif col('.') == len(getline('.'))
      " ...otherwise, if the cursor is at the end of the line, add a list
      "    item...

      exec ':normal! o' . umatches . ' ' | exec ':startinsert!'
    else
      " ...and if the cursor is in the middle of a line, use the default
      " behaviour for <CR>
      call feedkeys("\<CR>", "n")
    endif
  elseif empty(umatches)
    " The case of an ordered list

    if !empty(matchstr(line, '^\d\+\.\s\?$'))
      " If the user is on a blank list item (i.e.: "42. ") and presses <CR>,
      " end the list...
      exec ':normal! cc' | call feedkeys("\<CR>", "n")
    elseif col('.') == len(getline('.'))
      " ...otherwise, if the cursor is at the end of the line, increment the list item number...
      let l:nln=omatches + 1

      " ...and add a new item
      exec ':normal! o' . l:nln . '. ' | exec ':startinsert!'
    else
      " ...and if the cursor is in the middle of a line, use the default
      " behaviour for <CR>
      call feedkeys("\<CR>", "n")
    endif
  endif

  return
endf

" Remap <CR> for all .md files
au BufEnter *.md inoremap <buffer> <CR> <C-o>:call AutoMDList()<CR>

" vim:set sw=2:
