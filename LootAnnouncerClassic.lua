
-- --------------------------
-- Loot Announcer Classic
-- By Apollo in Taiwan
-- --------------------------
local name, addon = ...

local L = {}

if GetLocale() == "zhTW" then
	L["Announce"] = "公告紫裝"
	L["Weapon"] = "武器"
	L["Set"] = "套裝"
	L["Other"] = "散裝"
else
	L["Announce"] = "Announce"
	L["Weapon"] = "Weapon"
	L["Set"] = "Set"
	L["Other"] = "Other"
end

local ui_button = nil

local set_textures = function (btn)
    local ntex = btn:CreateTexture()
    ntex:SetTexture('Interface/Buttons/UI-Panel-Button-Up')
    ntex:SetTexCoord(0, 0.625, 0, 0.6875)
    ntex:SetAllPoints()
    btn:SetNormalTexture(ntex)

    local htex = btn:CreateTexture()
    htex:SetTexture('Interface/Buttons/UI-Panel-Button-Highlight')
    htex:SetTexCoord(0, 0.625, 0, 0.6875)
    htex:SetAllPoints()
    btn:SetHighlightTexture(htex)

    local ptex = btn:CreateTexture()
    ptex:SetTexture('Interface/Buttons/UI-Panel-Button-Down')
    ptex:SetTexCoord(0, 0.625, 0, 0.6875)
    ptex:SetAllPoints()
    btn:SetPushedTexture(ptex)
  end

  local get_announce_target = function()
	if IsInRaid() then
		if (UnitIsGroupLeader('player') or UnitIsGroupAssistant('player')) then
			return 'RAID_WARNING'
		else
			return 'RAID'
		end
	elseif IsInGroup() then
		return 'PARTY'
	else
		return 'SAY'
	end
end
  
local Announcement = function ()
	local weapon = ""
	local set = ""
	local other = ""
	for i = 1, GetNumLootItems() do	
		local itemLink = nil
		for j = 1, 10 do	-- 多Query幾次, 確保有拿到物品資訊
			itemLink = GetLootSlotLink(i)
			if itemLink ~= nil then break end
		end
		if itemLink ~= nil then	-- 有拿到物品資訊才做後續動作
			local itemRarity = nil
			local itemClassID = nil
			local itemSetID = nil
			for j = 1, 10 do	-- 多Query幾次, 確保有拿到物品資訊
				_, _, itemRarity, _, _, _, _, _,_, _, _, itemClassID, _, _, _, itemSetID = GetItemInfo(itemLink)
				if itemRarity ~= nil then break end
			end

			if itemRarity~=nil and itemRarity > 3 then
				if itemSetID~=nil then
					set = set..itemLink
				elseif itemClassID==LE_ITEM_CLASS_WEAPON then
					weapon = weapon..itemLink
				else 
					other = other..itemLink
				end
			end
		end
	end
	if set ~= "" then set = L["Set"] ..set end
	if weapon ~= "" then weapon = L["Weapon"] ..weapon end
	if other ~= "" then other = L["Other"]..other end
	local set_len = strlen(set)
	local weapon_len = strlen(weapon)
	local other_len = strlen(other)

	if set_len + weapon_len + other_len <= 255 then
		SendChatMessage( weapon..other..set, get_announce_target(), nil, nil) 
	elseif weapon_len + other_len <= 255 then
		SendChatMessage( weapon..other, get_announce_target(), nil, nil) 
		SendChatMessage( set, get_announce_target(), nil, nil) 
	elseif other_len + set_len <= 255 then
		SendChatMessage( weapon, get_announce_target(), nil, nil) 
		SendChatMessage( other..set, get_announce_target(), nil, nil) 
	elseif weapon_len + set_len <= 255 then
		SendChatMessage( weapon..set, get_announce_target(), nil, nil) 
		SendChatMessage( other, get_announce_target(), nil, nil) 
	else
		SendChatMessage( weapon, get_announce_target(), nil, nil) 
		SendChatMessage( set, get_announce_target(), nil, nil) 
		SendChatMessage( other, get_announce_target(), nil, nil) 
	end
end

ui_button = CreateFrame('Button', 'ButtonAnnouncement', LootFrame)
ui_button:SetPoint('TOPLEFT', LootFrame, 'TOPRIGHT')
ui_button:SetText(L["Announce"])
ui_button:SetWidth(72)
ui_button:SetHeight(20)
ui_button:SetNormalFontObject('GameFontNormalSmall')
ui_button:SetScript('OnClick', function ()
	Announcement()
end)
set_textures(ui_button)

