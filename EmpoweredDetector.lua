local EmpoweredDetectorFrame = CreateFrame("Frame")

-- Register Events
EmpoweredDetectorFrame:RegisterEvent("ADDON_LOADED")
EmpoweredDetectorFrame:RegisterEvent('PLAYER_ENTERING_WORLD')

-- Torghast-specific Empowerment spells
local empoweredSpells = {
	-- [357857] = true, -- Activate Empowerment
	[357861] = true, -- Activate Empowerment
}

-- Help command
local cmdColor = "|cfffff569"
local cmdHelp = {
	"|cffff4500Empowered|r|cff00ffffDetector|r: Slash Commands:",
	cmdColor.."/ed|r - print status",
	cmdColor.."/ed help|r - list of commands",
	cmdColor.."/ed on|r - enable EmpoweredDetector",
	cmdColor.."/ed off|r - disable EmpoweredDetector",
	cmdColor.."/ed group|r - announce to group",
	cmdColor.."/ed say|r - announce to /say",
	cmdColor.."/ed yell|r - announce to /yell",
	cmdColor.."/ed self|r - annouce to self",
	cmdColor.."/ed test|r - test the announcer",
}

-- Configuration
local function setting(cmd)
	cmd=string.upper(cmd)
	if cmd == "ON" or cmd == "OFF" then
		EmpoweredDetector_Enabled = (cmd == "ON")
		if EmpoweredDetector_Enabled then
			EmpoweredDetectorFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		else
			EmpoweredDetectorFrame:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		end
		print("Empowered Detector: " .. (EmpoweredDetector_Enabled and "|cff85ff85On|r" or "|cffff0000Off|r") .. ".")
	elseif cmd == "SAY" or cmd == "GROUP" or cmd == "SELF" or cmd == "YELL" then
		EmpoweredDetector_Mode = cmd
		print("Empowered Detector will announce to |cffff9c00"..EmpoweredDetector_Mode.."|r.")
	elseif cmd == "TEST" then
		EmpoweredDetectorFrame:Announce("[Test] Empowered Detector Announcer.")
	elseif cmd == "HELP" then
		print(table.concat(cmdHelp, "|n"))
	else
		print("Empowered Detector Status: "..(EmpoweredDetector_Enabled and "|cff85ff85On|r" or "|cffff0000Off|r").."|r and announcing to: |cff1cb619"..EmpoweredDetector_Mode.."|r.")
	end
end

-- Register Slash Commands
SlashCmdList["EMPOWERDETECTOR"] = setting;
SlashCmdList["ED"] = setting;
SLASH_EMPOWERDETECTOR1 = "/empowerdetector"
SLASH_ED1 = "/ed"

-- Start of EmpoweredDetectorFrame Detection
EmpoweredDetectorFrame:SetScript("OnEvent", function( self, event, ... )
	self[event]( self, ... )
end)

function EmpoweredDetectorFrame:PLAYER_ENTERING_WORLD()
	if EmpoweredDetector_Enabled == true and EmpoweredDetectorFrame:IS_IN_TORGHAST() then
		-- Register if this detector is enabled and the player is in Torghast.
		EmpoweredDetectorFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		print("|cffFF4500Empowered|cff00ffffDetector|r Loaded!")
	else
		EmpoweredDetectorFrame:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	end
end

function EmpoweredDetectorFrame:ADDON_LOADED()
	-- By default, it is enabled if not set.
	if EmpoweredDetector_Enabled == nil then
		EmpoweredDetector_Enabled = true
	end

	-- By default, the announcement is sent to the player's group.
	if EmpoweredDetector_Mode == nil then
		EmpoweredDetector_Mode = "GROUP"
	end
end

function EmpoweredDetectorFrame:UNIT_SPELLCAST_SUCCEEDED(unitTarget, _, spellID)
	-- Ignore everything except for a successful cast of Activate Empowerment.
	if EmpoweredDetector_Enabled and EmpoweredDetectorFrame:IS_IN_TORGHAST() then
		if empoweredSpells[spellID] then
			local name = GetUnitName(unitTarget, true)
			EmpoweredDetectorFrame:Announce("Empowered Detector: "..name.." cast "..GetSpellLink(spellID).." on the party!")
		end
	end
end
-- End of EmpoweredDetectorFrame Detection

-- Announcer Redirector
function EmpoweredDetectorFrame:Announce(msg)
	local mode = EmpoweredDetector_Mode
	if EmpoweredDetector_Mode == "SELF" then
		print(msg)
		return
	elseif EmpoweredDetector_Mode == "TEST" then
		mode="TEST"
	elseif EmpoweredDetector_Mode == "GROUP" then
		if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
			mode = "INSTANCE_CHAT"
		elseif IsInGroup() then
			mode = "PARTY"
		end
	end

	-- YELL and SAY via SendChatMessage are disabled in the outdoor world.
	if (mode == "YELL" or mode == "SAY") and not IsInInstance() then
		return
	end

	SendChatMessage(msg, mode)
end

function EmpoweredDetectorFrame:IS_IN_TORGHAST()
	local name, instanceType, _, _, _, _, _, _ = GetInstanceInfo()
	local i = string.find(string.lower(name), "torghast")
	if i == nil then
		return false
	end
	if IsInInstance() then
		return true
	end
	return false
end