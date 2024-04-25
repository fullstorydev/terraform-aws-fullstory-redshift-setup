#!/usr/bin/env python3

from json import load as jload
from os.path import exists
import re
from sys import exit, argv


CONFIG_FILE = "hooks/commit-msg.config.json"
CONFIG = dict()
class COLORS:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

if not exists(CONFIG_FILE):
    print(f"{COLORS.WARNING}WARNING: No conventional commit config file found. Skipping checks{COLORS.ENDC}")
    exit(0)
elif len(argv) != 2:
    print(f"{COLORS.FAIL}ERROR: No commit message passed as argument. Aborting.{COLORS.ENDC}")
    exit(1)


with open(CONFIG_FILE) as fh:
    CONFIG = jload(fh)

pattern = "^("
if CONFIG['revert']:
    CONFIG['types'].append('revert')

for msgType in CONFIG['types']:
    pattern = f"{pattern}{msgType}|"

# If an opening bracket comes immediately after the type, 
# It must be closed and contain a scope. 
# The second thing is that the type and/or scope must be followed with a colon symbol (:).
pattern = f"{pattern})(\\(.+\\))?: "

msg = argv[1]
passCheck = True

if not re.match(pattern, msg):
    passCheck = False
    errMsg = f"commit message does not match required pattern!\nAllowed commit types: {','.join(CONFIG['types'])}"

elif len(msg.split(':')[1]) > CONFIG['length']['max'] or len(msg.split(':')[1]) < CONFIG['length']['min']:
    passCheck = False
    errMsg = f"commit message is not between min [{CONFIG['length']['min']}] and max [{CONFIG['length']['max']}] characters!"   


if not passCheck:
    print(f"{COLORS.BOLD}{COLORS.FAIL}[INVALID COMMIT MESSAGE]{COLORS.ENDC}")
    print("=========================================================")
    print(f"{COLORS.FAIL}ERROR: {errMsg}{COLORS.ENDC}")
    print(f"{COLORS.WARNING}Check https://www.conventionalcommits.org/en/v1.0.0/#summary for correct syntax{COLORS.ENDC}")
    exit(1)

