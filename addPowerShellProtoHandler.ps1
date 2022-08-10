# Determine the scope:
# Set to $false to install machine-wide (for all users)
# Note: Doing so then requires running with ELEVATION.
$currentUserOnly = $true

if (-not $currentUserOnly) {
  net session *>$null
  if ($LASTEXITCODE) { Throw "You must run this script as administrator (elevated)." }
}

$ErrorActionPreference = 'Stop'

# The name of the new protocol scheme
$schemeName = 'custom'

$pwshPathEscaped = (Get-Process -Id $PID).Path -replace '\\', '\\'

$handlerScript = ($env:ALLUSERSPROFILE, $env:USERPROFILE)[$currentUserOnly] + "\${schemeName}UriHandler.ps1"
$handlerScriptEscaped = $handlerScript -replace '\\', '\\'

# Create the protocol handler script.
@'

# Remove the protocol scheme name from the 1st argument.
$argArray = $args.Clone()
$argArray[0] = $argArray[0] -replace '^[^:]+:'
# If the 1st argument is now empty, remove it.
if ('' -eq $argArray[0]) { $argArray = $argArray[1..($argArray.Count-1)] }

"Received $($argArray.Count) argument(s)."

$i = 0
foreach ($arg in $argArray) {
  Invoke-Expression $arg
}

'@ > $handlerScript

# Construct a temp. *.reg file.
# Target the scope-appropriate root registrykey.
$rootKey = ('HKEY_LOCAL_MACHINE\Software\Classes', 'HKEY_CURRENT_USER\Software\Classes')[$currentUserOnly]
# Determine a temp. file path.
$tempFile = [IO.Path]::GetTempPath() + [IO.Path]::GetRandomFileName() + '.reg'
@"
Windows Registry Editor Version 5.00

[$rootKey\$schemeName]
@="URL:$schemeName"
"URL Protocol"=""

[$rootKey\$schemeName\DefaultIcon]
@="$pwshPathEscaped"

[$rootKey\$schemeName\shell]
@="open"

[$rootKey\$schemeName\shell\open\command]
; === Tweak the PowerShell command line here: ===
@="\"$pwshPathEscaped\" -ExecutionPolicy Bypass -NoProfile -NoExit -File \"$handlerScriptEscaped\" %1"

"@ > $tempFile

# Import the *.reg file into the registry.
& {
  $ErrorActionPreference = 'Continue'
  reg.exe import $tempFile 2>$null
  if ($LASTEXITCODE) { Throw "Importing with reg.exe failed: $tempFile"}
}

# Remove the temp. *.reg file.
Remove-Item -ErrorAction Ignore -LiteralPath $tempFile

# ---

# Sample invocation of the new protocol with 3 arguments:
# $uri = "$schemeName`:one `"two & three`" four"
# Write-Verbose -Verbose "Invoking the following URI: $uri"
# Start-Process $uri