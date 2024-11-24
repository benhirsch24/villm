import re
import subprocess

def sanitize_for_vim(value):
    """
    Sanitize a string for use in a Vim `let` command.

    :param value: The input string to sanitize.
    :return: A sanitized string safe for Vim.
    """
    if not isinstance(value, str):
        raise ValueError("Input must be a string")

    # Escape single quotes by doubling them
    sanitized = value.replace("'", "''")

    return sanitized

def extract_first_code_block(markdown):
    # Regular expression pattern to find code blocks
    code_block_pattern = r'```(.*?)```'

    # Find all matches of the code block pattern
    matches = re.findall(code_block_pattern, markdown, re.DOTALL)

    common_languages_i_use = ['python', 'rust', 'javascript', 'typescript', 'go', 'c++']

    # Return the first match if available, otherwise return an empty string
    if matches:
        block = matches[0].strip()
        bs = block.split('\n')
        if bs[0] in common_languages_i_use:
            bs = bs[1:]
        return sanitize_for_vim('\n'.join(bs))
    else:
        return ""


def call_llm(prompt):
    """
    Call the `llm` binary with the given prompt and return its output.

    :param prompt: The input prompt to pass to the `llm` binary.
    :return: The output from the `llm` binary.
    """
    try:
        # Call the `llm` binary with the prompt
        result = subprocess.run(
            ["llm"],             # Command to run
            input=prompt,        # Pass the prompt as input
            text=True,           # Use text mode for input and output
            capture_output=True, # Capture stdout and stderr
            check=True           # Raise an error if the command fails
        )

        # Return the command's output
        res = result.stdout.strip()
        return sanitize_for_vim(res)

    except subprocess.CalledProcessError as e:
        # Handle errors from the `llm` binary
        return f"Error: {e.stderr.strip() if e.stderr else str(e)}"
