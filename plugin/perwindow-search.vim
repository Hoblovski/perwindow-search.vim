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
au WinNew,VimEnter,TabNew   * let w:pws_ptn=@/

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
            \ if !exists('w:pws_ptn') |
            \   let w:pws_ptn=@/ |
            \ else |
            \   let @/=w:pws_ptn |
            \ endif |
            \ call matchadd('SearchActive', w:pws_ptn, 0)

" on search:
" * update highlight matches
"
" As of vim 8.1, there is no associated autocmd event associated with it.
" CmdlineLeave looks like ok, but on CmdlineLeave, @/ is not updated so we end
" up highlighting the the old pattern.
cnoremap <expr> <silent> <CR> getcmdtype() == '/' ? '<CR>:call <SID>AfterSlashRegChange()<CR>' : '<CR>'
function! s:AfterSlashRegChange()
  let w:pws_ptn=@/
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

" Allows user to quickly set @/ to that of another window
function! s:SelectSearchPattern()
  echo 'Select search patterns'
  let lineid = 0
  let wininfos = getwininfo()
  echo printf('%3s : %3s [%3s] : %s', 'tab', 'win', 'idx', 'ptn')
  for win in wininfos
    if !has_key(win['variables'], 'pws_ptn')
      let lineid += 1
      echo '___'
      continue
    endif

    let idx = lineid
    if win['winid'] == win_getid()
      let idx = '**'
    endif
    echo printf('%3d : %3d [%3s] : %s', win['tabnr'], win['winnr'], idx, win['variables']['pws_ptn'])
    let lineid += 1
  endfor
  let x = input('Enter pattern idx, <C-C> to cancel...')
  if empty(x)
    return
  endif
  let x = str2nr(x)
  let win = wininfos[x]
  let @/ = win['variables']['pws_ptn']
  call <SID>AfterSlashRegChange()
endfunction

cnoremap <expr> <silent> <C-S> getcmdtype() == '/' ? '<C-C>:call <SID>SelectSearchPattern()<CR>' : '<C-S>'

