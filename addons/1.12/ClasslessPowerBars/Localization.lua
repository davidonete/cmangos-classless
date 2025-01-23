local L = AceLibrary("AceLocale-2.2"):new("ClasslessPowerBars")

local function enUS() return {
	["Move Above"] = true,
	["Move the bar above the player frame."] = true,
} end

L:RegisterTranslations("enUS", enUS)
L:RegisterTranslations("enGB", enUS)