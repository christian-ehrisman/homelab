delay 3
global frontApp, frontAppName, windowTitle
set windowTitle to ""
tell application "System Events"
    set frontApp to first application process whose name is "Microsoft Edge"---frontmost is true
    set frontAppName to name of frontApp
    tell process frontAppName
        tell (1st window whose value of attribute "AXMain" is true)
            set windowTitle to value of attribute "AXTitle"
        end tell
    end tell
end tell

return {windowTitle}

set uiScript to "click UI Element 2 of tab group 2 of group 1 of group 1 of group 1 of group \"" & windowTitle & "\" of window \"" & windowTitle & "\" of application process \"Microsoft Edge\""
display dialog  uiScript
my doWithTimeout(uiScript, timeoutSeconds)
on doWithTimeout(uiScript, timeoutSeconds)
	set endDate to (current date) + timeoutSeconds
	repeat
		try
			run script "tell application \"System Events\" " & uiScript & " end tell"
			exit repeat
		on error errorMessage
			if ((current date) > endDate) then
				error "Can not " & uiScript
			end if
		end try
	end repeat
end doWithTimeout