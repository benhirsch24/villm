# ViLLM: A minimal LLM interface in Vim

This is meant to be a super minimal interface to LLMs from Vim.

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

3. Set automatic wrapping width:
```vim
:set textwidth=80
```

4. Format existing text to the textwidth:
```vim
:set textwidth=80
:normal gggqG
```

5. For automatic wrapping as you type:
```vim
:set textwidth=80
:set formatoptions+=t
```

The most common quick fix for a single line is to put your cursor on it and type:
```
gqq
```

Or for a paragraph:
```
gqap
```
```
