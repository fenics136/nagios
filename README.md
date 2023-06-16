# Nagios check_ports Command

This command allows you to check the status of specific TCP and UDP ports on a host using Nagios.

## Command Definition

```cfg
define command {
    command_name    check_ports
    command_line    /usr/local/nagios/libexec/check_ports.sh -H $ARG1$ $ARG2$
}

Usage:
check_ports -H <host> [-t <tcp ports>] [-u <udp ports>] [-6] -o|-c

Parameters:
-H <host>: Host to scan.
-t <ports>: TCP ports to scan, specified as a comma-separated list. Accepts ranges.
-u <ports>: UDP ports to scan, specified as a comma-separated list. Accepts ranges.
-6: Enable IPv6 scanning.
-o: Expected result, ports are open.
-c: Expected result, ports are closed.

Example:
check_command       check_ports!example.com!-t 3306 -c

Note:

The host parameter (-H) is mandatory.
You can specify either TCP ports (-t), UDP ports (-u), or both.
Use the -6 option for IPv6 scanning.
Choose either -o or -c to define the expected result.
