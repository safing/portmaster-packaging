#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# run installation tests here as well.
. ${SCRIPT_DIR}/test-install.sh

finish_tests