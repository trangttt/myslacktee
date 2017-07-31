#!/usr/local/bin/bash - 
#===============================================================================
#
#          FILE: myslacktee.sh
# 
#         USAGE: ./myslacktee.sh 
# 
#   DESCRIPTION: Main slacktee
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: TRANG TRAN
#  ORGANIZATION: 
#       CREATED: 07/29/2017 09:31
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error



#-------------------------------------------------------------------------------
# Default configuration
#-------------------------------------------------------------------------------

# Incoming Webhooks integration URL. See https://my.slack.com/services/new/incoming-webhook
webhook_url="https://hooks.slack.com/services/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"
username="myslacktee"
icon="monkey_face"
channel="general"


SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ !  -d "$SOURCE_DIR" ]] ; then SOURCE_DIR="$PWD"; fi


# shellcheck source=./help.sh
. "$SOURCE_DIR/help.sh"



#-------------------------------------------------------------------------------
# Start script
#-------------------------------------------------------------------------------
function main(){
    parse_args "$@"
    setup_environment
    while IFS='' read -r line; do
        process_line "$line"
    done
    send_message "$webhook_url"  "$text" 
}

main "$@"

