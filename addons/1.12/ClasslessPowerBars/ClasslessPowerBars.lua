--local _, playerClass = UnitClass("player")
--if playerClass ~= "DRUID" then return end

local ClasslessPowerBars = AceLibrary("AceAddon-2.0"):new("AceConsole-2.0", "AceEvent-2.0", "AceDB-2.0")
local DruidManaLib = AceLibrary("DruidManaLib-1.0")
local L = AceLibrary("AceLocale-2.2"):new("ClasslessPowerBars")

local TEXTURE = "Interface\\TargetingFrame\\UI-StatusBar"

function ClasslessPowerBars:OnInitialize()
	self:RegisterDB("ClasslessPowerBarsDB")
	self:RegisterDefaults("profile", { moveAbove = false })
	self:RegisterChatCommand({ "/classlesspowerbars", "/cpb" }, {
		type = "group",
		args = {
			moveabove = {
				type = "toggle",
				name = L["Move Above"],
				desc = L["Move the bar above the player frame."],
				get = "IsMoveAbove",
				set = "ToggleMoveAbove",
			},
		},
	})
end

function ClasslessPowerBars:OnEnable()
	DEFAULT_CHAT_FRAME:AddMessage("ClasslessPowerBars:OnEnable")

	if not self.bar then
		DEFAULT_CHAT_FRAME:AddMessage("ClasslessPowerBars:OnEnable create bar")
		local bar = CreateFrame("StatusBar", "ClasslessPowerBars", PlayerFrame, "TextStatusBar")
		bar:SetWidth(78)
		bar:SetHeight(12)
		bar:SetStatusBarTexture(TEXTURE)
		bar:SetStatusBarColor(ManaBarColor[0].r, ManaBarColor[0].g, ManaBarColor[0].b)

		local bg = bar:CreateTexture("$parentBackground", "BACKGROUND")
		bg:SetAllPoints(bar)
		bg:SetTexture(TEXTURE)
		bg:SetVertexColor(0, 0, 0, 0.5)
		bar.bg = bg

		local bd = bar:CreateTexture("$parentBorder", "OVERLAY")
		bd:SetWidth(97)
		bd:SetHeight(16)
		bd:SetTexture("Interface\\CharacterFrame\\UI-CharacterFrame-GroupIndicator")
		bar.bd = bd

		local text = bar:CreateFontString("$parentText", "OVERLAY", "TextStatusBarText")
		text:SetPoint("CENTER", 0, 0)
		SetTextStatusBarText(bar, text)
		bar.textLockable = 1
		bar.text = text
		
		-- Enable dragging
		bar:SetMovable(true)
		bar:EnableMouse(true)
		bar:RegisterForDrag("LeftButton")
		bar:SetScript("OnDragStart", function(self) this:StartMoving() end)
		bar:SetScript("OnDragStop", function(self) this:StopMovingOrSizing() end)

		bar:SetScript("OnMouseUp", function(button)
			this:GetParent():Click(button)
		end)

		bar:SetScript("OnUpdate", function()
			local curMana, maxMana = DruidManaLib:GetMana()
			this:SetMinMaxValues(0, 100)
			this:SetValue(0)
		end)
		
		self.bar = bar
	end

	self:UpdatePosition()

	self:RegisterEvent("UNIT_DISPLAYPOWER")
	self:RegisterEvent("PLAYER_AURAS_CHANGED")

	self:UpdatePowerType()
end

function ClasslessPowerBars:OnDisable()
	DEFAULT_CHAT_FRAME:AddMessage("ClasslessPowerBars:OnDisable")
	self.bar:Hide()
end

function ClasslessPowerBars:UNIT_DISPLAYPOWER()
	self:UpdatePowerType()
end

function ClasslessPowerBars:PLAYER_AURAS_CHANGED()
	if not self.bar:IsShown() then return end
	self:UpdatePowerType()
end

function ClasslessPowerBars:IsMoveAbove()
	return self.db.profile.moveAbove
end

function ClasslessPowerBars:ToggleMoveAbove()
	self.db.profile.moveAbove = not self.db.profile.moveAbove
	self:UpdatePosition()
end

function ClasslessPowerBars:UpdatePosition()
	self.bar:ClearAllPoints()
	if self.db.profile.moveAbove then
		self.bar:SetPoint("TOPLEFT", 114, -10)
		self.bar.bd:SetPoint("TOPLEFT", -10, 4)
		self.bar.bd:SetTexCoord(0.0234375, 0.6875, 0.0, 1.0)
	else
		self.bar:SetPoint("BOTTOMLEFT", 114, 23)
		self.bar.bd:SetPoint("TOPLEFT", -10, 0)
		self.bar.bd:SetTexCoord(0.0234375, 0.6875, 1.0, 0.0)
	end
end

function ClasslessPowerBars:UpdatePowerType()
	--if self.loaded and UnitPowerType("player") ~= 0 then
	--	DEFAULT_CHAT_FRAME:AddMessage("ClasslessPowerBars:UpdatePowerType show bar")
		self.bar:Show()
	--else
	--	self.bar:Hide()
		self.loaded = true -- so we don't show a mana bar with bogus values
	--end
end