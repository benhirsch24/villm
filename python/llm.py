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
        return sanitize_for_vim(result.stdout.strip())

    except subprocess.CalledProcessError as e:
        # Handle errors from the `llm` binary
        return f"Error: {e.stderr.strip() if e.stderr else str(e)}"
