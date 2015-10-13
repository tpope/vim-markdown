" Vim syntax file
" Language:     Markdown
" Maintainer:   Tim Pope <vimNOSPAM@tpope.org>
" Filenames:    *.markdown
" Last Change:  2013 May 30

if exists("b:current_syntax")
  finish
endif

if !exists('main_syntax')
  let main_syntax = 'markdown'
endif

runtime! syntax/html.vim
unlet! b:current_syntax

if !exists('g:markdown_fenced_languages')
  let g:markdown_fenced_languages = []
endif
for s:type in map(copy(g:markdown_fenced_languages),'matchstr(v:val,"[^=]*$")')
  if s:type =~ '\.'
    let b:{matchstr(s:type,'[^.]*')}_subtype = matchstr(s:type,'\.\zs.*')
  endif
  exe 'syn include @markdownHighlight'.substitute(s:type,'\.','','g').' syntax/'.matchstr(s:type,'[^.]*').'.vim'
  unlet! b:current_syntax
endfor
unlet! s:type

syn sync minlines=10
syn case ignore

syn match markdownValid '[<>]\c[a-z/$!]\@!'
syn match markdownValid '&\%(#\=\w*;\)\@!'

syn match markdownLineStart "^[<@]\@!" nextgroup=@markdownBlock,htmlSpecialChar

syn cluster markdownBlock contains=markdownH1,markdownH2,markdownH3,markdownH4,markdownH5,markdownH6,markdownBlockquote,markdownListMarker,markdownOrderedListMarker,markdownCodeBlock,markdownRule
syn cluster markdownInline contains=markdownLineBreak,markdownLinkText,markdownItalic,markdownBold,markdownCode,markdownEscape,@htmlTop,markdownError

syn match markdownH1 "^.\+\n=\+$" contained contains=@markdownInline,markdownHeadingRule,markdownAutomaticLink
syn match markdownH2 "^.\+\n-\+$" contained contains=@markdownInline,markdownHeadingRule,markdownAutomaticLink

syn match markdownHeadingRule "^[=-]\+$" contained

syn region markdownH1 matchgroup=markdownHeadingDelimiter start="##\@!"      end="#*\s*$" keepend oneline contains=@markdownInline,markdownAutomaticLink contained
syn region markdownH2 matchgroup=markdownHeadingDelimiter start="###\@!"     end="#*\s*$" keepend oneline contains=@markdownInline,markdownAutomaticLink contained
syn region markdownH3 matchgroup=markdownHeadingDelimiter start="####\@!"    end="#*\s*$" keepend oneline contains=@markdownInline,markdownAutomaticLink contained
syn region markdownH4 matchgroup=markdownHeadingDelimiter start="#####\@!"   end="#*\s*$" keepend oneline contains=@markdownInline,markdownAutomaticLink contained
syn region markdownH5 matchgroup=markdownHeadingDelimiter start="######\@!"  end="#*\s*$" keepend oneline contains=@markdownInline,markdownAutomaticLink contained
syn region markdownH6 matchgroup=markdownHeadingDelimiter start="#######\@!" end="#*\s*$" keepend oneline contains=@markdownInline,markdownAutomaticLink contained

syn match markdownBlockquote ">\%(\s\=\|$\)" contained nextgroup=@markdownBlock

syn region markdownCodeBlock start="    \|\t" end="$" contained

" TODO: real nesting
syn match markdownListMarker "\%(\t\| \{0,4\}\)[-*+]\%(\s\+\S\)\@=" contained
syn match markdownOrderedListMarker "\%(\t\| \{0,4}\)\<\d\+\.\%(\s\+\S\)\@=" contained

syn match markdownRule "\* *\* *\*[ *]*$" contained
syn match markdownRule "- *- *-[ -]*$" contained

syn match markdownLineBreak " \{2,\}$"

syn region markdownIdDeclaration matchgroup=markdownLinkDelimiter start="^ \{0,3\}!\=\[" end="\]:" oneline keepend nextgroup=markdownUrl skipwhite
syn match markdownUrl "\S\+" nextgroup=markdownUrlTitle skipwhite contained
syn region markdownUrl matchgroup=markdownUrlDelimiter start="<" end=">" oneline keepend nextgroup=markdownUrlTitle skipwhite contained
syn region markdownUrlTitle matchgroup=markdownUrlTitleDelimiter start=+"+ end=+"+ keepend contained
syn region markdownUrlTitle matchgroup=markdownUrlTitleDelimiter start=+'+ end=+'+ keepend contained
syn region markdownUrlTitle matchgroup=markdownUrlTitleDelimiter start=+(+ end=+)+ keepend contained

syn region markdownLinkText matchgroup=markdownLinkTextDelimiter start="!\=\[\ze\%([^]]\|\n\%(>\s\=\)*\s*[^> \t]\@=\)*]\%(\n\s*\| \=\)[[(]" end="]" nextgroup=markdownLink,markdownId skipwhite skipnl contains=@markdownInline,markdownLineStart
syn region markdownLink matchgroup=markdownLinkDelimiter start="(" end=")" contains=markdownUrl keepend contained
syn region markdownId matchgroup=markdownIdDelimiter start="\[" end="\]" keepend contained
syn region markdownAutomaticLink matchgroup=markdownUrlDelimiter start="<\%(\w\+:\|[[:alnum:]_+-]\+@\)\@=" end=">" keepend oneline

let s:concealends = has('conceal') ? 'concealends' : ''
function! s:InlineRegionPatterns(start, end)
  " generate a new start pattern that matches the given start, followed by
  " the end after some text, without any blank lines in between.
  let l:start = '\%(' . a:start . '\)\ze\%(.\|\n\%(>\s\=\)*\s*[^> \t]\@=\)\{-}\%(' . a:end . '\)'
  " assume that the '"' character can be used as a delimiter
  return 'start="' . l:start . '" end="' . a:end . '"'
endfunction
exe 'syn region markdownItalic matchgroup=markdownItalicDelimiter' s:InlineRegionPatterns('\%(\S\@<=\*\|\*\S\@=\)\ze\%(.\|\n\s*\S\@=\)\{-}', '\S\@<=\*\|\*\S\@=') 'keepend contains=markdownLineStart' s:concealends
exe 'syn region markdownItalic matchgroup=markdownItalicDelimiter' s:InlineRegionPatterns('\S\@<=_\|_\S\@=', '\S\@<=_\|_\S\@=') 'keepend contains=markdownLineStart' s:concealends
exe 'syn region markdownBold matchgroup=markdownBoldDelimiter' s:InlineRegionPatterns('\S\@<=\*\*\|\*\*\S\@=', '\S\@<=\*\*\|\*\*\S\@=') 'keepend contains=markdownLineStart,markdownItalic' s:concealends
exe 'syn region markdownBold matchgroup=markdownBoldDelimiter' s:InlineRegionPatterns('\S\@<=__\|__\S\@=', '\S\@<=__\|__\S\@=') 'keepend contains=markdownLineStart,markdownItalic' s:concealends
exe 'syn region markdownBoldItalic matchgroup=markdownBoldItalicDelimiter' s:InlineRegionPatterns('\S\@<=\*\*\*\|\*\*\*\S\@=', '\S\@<=\*\*\*\|\*\*\*\S\@=') 'keepend contains=markdownLineStart' s:concealends
exe 'syn region markdownBoldItalic matchgroup=markdownBoldItalicDelimiter' s:InlineRegionPatterns('\S\@<=___\|___\S\@=', '\S\@<=___\|___\S\@=') 'keepend contains=markdownLineStart' s:concealends

exe 'syn region markdownCode matchgroup=markdownCodeDelimiter' s:InlineRegionPatterns('`\%(``\)\@!', '`') 'keepend contains=markdownLineStart'
exe 'syn region markdownCode matchgroup=markdownCodeDelimiter' s:InlineRegionPatterns('`\@1<!```\@! \=', ' \=``') 'keepend contains=markdownLineStart'
" experimentally, markdown code fences do not require match start/end markers,
" they only care that the start/end markers are independently valid.
syn region markdownFencedCode matchgroup=markdownCodeFence start="\s*```.*$" start="\s*\~\{3}.*$" end="^\s*`\{3,}\ze\s*$" end="^\s*\~\{3,}\ze\s*$" contained keepend
syn cluster markdownBlock add=markdownFencedCode

syn match markdownFootnote "\[^[^\]]\+\]"
syn match markdownFootnoteDefinition "^\[^[^\]]\+\]:"

if main_syntax ==# 'markdown'
  for s:type in g:markdown_fenced_languages
    let s:type = matchstr(s:type,'[^=]*$')
    let s:regionName = 'markdownHighlight'.substitute(s:type,'\..*','','')
    exe 'syn region' s:regionName ' matchgroup=markdownCodeDelimiter start="\s*```\s*'.s:type.'\>.*$" end="^\s*```\ze\s*$" keepend contained contains=@markdownHighlight'.substitute(s:type,'\.','','g')
    exe 'syn cluster markdownBlock add='.s:regionName
  endfor
  unlet! s:type
  unlet! s:regionName
endif

syn match markdownEscape "\\[][\\`*_{}()<>#+.!-]"
syn match markdownError "\w\@<=_\w\@="

hi def link markdownH1                    htmlH1
hi def link markdownH2                    htmlH2
hi def link markdownH3                    htmlH3
hi def link markdownH4                    htmlH4
hi def link markdownH5                    htmlH5
hi def link markdownH6                    htmlH6
hi def link markdownHeadingRule           markdownRule
hi def link markdownHeadingDelimiter      Delimiter
hi def link markdownOrderedListMarker     markdownListMarker
hi def link markdownListMarker            htmlTagName
hi def link markdownBlockquote            Comment
hi def link markdownRule                  PreProc

hi def link markdownFootnote              Typedef
hi def link markdownFootnoteDefinition    Typedef

hi def link markdownLinkText              htmlLink
hi def link markdownIdDeclaration         Typedef
hi def link markdownId                    Type
hi def link markdownAutomaticLink         markdownUrl
hi def link markdownUrl                   Float
hi def link markdownUrlTitle              String
hi def link markdownIdDelimiter           markdownLinkDelimiter
hi def link markdownUrlDelimiter          htmlTag
hi def link markdownUrlTitleDelimiter     Delimiter

hi def link markdownItalic                htmlItalic
hi def link markdownItalicDelimiter       markdownItalic
hi def link markdownBold                  htmlBold
hi def link markdownBoldDelimiter         markdownBold
hi def link markdownBoldItalic            htmlBoldItalic
hi def link markdownBoldItalicDelimiter   markdownBoldItalic
hi def link markdownCodeDelimiter         Delimiter
hi def link markdownCodeFence             markdownCodeDelimiter

hi def link markdownEscape                Special
hi def link markdownError                 Error

let b:current_syntax = "markdown"
if main_syntax ==# 'markdown'
  unlet main_syntax
endif

" vim:set sw=2:
