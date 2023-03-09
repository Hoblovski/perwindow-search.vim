" perwindow-search.vim 
" Description:  Allows each vim window to have its own search patterns
" Maintainer:   Hoblovski <https://github.com/Hoblovski/>
" Version:      0.1


" Dont use builtin hl-Search because we want search results to be highlighted
" only in current window, while hl-Search in one window causes results in
" another window to be highlighted. Alternatively we use custom highlight
" groups, and manually call clearmatches() and matchadd().
set nohlsearch

function! s:DefineSearchHighlights()
  hi SearchInactive term=reverse ctermfg=0 ctermbg=magenta
  hi SearchActive term=reverse ctermfg=0 ctermbg=cyan
endfunction

function! s:UndefineSearchHighlights()
  hi clear SearchInactive
  hi clear SearchActive
endfunction
call <SID>UndefineSearchHighlights()

" on new window:
" * inherit search pattern
" the highlight part is done subsequently by WinEnter
au WinNew,VimEnter,TabNew   * let w:pws_ptn=''

" on leave window:
" * save search pattern
" * update highlight matches: set search results in current window to inactive
au WinLeave * call clearmatches() |
            \ let w:pws_ptn=@/ |
            \ call matchadd('SearchInactive', w:pws_ptn, 0)

" on enter window:
" * restore search pattern
" * update highlight matches: set search results in current window to active
au WinEnter * call clearmatches() |
            \ let @/=w:pws_ptn |
            \ call matchadd('SearchActive', w:pws_ptn, 0)

" on search:
" * update highlight matches
"
" As of vim 8.1, there is no associated autocmd event associated with it.
" CmdlineLeave looks like ok, but on CmdlineLeave, @/ is not updated so we end
" up highlighting the the old pattern.
cnoremap <expr> <silent> <CR> getcmdtype() == '/' ? '<CR>:call <SID>AfterSlashRegChange()<CR>' : '<CR>'
function! s:AfterSlashRegChange()
  call clearmatches()
  call <SID>DefineSearchHighlights()
  call matchadd('SearchActive', @/, 0)
endfunction

" our own version of :nohls is keystroke sequence / <C-C>
cnoremap <expr> <silent> <C-C> getcmdtype() == '/' ? '<C-C>:call <SID>UndefineSearchHighlights()<CR>' : '<C-C>'

" like vim does, n N automatically sets :hls even if :nohls was
" previously set
nnoremap <silent> n n:call <SID>DefineSearchHighlights()<CR>
nnoremap <silent> N N:call <SID>DefineSearchHighlights()<CR>

nnoremap <silent> * *:call <SID>AfterSlashRegChange()<CR>
nnoremap <silent> # #:call <SID>AfterSlashRegChange()<CR>

