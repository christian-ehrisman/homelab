set timeoutSeconds to 2.0
global frontApp, frontAppName, windowTitle, uiScript

set targetProcessName to "Microsoft Edge"
set OC to " \""
set CC to "\" "
set c1 to "click UI Element 2 of tab group 2 of group 1 of group 1 of group 1 of group"
set c2 to "of window"
set c3 to "of application process \"Microsoft Edge\""
---
set windowTitle to ""
tell application "System Events"
    set frontApp to first application process whose name is targetProcessName---frontmost is true
    set frontAppName to name of frontApp
    tell process frontAppName
        tell (1st window whose value of attribute "AXMain" is true)
            set windowTitle to value of attribute "AXTitle"
        end tell
    end tell
end tell

set uiScript to c1 & OC & windowTitle & CC & c2 & OC & windowTitle & CC & c3

my doWithTimeout(uiScript, timeoutSeconds)
on doWithTimeout(uiScript, timeoutSeconds)
	set endDate to (current date) + timeoutSeconds
	repeat
		try
			run script "tell application \"System Events\"
" & uiScript & "
end tell"
			exit repeat
		on error errorMessage
			if ((current date) > endDate) then
				error "Can not " & uiScript
			end if
		end try
	end repeat
end doWithTimeout