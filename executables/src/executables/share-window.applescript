#!/usr/bin/osascript

# @raycast.schemaVersion 1
# @raycast.title ShareWindow
# @raycast.mode compact
# @raycast.packageName Executables
# @raycast.description Exit fullscreen, resize the focused window to 1920x1080, and center it on its current display.

use AppleScript version "2.4"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property targetWidth : 1920
property targetHeight : 1080
property fullscreenPollCount : 40
property fullscreenPollDelay : 0.1

on run
	try
		tell application "System Events"
			if UI elements enabled is false then error "Accessibility access is required for Raycast to control windows."

			set frontProcess to first application process whose frontmost is true
			set processName to name of frontProcess
			set targetWindow to my targetWindowFor(frontProcess)
		end tell

		set targetWindow to my exitFullscreenIfNeeded(processName, targetWindow)

		tell application "System Events"
			set frameRecord to my frameFor(targetWindow)
		end tell

		set screenBounds to my screenBoundsForFrame(frameRecord)
		set screenWidth to (rightEdge of screenBounds) - (leftEdge of screenBounds)
		set screenHeight to (bottomEdge of screenBounds) - (topEdge of screenBounds)

		if screenWidth < targetWidth or screenHeight < targetHeight then
			error "The current display's usable area is smaller than 1920x1080."
		end if

		set newX to (leftEdge of screenBounds) + ((screenWidth - targetWidth) div 2)
		set newY to (topEdge of screenBounds) + ((screenHeight - targetHeight) div 2)

		tell application "System Events"
			tell targetWindow
				set size to {targetWidth, targetHeight}
				set position to {newX, newY}
			end tell
		end tell

		return "Resized " & processName & " to 1920x1080"
	on error errMsg number errNum
		error errMsg number errNum
	end try
end run

on targetWindowFor(frontProcess)
	tell application "System Events"
		tell frontProcess
			if (count of windows) is 0 then error "The frontmost app has no windows to resize."

			repeat with candidateWindow in windows
				try
					if value of attribute "AXSubrole" of candidateWindow is "AXStandardWindow" then return candidateWindow
				on error
					-- Skip windows that don't expose a standard subrole.
				end try
			end repeat

			return front window
		end tell
	end tell
end targetWindowFor

on exitFullscreenIfNeeded(processName, targetWindow)
	tell application "System Events"
		tell application process processName
			set fullscreenState to false
			try
				set fullscreenState to value of attribute "AXFullScreen" of targetWindow
			on error
				return targetWindow
			end try

			if fullscreenState is false then return targetWindow

			set value of attribute "AXFullScreen" of targetWindow to false
		end tell
	end tell

	repeat fullscreenPollCount times
		delay fullscreenPollDelay
		tell application "System Events"
			tell application process processName
				set targetWindow to my targetWindowFor(it)
				try
					if (value of attribute "AXFullScreen" of targetWindow) is false then
						delay 0.1
						return targetWindow
					end if
				on error
					return targetWindow
				end try
			end tell
		end tell
	end repeat

	error "Timed out waiting for the window to exit fullscreen."
end exitFullscreenIfNeeded

on frameFor(targetWindow)
	tell application "System Events"
		tell targetWindow
			set {windowX, windowY} to position
			set {windowWidth, windowHeight} to size
		end tell
	end tell

	return {x:windowX, y:windowY, width:windowWidth, height:windowHeight}
end frameFor

on screenBoundsForFrame(frameRecord)
	set candidateScreens to my visibleScreens()
	set midX to (x of frameRecord) + ((width of frameRecord) / 2)
	set midY to (y of frameRecord) + ((height of frameRecord) / 2)

	repeat with candidateScreen in candidateScreens
		set screenRecord to contents of candidateScreen
		if midX >= (leftEdge of screenRecord) and midX <= (rightEdge of screenRecord) and midY >= (topEdge of screenRecord) and midY <= (bottomEdge of screenRecord) then
			return screenRecord
		end if
	end repeat

	set bestScreen to missing value
	set bestOverlap to -1

	set frameLeft to x of frameRecord
	set frameTop to y of frameRecord
	set frameRight to frameLeft + (width of frameRecord)
	set frameBottom to frameTop + (height of frameRecord)

	repeat with candidateScreen in candidateScreens
		set screenRecord to contents of candidateScreen
		set overlapLeft to my maxValue(frameLeft, leftEdge of screenRecord)
		set overlapTop to my maxValue(frameTop, topEdge of screenRecord)
		set overlapRight to my minValue(frameRight, rightEdge of screenRecord)
		set overlapBottom to my minValue(frameBottom, bottomEdge of screenRecord)

		if overlapRight > overlapLeft and overlapBottom > overlapTop then
			set overlapArea to (overlapRight - overlapLeft) * (overlapBottom - overlapTop)
			if overlapArea > bestOverlap then
				set bestOverlap to overlapArea
				set bestScreen to screenRecord
			end if
		end if
	end repeat

	if bestScreen is not missing value then return bestScreen

	error "Could not determine which display the focused window is on."
end screenBoundsForFrame

on visibleScreens()
	set cocoa to current application
	set screenList to cocoa's NSScreen's screens()
	set visibleScreenRecords to {}

	repeat with currentScreen in screenList
		set wholeFrame to currentScreen's frame()
		set visibleFrame to currentScreen's visibleFrame()

		set screenLeft to (cocoa's NSMinX(visibleFrame)) as integer
		set screenTop to ((cocoa's NSMaxY(wholeFrame)) - (cocoa's NSMaxY(visibleFrame))) as integer
		set screenRight to (cocoa's NSMaxX(visibleFrame)) as integer
		set screenBottom to (screenTop + (cocoa's NSHeight(visibleFrame))) as integer

		set end of visibleScreenRecords to {leftEdge:screenLeft, topEdge:screenTop, rightEdge:screenRight, bottomEdge:screenBottom}
	end repeat

	return visibleScreenRecords
end visibleScreens

on minValue(a, b)
	if a < b then return a
	return b
end minValue

on maxValue(a, b)
	if a > b then return a
	return b
end maxValue
