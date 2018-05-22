#Requires -Version 2

param (
	[string] $Version = $(throw "-Version is required."),
	[string] $InstallPath = $(throw "-InstallPath is required.")
)

if($InstallPath.StartsWith("./")) {
	$InstallPath = $InstallPath.replace("./", "$pwd/")
}

if($InstallPath.StartsWith(".\")) {
	$InstallPath = $InstallPath.replace(".\", "$pwd\")
}

$InstallPath = [System.IO.Path]::GetFullPath($InstallPath)

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

function Get-CMakeFileUrl
{
	$fileNameOriginal = "cmake-${Version}-${windowsArch}-${processorArch}.zip"
	$fileNameX86 = "cmake-${Version}-${X86WindowsArch}-${X86ProcessorArch}.zip"
	
	$fileName = $fileNameOriginal
	$url = $cmakeUrlTemplate
	
	for($i = 0; $i -lt $cmakeVersions.Count; $i++){
		if($cmakeVersions[$i][1] -eq $fileNameOriginal){
			$fileName = $fileNameOriginal
			$url = $url.replace("{0}", $cmakeVersions[$i][0]).replace("{1}", $cmakeVersions[$i][1])
			break
		}
	}
	
	if($url -ne $cmakeUrlTemplate){
		return @($fileName, $url)
	}
	
	for($i = 0; $i -lt $cmakeVersions.Count; $i++){
		if($cmakeVersions[$i][1] -eq $fileNameX86){
			$fileName = $fileNameX86
			$url = $url.replace("{0}", $cmakeVersions[$i][0]).replace("{1}", $cmakeVersions[$i][1])
			break
		}
	}
	
	if($url -eq $cmakeUrlTemplate){
		return @()
	}
	
	return @($fileName, $url)
}

$cmakeUrlTemplate = "https://cmake.org/files/{0}/{1}"
$cmakeVersions = @(
	@("v2.4", "cmake-2.4.2-win32-x86.zip"),
	@("v2.4", "cmake-2.4.3-win32-x86.zip"),
	@("v2.4", "cmake-2.4.4-win32-x86.zip"),
	@("v2.4", "cmake-2.4.5-win32-x86.zip"),
	@("v2.4", "cmake-2.4.6-win32-x86.zip"),
	@("v2.4", "cmake-2.4.7-win32-x86.zip"),
	@("v2.4", "cmake-2.4.8-win32-x86.zip"),
	@("v2.6", "cmake-2.6.0-win32-x86.zip"),
	@("v2.6", "cmake-2.6.1-win32-x86.zip"),
	@("v2.6", "cmake-2.6.2-win32-x86.zip"),
	@("v2.6", "cmake-2.6.3-win32-x86.zip"),
	@("v2.6", "cmake-2.6.4-win32-x86.zip"),
	@("v2.8", "cmake-2.8.0-win32-x86.zip"),
	@("v2.8", "cmake-2.8.1-win32-x86.zip"),
	@("v2.8", "cmake-2.8.2-win32-x86.zip"),
	@("v2.8", "cmake-2.8.3-win32-x86.zip"),
	@("v2.8", "cmake-2.8.4-win32-x86.zip"),
	@("v2.8", "cmake-2.8.5-win32-x86.zip"),
	@("v2.8", "cmake-2.8.6-win32-x86.zip"),
	@("v2.8", "cmake-2.8.7-win32-x86.zip"),
	@("v2.8", "cmake-2.8.8-win32-x86.zip"),
	@("v2.8", "cmake-2.8.9-win32-x86.zip"),
	@("v2.8", "cmake-2.8.10-win32-x86.zip"),
	@("v2.8", "cmake-2.8.10.1-win32-x86.zip"),
	@("v2.8", "cmake-2.8.10.2-win32-x86.zip"),
	@("v2.8", "cmake-2.8.11-win32-x86.zip"),
	@("v2.8", "cmake-2.8.11.1-win32-x86.zip"),
	@("v2.8", "cmake-2.8.11.2-win32-x86.zip"),
	@("v2.8", "cmake-2.8.12-win32-x86.zip"),
	@("v2.8", "cmake-2.8.12.1-win32-x86.zip"),
	@("v2.8", "cmake-2.8.12.2-win32-x86.zip"),
	@("v3.0", "cmake-3.0.0-win32-x86.zip"),
	@("v3.0", "cmake-3.0.1-win32-x86.zip"),
	@("v3.0", "cmake-3.0.2-win32-x86.zip"),
	@("v3.1", "cmake-3.1.0-win32-x86.zip"),
	@("v3.1", "cmake-3.1.1-win32-x86.zip"),
	@("v3.1", "cmake-3.1.2-win32-x86.zip"),
	@("v3.1", "cmake-3.1.3-win32-x86.zip"),
	@("v3.2", "cmake-3.2.0-win32-x86.zip"),
	@("v3.2", "cmake-3.2.1-win32-x86.zip"),
	@("v3.2", "cmake-3.2.2-win32-x86.zip"),
	@("v3.2", "cmake-3.2.3-win32-x86.zip"),
	@("v3.3", "cmake-3.3.0-win32-x86.zip"),
	@("v3.3", "cmake-3.3.1-win32-x86.zip"),
	@("v3.3", "cmake-3.3.2-win32-x86.zip"),
	@("v3.4", "cmake-3.4.0-win32-x86.zip"),
	@("v3.4", "cmake-3.4.1-win32-x86.zip"),
	@("v3.4", "cmake-3.4.2-win32-x86.zip"),
	@("v3.4", "cmake-3.4.3-win32-x86.zip"),
	@("v3.5", "cmake-3.5.0-win32-x86.zip"),
	@("v3.5", "cmake-3.5.1-win32-x86.zip"),
	@("v3.5", "cmake-3.5.2-win32-x86.zip"),
	@("v3.6", "cmake-3.6.0-win32-x86.zip"),
	@("v3.6", "cmake-3.6.0-win64-x64.zip"),
	@("v3.6", "cmake-3.6.1-win32-x86.zip"),
	@("v3.6", "cmake-3.6.1-win64-x64.zip"),
	@("v3.6", "cmake-3.6.2-win32-x86.zip"),
	@("v3.6", "cmake-3.6.2-win64-x64.zip"),
	@("v3.6", "cmake-3.6.3-win32-x86.zip"),
	@("v3.6", "cmake-3.6.3-win64-x64.zip"),
	@("v3.7", "cmake-3.7.0-win32-x86.zip"),
	@("v3.7", "cmake-3.7.0-win64-x64.zip"),
	@("v3.7", "cmake-3.7.1-win32-x86.zip"),
	@("v3.7", "cmake-3.7.1-win64-x64.zip"),
	@("v3.7", "cmake-3.7.2-win32-x86.zip"),
	@("v3.7", "cmake-3.7.2-win64-x64.zip"),
	@("v3.8", "cmake-3.8.0-win32-x86.zip"),
	@("v3.8", "cmake-3.8.0-win64-x64.zip"),
	@("v3.8", "cmake-3.8.1-win32-x86.zip"),
	@("v3.8", "cmake-3.8.1-win64-x64.zip"),
	@("v3.8", "cmake-3.8.2-win32-x86.zip"),
	@("v3.8", "cmake-3.8.2-win64-x64.zip"),
	@("v3.9", "cmake-3.9.0-win32-x86.zip"),
	@("v3.9", "cmake-3.9.0-win64-x64.zip"),
	@("v3.9", "cmake-3.9.1-win32-x86.zip"),
	@("v3.9", "cmake-3.9.1-win64-x64.zip"),
	@("v3.9", "cmake-3.9.2-win32-x86.zip"),
	@("v3.9", "cmake-3.9.2-win64-x64.zip"),
	@("v3.9", "cmake-3.9.3-win32-x86.zip"),
	@("v3.9", "cmake-3.9.3-win64-x64.zip"),
	@("v3.9", "cmake-3.9.4-win32-x86.zip"),
	@("v3.9", "cmake-3.9.4-win64-x64.zip"),
	@("v3.9", "cmake-3.9.5-win32-x86.zip"),
	@("v3.9", "cmake-3.9.5-win64-x64.zip"),
	@("v3.9", "cmake-3.9.6-win32-x86.zip"),
	@("v3.9", "cmake-3.9.6-win64-x64.zip"),
	@("v3.10", "cmake-3.10.0-win32-x86.zip"),
	@("v3.10", "cmake-3.10.0-win64-x64.zip"),
	@("v3.10", "cmake-3.10.1-win32-x86.zip"),
	@("v3.10", "cmake-3.10.1-win64-x64.zip"),
	@("v3.10", "cmake-3.10.2-win32-x86.zip"),
	@("v3.10", "cmake-3.10.2-win64-x64.zip"),
	@("v3.10", "cmake-3.10.3-win32-x86.zip"),
	@("v3.10", "cmake-3.10.3-win64-x64.zip"),
	@("v3.11", "cmake-3.11.0-win32-x86.zip"),
	@("v3.11", "cmake-3.11.0-win64-x64.zip"),
	@("v3.11", "cmake-3.11.1-win32-x86.zip"),
	@("v3.11", "cmake-3.11.1-win64-x64.zip")
)

if(!(Test-Path $InstallPath)) {
	New-Item -Type Directory $InstallPath | Out-Null
}

$cmakeZip = Get-CMakeFileUrl

if($cmakeZip.Count -eq 0) {
	throw "CMake v$Version not found!"
}

$cmakeUrl = $cmakeZip[1]
$cmakeFileName = $cmakeZip[0]
$cmakeDirName = [System.IO.path]::GetFileNameWithoutExtension($cmakeFileName)
$cmakeFilePath = [System.IO.Path]::Combine($InstallPath, $cmakeFileName)
$cmakeDirPath = [System.IO.Path]::Combine($InstallPath, $cmakeDirName)
$cmakeBinFolderPath = [System.IO.Path]::Combine($InstallPath, "bin")
$cmakeBinPath = [System.IO.Path]::Combine($cmakeBinFolderPath, "cmake.exe")

"Installing CMake v$Version..." | Write-Host
"-----------------------------" | Write-Host

" -> Downloading $cmakeUrl..." | Write-Host
Get-WebFile -Url $cmakeUrl -Path $cmakeFilePath

" -> Extracting $cmakeFileName" | Write-Host
Extract-ZipFile -FilePath $cmakeFilePath -DirPath $InstallPath

" -> Moving install files..." | Write-Host
Get-ChildItem -Path $cmakeDirPath -Recurse -Directory | Move-Item -Destination $InstallPath
Get-ChildItem -Path $cmakeDirPath -Recurse -File | Move-Item -Destination $InstallPath

" -> Removing temporary files..." | Write-Host
Remove-Item $cmakeDirPath -Force -Recurse
Remove-Item $cmakeFilePath -Force

if(!(Test-Path $cmakeBinPath)) {
	throw "CMake v$Version install fail!"
}

"-----------------------------" | Write-Host
"CMake v$Version successfully install!" | Write-Host
"" | Write-Host
"Add ""$cmakeBinFolderPath"" to PATH!" | Write-Host
' - PS : $env:Path = "' + $cmakeBinFolderPath + ';${env:Path}"' | Write-Host
' - CMD: set PATH="'    + $cmakeBinFolderPath + ';%PATH%"' | Write-Host
"" | Write-Host
