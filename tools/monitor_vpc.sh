#!/usr/bin/env bash

usage() {
  # This script is used to help automatically restart or stop the z/OS VPCs
  echo "Usage: $(basename $0) [-h] -a <action> -i <instance_name> -p <ip_address>"
  echo "  e.g. ./monitor_vpc.sh -a restart -i zopen-cimachine -p 192.x.x.x"
  echo "  -a  Action to perform: restart-if-down, restart or stop"
  echo "  -i  The name of the VPC instance"
  echo "  -p  The IP address of the VPC instance"
  echo "  -h  Display this help message"
}

# Check if ibmcloud is a runnable command
if ! command -v ibmcloud > /dev/null; then
    echo "Error: ibmcloud command not found. Please install the IBM Cloud CLI and make sure it is in your PATH."
    exit 1
fi

# Parse script arguments
while getopts "a:i:p:r:h" opt; do
  case $opt in
    a) action="$OPTARG"
    ;;
    i) vpc_instance="$OPTARG"
    ;;
    p) ip_address="$OPTARG"
    ;;
    r) region="$OPTARG"
    ;;
    h) usage
       exit 0
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
        usage
        exit 1
    ;;
  esac
done

# Check if all required arguments are provided
if [ -z "$action" ] || [ -z "$vpc_instance" ] || [ -z "$ip_address" ]; then
    echo "Error: Missing required arguments"
    usage
    exit 1
fi

# Check if action is valid
if [ "$action" != "restart-if-down" ] && [ "$action" != "restart" ] && [ "$action" != "stop" ]; then
    echo "Error: Invalid action specified. Please use one of the following actions: restart-if-down, restart, stop"
    usage
    exit 1
fi

if [ -z "$IBMCLOUD_API_KEY" ]; then
    echo "You must set the IBMCLOUD_API_KEY environment variable."
    exit 1
fi

# Login to IBM Cloud
if ! ibmcloud login -r $region; then
    echo "Error: Failed to login to IBM Cloud. Please check your IBMCLOUD_API_KEY environment variable."
    exit 1
fi

# Perform action based on input
if [ "$action" == "restart" ]; then
    # Stop the instance
    if ! echo "y" | ibmcloud is instance-stop "$vpc_instance"; then
        echo "Error: Failed to stop the instance $vpc_instance"
        exit 1
    fi
    echo "Instance $vpc_instance stopped"
    
    # Wait for 180 seconds
    sleep 180
    
    # Start the instance
    if ! ibmcloud is instance-start "$vpc_instance"; then
        echo "Error: Failed to start the instance $vpc_instance"
        exit 1
    fi
    echo "Instance $vpc_instance started"

elif [ "$action" == "restart-if-down" ]; then
    # Check if IP address is reachable
    if ! nc -zv "$ip_address" 22; then
        # IP address is not reachable, perform restart action
        if ! echo "y" | ibmcloud is instance-stop "$vpc_instance"; then
            echo "Error: Failed to stop the instance $vpc_instance"
            exit 1
    fi
    echo "Instance $vpc_instance stopped"

    # Wait for 180 seconds
    sleep 180
    
    # Start the instance
    if ! ibmcloud is instance-start "$vpc_instance"; then
        echo "Error: Failed to start the instance $vpc_instance"
        exit 1
    fi
    echo "Instance $vpc_instance started"
else
    echo "Instance $vpc_instance is already running, no action taken."
fi

elif [ "$action" == "stop" ]; then
  # Stop the instance
  if ! ibmcloud is instance-stop "$vpc_instance"; then
     echo "Error: Failed to stop the instance $vpc_instance"
     exit 1
  fi
   echo "Instance $vpc_instance stopped"
fi
