#!/usr/bin/env python3

import sys, yaml, subprocess, os.path, os, shutil, tempfile

from lib.ta.lib import TA_LEVEL_FATAL, ta_comment, ta_greeting

# http://stackoverflow.com/a/12514470/5801152
def copytree(src, dst, symlinks=False, ignore=None):
  if os.path.isfile(src):
    shutil.copy2(src, dst)
  else:
    for item in os.listdir(src):
      s = os.path.join(src, item)
      d = os.path.join(dst, item)
      if os.path.isdir(s):
        shutil.copytree(s, d, symlinks, ignore)
      else:
        shutil.copy2(s, d)


submission = sys.argv[1]
workdir = tempfile.mkdtemp()
copytree(submission, workdir)

order = yaml.safe_load(open("order.yaml"))

env = os.environ.copy()
libpath = os.path.join(os.path.dirname(os.path.realpath(__file__)), "lib")

if "PYTHONPATH" in env:
  env["PYTHONPATH"] = ":".join([libpath, env["PYTHONPATH"]])
else:
  env["PYTHONPATH"] = libpath

OK = True

def changeenv(env, changes):
  for change in changes:
    for key, value in change.items():
      env[key] = value
  return env

def runtest(command, env):
  global OK
  proc = subprocess.Popen([command, workdir], env=env)
  proc.wait()
  if proc.returncode != 0:
    OK = False
    print(command, "FAILED")
    if proc.returncode == TA_LEVEL_FATAL:
      ta_comment(TA_LEVEL_FATAL,
        "FATAL TEST FAILURE; Cowardly refusing to conduct further tests.")
      sys.exit(0)

for phase in order['phases']:
  phasepath = phase['path']
  for test in phase['tests']:
    testpath = test['path']
    command = os.path.join(phasepath, testpath)
    if 'env' in test:
      env = changeenv(env, test['env'])
    runtest(command, env)

ta_greeting("---")
if OK:
  ta_greeting("I am satisfied.")
else:
  ta_greeting("I am not fully satisfied.")

ta_greeting("---")
ta_greeting("Found a bug? Are the messages too cryptic?\nLet us know an Absalon or Discord.")
