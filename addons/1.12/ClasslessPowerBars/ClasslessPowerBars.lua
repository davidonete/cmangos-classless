ClasslessPowerBarsDB = {}

ClasslessPowerBars = CreateFrame("Frame")

ClasslessPowerBars.initialized = false
ClasslessPowerBars.debug = true
ClasslessPowerBars.serverMessagePrefix = "classless"
-- 1: mana, 2: rage, 3: nil, 4: energy
ClasslessPowerBars.powerBars = { nil, nil, nil, nil } 

ClasslessPowerBars:RegisterEvent("CHAT_MSG_ADDON")
ClasslessPowerBars:RegisterEvent("ADDON_LOADED")
ClasslessPowerBars:RegisterEvent("PLAYER_ENTERING_WORLD")

function ClasslessPowerBars:SendDebugMessage(msg)
    if self.debug then
		DEFAULT_CHAT_FRAME:AddMessage('|cff0070de[DEBUG:' .. GetTime() .. ']|cffffffff[' .. tostring(msg) .. ']')
	end
end

function ClasslessPowerBars:Explode(str, delimiter)
    local result = {}
    local from = 1
    local delimFrom, delimTo = string.find(str, delimiter, from, 1, true)
    while delimFrom do
        table.insert(result, string.sub(str, from, delimFrom - 1))
        from = delimTo + 1
        delimFrom, delimTo = string.find(str, delimiter, from, true)
    end
    table.insert(result, string.sub(str, from))
    return result
end

function ClasslessPowerBars:IsManaPower(powerType)
	return powerType == 0
end

function ClasslessPowerBars:IsRagePower(powerType)
	return powerType == 1
end

function ClasslessPowerBars:IsEnergyPower(powerType)
	return powerType == 3
end

function ClasslessPowerBars:SendServerMessage(msg)
	SendChatMessage("." .. self.serverMessagePrefix .. " " .. msg)
end

function ClasslessPowerBars:SendInitializeRequest()
	if self.initialized == false then
		ClasslessPowerBars:SendDebugMessage("SendInitializeRequest")
		self:SendServerMessage("enableAddon")
	end
end

function ClasslessPowerBars:HandleInitialize()
	if self.initialized == false then
		self:SendDebugMessage("HandleInitialize")
		self.initialized = true;
		
		local _, playerClass = UnitClass("player")
		local hasDefaultRageBar = playerClass == "WARRIOR"
		local hasDefaultEnergyBar = playerClass == "ROGUE"
		local hasDefaultManaBar = not (hasDefaultEnergyBar or hasDefaultRageBar)
		
		local baseSize = { 106, 12 }
		local baseSizeBD = { 126, 16 }
		local offsetSize = { 20, 0 }
		local offsetSizeBD = { 23, 0 }
		local basePosition = { 111, 22 }
		local offsetPosition = { -11, 14 }
		local barCount = 0;
		
		for barID = 1, 4 do
			local powerType = barID - 1;
			if (self:IsManaPower(powerType) and not hasDefaultManaBar) or (self:IsRagePower(powerType) and not hasDefaultRageBar) or (self:IsEnergyPower(powerType) and not hasDefaultEnergyBar) then	
				self.powerBars[barID] = CreateFrame("StatusBar", "ClasslessPowerBars", PlayerFrame, "TextStatusBar")
				self.powerBars[barID]:SetWidth(baseSize[1] - (offsetSize[1] * barCount))
				self.powerBars[barID]:SetHeight(baseSize[2] - (offsetSize[2] * barCount))
				self.powerBars[barID]:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
				self.powerBars[barID]:SetStatusBarColor(ManaBarColor[powerType].r, ManaBarColor[powerType].g, ManaBarColor[powerType].b)

				local bg = self.powerBars[barID]:CreateTexture("$parentBackground", "BACKGROUND")
				bg:SetAllPoints(self.powerBars[barID])
				bg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
				bg:SetVertexColor(0, 0, 0, 0.5)
				self.powerBars[barID].bg = bg

				local bd = self.powerBars[barID]:CreateTexture("$parentBorder", "OVERLAY")
				bd:SetWidth(baseSizeBD[1] - (offsetSizeBD[1] * barCount))
				bd:SetHeight(baseSizeBD[2] - (offsetSizeBD[2] * barCount))
				bd:SetTexture("Interface\\CharacterFrame\\UI-CharacterFrame-GroupIndicator")
				self.powerBars[barID].bd = bd

				local text = self.powerBars[barID]:CreateFontString("$parentText", "OVERLAY", "TextStatusBarText")
				text:SetPoint("CENTER", 0, 0)
				SetTextStatusBarText(self.powerBars[barID], text)
				self.powerBars[barID].textLockable = 1
				self.powerBars[barID].text = text
				
				self.powerBars[barID]:SetMinMaxValues(0, 100)
				self.powerBars[barID]:SetValue(100)
				
				self.powerBars[barID]:SetScript("OnMouseUp", function(button)
					this:GetParent():Click(button)
				end)
				
				self.powerBars[barID]:SetPoint("BOTTOMLEFT", basePosition[1] - (offsetPosition[1] * barCount), basePosition[2] - (offsetPosition[2] * barCount))
				self.powerBars[barID].bd:SetPoint("TOPLEFT", -10, 0)
				self.powerBars[barID].bd:SetTexCoord(0.0234375, 0.6875, 1.0, 0.0)
			
				barCount = barCount + 1;
			end
		end
	end
end

function ClasslessPowerBars:HandlePowerUpdate(powerType, current, total)
	if self.initialized then
		self:SendDebugMessage("HandlePowerUpdate Power: " .. powerType .. " Current: " .. current .. " Total: " .. total)
		local barID = powerType + 1
		if self.powerBars[barID] then
			self.powerBars[barID]:SetMinMaxValues(0, total)
			self.powerBars[barID]:SetValue(current)
		end
	end
end

function ClasslessPowerBars:HandleServerMessage(msg)
	--self:SendDebugMessage("HandleServerMessage " .. msg)
	
	local args = self:Explode(msg, "#")
	if string.find(msg, "AddonEnabled", 1, true) then
		self:HandleInitialize()
	elseif string.find(msg, "PowerUpdate", 1, true) then
		-- PowerUpdate#powerType;current;total
		args = self:Explode(args[2], ";")
		self:HandlePowerUpdate(args[1], args[2], args[3])
	end
end

ClasslessPowerBars:SetScript("OnEvent", function()
	if event then
		--ClasslessPowerBars:SendDebugMessage("Event received: "..event)
		if event == 'ADDON_LOADED' or event == 'PLAYER_ENTERING_WORLD' then
			ClasslessPowerBars:SendInitializeRequest()
		elseif event == 'CHAT_MSG_ADDON' then
			if string.find(arg1, ClasslessPowerBars.serverMessagePrefix, 1, true) then
				ClasslessPowerBars:HandleServerMessage(arg2)
			end
		end
	end
end)