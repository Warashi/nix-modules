language message C
set nocompatible

augroup MyAutoCmd
  autocmd!
augroup END

let g:denops#deno = '@deno@'

set runtimepath^=@merged_plugins@

" --------------------------------------------------
"  Skkeleton Configuration
" --------------------------------------------------
function s:skkeleton_initialize()
  call skkeleton#config(#{
  \   globalDictionaries: ['@skk_jisyo_l@'],
  \ })
endfunction

inoremap <C-j> <Plug>(skkeleton-enable)

augroup MyAutoCmd
  autocmd User skkeleton-initialize-pre call s:skkeleton_initialize()
augroup END

call skkeleton#initialize()

" --------------------------------------------------
"  DDC Configuration
" --------------------------------------------------
call ddc#custom#load_config('@ddc_config_ts@')

inoremap <expr><C-n> pum#visible() ? '<Cmd>call pum#map#select_relative(1)<CR>' : '<C-n>'
inoremap <expr><C-p> pum#visible() ? '<Cmd>call pum#map#select_relative(-1)<CR>' : '<C-p>'
inoremap <expr><C-y> pum#visible() ? '<Cmd>call pum#map#confirm_suffix()<CR>' : '<C-y>'

call ddc#enable()

" --------------------------------------------------
"  Start in Insert Mode
" --------------------------------------------------
augroup MyAutoCmd
  autocmd InsertEnter * ++once call skkeleton#handle('enable', {})
  autocmd BufWinEnter * startinsert
augroup END
