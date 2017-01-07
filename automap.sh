#!/bin/sh

function printBanner() {
    # Welcome message
    echo "
     _         _                              
    / \  _   _| |_ ___  _ __ ___   __ _ _ __  
   / _ \| | | | __/ _ \| '_   _ \ / _  | '_ \ 
  / ___ \ |_| | || (_) | | | | | | (_| | |_) |
 /_/   \_\__,_|\__\___/|_| |_| |_|\__,_| .__/ 
                                       |_|     
  _      ___              
 |_)      | _|_ _|_  _. o 
 |_) \/  _|_ |_  |_ (_| | 
     /                    
	"
}

function getPorts() {
    # Host IP
    host_ip=$1
    # Type of info saught ("OS" or "PORT")
    nmap_results=`sudo nmap -A $host_ip`
    port_results=`echo "$nmap_results" | grep "open"`
    echo "$port_results"
}

# Command line arguments
non_verbose=0
show_ports=0
while getopts "qph" opt; do
    case $opt in
        q)
            non_verbose=1
            ;;
        p)
            show_ports=1
            ;;
        h)
            echo "This simple script uses nmap to automate host discovery on a network. \nUse the -q option to use quite mode, where only a list of host IPs is printed."
            exit 0
            ;;
    esac
done

# Gateway IP
gateway=`netstat -r -n | grep "default" --max-count=1 | awk '{ print $2 }'`

# Network IP range
ip_range=`echo $gateway | cut -d '.' -f 1-3`".1-255"

# Print verbose Feedback
if [ $non_verbose -eq 0 ]; then
    # Banner
    printBanner
    # Gateway
    printf "\033[32m ✓ \033[0m Gateway IPv4: %s\n" "$gateway"
    # IP Range
    printf "\033[32m ✓ \033[0m IPv4 Range for devices on this network: %s\n" "$ip_range"
    echo "________________________________________________________________\n"
    # Command to be executed
    echo " $ nmap -sn "$ip_range
    # Divider
    echo "-----------------------------------------------------------"
fi

# Nmap results
nmap_results=`nmap -sn $ip_range | grep "report" | awk '{print $5}'`

# Print verbose nmap results 
if [ $non_verbose -eq 0 ]; then
    echo " Filtered (cleaner) results:\n"
    echo "$nmap_results" | nl -s "| "
    echo "-----------------------------------------------------------\n"
# Print non-verbose nmap results
elif [ $non_verbose -eq 1 -a $show_ports -eq 0 ]; then
    echo "$nmap_results"
fi

# Port output
if [ $show_ports -eq 1 ]; then
    echo "$nmap_results" | while read host; do
        aggressive_output=`getPorts $host`
        if [ $non_verbose -eq 0 ]; then
            echo " $ nmap -A $host | grep \"open\""
            echo "-----------------------------------------------------------\n"
            echo " Filtered (cleaner results:\n"
            echo "$aggressive_output"
            echo "-----------------------------------------------------------\n"
        else 
            echo "$aggressive_output" | while read output_line; do
                port=`echo $output_line | cut -d "/" -f 1`
                if [ "$port" ]; then
                    printf "%s:%s\n" $host $port
                fi
            done
        fi
    done
fi
