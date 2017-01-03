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

# Command line arguments
non_verbose=0
while getopts "qh" opt; do
    case $opt in
        q)
            non_verbose=1
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
    echo " Filtered (cleaner) results:\n"
fi

# Nmap results
nmap_results=`nmap -sn $ip_range | grep "report" | awk '{print $5}'`

# Print verbose nmap results 
if [ $non_verbose -eq 0 ]; then
    echo "$nmap_results" | nl -s "| "
    echo "-----------------------------------------------------------\n"
# Print non-verbose nmap resu;ts
else
    echo "$nmap_results"
fi
