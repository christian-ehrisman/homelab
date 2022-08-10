Creates a custom URI protocol custom: (rather than pwsh:, given that PowerShell is simply used to implement the protocol) to which an open-ended number of arguments can be passed.

Does so for the current user only (HKEY_CURRENT_USER\Software\Classes) by default; however, it's easy to tweak the code to implement the custom protocol for all users instead (HKEY_LOCAL_MACHINE\Software\Classes), though you'll need to run the code with elevation (as administrator) then.

A handler *.ps1 script is automatically created:

At $env:USERPROFILE\customUriHandler.ps1 in the current-user scenario.

At $env:ALLUSERPROFILE\customUriHandler.ps1 in the all-users scenario.

The handler script simply echoes the arguments passed to it, and it is invoked in a PowerShell script window that is kept open after script execution (-NoExit); tweak the PowerShell command as needed.

The protocol expects its arguments as if it were a shell command, i.e., as a space-separated list of arguments, with argument-individual "..." quoting, if necessary.

The sample command at the end uses Start-Process to invoke the following URI, which you could also submit from the Run dialog (WinKey-R), which passes arguments one, two & three, four:

URI: custom:one "two & three" four
Invocation via Start-Process: Start-Process 'custom:one "two & three" four'
Caveat: If you submit this URI via a web browser's address bar (note: doesn't seem to work with Microsoft Edge), it is URI-escaped, and a single one%20%22two%20&%20three%22%20four argument is passed instead, which would require custom parsing; similarly, submitting from File Explorer's address bar passes one%20two%20&%20three%20four, though note that the " chars. are - curiously - lost in the process.