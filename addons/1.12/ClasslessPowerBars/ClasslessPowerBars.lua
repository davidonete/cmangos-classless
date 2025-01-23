ClasslessPowerBarsDB = {}

ClasslessPowerBars = CreateFrame("Frame")

ClasslessPowerBars.initialized = false
ClasslessPowerBars.debug = true
ClasslessPowerBars.serverMessagePrefix = "classless"

ClasslessPowerBars:RegisterEvent("CHAT_MSG_ADDON")
ClasslessPowerBars:RegisterEvent("ADDON_LOADED")
ClasslessPowerBars:RegisterEvent("PLAYER_ENTERING_WORLD")

function ClasslessPowerBars:SendDebugMessage(msg)
    if self.debug then
		DEFAULT_CHAT_FRAME:AddMessage('|cff0070de[DEBUG:' .. GetTime() .. ']|cffffffff[' .. msg .. ']')
	end
end

function ClasslessPowerBars:SendServerMessage(msg)
	SendChatMessage("." .. self.serverMessagePrefix .. " " .. msg)
end

function ClasslessPowerBars:HandleServerMessage(msg)
	ClasslessPowerBars:SendDebugMessage("HandleServerMessage "..msg)
end

ClasslessPowerBars:SetScript("OnEvent", function()
	if event then
		ClasslessPowerBars:SendDebugMessage("Event received: "..event)
		if event == 'ADDON_LOADED' or event == 'PLAYER_ENTERING_WORLD' then
			ClasslessPowerBars:SendServerMessage("enableAddon")
		elseif event == 'CHAT_MSG_ADDON' then
			if string.find(arg1, ClasslessPowerBars.serverMessagePrefix, 1, true) then
				ClasslessPowerBars:HandleServerMessage(arg2)
			end
		end
	end
end)