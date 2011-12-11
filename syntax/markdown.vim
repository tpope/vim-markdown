" Vim syntax file
" Language:     Markdown
" Maintainer:   Tim Pope <vimNOSPAM@tpope.org>
" Filenames:    *.markdown

if exists("b:current_syntax")
  finish
endif

runtime! syntax/html.vim
unlet! b:current_syntax

" Let the user determine which markers to conceal and which not to conceal:
"   #: headings, *: bullets, d: id declarations, l: links, a: automatic links,
"   i: italic text, b: bold text, B: bold and italic text, c: code fragments,
"   e: common HTML entities, s: escapes
if !has("conceal")
  let s:markdown_conceal = ''
elseif !exists("g:markdown_conceal")
  let s:markdown_conceal = '#*dlaibBces'
else
  let s:markdown_conceal = g:markdown_conceal
endif

" Decide whether to render list bullets as a proper bullet character.
let s:conceal_bullets = (&encoding == 'utf-8' && s:markdown_conceal =~ '*')

syn sync minlines=10
syn case ignore

syn match markdownValid '[<>]\S\@!'
syn match markdownValid '&\%(#\=\w*;\)\@!'

syn match markdownLineStart "^[<@]\@!" nextgroup=@markdownBlock

syn cluster markdownBlock contains=markdownH1,markdownH2,markdownH3,markdownH4,markdownH5,markdownH6,markdownBlockquote,markdownListMarker,markdownOrderedListMarker,markdownCodeBlock,markdownRule
syn cluster markdownInline contains=markdownLineBreak,markdownLinkText,markdownItalic,markdownBold,markdownCode,markdownEscape,@htmlTop

syn match markdownH1 "^.\+\n=\+$" contained contains=@markdownInline,markdownHeadingRule
syn match markdownH2 "^.\+\n-\+$" contained contains=@markdownInline,markdownHeadingRule

syn match markdownHeadingRule "^[=-]\+$" contained

if s:markdown_conceal =~ '#'
  syn region markdownH1 matchgroup=markdownHeadingDelimiter start="##\@!\s*"      end="#*\s*$" keepend oneline contains=@markdownInline contained concealends
  syn region markdownH2 matchgroup=markdownHeadingDelimiter start="###\@!\s*"     end="#*\s*$" keepend oneline contains=@markdownInline contained concealends
  syn region markdownH3 matchgroup=markdownHeadingDelimiter start="####\@!\s*"    end="#*\s*$" keepend oneline contains=@markdownInline contained concealends
  syn region markdownH4 matchgroup=markdownHeadingDelimiter start="#####\@!\s*"   end="#*\s*$" keepend oneline contains=@markdownInline contained concealends
  syn region markdownH5 matchgroup=markdownHeadingDelimiter start="######\@!\s*"  end="#*\s*$" keepend oneline contains=@markdownInline contained concealends
  syn region markdownH6 matchgroup=markdownHeadingDelimiter start="#######\@!\s*" end="#*\s*$" keepend oneline contains=@markdownInline contained concealends
else
  syn region markdownH1 matchgroup=markdownHeadingDelimiter start="##\@!"      end="#*\s*$" keepend oneline contains=@markdownInline contained
  syn region markdownH2 matchgroup=markdownHeadingDelimiter start="###\@!"     end="#*\s*$" keepend oneline contains=@markdownInline contained
  syn region markdownH3 matchgroup=markdownHeadingDelimiter start="####\@!"    end="#*\s*$" keepend oneline contains=@markdownInline contained
  syn region markdownH4 matchgroup=markdownHeadingDelimiter start="#####\@!"   end="#*\s*$" keepend oneline contains=@markdownInline contained
  syn region markdownH5 matchgroup=markdownHeadingDelimiter start="######\@!"  end="#*\s*$" keepend oneline contains=@markdownInline contained
  syn region markdownH6 matchgroup=markdownHeadingDelimiter start="#######\@!" end="#*\s*$" keepend oneline contains=@markdownInline contained
endif

syn match markdownBlockquote ">\s" contained nextgroup=@markdownBlock

syn region markdownCodeBlock start="    \|\t" end="$" contained

" TODO: real nesting
syn match markdownListMarker " \{0,4\}[-*+]\%(\s\+\S\)\@=" contained
syn match markdownOrderedListMarker " \{0,4}\<\d\+\.\%(\s*\S\)\@=" contained

if s:conceal_bullets
  syntax match markdownPrettyListMarker /[-*+]/ conceal cchar=• contained containedin=markdownListMarker
endif

syn match markdownRule "\* *\* *\*[ *]*$" contained
syn match markdownRule "- *- *-[ -]*$" contained

syn match markdownLineBreak "\s\{2,\}$"

if s:markdown_conceal =~# 'd'
  syn region markdownIdDeclaration matchgroup=markdownLinkDelimiter start="^ \{0,3\}!\=\[" end="\]\ze:" oneline keepend nextgroup=markdownUrl skipwhite concealends
else
  syn region markdownIdDeclaration matchgroup=markdownLinkDelimiter start="^ \{0,3\}!\=\[" end="\]:" oneline keepend nextgroup=markdownUrl skipwhite
endif

syn match markdownUrl "\S\+" nextgroup=markdownUrlTitle skipwhite contained
syn region markdownUrl matchgroup=markdownUrlDelimiter start="<" end=">" oneline keepend nextgroup=markdownUrlTitle skipwhite contained
syn region markdownUrlTitle matchgroup=markdownUrlTitleDelimiter start=+"+ end=+"+ keepend contained
syn region markdownUrlTitle matchgroup=markdownUrlTitleDelimiter start=+'+ end=+'+ keepend contained
syn region markdownUrlTitle matchgroup=markdownUrlTitleDelimiter start=+(+ end=+)+ keepend contained

if s:markdown_conceal =~# 'l'
  syn region markdownLinkText matchgroup=markdownLinkTextDelimiter start="!\=\[\%(\_[^]]*]\%( \=[[(]\)\)\@=" end="\]\%( \=[[(]\)\@=" keepend nextgroup=markdownLink,markdownId skipwhite contains=@markdownInline,markdownLineStart concealends
  syn region markdownLink matchgroup=markdownLinkDelimiter start="(" end=")" contains=markdownUrl keepend contained conceal
  syn region markdownId matchgroup=markdownIdDelimiter start="\s*\[" end="\]" keepend contained conceal
else
  syn region markdownLinkText matchgroup=markdownLinkTextDelimiter start="!\=\[\%(\_[^]]*]\%( \=[[(]\)\)\@=" end="\]\%( \=[[(]\)\@=" keepend nextgroup=markdownLink,markdownId skipwhite contains=@markdownInline,markdownLineStart
  syn region markdownLink matchgroup=markdownLinkDelimiter start="(" end=")" contains=markdownUrl keepend contained
  syn region markdownId matchgroup=markdownIdDelimiter start="\[" end="\]" keepend contained
endif

if s:markdown_conceal =~# 'a'
  syn region markdownAutomaticLink matchgroup=markdownUrlDelimiter start="<\%(\w\+:\|[[:alnum:]_+-]\+@\)\@=" end=">" keepend oneline concealends
else
  syn region markdownAutomaticLink matchgroup=markdownUrlDelimiter start="<\%(\w\+:\|[[:alnum:]_+-]\+@\)\@=" end=">" keepend oneline
endif

if s:markdown_conceal =~# 'i'
  syn region markdownItalic matchgroup=markdownItalicDelimiter start="\S\@<=\*\|\*\S\@=" end="\S\@<=\*\|\*\S\@=" keepend contains=markdownLineStart concealends
  syn region markdownItalic matchgroup=markdownItalicDelimiter start="\S\@<=_\|_\S\@=" end="\S\@<=_\|_\S\@=" keepend contains=markdownLineStart concealends
else
  syn region markdownItalic start="\S\@<=\*\|\*\S\@=" end="\S\@<=\*\|\*\S\@=" keepend contains=markdownLineStart
  syn region markdownItalic start="\S\@<=_\|_\S\@=" end="\S\@<=_\|_\S\@=" keepend contains=markdownLineStart
endif

if s:markdown_conceal =~# 'b'
  syn region markdownBold matchgroup=markdownBolDelimiter start="\S\@<=\*\*\|\*\*\S\@=" end="\S\@<=\*\*\|\*\*\S\@=" keepend contains=markdownLineStart concealends
  syn region markdownBold matchgroup=markdownBolDelimiter start="\S\@<=__\|__\S\@=" end="\S\@<=__\|__\S\@=" keepend contains=markdownLineStart concealends
else
  syn region markdownBold start="\S\@<=\*\*\|\*\*\S\@=" end="\S\@<=\*\*\|\*\*\S\@=" keepend contains=markdownLineStart
  syn region markdownBold start="\S\@<=__\|__\S\@=" end="\S\@<=__\|__\S\@=" keepend contains=markdownLineStart
endif

if s:markdown_conceal =~# 'B'
  syn region markdownBoldItalic matchgroup=markdownBoldItalicDelimiter start="\S\@<=\*\*\*\|\*\*\*\S\@=" end="\S\@<=\*\*\*\|\*\*\*\S\@=" keepend contains=markdownLineStart concealends
  syn region markdownBoldItalic matchgroup=markdownBoldItalicDelimiter start="\S\@<=___\|___\S\@=" end="\S\@<=___\|___\S\@=" keepend contains=markdownLineStart concealends
else
  syn region markdownBoldItalic start="\S\@<=\*\*\*\|\*\*\*\S\@=" end="\S\@<=\*\*\*\|\*\*\*\S\@=" keepend contains=markdownLineStart
  syn region markdownBoldItalic start="\S\@<=___\|___\S\@=" end="\S\@<=___\|___\S\@=" keepend contains=markdownLineStart
endif

if s:markdown_conceal =~# 'c'
  syn region markdownCode matchgroup=markdownCodeDelimiter start="`" end="`" keepend contains=markdownLineStart concealends
  syn region markdownCode matchgroup=markdownCodeDelimiter start="`` \=" end=" \=``" keepend contains=markdownLineStart concealends
  syn region markdownCode matchgroup=markdownCodeDelimiter start="^\s*\zs```\s*\w*\ze\s*$" end="^```\ze\s*$" keepend concealends
else
  syn region markdownCode matchgroup=markdownCodeDelimiter start="`" end="`" keepend contains=markdownLineStart
  syn region markdownCode matchgroup=markdownCodeDelimiter start="`` \=" end=" \=``" keepend contains=markdownLineStart
  syn region markdownCode matchgroup=markdownCodeDelimiter start="^\s*\zs```\s*\w*\ze\s*$" end="^```\ze\s*$" keepend
endif

syn match markdownEscape "\\[][\\`*_{}()#+.!-]"
if s:markdown_conceal =~# 's'
  syn match markdownEscapeMarker "\\" contained containedin=markdownEscape conceal
endif

syn match markdownError "\w\@<=_\w\@="

if s:markdown_conceal =~# 'e'
  " There's no equivalent for these without the conceal feature.
  syntax match markdownLessThan /&lt;/ conceal cchar=<
  syntax match markdownGreaterThan /&gt;/ conceal cchar=>
  syntax match markdownAmpersand /&amp;/ conceal cchar=&
endif

if s:markdown_conceal =~# '[*e]'
  " The "conceal cchar=..." characters (list bullets and HTML entities) look
  " really crappy by default because of the default styling for "concealed"
  " characters. We want it to look more or less like regular text:
  hi link Conceal htmlTagName
endif

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
hi def link markdownBold                  htmlBold
hi def link markdownBoldItalic            htmlBoldItalic
hi def link markdownCodeDelimiter         Delimiter

hi def link markdownEscape                Special
hi def link markdownError                 Error

if s:conceal_bullets
  hi def link markdownPrettyListMarker markdownListMarker
endif

if s:markdown_conceal =~# 'e'
  hi def link markdownLessThan markdownListMarker
  hi def link markdownGreaterThan markdownListMarker
  hi def link markdownAmpersand markdownListMarker
endif

let b:current_syntax = "markdown"

" vim:set sw=2:
