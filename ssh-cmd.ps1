# Usage: .\ssh-cmd.ps1 <IP> <PASSWORD> <COMMAND>
# Runs a command on the remote trading box via plink (PuTTY).
# Requires plink.exe in PATH — download from https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html

param(
    [Parameter(Mandatory)][string]$IP,
    [Parameter(Mandatory)][string]$Password,
    [Parameter(Mandatory)][string]$Command
)

# Auto-accept host key on first connect
echo y | plink -ssh -pw $Password root@$IP $Command 2>$null
