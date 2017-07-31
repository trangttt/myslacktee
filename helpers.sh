#!/bin/bash - 
#===============================================================================
#
#          FILE: helpers.sh
# 
#         USAGE: ./helpers.sh 
# 
#   DESCRIPTION: helpers functions
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: TRANG TRAN 
#  ORGANIZATION: 
#       CREATED: 07/29/2017 10:26
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
function echoerr()
{
    printf "%s\n" "$*" >&2;
}

function err_exit()
{
    exit_code=$1
    shift
    echoerr "$SOURCE_NAME: $*"
    exit "$exit_code"
}





