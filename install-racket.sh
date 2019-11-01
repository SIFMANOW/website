#!/bin/bash

set -e

curl -L -o racket-7.4-x86_64-linux.sh https://mirror.racket-lang.org/installers/7.4/racket-7.4-x86_64-linux.sh
chmod u+rx racket-7.4-x86_64-linux.sh
./racket-7.4-x86_64-linux.sh<<EOF
no
"$RACKET_DIR"

EOF
rm ./racket-7.4-x86_64-linux.sh
