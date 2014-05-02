using terms from application "Messages"
	on addressed message received
		(* Do nothing *)
	end addressed message received
	
	on received text invitation
		(* Do nothing *)
	end received text invitation
	
	on received audio invitation
		(* Do nothing *)
	end received audio invitation
	
	on received video invitation
		(* Do nothing *)
	end received video invitation
	
	on received file transfer invitation
		(* Do nothing *)
	end received file transfer invitation
	
	on av chat started
		(* Do nothing *)
	end av chat started
	
	on completed file transfer
		(* Do nothing *)
	end completed file transfer
	
	on av chat ended
		(* Do nothing *)
	end av chat ended
	
	on received local screen sharing invitation
		(* Do nothing *)
	end received local screen sharing invitation
	
	on buddy authorization requested
		(* Do nothing *)
	end buddy authorization requested
	
	on addressed chat room message received
		(* Do nothing *)
	end addressed chat room message received
	
	on received remote screen sharing invitation
		(* Do nothing *)
	end received remote screen sharing invitation
	
	on buddy became available
		(* Do nothing *)
	end buddy became available
	
	on buddy became unavailable
		(* Do nothing *)
	end buddy became unavailable
	
	on message received theMessage from theBuddy for theChat
		sendMessage(theMessage, theBuddy, theChat)
	end message received
	
	on active chat message received theMessage from theBuddy for theChat
		sendMessage(theMessage, theBuddy, theChat)
	end active chat message received
	
	on chat room message received theMessage from theBuddy for theChat
		sendMessage(theMessage, theBuddy, theChat)
	end chat room message received
	
	on logout finished
		(* Do nothing *)
	end logout finished
	
	on login finished
		(* Do nothing *)
	end login finished
	
	property alphaList : "abcdefghijklmnopqrstuvwxyz"'s items & reverse of "ABCDEFGHIJKLMNOPQRSTUVWXYZ"'s items
	
	on textItems from t
		try
			t's text items
		on error number -2706
			tell (count t's text items) div 2 to my (textItems from (t's text 1 thru text item it)) & my (textItems from (t's text from text item (it + 1) to -1))
		end try
	end textItems
	
	to changeCase of t to c
		if (count t) is 0 then return t
		considering case
			if c is not in {"upper", "lower", "title", "sentence"} then
				error "The word \"" & c & "\" is not a valid option. Please use \"upper\", \"lower\", \"title\" or \"sentence\"."
			else if c is "upper" then
				set n to 1
			else
				set n to -1
			end if
			set d to text item delimiters
			repeat with n from n to n * 26 by n
				set text item delimiters to my alphaList's item n
				set t to textItems from t
				set text item delimiters to my alphaList's item -n
				tell t to set t to beginning & ({""} & rest)
			end repeat
			if c is in {"title", "sentence"} then
				if c is "title" then
					set s to space
				else
					set s to ". "
				end if
				set t to (t's item 1 & s & t)'s text 2 thru -1
				repeat with i in {s, tab, return, ASCII character 10}
					set text item delimiters to i
					if (count t's text items) > 1 then repeat with n from 1 to 26
						set text item delimiters to i & my alphaList's item n
						if (count t's text items) > 1 then
							set t to textItems from t
							set text item delimiters to i & my alphaList's item -n
							tell t to set t to beginning & ({""} & rest)
						end if
					end repeat
				end repeat
				set t to t's text ((count s) + 1) thru -1
			end if
			set text item delimiters to d
		end considering
		t
	end changeCase
	
	on write_to_file(this_data, target_file, append_data)
		try
			set the target_file to the target_file as string
			set the open_target_file to open for access file target_file with write permission
			if append_data is false then set eof of the open_target_file to 0
			write this_data to the open_target_file starting at eof
			close access the open_target_file
			return true
		on error
			try
				close access file target_file
			end try
			return false
		end try
	end write_to_file
	
	on unblockPerson(personToUnblock)
		set blockedPeopleTxt to alias "Macintosh HD:Users:YourUserName:Library:Application Scripts:com.apple.iChat:Messages Bot:Blocked People.txt"
		set blockedPeople to (read blockedPeopleTxt)
		write_to_file(deleteLinesFromText(blockedPeople & "\n", personToUnblock), blockedPeopleTxt, false)
	end unblockPerson
	
	on deleteLinesFromText(theText, deletePhrase)
		set newText to ""
		try
			-- here's how you can delete all lines of text fron fileText that contain the deletePhrase.
			-- first turn the text into a list so you can repeat over each line of text
			set textList to paragraphs of theText
			
			-- now repeat over the list and ignore lines that have the deletePhrase
			repeat with i from 1 to count of textList
				set thisLine to item i of textList
				if thisLine does not contain deletePhrase then
					set newText to newText & thisLine & return
				end if
			end repeat
			if newText is not "" then set newText to text 1 thru -2 of newText
		on error
			set newText to theText
		end try
		return newText
	end deleteLinesFromText
	
	on message sent theMessage for theChat
		if ((changeCase of theMessage to "lower") is "/list blocked" or (changeCase of theMessage to "lower") is "/listblocked") then
			send listBlockedPeople() to theChat
		else
			if (theMessage starts with "/block ") then
				set blockedPerson to str_replace("/block ", "", theMessage)
				blockPerson(blockedPerson)
				send blockedPerson & " was successfully blocked, master; may you be to never unblock this bad wizard!" to theChat
			else
				if (theMessage starts with "/unblock ") then
					set blockedPerson to str_replace("/unblock ", "", theMessage)
					unblockPerson(blockedPerson)
					send blockedPerson & " was successfully unblocked, master; may you be to never block this good wizard ever again!" to theChat
				else
					if ((changeCase of theMessage to "lower") contains "shut up" and (changeCase of theMessage to "lower") contains "Dobby") then
						send "Yes, master." to theChat
					else
						if (theMessage starts with "/choose ") then
							try
								set optionsText to theMessage
								set optionsText to str_replace("/choose ", "", optionsText)
								set options to split(optionsText, ",")
								if ((count of options) is 1) then
									send "Feed me more items!" to theChat
								else
									set chosenOption to some item of options
									send ("Master: " & chosenOption & ", I choose you!") to theChat
								end if
							on error
								(* Should go on to "Person said text" *)
							end try
						else
							(* It still won't matter if they actually get a loop through, I just like it this way. *)
							set blacky to {"for", "while"}
							try
								repeat with theItem in blacky
									if (theMessage contains theItem or theMessage starts with "\"" or theMessage is "true" or theMessage is "false" or theMessage is "yes" or theMessage is "no") then
										send "(Nice try, " & theBuddy & ")" to theChat
										error "You don't have access to these commands."
									end if
								end repeat
								send ("Master, the answer is " & ((do shell script "/System/Library/Frameworks/JavaScriptCore.framework/Versions/Current/Resources/jsc -e \"print(" & theMessage & ")\"") as string)) to theChat
							on error
								send ("Master said '" & theMessage & "'") to theChat
							end try
						end if
					end if
				end if
			end if
		end if
	end message sent
	
	to split(someText, delimiter)
		set AppleScript's text item delimiters to delimiter
		set someText to someText's text items
		set AppleScript's text item delimiters to {""} --> restore delimiters to default value
		return someText
	end split
	
	on str_replace(find, replace, subject)
		set prevTIDs to text item delimiters of AppleScript
		set returnList to true
		
		-- This wouldn't make sense (you could have it raise an error instead)
		if class of find is not list and class of replace is list then return subject
		if class of find is not list then set find to {find}
		if class of subject is not list then Â
			set {subject, returnList} to {{subject}, false}
		
		set findCount to count find
		set usingReplaceList to class of replace is list
		
		try
			repeat with i from 1 to (count subject)
				set thisSubject to item i of subject
				
				repeat with n from 1 to findCount
					set text item delimiters of AppleScript to item n of find
					set thisSubject to text items of thisSubject
					
					if usingReplaceList then
						try
							item n of replace
						on error
							"" -- `replace` ran out of items
						end try
					else
						replace
					end if
					
					set text item delimiters of AppleScript to result
					set thisSubject to "" & thisSubject
				end repeat
				
				set item i of subject to thisSubject
			end repeat
		end try
		
		set text item delimiters of AppleScript to prevTIDs
		if not returnList then return beginning of subject
		return subject
	end str_replace
	
	on listBlockedPeople()
		try
			set listOfBlockedPeople to ""
			set blockedPeople to paragraphs of (read file "Macintosh HD:Users:YourUserName:Library:Application Scripts:com.apple.iChat:Messages Bot:Blocked People.txt")
			set amountOfBlockedPeople to length of blockedPeople
			repeat with nextLine in blockedPeople
				if amountOfBlockedPeople is greater than 1 then
					set listOfBlockedPeople to (listOfBlockedPeople & nextLine & ", ")
					set amountOfBlockedPeople to (amountOfBlockedPeople - 1)
				else
					if amountOfBlockedPeople is 1 then
						set listOfBlockedPeople to (listOfBlockedPeople & nextLine)
					end if
				end if
			end repeat
			return listOfBlockedPeople
		on error
			return "Nobody's blocked... yet."
		end try
	end listBlockedPeople
	
	to joinList(aList, delimiter)
		set retVal to ""
		set prevDelimiter to AppleScript's text item delimiters
		set AppleScript's text item delimiters to delimiter
		set retVal to aList as string
		set AppleScript's text item delimiters to prevDelimiter
		return retVal
	end joinList
	
	on blockPerson(thePerson)
		set blockedPeopleTxt to alias "Macintosh HD:Users:YourUserName:Library:Application Scripts:com.apple.iChat:Messages Bot:Blocked People.txt"
		write thePerson & "\n" starting at (1 + (get eof blockedPeopleTxt)) to blockedPeopleTxt
	end blockPerson
	
	on sendMessage(theMessage, theBuddy, theChat)
		try
			set blockedPeopleTxt to alias "Macintosh HD:Users:YourUserName:Library:Application Scripts:com.apple.iChat:Messages Bot:Blocked People.txt"
			set blockedPersonChatting to false
			set blockedPeople to (read blockedPeopleTxt)
			repeat with blockedPerson in paragraphs of blockedPeople
				if (blockedPerson as string is full name of theBuddy) then
					set blockedPersonChatting to true
				end if
			end repeat
		on error
			(* Do nothing *)
		end try
		if (blockedPersonChatting is false) then
			if ((changeCase of theMessage to "lower") is "/list blocked" or (changeCase of theMessage to "lower") is "/listblocked") then
				send listBlockedPeople() to theChat
			else
				if (theMessage starts with "/choose ") then
					try
						set optionsText to theMessage
						set optionsText to str_replace("/choose ", "", optionsText)
						set options to split(optionsText, ",")
						if ((count of options) is 1) then
							send "Feed me more items!" to theChat
						else
							set chosenOption to some item of options
							send (full name of theBuddy & ": " & chosenOption & ", I choose you!") to theChat
						end if
					on error
						(* Should go on to "Person said text" *)
					end try
				else
					set blacky to {"for", "while"}
					try
						repeat with theItem in blacky
							if (theMessage contains theItem or theMessage starts with "\"" or theMessage is "true" or theMessage is "false" or theMessage is "yes" or theMessage is "no") then
								send "(Nice try, " & theBuddy & ")" to theChat
								error "You don't have access to these commands."
							end if
						end repeat
						send (full name of theBuddy & ", the answer is " & ((do shell script "/System/Library/Frameworks/JavaScriptCore.framework/Versions/Current/Resources/jsc -e \"print(" & theMessage & ")\"") as string)) to theChat
					on error
						send (full name of theBuddy & " said '" & theMessage & "'") to theChat
					end try
				end if
			end if
		else
			send "You is a bad wizard!  I only serve Master and his friends!"
		end if
	end sendMessage
end using terms from