#Requires -Version 2

param (
	[string] $Version = $(throw "-Version is required."),
	[string] $InstallPath = $(throw "-InstallPath is required."),
    [string] $DownloadPath = ""
)

if($InstallPath.StartsWith("./")) { $InstallPath = $InstallPath.replace("./", "$pwd/") }
if($InstallPath.StartsWith(".\")) { $InstallPath = $InstallPath.replace(".\", "$pwd\") }

if("${DownloadPath}" -eq "") {
    $DownloadPath = $InstallPath
} else {
    if($DownloadPath.StartsWith("./")) { $DownloadPath = $DownloadPath.replace("./", "$pwd/") }
    if($DownloadPath.StartsWith(".\")) { $DownloadPath = $DownloadPath.replace(".\", "$pwd\") }
}

$InstallPath = [System.IO.Path]::GetFullPath($InstallPath)
$DownloadPath = [System.IO.Path]::GetFullPath($DownloadPath)

$X86ProcessorArch = "x86"
$X86WindowsArch = "win32"
$X64ProcessorArch = "x64"
$X64WindowsArch = "win64"

$processorArch = $X86ProcessorArch
$windowsArch = $X86WindowsArch

if([IntPtr]::Size -eq 8) {
	$processorArch = $X64ProcessorArch
	$windowsArch = $X64WindowsArch
}

Add-Type -AssemblyName System.IO.Compression.FileSystem

function Extract-ZipFile
{
    param
	(
		[string]$FilePath,
		[string]$DirPath
	)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($FilePath, $DirPath)
}

function Get-WebFile
{
    param (
        [string] $Url,
        [string] $Path
    )
    
    $wc = New-Object System.Net.WebClient
	
	# Credencials
	$wc.UseDefaultCredentials = $true
	
	# Proxy
	$wc.Proxy = [System.Net.WebRequest]::DefaultWebProxy
	$wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials

    $wc.DownloadFile($Url, $Path)
}

function Get-CURLLSourceFileUrl
{
	$fileNameOriginal = "curl-${Version}.zip"
	$url = $urlTemplate
	
	for($i = 0; $i -lt $versionFiles.Count; $i++) {
		if($versionFiles[$i] -eq $fileNameOriginal) {
		 	$fileName = $fileNameOriginal
		 	$url = $url.replace("{0}", $versionFiles[$i])
		 	break
		}
	}
	
	if($url -ne $urlTemplate){
		return @($fileName, $url)
	}
	
    return @()
}

$urlTemplate = "https://curl.haxx.se/download/{0}"
$versionFiles = @(
	"curl-7.20.0.zip", "curl-7.20.1.zip",
	"curl-7.21.0.zip", "curl-7.21.1.zip", "curl-7.21.2.zip", "curl-7.21.3.zip", "curl-7.21.4.zip", "curl-7.21.5.zip", "curl-7.21.6.zip", "curl-7.21.7.zip",
	"curl-7.22.0.zip",
	"curl-7.23.0.zip", "curl-7.23.1.zip",
	"curl-7.24.0.zip",
	"curl-7.25.0.zip",
	"curl-7.26.0.zip",
	"curl-7.27.0.zip",
	"curl-7.28.0.zip", "curl-7.28.1.zip",
	"curl-7.29.0.zip",
	"curl-7.30.0.zip",
	"curl-7.31.0.zip",
	"curl-7.32.0.zip",
	"curl-7.33.0.zip",
	"curl-7.34.0.zip",
	"curl-7.35.0.zip",
	"curl-7.36.0.zip",
	"curl-7.37.0.zip", "curl-7.37.1.zip",
	"curl-7.38.0.zip",
	"curl-7.39.0.zip",
	"curl-7.40.0.zip",
	"curl-7.41.0.zip",
	"curl-7.42.0.zip", "curl-7.42.1.zip",
	"curl-7.43.0.zip",
	"curl-7.44.0.zip",
	"curl-7.45.0.zip",
	"curl-7.46.0.zip",
	"curl-7.47.0.zip", "curl-7.47.1.zip",
	"curl-7.48.0.zip",
	"curl-7.49.0.zip", "curl-7.49.1.zip",
	"curl-7.50.0.zip", "curl-7.50.1.zip", "curl-7.50.2.zip", "curl-7.50.3.zip",
	"curl-7.51.0.zip",
	"curl-7.52.0.zip", "curl-7.52.1.zip",
	"curl-7.53.0.zip", "curl-7.53.1.zip",
	"curl-7.54.0.zip", "curl-7.54.1.zip",
	"curl-7.55.0.zip", "curl-7.55.1.zip",
	"curl-7.56.0.zip", "curl-7.56.1.zip",
	"curl-7.57.0.zip",
	"curl-7.58.0.zip",
	"curl-7.59.0.zip",
	"curl-7.60.0.zip"
)

if(!(Test-Path $InstallPath)) {
	New-Item -Type Directory $InstallPath | Out-Null
}

$curlZip = Get-CURLLSourceFileUrl

if($curlZip.Count -eq 0) {
	throw "CURL v$Version not found!"
}

$CURLUrl = $curlZip[1]
$CURLFileName = $curlZip[0]
$CURLDirName = [System.IO.path]::GetFileNameWithoutExtension($CURLFileName)
$CURLFilePath = [System.IO.Path]::Combine($DownloadPath, $CURLFileName)
$CURLDirPath = [System.IO.Path]::Combine($DownloadPath, $CURLDirName)
$CURLBinFolderPath = [System.IO.Path]::Combine($InstallPath, "bin")
$CURLBinPath = [System.IO.Path]::Combine($CURLBinFolderPath, "curl.exe")

$CURLBuildPath = [System.IO.Path]::Combine($CURLDirPath, "winbuild")
$CURLBuildArtifactsPath = [System.IO.Path]::Combine($CURLDirPath, "builds")

"Installing CURL v$Version..." | Write-Host
"-----------------------------" | Write-Host

" -> Downloading $CURLUrl..." | Write-Host
Get-WebFile -Url $CURLUrl -Path $CURLFilePath

" -> Extracting $CURLFileName" | Write-Host
Extract-ZipFile -FilePath $CURLFilePath -DirPath $DownloadPath

" -> Building source (this may take a while.)..." | Write-Host
Push-Location $CURLBuildPath
& nmake /f Makefile.vc mode=static DEBUG=no MACHINE=$processorArch | Out-Null
Pop-Location

" -> Moving install files..." | Write-Host
Get-Item -Path "$CURLBuildArtifactsPath\**" -Exclude "*obj*" | ForEach-Object {
    $FileMatch = [System.IO.Path]::Combine($CURLBuildArtifactsPath, $_.Name)
    Copy-Item "$FileMatch\*" $InstallPath -Recurse -Force
}

" -> Removing temporary files..." | Write-Host
Remove-Item $CURLDirPath -Force -Recurse
Remove-Item $CURLFilePath -Force

if(!(Test-Path $CURLBinPath)) {
	throw "CURL v$Version install fail!"
}

"-----------------------------" | Write-Host
"CURL v$Version successfully install!" | Write-Host
"" | write-host
"Add ""$CURLBinFolderPath"" to PATH!" | Write-Host
' - PS : $env:Path = "' + $CURLBinFolderPath + ';${env:Path}"' | Write-Host
' - CMD: set PATH="'    + $CURLBinFolderPath + ';%PATH%"' | Write-Host
"" | Write-Host
