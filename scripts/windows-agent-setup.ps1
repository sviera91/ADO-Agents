param (
    [Parameter(Mandatory=$true)]
    [string]$PATToken,
    [Parameter(Mandatory=$true)]
    [string]$devopsOrg,
    [Parameter(Mandatory=$true)]
    [string]$pool,
    [Parameter(Mandatory=$true)]
    [string]$agent
)

write-host "--- Install Azure PowerShell ---"
Install-PackageProvider -Name NuGet -Force
Install-Module PowerShellGet -Force
Install-Module -Name Az -AllowClobber -Scope AllUsers -SkipPublisherCheck -Force
Install-Module -Name AzureAD -AllowClobber -Scope AllUsers -SkipPublisherCheck -Force
Install-Module -Name Pester -AllowClobber -Scope AllUsers -SkipPublisherCheck -Force


write-host "--- Install Chocolatey ---"
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

write-host "--- Install tools ---"
choco feature enable -n allowGlobalConfirmation
choco install python -y
choco install awscli -y
choco install docker-desktop -y
choco install terraform -y
choco install azure-cli -y
refreshenv

write-host "--- Setting Azure DevOps Agent ---"
mkdir c:\agent
cd c:\agent
Invoke-WebRequest -Uri https://vstsagentpackage.azureedge.net/agent/2.183.1/vsts-agent-win-x64-2.183.1.zip -OutFile "c:\agent\vsts-agent-win-x64-2.183.1.zip" -UseBasicParsing
Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory("c:\agent\vsts-agent-win-x64-2.183.1.zip", "$PWD")
.\config.cmd --unattended --url $devopsOrg --auth PAT --token $PATToken --runAsService --pool $pool --agent $agent --replace
