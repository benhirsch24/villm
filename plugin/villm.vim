command! -nargs=* LLMChat call villm#LLM_Chat(<q-args>)
command! -range -nargs=* LLMExplain call villm#LLM_Explain(<q-args>)
command! -nargs=* LLMInsert call villm#LLM_Insert(<q-args>)
command! -nargs=* LLMLastResponse call villm#LLM_LastResponse()
command! -range -nargs=* LLMRewrite call villm#LLM_Rewrite(<q-args>)
command! -nargs=* LLMModify call villm#LLM_Modify(<q-args>)

function! villm#LLM_Chat(prompt)
    let l:python_path = g:villm_path . '/python'

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
    let g:last_response = l:response
    if l:response !=# 'Error'
        call setreg('"', l:response)
	echo l:response
    else
        echo "Error: "
    endif
endfunction

function! villm#LLM_Insert(prompt)
    let l:python_path = g:villm_path . '/python'
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
    let g:last_response = response

    " Insert the response at the current cursor position
    if response !=# 'Error'
        " insert code at current position
        set paste
        execute "normal! i" . code
        set nopaste
    else
        echo "No valid response available to insert."
    endif
endfunction

function! villm#LLM_LastResponse()
    " record current window
    let l:currentWindow=winnr()

    " Paste full response in split
    execute "vnew"
    execute "normal! i" . g:last_response

    " Go back to the original window
    exe l:currentWindow . "wincmd w"
endfunction

function! villm#get_visual_selection()
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

function! villm#LLM_Rewrite(prompt) range
    let l:selected_text = villm#get_visual_selection()

    " Prepare the full prompt by combining the user's input with the selected text
    let l:full_prompt = a:prompt . "\n\n" . l:selected_text

    let l:script_path = expand('<sfile>:p:h')
    let l:python_path = g:villm_path . '/python'

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
code = llm.extract_first_code_block(response)
vim.command(f"let g:code = '{code}'")
vim.command(f"let g:response = '{response}'")
EOF

    " Fetch the response
    let response = g:response
    let code = g:code
    let g:last_response = response

    if mode() ==# 'v' || mode() ==# 'V'
        let l:start_line = getpos("'<")[1]
        let l:end_line = getpos("'>")[1]
    else
        let l:start_line = a:firstline
        let l:end_line = a:lastline
    endif


    " Replace the selected text with the response
    if response !=# 'Error'
        " Replace the selected lines with the response
        execute "normal! gvd"
        set paste
        execute "normal! i" . code . "\n"
        set nopaste
    else
        echo "Error in LLM response: " . l:response
    endif
endfunction

function! villm#LLM_Explain(prompt) range
    let l:selected_text = villm#get_visual_selection()

    " Prepare the full prompt by combining the user's input with the selected text
    let l:full_prompt = a:prompt . "\n\n" . l:selected_text

    let l:script_path = expand('<sfile>:p:h')
    let l:python_path = g:villm_path . '/python'

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
vim.command(f"let g:response = '{response}'")
EOF

    " Fetch the response
    let g:last_response = g:response

    " Replace the selected text with the response
    if g:last_response !=# 'Error'
        " record current window
        let l:currentWindow=winnr()

        " Paste full response in split
        execute "vnew"
        execute "normal! i" . g:last_response

        " Go back to the original window
        exe l:currentWindow . "wincmd w"
    else
        echo "Error in LLM response: " . l:last_response
    endif
endfunction

function! villm#LLM_Modify(prompt)
    " Get the current buffer content
    let l:current_content = join(getline(1, '$'), "\n")
    let l:python_path = g:villm_path . '/python'

    " Call the LLM and get the modified content
    python3 << EOF
import sys
import vim
path = vim.eval('l:python_path')
sys.path.insert(0, path)
import llm

# Get the file content and prompt
current_content = vim.eval("l:current_content")
prompt = vim.eval("a:prompt")

# Combine the prompt with the file content
full_prompt = f"The following will be instructions for how to modify a code file. Please follow the instructions and then return the new file with modifications in full.\n\n<instructions>{prompt}</instructions>\n\n<current_code>```{current_content}```</current_code>"

# Get the LLM's response
response = llm.call_llm(full_prompt)
code = llm.extract_first_code_block(response)

# Store the modified content in Vim's variable
vim.command(f"let g:llm_response = '{response}'")
vim.command(f"let g:code = '{code}'")
EOF

    " Check if the LLM returned a valid response
    if !exists('g:code') || g:code ==# ''
        echo "Error: No response from LLM."
        return
    endif

    let g:last_response = g:llm_response

    " Write the LLM's response to a temporary file
    let l:temp_file = tempname()
    call writefile(split(g:code, "\n"), l:temp_file)

    " Launch a diff between the current buffer and the temporary file
    execute "vert diffsplit " . l:temp_file
endfunction

