"=============================================================================
" File: knife.vim
" Author: Thom May <thom@clearairturbulence.org>
" Last Change: 03-Jun-2011
" Version: 0.0.1
" WebPage: https://github.com/thommay/knife.vim
" License: BSD
" Usage:
"   
"   :Knodes
"     get a list of current registered nodes
"
"   :Kroles
"     get a list of roles
"
"   :Krole role
"     create the specified role
"
"   :Kenvs
"     get a list of environments
"
"   :Kenv env
"     create a new environment
"
"   :Knife ...
"     pass the command line through to knife
"


if &cp || (exists('g:loaded_knife_vim') && g:loaded_knife_vim)
  finish
endif
let g:loaded_knife_vim = 1

if !executable('knife')
  echoerr "Knife requires the 'knife' command - install chef"
  finish
endif

" Note: A colon in the file name has side effects on Windows due to NTFS Alternate Data Streams; avoid it. 
let s:bufprefix = 'knife' . (has('unix') ? ':' : '_')
function! s:NodeList()
  let winnum = bufwinnr(bufnr(s:bufprefix.'nodelist'))
  if winnum != -1
    if winnum != bufwinnr('%')
      exe "normal \<c-w>".winnum."w"
    endif
    setlocal modifiable
  else
    exec 'silent split' s:bufprefix.'nodelist'
  endif
  silent %d _
  exec 'silent r! knife node list'
  silent normal! ggdd
  silent! %s/^\s*/node: /
  setlocal buftype=nofile bufhidden=hide noswapfile
  setlocal nomodified
  syntax match SpecialKey /^node:/he=e-1
  exec 'nnoremap <silent> <buffer> <cr> :call <SID>KnifeListAction()<cr>'
endfunction

function s:KnifeListAction()
  let line = getline('.')
  let mx = '^node: \(.*\)\s*'
  if line =~# mx
    let node = substitute(line, mx, '\1', '')
    call s:NodeGet(node)
    return
  endif
endfunction

function! Knode(...)
  let args = (a:0 > 0) ? split(a:1, ' ') : []
  for arg in args
    if arg == '-l'
      call s:NodeList()
    endif
  endfor
endfunction

command! -nargs=? -range=% Knode :call Knode(<f-args>)
