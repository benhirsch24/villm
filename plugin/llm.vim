command! -nargs=* LLMConfig call llm#LLM_Config(<q-args>)
command! -nargs=* LLMChat call llm#LLM_Chat(<q-args>)
command! -nargs=* LLMInsert call llm#LLM_Insert(<q-args>)
command! -range -nargs=* LLMRewrite call llm#LLM_Rewrite(<q-args>)

function! llm#LLM_Config(prompt)
    python3 << EOF
import boto3
import json
import vim

print('No current real configuration needed')
EOF
endfunction

function! llm#LLM_Chat(prompt)
    let l:python_path = '/Users/ben/.vim/bundle/villm/python'

    " Call the python script
    python3 << EOF
import sys
import vim
path = vim.eval('l:python_path')
sys.path.insert(0, path)
import llm

# Get prompt from arg
prompt = vim.eval("a:prompt")

response = llm.call_llm(prompt)
vim.command(f"let g:llm_response = '{response}'")
EOF

    let l:response = g:llm_response
    if l:response !=# 'Error'
        call setreg('"', l:response)
	echo l:response
    else
        echo "Error: "
    endif
endfunction

function! llm#LLM_Insert(prompt)
    let l:python_path = '/Users/ben/.vim/bundle/villm/python'
    echo l:python_path
    python3 << EOF
import sys
import vim
path = vim.eval('l:python_path')
sys.path.insert(0, path)

import llm

# Get prompt from arg
prompt = vim.eval("a:prompt")

response = llm.call_llm(prompt)
code = llm.extract_first_code_block(response)
vim.command(f"let g:llm_response = '{response}'")
vim.command(f"let g:code = '{code}'")
EOF
    " Fetch the response stored in the global variable
    let response = g:llm_response
    let code = g:code

    " Insert the response at the current cursor position
    if response !=# 'Error'
        " insert code at current position
        set paste
        execute "normal! i" . code
	set nopaste

	" record current window
	let l:currentWindow=winnr()

	" Paste full response in split
	execute "new"
	execute "normal! i" . response

        " Go back to the original window
        exe l:currentWindow . "wincmd w"
    else
        echo "No valid response available to insert."
    endif
endfunction

function! llm#get_visual_selection()
    " Why is this not a built-in Vim script function?!
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, "\n")
endfunction

function! llm#LLM_Rewrite(prompt) range
    let l:selected_text = llm#get_visual_selection()

    " Prepare the full prompt by combining the user's input with the selected text
    let l:full_prompt = a:prompt . "\n\n" . l:selected_text

    let l:script_path = expand('<sfile>:p:h')
    let l:python_path = '/Users/ben/.vim/bundle/villm/python'

    " Call the LLM with the full prompt
    python3 << EOF
import sys
import vim
path = vim.eval('l:python_path')
sys.path.insert(0, path)
import llm

# Get prompt from arg
prompt = vim.eval("l:full_prompt")

response = llm.call_llm(prompt)
vim.command(f"let g:llm_response = '{response}'")
EOF

    " Fetch the response
    let l:response = l:selected_text . "\n" . g:llm_response

    if mode() ==# 'v' || mode() ==# 'V'
        let l:start_line = getpos("'<")[1]
        let l:end_line = getpos("'>")[1]
    else
        let l:start_line = a:firstline
        let l:end_line = a:lastline
    endif


    " Replace the selected text with the response
    if l:response !=# 'Error'
        " Replace the selected lines with the response
        call setline(l:start_line, split(l:response, "\n"))
        if l:end_line > l:start_line
            call deletebufline('%', l:start_line + 1, l:end_line)
        endif
    else
        echo "Error in LLM response: " . l:response
    endif
endfunction

function! OpenPasteAndSwitch()
    " Save the current buffer name
    let old_buffer = bufnr('')

    " Open a vertical split and switch to it
    execute 'vsplit' . old_buffer

    " Paste the current buffer's contents into the new buffer
    " This assumes the current buffer has text to paste
    " You might need to adjust this part based on your specific needs
    execute 'normal! P'

    " Switch back to the original buffer
    execute 'buffer ' . old_buffer
endfunction
