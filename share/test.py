#!/usr/bin/env python3

from pathlib import Path
import sys, yaml, subprocess, os.path, os, getpass, tempfile, zipfile, atexit, \
    shutil
from lib.ta.lib import TA_LEVEL_FATAL, ta_comment, ta_greeting

# Semantics: Should be called on a directory containing a single *.zip or
# code/ directory OR with the path of a *.zip file

# Name of dir/file containing code
CODE='code'
CODE_ZIP=CODE+'.zip'

# Tmp dir prefix
TMP_PREFIX='ota.'

# If called on a directory strip trailing slash for consistency, if called
# without an argument assume the submission is in the current directory.
submission = sys.argv[1].rstrip('/') or '.'

# Graciously (but still print a warning) handle calling with path to code
# dir/zip
if os.path.splitext(os.path.basename(submission))[0] == CODE:
    print('!! You should call this script on the directory containing {}'\
          .format(os.path.basename(submission)),
          file=sys.stderr
    )
    submission = os.path.dirname(submission)

code_dir = os.path.join(submission, CODE)
code_zip = os.path.join(submission, CODE_ZIP)

# If the submission contains a directory (i.e. `solution/code/` or we unpacked a
# submission to do some fixing-upping) we zip it up and move it to a temporary
# directory to mimic a student hand-in
if os.path.isdir(code_dir):
    # Prefer code dir over zip, but print a warning
    if os.path.exists(code_zip):
        print('!! Found {}/ directory, ignoring {}'\
              .format(CODE, CODE_ZIP),
              file=sys.stderr
        )

    # Create tmp dir and make writable from inside docker
    tmpdir = tempfile.mkdtemp(prefix=TMP_PREFIX)
    os.chmod(tmpdir, 0o755)

    # Path to code.zip inside tmp dir
    zip_path = os.path.join(tmpdir, CODE_ZIP)

    # Tell user about this
    print('Zipping to {}'\
          .format(zip_path),
          file=sys.stderr
    )

    # Should we clean up after?
    if 'KEEP_TMP' not in os.environ:
        print('  (set environment variable `KEEP_TMP` to skip deletion)',
              file=sys.stderr
        )
        atexit.register(lambda: shutil.rmtree(tmpdir, ignore_errors=True))

    zip = zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED)
    for root, dirs, files in os.walk(code_dir):
        for file in files:
            fpath = os.path.join(root, file)
            arc = os.path.relpath(fpath, submission)
            zip.write(fpath, arc)
    zip.close()

    # Update submission path to temp dir
    submission_dir = tmpdir

elif os.path.isfile(code_zip):
    # Called on a zip; dir should contain nothing else, otherwise print a
    # warning
    # NB: Should we be harsher here and simply bail?
    if len(os.listdir(submission)) != 1:
        print('!! This directory should contain a {} and nothing else.  You ' \
              'are skating on thin ice.'.format(CODE_ZIP),
              file=sys.stderr
        )
    submission_dir = submission

elif (os.path.isdir(submission) and
      len(list(Path(submission).glob('*.zip'))) == 1):
    # Called on a directory with a single zip file, what the testserver does
    submission_dir = submission

elif (os.path.isfile(submission) and
      os.path.splitext(os.path.basename(submission))[1] == '.zip'):
    # Called with on a zip not called code.zip, we'll allow it
    submission_dir = os.path.dirname(submission)

    # We'll still print a warning
    if len(os.listdir(submission_dir)) != 1:
        print('!! This directory should contain a single zip file '
              'and nothing else.  You are skating on thin ice.',
              file=sys.stderr
        )

else:
    print(f'Could not find {CODE}[.zip], exiting',
          file=sys.stderr
    )
    sys.exit(1)

order = yaml.safe_load(open("order.yaml"))

docker_image=order['docker_image']

mounts = [
  (submission_dir, "/home/user/submission:ro"),
  (os.environ.get("ONLINETA_BASEDIR") +
   "/share", "/home/user/OnlineTA/share:ro"),
  (os.getcwd(), "/home/user/curtest:ro"),
]

mounts = " ".join("-v \"%s:%s\"" % (k, v) for (k, v) in mounts)

cmd = ['docker', 'image', 'inspect', '--format={{.Created}}', docker_image]
proc = subprocess.run(
    cmd,
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
)

if b"No such image" in proc.stderr:
    # On the server the docker image should already have been created
    # by the deployment script. Thus, it's probably a TA who needs
    # instructions on how to build the docker image on their own
    # machine
    print(f'Docker image "{docker_image}" doesn\'t exist...',
          f"You need to execute the command:",
          f"   docker build -t {docker_image} .",
          f"in the tests directory for the assignment",
          sep=os.linesep,
          file=sys.stderr)
    sys.exit(1)
elif proc.returncode == 0:
    pass
else:
    print('Command `{}` failed:\n{}'.format(' '.join(cmd), proc.stderr.decode('utf8')),
          file=sys.stderr)
    sys.exit(1)


os.system(
    "docker run -i --rm {} --cap-add=SYS_PTRACE -e ONLINETA_BASEDIR=/home/user/OnlineTA -w /home/user/curtest {} /home/user/OnlineTA/share/runphases.py /home/user/submission".format(mounts, docker_image))

sys.exit(0)
