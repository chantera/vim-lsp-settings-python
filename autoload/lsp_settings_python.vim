function! lsp_settings_python#init() abort
  augroup vim_lsp_settings_python
    autocmd!
    autocmd FileType python call s:suggest('pylsp-all')
  augroup END

  command! LspInstallExtensions call s:install('pylsp-all')
endfunction

function! s:suggest(cmd) abort
  if !exists('g:loaded_lsp_settings') || !lsp_settings#executable(a:cmd)
    return
  endif

  let l:server_install_dir = lsp_settings#servers_dir() . '/' . a:cmd
  if executable(l:server_install_dir . '/venv/bin/mypy')
    return
  endif

  redraw!
  echohl Directory
  unsilent echomsg 'Please do :LspInstallExtensions'
  echohl None
endfunction

function! s:install(cmd) abort
  if !exists('g:loaded_lsp_settings')
    return
  elseif !lsp_settings#executable(a:cmd)
    call lsp_settings#utils#error(printf('Please do :LspInstallServer %s first', a:cmd))
    return
  endif

  let l:server_install_dir = lsp_settings#servers_dir() . '/' . a:cmd
  if executable(l:server_install_dir . '/venv/bin/mypy')
    call lsp_settings#utils#msg('extensions are already installed')
    return
  endif

  let l:packages = ['pylsp-mypy', 'python-lsp-isort', 'python-lsp-black']

  if confirm(printf('Add %s to %s?', join(l:packages, ', '), a:cmd), "&Yes\n&Cancel") !=# 1
    return
  endif

  let l:command = printf('./venv/bin/pip3 install %s', join(l:packages, ' '))
  if has('nvim')
    split new
    call termopen(l:command, {'cwd': l:server_install_dir, 'on_exit': function('s:on_installed', [l:command])})
  else
    let l:bufnr = term_start(l:command, {'cwd': l:server_install_dir})
    let l:job = term_getjob(l:bufnr)
    if l:job != v:null
      call job_setoptions(l:job, {'exit_cb': function('s:on_installed', [l:command])})
    endif
  endif
endfunction

function! s:on_installed(cmd, job, code, ...) abort
  if a:code == 0
    call lsp_settings#utils#msg(printf('SUCCESS: `%s`', a:cmd))
  else
    call lsp_settings#utils#error(printf('ERROR: `%s`', a:cmd))
  endif
endfunction
