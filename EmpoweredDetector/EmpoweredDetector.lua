local EmpoweredDetectorFrame = CreateFrame("Frame")

-- Register Events
EmpoweredDetectorFrame:RegisterEvent("ADDON_LOADED")
EmpoweredDetectorFrame:RegisterEvent('PLAYER_ENTERING_WORLD')

-- Torghast-specific Empowerment spells
local empoweredSpells = {
	-- [357857] = true, -- Activate Empowerment
	[357861] = true, -- Activate Empowerment
}

-- Configuration
local function setting(cmd)
	cmd=string.upper(cmd)
	if cmd == 'ON' or cmd == 'OFF' then
		EmpoweredDetector_Enabled = (cmd == 'ON')
		if EmpoweredDetector_Enabled then
			EmpoweredDetectorFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		else
			EmpoweredDetectorFrame:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		end
		print("Empowered Detector: " .. (EmpoweredDetector_Enabled and "|cff85ff85On|r" or "|cffff0000Off|r") .. ".")
		
	elseif cmd == 'SAY' or cmd == 'GROUP' or cmd == 'SELF' or cmd == 'YELL' then
		EmpoweredDetector_Mode = cmd
		print("Empowered Detector will announce to |cffff9c00"..EmpoweredDetector_Mode.."|r.")
		
	elseif cmd == 'TEST' then
		EmpoweredDetectorFrame:Announce("[Test] Empowered Detector Announcer.")
		
	else
		print("Empowered Detector Status: "..(EmpoweredDetector_Enabled and "|cff85ff85On|r" or "|cffff0000Off|r").."|r and announcing to: |cff1cb619"..EmpoweredDetector_Mode.."|r.\nCommands: {on|off|group|say|yell|self|test}")
	end
end

-- Register Slash Commands
SlashCmdList["EMPOWERDETECTOR"] = setting;
SlashCmdList["ED"] = setting;
SLASH_EMPOWERDETECTOR1 = "/empowerdetector"
SLASH_ED1 = "/ed"

EmpoweredDetectorFrame:SetScript('OnEvent', function( self, event, ... )
	self[event]( self, ... )
end)

function EmpoweredDetectorFrame:PLAYER_ENTERING_WORLD()
    print("|cffFF4500Empowered|cff00ffffDetector|r loaded!")
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

	-- Register if this detector is enabled.
	if EmpoweredDetector_Enabled == true then
		EmpoweredDetectorFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	else
		EmpoweredDetectorFrame:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	end
end

function EmpoweredDetectorFrame:UNIT_SPELLCAST_SUCCEEDED(unitTarget, _, spellID)
	-- Ignore everything except for a successful cast of Activate Empowerment.
	if EmpoweredDetector_Enabled then
		if empoweredSpells[spellID] then
			local name = GetUnitName(unitTarget, true)
			EmpoweredDetectorFrame:Announce("Empowered Detector: "..name.." cast "..GetSpellLink(spellID).." on the party!")
		end
	end
end

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