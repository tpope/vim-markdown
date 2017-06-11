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

syn match markdown "^" nextgroup=@markdownBlockL0
syn cluster markdownInline contains=markdownLineBreak,markdownLinkText,markdownItalic,markdownBold,markdownCode,markdownEscape,@htmlTop,markdownError,markdownHighlighttex,markdownAutomaticLink

syn match markdownLineBreak " \{2,}$"

if !exists('g:markdown_list_nesting_depth')
  let g:markdown_list_nesting_depth = 2
endif
let s:nesting = g:markdown_list_nesting_depth
while s:nesting >= 0
  let s:indent_num = s:nesting * &tabstop
  let s:indent_pat = ' \{' . s:indent_num . ',' . (s:indent_num + &tabstop - 1) . '}'
  if s:nesting == 0
    exe 'syn cluster markdownBlockL' . s:nesting . ' contains=markdownList,markdownParagraphL' . s:nesting . ',markdownRuleL' . s:nesting . ',markdownBlockquoteL' . s:nesting . ',markdownCodeBlockL' . s:nesting . ',@markdownHeadingL' . s:nesting
  else
    exe 'syn cluster markdownBlockL' . s:nesting . ' contains=markdownListItemBlockL' . s:nesting . ',markdownParagraphL' . s:nesting . ',markdownRuleL' . s:nesting . ',markdownBlockquoteL' . s:nesting . ',markdownCodeBlockL' . s:nesting . ',@markdownHeadingL' . s:nesting
  endif

  exe 'syn region markdownParagraphL' . s:nesting . ' start="^' . s:indent_pat . '\%(#.\+\)\@!\S" end="^\s*$\|\%(\n' . s:indent_pat . '\%(#.\+\|>\s*\)\)\@=" keepend contains=@markdownInline contained'

  exe 'syn match markdownRuleL' . s:nesting . ' "' . s:indent_pat . '\* *\* *\*[ *]*$" contained'
  exe 'syn match markdownRuleL' . s:nesting . ' "' . s:indent_pat . '- *- *-[ -]*$" contained'

  exe 'syn region markdownBlockquoteL' . s:nesting . ' matchgroup=markdownBlockquoteDelimiter start="' . s:indent_pat . '>\%(\s\|$\)" end="$" contains=@markdownInline contained'

  exe 'syn region markdownCodeBlockL' . s:nesting . ' start=" \{' . (s:indent_num + &tabstop) . '}" end="$" contained'

  exe 'syn cluster markdownHeadingL' . s:nesting . ' contains=markdownH1L' . s:nesting . ',markdownH2L' . s:nesting . ',markdownH3L' . s:nesting . ',markdownH4L' . s:nesting . ',markdownH5L' . s:nesting . ',markdownH6L' . s:nesting
  exe 'syn match markdownH1L' . s:nesting . ' "\%(\%(^\s*\n\)\@<=\|\%^\) \{' . s:indent_num . '}\s*\S.*\n \{' . s:indent_num . '}=\+\s*$" contains=@markdownInline,markdownHeadingRuleL' . s:nesting . ' contained'
  exe 'syn match markdownH2L' . s:nesting . ' "\%(\%(^\s*\n\)\@<=\|\%^\) \{' . s:indent_num . '}\s*\S.*\n \{' . s:indent_num . '}-\+\s*$" contains=@markdownInline,markdownHeadingRuleL' . s:nesting . ' contained'
  exe 'syn match markdownHeadingRuleL' . s:nesting . ' "^ \{' . s:indent_num . '}[=-]\+\s*$" contained'
  exe 'syn region markdownH1L' . s:nesting . ' matchgroup=markdownHeadingDelimiter start="^ \{' . s:indent_num . '}##\@!"      end="$" keepend oneline contains=@markdownInline contained'
  exe 'syn region markdownH2L' . s:nesting . ' matchgroup=markdownHeadingDelimiter start="^ \{' . s:indent_num . '}###\@!"     end="$" keepend oneline contains=@markdownInline contained'
  exe 'syn region markdownH3L' . s:nesting . ' matchgroup=markdownHeadingDelimiter start="^ \{' . s:indent_num . '}####\@!"    end="$" keepend oneline contains=@markdownInline contained'
  exe 'syn region markdownH4L' . s:nesting . ' matchgroup=markdownHeadingDelimiter start="^ \{' . s:indent_num . '}#####\@!"   end="$" keepend oneline contains=@markdownInline contained'
  exe 'syn region markdownH5L' . s:nesting . ' matchgroup=markdownHeadingDelimiter start="^ \{' . s:indent_num . '}######\@!"  end="$" keepend oneline contains=@markdownInline contained'
  exe 'syn region markdownH6L' . s:nesting . ' matchgroup=markdownHeadingDelimiter start="^ \{' . s:indent_num . '}#######\@!" end="$" keepend oneline contains=@markdownInline contained'

  if s:nesting == 0
    exe 'syn region markdownList start="\%(\%(^\s*\n\)\@<=\|\%^\)' . s:indent_pat . '\%([*+-]\|\d\+\.\)\s\+\S" end="^\s*\%(\n' . s:indent_pat . '\S\)\@=\n" contained keepend contains=markdownListItemBlockL' . s:nesting
  endif

  exe 'syn region markdownListItemBlockL' . s:nesting . ' start="^' . s:indent_pat . '\%([*+-]\|\d\+\.\)\s\+\S" end="\n\%(' . s:indent_pat . '\%([*+-]\|\d\+\.\)\s\+\S\)\@=\|^\s*\%(\n' . s:indent_pat . '\S\)\@=\n" contained keepend contains=markdownListItemL' . s:nesting . ',markdownListMarkerL' . s:nesting . ',@markdownBlockL' . (s:nesting + 1)
  exe 'syn match markdownListMarkerL' . s:nesting . ' "\%(^' . s:indent_pat . '\)\@<=\%([*+-]\|\d\+\.\)\%(\s\+\S\)\@=" contained'
  exe 'syn match markdownListItemL' . s:nesting . ' "\%(^' . s:indent_pat . '\%([*+-]\|\d\+\.\)\s\+\)\@<=\S.*\%(\n\%( *\%([*+-]\|\d\+\.\)\s\+\S\)\@!\s*\S.*\)*$" contained keepend contains=@markdownInline'

  exe 'hi def link markdownBlockL' . s:nesting . ' markdownBlock'
  exe 'hi def link markdownParagraphL' . s:nesting . ' markdownParagraph'
  exe 'hi def link markdownRuleL' . s:nesting . ' markdownRule'
  exe 'hi def link markdownBlockquoteL' . s:nesting . ' markdownBlockquote'
  exe 'hi def link markdownCodeBlockL' . s:nesting . ' markdownCodeBlock'
  exe 'hi def link markdownHeadingL' . s:nesting . ' markdownHeading'
  exe 'hi def link markdownHeadingRuleL' . s:nesting . ' markdownHeadingRule'
  exe 'hi def link markdownH1L' . s:nesting . ' markdownH1'
  exe 'hi def link markdownH2L' . s:nesting . ' markdownH2'
  exe 'hi def link markdownH3L' . s:nesting . ' markdownH3'
  exe 'hi def link markdownH4L' . s:nesting . ' markdownH4'
  exe 'hi def link markdownH5L' . s:nesting . ' markdownH5'
  exe 'hi def link markdownH6L' . s:nesting . ' markdownH6'
  exe 'hi def link markdownListItemBlockL' . s:nesting . ' markdownListItemBlock'
  exe 'hi def link markdownListMarkerL' . s:nesting . ' markdownListMarker'
  exe 'hi def link markdownListItemL' . s:nesting . ' markdownListItem'

  let s:nesting -= 1
endwhile

syn match markdownUrl "\S\+" nextgroup=markdownUrlTitle skipwhite contained
syn region markdownUrl matchgroup=markdownUrlDelimiter start="<" end=">" oneline keepend nextgroup=markdownUrlTitle skipwhite contained
syn region markdownUrlTitle matchgroup=markdownUrlTitleDelimiter start=+"+ end=+"+ keepend contained
syn region markdownUrlTitle matchgroup=markdownUrlTitleDelimiter start=+'+ end=+'+ keepend contained
syn region markdownUrlTitle matchgroup=markdownUrlTitleDelimiter start=+(+ end=+)+ keepend contained

syn region markdownLinkText matchgroup=markdownLinkTextDelimiter start="!\=\[\%(\_[^]]*]\%( \=[[(]\)\)\@=" end="\]\%( \=[[(]\)\@=" nextgroup=markdownLink,markdownId skipwhite contains=@markdownInline,markdownLineStart
syn region markdownLink matchgroup=markdownLinkDelimiter start="(" end=")" contains=markdownUrl keepend contained
syn region markdownId matchgroup=markdownIdDelimiter start="\[" end="\]" keepend contained
syn region markdownAutomaticLink matchgroup=markdownUrlDelimiter start="<\%(\w\+:\|[[:alnum:]_+-]\+@\)\@=" end=">" keepend oneline contained

syn region markdownItalic matchgroup=markdownItalicDelimiter start="\S\@<=\*\|\*\S\@=" end="\S\@<=\*\|\*\S\@=" keepend contained contains=markdownLineStart
syn region markdownItalic matchgroup=markdownItalicDelimiter start="\S\@<=_\|_\S\@=" end="\S\@<=_\|_\S\@=" keepend contained contains=markdownLineStart
syn region markdownBold matchgroup=markdownBoldDelimiter start="\S\@<=\*\*\|\*\*\S\@=" end="\S\@<=\*\*\|\*\*\S\@=" keepend contained contains=markdownLineStart,markdownItalic
syn region markdownBold matchgroup=markdownBoldDelimiter start="\S\@<=__\|__\S\@=" end="\S\@<=__\|__\S\@=" keepend contained contains=markdownLineStart,markdownItalic
syn region markdownBoldItalic matchgroup=markdownBoldItalicDelimiter start="\S\@<=\*\*\*\|\*\*\*\S\@=" end="\S\@<=\*\*\*\|\*\*\*\S\@=" keepend contained contains=markdownLineStart
syn region markdownBoldItalic matchgroup=markdownBoldItalicDelimiter start="\S\@<=___\|___\S\@=" end="\S\@<=___\|___\S\@=" keepend contained contains=markdownLineStart

syn region markdownCode matchgroup=markdownCodeDelimiter start="`" end="`" keepend contains=markdownLineStart
syn region markdownCode matchgroup=markdownCodeDelimiter start="`` \=" end=" \=``" keepend contains=markdownLineStart
syn region markdownCode matchgroup=markdownCodeDelimiter start="^\s*```.*$" end="^\s*```\ze\s*$" keepend

syn match markdownFootnote "\[^[^\]]\+\]"
syn match markdownFootnoteDefinition "^\[^[^\]]\+\]:"

if main_syntax ==# 'markdown'
  for s:type in g:markdown_fenced_languages
    exe 'syn region markdownHighlight'.substitute(matchstr(s:type,'[^=]*$'),'\..*','','').' matchgroup=markdownCodeDelimiter start="^\s*```\s*'.matchstr(s:type,'[^=]*').'\>.*$" end="^\s*```\ze\s*$" keepend contains=@markdownHighlight'.substitute(matchstr(s:type,'[^=]*$'),'\.','','g')
  endfor
  unlet! s:type
endif

syn match markdownEscape "\\[][\\`*_{}()#+.!-]"
syn match markdownError "\w\@<=_\w\@="

let g:tex_no_error=1
syn include syntax/tex.vim
syn region markdownHighlighttex matchgroup=markdownCodeDelimiter start="\\\\(\ze[^ \n]" end="[^ \n]\zs\\\\)" keepend contains=@texMathZoneGroup
syn region markdownHighlighttex matchgroup=markdownCodeDelimiter start="\\\\\[" end="\\\\\]" keepend contains=@texMathZoneGroup
syn region markdownHighlighttex matchgroup=markdownCodeDelimiter start="\$\ze[^ \n]" end="[^ \n]\zs\$" keepend contains=@texMathZoneGroup
syn region markdownHighlighttex matchgroup=markdownCodeDelimiter start="\$\$" end="\$\$" keepend contains=@texMathZoneGroup

hi def link markdownH1                    htmlH1
hi def link markdownH2                    htmlH2
hi def link markdownH3                    htmlH3
hi def link markdownH4                    htmlH4
hi def link markdownH5                    htmlH5
hi def link markdownH6                    htmlH6
hi def link markdownHeadingRule           markdownRule
hi def link markdownHeadingDelimiter      Delimiter
hi def link markdownListMarkerL1          htmlTagName
hi def link markdownListMarkerL2          htmlTagName
hi def link markdownBlockquoteDelimiter   Comment
hi     link markdownBlockquote            Normal
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

hi def link markdownEscape                Special
hi def link markdownError                 Error

let b:current_syntax = "markdown"
if main_syntax ==# 'markdown'
  unlet main_syntax
endif

" vim:set sw=2:
