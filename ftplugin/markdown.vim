" Vim filetype plugin
" Language:     Markdown
" Maintainer:   Tim Pope <https://github.com/tpope/vim-markdown>
" Last Change:  2019 Dec 05

if exists("b:did_ftplugin")
  finish
endif

runtime! ftplugin/html.vim ftplugin/html_*.vim ftplugin/html/*.vim

setlocal comments=fb:*,fb:-,fb:+,n:> commentstring=<!--%s-->
setlocal formatoptions+=tcqln formatoptions-=r formatoptions-=o
setlocal formatlistpat=^\\s*\\d\\+\\.\\s\\+\\\|^\\s*[-*+]\\s\\+\\\|^\\[^\\ze[^\\]]\\+\\]:\\&^.\\{4\\}

if exists('b:undo_ftplugin')
  let b:undo_ftplugin .= "|setl cms< com< fo< flp< et< ts< sts< sw<"
else
  let b:undo_ftplugin = "setl cms< com< fo< flp< et< ts< sts< sw<"
endif

if get(g:, 'markdown_recommended_style', 1)
  setlocal expandtab tabstop=4 softtabstop=4 shiftwidth=4
endif

if !exists("g:no_plugin_maps") && !exists("g:no_markdown_maps")
  nnoremap <silent><buffer> [[ :<C-U>call search('\%(^#\{1,5\}\s\+\S\\|^\S.*\n^[=-]\+$\)', "bsW")<CR>
  nnoremap <silent><buffer> ]] :<C-U>call search('\%(^#\{1,5\}\s\+\S\\|^\S.*\n^[=-]\+$\)', "sW")<CR>
  xnoremap <silent><buffer> [[ :<C-U>exe "normal! gv"<Bar>call search('\%(^#\{1,5\}\s\+\S\\|^\S.*\n^[=-]\+$\)', "bsW")<CR>
  xnoremap <silent><buffer> ]] :<C-U>exe "normal! gv"<Bar>call search('\%(^#\{1,5\}\s\+\S\\|^\S.*\n^[=-]\+$\)', "sW")<CR>
  let b:undo_ftplugin .= '|sil! nunmap <buffer> [[|sil! nunmap <buffer> ]]|sil! xunmap <buffer> [[|sil! xunmap <buffer> ]]'
endif

function! s:NotCodeBlock(lnum) abort
  return synIDattr(synID(a:lnum, 1, 1), 'name') !=# 'markdownCode'
endfunction

function! MarkdownFold() abort
  let line = getline(v:lnum)

  if line =~# '^#\+ ' && s:NotCodeBlock(v:lnum)
    return ">" . match(line, ' ')
  endif

  let nextline = getline(v:lnum + 1)
  if (line =~ '^.\+$') && (nextline =~ '^=\+$') && s:NotCodeBlock(v:lnum + 1)
    return ">1"
  endif

  if (line =~ '^.\+$') && (nextline =~ '^-\+$') && s:NotCodeBlock(v:lnum + 1)
    return ">2"
  endif

  return "="
endfunction

function! s:HashIndent(lnum) abort
  let hash_header = matchstr(getline(a:lnum), '^#\{1,6}')
  if len(hash_header)
    return hash_header
  else
    let nextline = getline(a:lnum + 1)
    if nextline =~# '^=\+\s*$'
      return '#'
    elseif nextline =~# '^-\+\s*$'
      return '##'
    endif
  endif
endfunction

function! MarkdownFoldText() abort
  let hash_indent = s:HashIndent(v:foldstart)
  let title = substitute(getline(v:foldstart), '^#\+\s*', '', '')
  let foldsize = (v:foldend - v:foldstart + 1)
  let linecount = '['.foldsize.' lines]'
  return hash_indent.' '.title.' '.linecount
endfunction

if has("folding") && get(g:, "markdown_folding", 0)
  setlocal foldexpr=MarkdownFold()
  setlocal foldmethod=expr
  setlocal foldtext=MarkdownFoldText()
  let b:undo_ftplugin .= "|setl foldexpr< foldmethod< foldtext<"
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
