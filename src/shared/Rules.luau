-- Pure game rules shared with the command-line regression tests.
local Rules = {}

function Rules.delivery(index, route, carrying, kind, flashlight, sprinting, noisyUntil, now)
	if index < route then return "RepeatedBell" end
	if index > route then return "WrongAddress" end
	if not carrying then return "NoParcel" end
	if kind == "Dark" and flashlight then return "Light" end
	if kind == "Quiet" and (sprinting or now < noisyUntil) then return "Noise" end
	return "Deliver"
end

function Rules.detectable(z, distance, radius, sprinting, flashlight, angry)
	if z >= -12 then return false end
	local range = radius + (if sprinting then 55 else 0) + (if flashlight then 25 else 0)
	return angry or distance < range
end

return Rules
