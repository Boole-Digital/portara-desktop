# Usage: .\ssh-cmd.ps1 <IP> <PASSWORD> <COMMAND>
# Runs a command on the remote trading box via plink (PuTTY).
# Requires plink.exe in PATH — download from https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html

param(
    [Parameter(Mandatory)][string]$IP,
    [Parameter(Mandatory)][string]$Password,
    [Parameter(Mandatory)][string]$Command
)

# Strip one level of backslash escaping from password (parity with ssh-cmd.sh)
$Password = $Password -replace '\\(.)', '$1'

# Write command to temp file — avoids PowerShell argument-quoting issues with plink
$tmpFile = [System.IO.Path]::GetTempFileName()
try {
    [System.IO.File]::WriteAllText($tmpFile, $Command)
    # Auto-accept host key on first connect; -m reads remote command from file
    echo y | plink -ssh -pw $Password -m $tmpFile root@$IP 2>$null
} finally {
    Remove-Item $tmpFile -ErrorAction SilentlyContinue
}
