if exists('g:loaded_lsp_settings_python')
  finish
endif

let g:loaded_lsp_settings_python = 1

call lsp_settings_python#init()
