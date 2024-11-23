command! -nargs=* LLMConfig call llm#LLM_Config(<q-args>)
command! -nargs=* LLMChat call llm#LLM_Chat(<q-args>)
command! -nargs=* LLMInsert call llm#LLM_Insert(<q-args>)
command! -range -nargs=* LLMRewrite call llm#LLM_Rewrite(<q-args>)

if !exists('g:villm_aws_profile')
    let g:villm_aws_profile = 'default'  " Default AWS profile
endif

if !exists('g:villm_aws_bedrock_model_id')
    let g:villm_aws_bedrock_model_id = 'anthropic.claude-3-5-sonnet-20241022-v2:0'  " Default model
endif

if !exists('g:villm_aws_region')
    let g:villm_aws_region = 'us-west-2'  " Default AWS region
endif

function! llm#LLM_Config(prompt)
    python3 << EOF
import boto3
import json
import vim

# Get global config
profile = vim.vars.get('villm_aws_profile', 'default').decode('utf-8')
model_id = vim.vars.get('villm_aws_bedrock_model_id', 'anthropic.claude-3-5-sonnet-20241022-v2:0').decode('utf-8')
region = vim.vars.get('villm_aws_region', 'us-west-2').decode('utf-8')
print(f"{profile} {model_id} {region}")
EOF
endfunction

function! llm#LLM_Chat(prompt)
    python3 << EOF
import boto3
import json
import vim

# Get global config
profile = vim.vars.get('villm_aws_profile', 'default').decode('utf-8')
model_id = vim.vars.get('villm_aws_bedrock_model_id', 'anthropic.claude-3-5-sonnet-20241022-v2:0').decode('utf-8')
region = vim.vars.get('villm_aws_region', 'us-west-2').decode('utf-8')

# Initialize Bedrock client
session = boto3.Session(profile_name=profile)
bedrock = session.client('bedrock-runtime', region_name=region)

# Get the prompt from function args
prompt = vim.eval("a:prompt")

# Prepare the request body
request_body = {
    "anthropic_version": "bedrock-2023-05-31",
    "max_tokens": 1000,
    "messages": [
        {
            "role": "user",
            "content": prompt
        }
    ],
    "temperature": 0.7
}

try:
    # Call Bedrock with Claude model
    response = bedrock.invoke_model(
        modelId=model_id,
        body=json.dumps(request_body)
    )

    # Parse the response
    response_body = json.loads(response['body'].read())
    response_text = response_body['content'][0]['text']
    response_text = response_text.replace('\'', '\'\'')

    # Set the response in Vim's global variable
    vim.command(f"let g:llm_response = '{response_text}'")

except Exception as e:
    # Handle errors
    error_message = str(e).replace("'", "''")
    vim.command(f"let g:llm_response = 'Error: {error_message}'")

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
    python3 << EOF
import boto3
import json
import vim

# Get global config
profile = vim.vars.get('villm_aws_profile', 'default').decode('utf-8')
model_id = vim.vars.get('villm_aws_bedrock_model_id', 'anthropic.claude-3-5-sonnet-20241022-v2:0').decode('utf-8')
region = vim.vars.get('villm_aws_region', 'us-west-2').decode('utf-8')

# Initialize Bedrock client
session = boto3.Session(profile_name=profile)
bedrock = session.client('bedrock-runtime', region_name=region)

prompt = vim.eval("a:prompt")

# Prepare the request body
request_body = {
    "anthropic_version": "bedrock-2023-05-31",
    "max_tokens": 1000,
    "messages": [
        {
            "role": "user",
            "content": prompt
        }
    ],
    "temperature": 0.7
}

try:
    # Call Bedrock with Claude model
    response = bedrock.invoke_model(
        modelId=model_id,
        body=json.dumps(request_body)
    )

    # Parse the response
    response_body = json.loads(response['body'].read())
    response_text = response_body['content'][0]['text']
    response_text = response_text.replace('\'', '\'\'')

    # Set the response in Vim's global variable
    vim.command(f"let g:llm_response = '{response_text}'")

except Exception as e:
    # Handle errors
    error_message = str(e).replace("'", "''")
    vim.command(f"let g:llm_response = 'Error: {error_message}'")

EOF
    " Fetch the response stored in the global variable
    let response = g:llm_response

    " Insert the response at the current cursor position
    if response !=# 'Error'
        execute "normal! i" . response
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

    " Call the LLM with the full prompt
    python3 << EOF
import boto3
import json
import vim


# Get global config
profile = vim.vars.get('villm_aws_profile', 'default').decode('utf-8')
model_id = vim.vars.get('villm_aws_bedrock_model_id', 'anthropic.claude-3-5-sonnet-20241022-v2:0').decode('utf-8')
region = vim.vars.get('villm_aws_region', 'us-west-2').decode('utf-8')

# Initialize Bedrock client
session = boto3.Session(profile_name=profile)
bedrock = session.client('bedrock-runtime', region_name=region)

# Fetch the prompt and selected text
full_prompt = vim.eval("l:full_prompt")

# Prepare the request body
request_body = {
    "anthropic_version": "bedrock-2023-05-31",
    "max_tokens": 1000,
    "messages": [
        {
            "role": "user",
            "content": full_prompt
        }
    ],
    "temperature": 0.7
}

try:
    # Call Bedrock with Claude model
    response = bedrock.invoke_model(
        modelId=model_id,
        body=json.dumps(request_body)
    )

    # Parse the response
    response_body = json.loads(response['body'].read())
    response_text = response_body['content'][0]['text']
    response_text = response_text.replace('\'', '\'\'')

    # Set the response to a Vim variable
    vim.command(f"let g:llm_response = '{response_text}'")

except Exception as e:
    # Handle errors
    error_message = str(e).replace("'", "''")
    vim.command(f"let g:llm_response = 'Error: {error_message}'")

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
