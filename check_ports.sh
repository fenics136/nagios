#!/bin/bash

# Nagios exit codes
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

# Function to display usage instructions
usage() {
    echo "check_ports: Could not parse arguments"
    echo "Usage:"
    echo "check_ports -H <host> [-t <tcp ports>] [-u <udp ports>] [-6] -o|-c"
    echo "Parameters:"
    echo "  -H <host>: Host to scan"
    echo "  -t <ports> and/or -u <ports>: TCP and/or UDP ports to scan, comma-separated list, accepts ranges (ex: 21-25,80,139)"
    echo "  -6: IPv6 scanning"
    echo "  -o or -c: Expected result, ports are open or closed"
}

# Parse command-line arguments
while getopts ":H:t:u:6oc" opt; do
    case $opt in
        H)
            TARGET_HOST=$OPTARG
            ;;
        t)
            TCP_PORTS=$OPTARG
            ;;
        u)
            UDP_PORTS=$OPTARG
            ;;
        6)
            USE_IPV6=true
            ;;
        o)
            EXPECTED_RESULT="open"
            ;;
        c)
            EXPECTED_RESULT="closed"
            ;;
        \?)
            usage
            exit $STATE_UNKNOWN
            ;;
    esac
done

# Check if required arguments are provided
if [[ -z $TARGET_HOST ]] || [[ -z $EXPECTED_RESULT ]]; then
    usage
    exit $STATE_UNKNOWN
fi

# Function to check if a port is open or closed
check_port() {
    port=$1
    timeout=5
    if [[ -n $USE_IPV6 ]]; then
        nc_cmd="nc -6"
    else
        nc_cmd="nc"
    fi
    $nc_cmd -z -w $timeout $TARGET_HOST $port >/dev/null 2>&1
    result=$?
    if [[ $result -eq 0 ]] && [[ $EXPECTED_RESULT == "open" ]]; then
        echo "OK - Port $port is open"
        exit $STATE_OK
    elif [[ $result -eq 1 ]] && [[ $EXPECTED_RESULT == "closed" ]]; then
        echo "OK - Port $port is closed"
        exit $STATE_OK
    else
        echo "CRITICAL - Port $port is not in the expected state ($EXPECTED_RESULT)"
        exit $STATE_CRITICAL
    fi
}

# Check TCP ports if provided
if [[ -n $TCP_PORTS ]]; then
    IFS=',' read -ra tcp_ports_array <<< "$TCP_PORTS"
    for port_range in "${tcp_ports_array[@]}"; do
        if [[ $port_range == *-* ]]; then
            IFS='-' read -ra range_parts <<< "$port_range"
            start_port=${range_parts[0]}
            end_port=${range_parts[1]}
            for (( port=start_port; port <= end_port; port++ )); do
                check_port $port
            done
        else
            check_port $port_range
        fi
    done
fi

# Check UDP ports if provided
if [[ -n $UDP_PORTS ]]; then
    IFS=',' read -ra udp_ports_array <<< "$UDP_PORTS"
    for port_range in "${udp_ports_array[@]}"; do
        if [[ $port_range == *-* ]]; then
            IFS='-' read -ra range_parts <<< "$port_range"
            start_port=${range_parts[0]}
            end_port=${range_parts[1]}
            for (( port=start_port; port <= end_port; port++ )); do
                check_port $port
            done
        else
            check_port $port_range
        fi
    done
fi

# No ports provided, display usage
usage
exit $STATE_UNKNOWN
