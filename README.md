# ViLLM: A minimal LLM interface in Vim

This is meant to be a super minimal interface to LLMs from Vim. It uses [Simonw's LLM](https://llm.datasette.io/en/stable/index.html) program to interface with LLMs as that is already a great tool to talk to multiple LLMs.

I often don't want a detailed autocomplete from LLMs when I code but they do add
some value. Sometimes I just want to chat with it a bit, or there's some
code/text rewriting and I want an easier macro. ViLLM is meant to fill that need
for me.

Example use case (used while writing this README): I wrote that first section of
the README in one long line, and I wanted to figure out how to auto-wrap it. So
I asked:

```
:LLMChat If I have a line longer than 80 characters is there a way to auto-wrap it in vim? Ie fix it up?

Response:
Yes, there are several ways to auto-wrap lines in Vim:

1. Using `gq` command:
   - Position your cursor at the start of the line
   - Press `gq` followed by a motion (like `j` or `ap` for a paragraph)
   - Or visually select the text (V) and press `gq`

2. Using `gw` (similar to `gq` but preserves cursor position):
   - Works the same way as `gq`
   - `gw` followed by a motion

...
etc
```

## Current Commands

**LLMChat** is used to chat with your llm. Eg: `:LLMChat How do I write a struct in Rust?`

**LLMInsert** is used to insert code to where your current cursor is. `:LLMInsert Write a struct in Rust with a field named "CoolField"`

**LLMRewrite** is used to pass whatever is currently selected along with a prompt. `:LLMRewrite Add a field to this Rust struct called "CoolerField"`

**LLMExplain** passes what is currently selected to the model along with a prompt. `:LLMExplain What fields are in this struct?`

**LLMLastResponse** will open a new vertical split buffer and paste the last full response from the LLM (ie: not just the code).

## Setup

First install `llm` from https://llm.datasette.io/

I use Pathogen for Vim so that's how I'd recommend setting it up.

`git clone https://github.com/benhirsch24/villm.git ~/.vim/bundle/villm`

Then define a global in your `.vimrc` to the install.

```
let g:villm_path = '/Users/yourname/.vim/bundle/villm'
```

Depending on the model you want to use you may need to set up environment variables. For example I like to use Anthropic via AWS Bedrock so I set the AWS region and profile.

```
let $AWS_DEFAULT_REGION='us-west-2'
let $AWS_PROFILE='my secret profile name'
```
