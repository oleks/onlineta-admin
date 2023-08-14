import sys

TA_LEVEL_GREETING=0
TA_LEVEL_STYLE=1
TA_LEVEL_BAD=2
TA_LEVEL_FATAL=255

def ta_comment(level, msg):
  if level == TA_LEVEL_GREETING:
    print(msg)
    return

  msg = "  " + msg.replace("\n", "\n  ")
  if level == TA_LEVEL_STYLE:
    print("Comment:")
  elif level == TA_LEVEL_BAD:
    print("Warning:")
  elif level == TA_LEVEL_FATAL:
    print("Fatal problem:")

  print(msg)

def ta_greeting(msg):
  ta_comment(TA_LEVEL_GREETING, msg)

def ta_problem(level, code, msg):
  code = code.rstrip()
  max_line_len = max(map(len, code.split("\n")))
  ta_comment(level, "%s\n%s\n%s" %
    (code, "^" * max_line_len, msg))
  sys.exit(level)

def ta_fatal(msg):
  ta_comment(TA_LEVEL_FATAL, msg)
  sys.exit(TA_LEVEL_FATAL)

def re_spaces(re_str):
  return re_str.replace(r" ", r"\s*")
