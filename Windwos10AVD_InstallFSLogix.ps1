$Logpath = "C:\data\cslogs\Build\InstallFsLogix.log"

Function Write-Log{
    Param(
        [parameter(Position=0,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True,Mandatory=$True)]
        [string]$Message,
        [parameter(Position=1,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True,Mandatory=$False)]
        [ValidateSet("INFO","WARNING","ERROR","SUCCESS")]
        [string]$Level="INFO",
        [parameter(Position=2,Mandatory=$False)]
        [ValidateSet($False,$True)]
        [string]$Visible=$False
    )

    $time = get-date -Format "HH:mm:ss"
    $text = $Level + " [$time] " + $Message

    $text | Out-File -FilePath $LogPath -Append
    if($Visible -eq $True){
		
        switch ($Level){
            "SUCCESS" {$Color = "Green"}
            "WARNING" {$Color = "Yellow"}
            "ERROR" {$Color = "Red"}
            Default {$Color = "White"}
        }
		write-host -ForegroundColor $color $text
    }
}


Write-Log -Message "******* Script started *******" -Visible $true
New-Item -Path C:\\ -Name fslogix -ItemType Directory -ErrorAction SilentlyContinue
$LocalPath = 'C:\\fslogix'
$WVDflogixURL = 'https://raw.githubusercontent.com/DeanCefola/Azure-WVD/master/PowerShell/FSLogixSetup.ps1'
$WVDFslogixInstaller = 'FSLogixSetup.ps1'
$outputPath = $LocalPath + '\' + $WVDFslogixInstaller
Invoke-WebRequest -Uri $WVDflogixURL -OutFile $outputPath
Set-Location $LocalPath

$fsLogixURL="https://aka.ms/fslogix_download"
$installerFile="fslogix_download.zip"

Invoke-WebRequest $fsLogixURL -OutFile $LocalPath\$installerFile
Expand-Archive $LocalPath\$installerFile -DestinationPath $LocalPath
Write-Log -Message "Download Fslogix installer finished" -Visible $true

Write-Log "Start Fslogix installer" -Visible $true
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force -Verbose
.\\FSLogixSetup.ps1 -ProfilePath \\wvdSMB\wvd -Verbose 
Write-Log "Finished Fslogix installer" -Visible $true