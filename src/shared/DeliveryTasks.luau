local Tasks = {}

Tasks.Names = { "Mailbox", "Signature", "Photo" }

function Tasks.instruction(kind, stage)
	if kind == "Mailbox" then return "Place the parcel in the roadside mailbox." end
	if kind == "Signature" then
		return if stage == "Waiting" then "Wait three seconds, then collect the signature at the door." else "Ring at the door, then wait for the customer's signature."
	end
	return if stage == "Photo" then "Go to the photo marker, face the front door, and take proof of delivery." else "Leave the parcel at the door, then photograph it from the street."
end

-- No client can choose its task, skip a stage, or supply the signature timer.
function Tasks.interact(kind, stage, action, now, started, facingDoor)
	if kind == "Mailbox" then return if action == "Mailbox" then "Complete" else "WrongTarget" end
	if kind == "Signature" then
		if action ~= "Door" then return "WrongTarget" end
		if stage == "Start" then return "Wait" end
		if stage ~= "Waiting" then return "WrongTarget" end
		return if now - started >= 3 then "Complete" else "Waiting"
	end
	if kind == "Photo" then
		if stage == "Start" then return if action == "Door" then "Place" else "PlaceFirst" end
		if stage ~= "Photo" then return "WrongTarget" end
		if action ~= "Photo" then return "NeedPhoto" end
		return if facingDoor then "Complete" else "FaceDoor"
	end
	return "WrongTarget"
end

return Tasks
