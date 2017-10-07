#!/bin/bash
#####################################################################
# NAME:
#   myips -- list all active networks
#
# SYNOPSIS:
#   myips
#
# DESCRIPTION:
#   For Mac OS X, list the active networks by port and protocol
#
#####################################################################
# REVISIONS:
#   20171006 DW creation date
#
#####################################################################

NETWORKS=$(networksetup -listnetworkserviceorder | grep 'Hardware Port')
printf "\nPRIVATE IPs"
printf "\n=================================================================="
printf "\n Interface \tIP Address \tMAC Address \t\tProtocol"
printf "\n=================================================================="
while read line; do
    PROTOCOL=$(echo $line | awk -F  "(, )|(: )|[)]" '{print $2}')
    PORT=$(echo $line | awk -F  "(, )|(: )|[)]" '{print $4}')
    if [ -n "${PORT}" ]; then
        IFCONFIG="$(ifconfig ${PORT} 2>/dev/null)"
        echo "${IFCONFIG}" | grep 'status: active' > /dev/null 2>&1
        rc="$?"
        if [ "$rc" -eq 0 ]; then
            CUR_PORT="${PORT}"
            CUR_PROTOCOL="${PROTOCOL}"
            CUR_MAC=$(echo "${IFCONFIG}" | awk '/ether/{print $2}')
            CUR_IP=$(ipconfig getifaddr ${CUR_PORT})
            printf "\n   ${CUR_PORT} \t\t${CUR_IP} \t${CUR_MAC} \t${CUR_PROTOCOL}"
        fi
    fi

done <<< "$(echo "${NETWORKS}")"

printf "\n\nPUBLIC IP"
printf "\n=================================================================="
printf "\n IP Address \t\tFQDN"
printf "\n=================================================================="
PubIP=$(dig +short myip.opendns.com @resolver1.opendns.com)
HOST_PubIP=$(host ${PubIP} | awk '{print $NF}' | sed "s/.$//")
printf "\n ${PubIP} \t\t${HOST_PubIP}\n\n"

# END
