import re

__COMMENTS = re.compile(r"\"(\\\"|[^\"])*?\"|--.*?$|{-.*?-}",
  re.MULTILINE | re.DOTALL)
# re.MULTILINE because Haskell strings can be multiline

__WHITESPACED_LINE = re.compile(r"^\s*?\n", re.MULTILINE)
# re.MULTILINE because ^ should match start of line, not string.

def __strip_comments_sub(match):
  whole = match.group(0)
  if not whole.startswith("\""):
    return ""
  else:
    return whole

def strip_whitespaced_lines(haskell_code):
  return __WHITESPACED_LINE.sub("", haskell_code)

def strip_comments(haskell_code):
  no_comments = __COMMENTS.sub(__strip_comments_sub, haskell_code)
  return strip_whitespaced_lines(no_comments)
