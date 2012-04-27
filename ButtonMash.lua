-- only for dks
if select(2, UnitClass('player')) ~= "ROGUE" then return end

ButtonMash = {};
ButtonMash.fully_loaded = false;
ButtonMash.default_options = {

	-- main frame position
	frameRef = "CENTER",
	frameX = 0,
	frameY = 0,
	hide = false,
};

ButtonMash.start_w = 204;
ButtonMash.start_h = 143;
ButtonMash.bleed_mobs = {};
ButtonMash.misc_counter = 1;
ButtonMash.cd_buttons_max = 10;
ButtonMash.last_combo_guid = nil;
ButtonMash.last_combo_count = 0;

ButtonMash.btn_text = {
	ss = "2",
	snd = "7",
	rev = "1",
	rup = "4",
	evi = "3",
	ar = "ALT-1",
	ks = "ALT-2",
	bf = "ALT-3",
};

ButtonMash.cooldown_spells = {
	"Lifeblood",		-- herbalists
	"Rocket Barrage",	-- goblins
	"Blood Fury",		-- orcs
	"War Stomp",		-- tauren
	"Berserking",		-- trolls
};

ButtonMash.bleed_debuffs = {};
ButtonMash.bleed_debuffs["Mangle"]	= 1; -- bear/cat druid
ButtonMash.bleed_debuffs["Hemorrhage"]	= 1; -- sub rogue
ButtonMash.bleed_debuffs["Blood Frenzy"]	= 1; -- arms warrior
ButtonMash.bleed_debuffs["Tendon Rip"]	= 1; -- hyena pet
ButtonMash.bleed_debuffs["Gore"]		= 1; -- boar pet
ButtonMash.bleed_debuffs["Stampede"]	= 1; -- rhino pet

function ButtonMash.OnReady()

	-- set up default options
	_G.ButtonMashPrefs = _G.ButtonMashPrefs or {};

	local k,v;
	for k,v in pairs(ButtonMash.default_options) do
		if (not _G.ButtonMashPrefs[k]) then
			_G.ButtonMashPrefs[k] = v;
		end
	end

	ButtonMash.CreateUIFrame();
end

function ButtonMash.OnSaving()

	if (ButtonMash.UIFrame) then
		local point, relativeTo, relativePoint, xOfs, yOfs = ButtonMash.UIFrame:GetPoint()
		_G.ButtonMashPrefs.frameRef = relativePoint;
		_G.ButtonMashPrefs.frameX = xOfs;
		_G.ButtonMashPrefs.frameY = yOfs;
	end
end

function ButtonMash.OnUpdate()
	if (not ButtonMash.fully_loaded) then
		return;
	end

	-- hide if we're not a combat rogue
	local talentGroup = GetActiveTalentGroup(false, false);
	local _, _, _, _, combatPoints = GetTalentTabInfo(2, false, false, talentGroup);
	if (combatPoints <= 11) then
		ButtonMash.UIFrame:hide();
		return;
	end

	if (ButtonMashPrefs.hide) then 
		return;
	end

	ButtonMash.UpdateFrame();
end

function ButtonMash.OnEvent(frame, event, ...)

	if (event == 'ADDON_LOADED') then
		local name = ...;
		if name == 'ButtonMash' then
			ButtonMash.OnReady();
		end
		return;
	end

	if (event == 'PLAYER_LOGIN') then

		ButtonMash.fully_loaded = true;
		return;
	end

	if (event == 'PLAYER_LOGOUT') then
		ButtonMash.OnSaving();
		return;
	end

	if (event == 'UNIT_COMBO_POINTS') then

		ButtonMash.last_combo_guid = UnitGUID('target');
		ButtonMash.last_combo_count = 0;
	end
end

function ButtonMash.CreateUIFrame()

	-- create the UI frame
	ButtonMash.UIFrame = CreateFrame("Frame",nil,UIParent);
	ButtonMash.UIFrame:SetFrameStrata("BACKGROUND")
	ButtonMash.UIFrame:SetWidth(ButtonMash.start_w);
	ButtonMash.UIFrame:SetHeight(ButtonMash.start_h);

	-- make it black
	--ButtonMash.UIFrame.texture = ButtonMash.UIFrame:CreateTexture();
	--ButtonMash.UIFrame.texture:SetAllPoints(ButtonMash.UIFrame);
	--ButtonMash.UIFrame.texture:SetTexture(0, 0, 0);

	-- position it
	ButtonMash.UIFrame:SetPoint(_G.ButtonMashPrefs.frameRef, _G.ButtonMashPrefs.frameX, _G.ButtonMashPrefs.frameY);

	-- make it draggable
	ButtonMash.UIFrame:SetMovable(true);
	ButtonMash.UIFrame:EnableMouse(true);

	-- create a button that covers the entire addon
	ButtonMash.Cover = CreateFrame("Button", nil, ButtonMash.UIFrame);
	ButtonMash.Cover:SetFrameLevel(128);
	ButtonMash.Cover:SetPoint("TOPLEFT", 0, 0);
	ButtonMash.Cover:SetWidth(ButtonMash.start_w);
	ButtonMash.Cover:SetHeight(ButtonMash.start_h);
	ButtonMash.Cover:EnableMouse(true);
	ButtonMash.Cover:RegisterForClicks("AnyUp");
	ButtonMash.Cover:RegisterForDrag("LeftButton");
	ButtonMash.Cover:SetScript("OnDragStart", ButtonMash.OnDragStart);
	ButtonMash.Cover:SetScript("OnDragStop", ButtonMash.OnDragStop);
	ButtonMash.Cover:SetScript("OnClick", ButtonMash.OnClick);

	-- add a main label - just so we can show something
	ButtonMash.Label = ButtonMash.Cover:CreateFontString(nil, "OVERLAY");
	ButtonMash.Label:SetPoint("CENTER", ButtonMash.UIFrame, "CENTER", 2, 0);
	ButtonMash.Label:SetJustifyH("LEFT");
	ButtonMash.Label:SetFont([[Fonts\FRIZQT__.TTF]], 12, "OUTLINE");
	ButtonMash.Label:SetText(" ");
	ButtonMash.Label:SetTextColor(1,1,1,1);
	ButtonMash.SetFontSize(ButtonMash.Label, 10);

	ButtonMash.buttons = {};

	ButtonMash.buttons.ss  = ButtonMash.CreateButton(ButtonMash.UIFrame, 41*0, 0, 40, 40, [[Interface\Icons\spell_shadow_ritualofsacrifice]]);
	ButtonMash.buttons.snd = ButtonMash.CreateButton(ButtonMash.UIFrame, 41*1, 0, 40, 40, [[Interface\Icons\ability_rogue_slicedice]]);
	ButtonMash.buttons.rev = ButtonMash.CreateButton(ButtonMash.UIFrame, 41*2, 0, 40, 40, [[Interface\Icons\inv_sword_97]]);
	ButtonMash.buttons.rup = ButtonMash.CreateButton(ButtonMash.UIFrame, 41*3, 0, 40, 40, [[Interface\Icons\ability_rogue_rupture]]);
	ButtonMash.buttons.evi = ButtonMash.CreateButton(ButtonMash.UIFrame, 41*4, 0, 40, 40, [[Interface\Icons\ability_rogue_eviscerate]]);

	ButtonMash.buttons.ar  = ButtonMash.CreateButton(ButtonMash.UIFrame, 41*1, 62, 40, 40, [[Interface\Icons\spell_shadow_shadowworddominate]]);
	ButtonMash.buttons.ks  = ButtonMash.CreateButton(ButtonMash.UIFrame, 41*2, 62, 40, 40, [[Interface\Icons\ability_rogue_murderspree]]);
	ButtonMash.buttons.bf  = ButtonMash.CreateButton(ButtonMash.UIFrame, 41*3, 62, 40, 40, [[Interface\Icons\ability_warrior_punishingblow]]);

	local k, btn;
	for k,btn in pairs(ButtonMash.buttons) do
		btn.label:SetText(ButtonMash.btn_text[k]);
	end

	ButtonMash.PointBoxes = {};
	ButtonMash.PointBoxes[1] = ButtonMash.CreateComboBox(ButtonMash.UIFrame, 41*0, 41, 40, 20);
	ButtonMash.PointBoxes[2] = ButtonMash.CreateComboBox(ButtonMash.UIFrame, 41*1, 41, 40, 20);
	ButtonMash.PointBoxes[3] = ButtonMash.CreateComboBox(ButtonMash.UIFrame, 41*2, 41, 40, 20);
	ButtonMash.PointBoxes[4] = ButtonMash.CreateComboBox(ButtonMash.UIFrame, 41*3, 41, 40, 20);
	ButtonMash.PointBoxes[5] = ButtonMash.CreateComboBox(ButtonMash.UIFrame, 41*4, 41, 40, 20);

	ButtonMash.cd_buttons = {};
	local i;
	for i=1,ButtonMash.cd_buttons_max do
		ButtonMash.cd_buttons[i] = ButtonMash.CreateButton(ButtonMash.UIFrame, 0, 103, 40, 40, [[Interface\Icons\spell_shadow_shadowworddominate]]);
	end

end

function ButtonMash.CreateButton(parent, x, y, w, h, texture)

	ButtonMash.misc_counter = ButtonMash.misc_counter + 1;
	local name = "ButtonMashBtn"..ButtonMash.misc_counter;

	-- the actual button
	local b = CreateFrame("Button", name, parent);
	b:SetPoint("TOPLEFT", x, 0-y)
	b:SetWidth(w)
	b:SetHeight(h)
	b:SetNormalTexture(texture);

	function b:SetStateColor(col)
		local tex = self:GetNormalTexture();
		if (col == 'blue') then
			tex:SetVertexColor(0.5, 0.5, 1.0);
		elseif (col == 'off') then
			tex:SetVertexColor(0.3, 0.3, 0.3);
		else
			tex:SetVertexColor(1.0, 1.0, 1.0);
		end
	end

	function b:SetSpellState(spellName)
		self:SetCooldown(true, spellName);
		local isUsable, notEnoughMana = IsUsableSpell(spellName);
		if (isUsable) then
			self:SetStateColor('normal');
		elseif (notEnoughMana) then
			self:SetStateColor('blue');
		else
			self:SetStateColor('off');
		end
	end


	-- the text label - use to show key binds
	b.label = b:CreateFontString(nil, "OVERLAY");
	b.label:Show()
	b.label:ClearAllPoints()
	b.label:SetTextColor(1, 1, 1, 1);
	b.label:SetFont([[Fonts\FRIZQT__.TTF]], 12, "OUTLINE");
	b.label:SetPoint("CENTER", b, "CENTER", 0, 0);
	b.label:SetText(" ");


	-- the cooldown timer
	b.cooldown = CreateFrame("Cooldown", name.."_cooldown", b, "CooldownFrameTemplate");
	b.cooldown:SetAllPoints(b);
	b.cooldown:Hide();
	b.cd_start = 0;
	b.cd_duration = 0;

	function b:SetCooldown(enable, spellName)

		if (not enable) then
			return self:SetCooldownManual(false);
		end

		local start, duration, enabledToo = GetSpellCooldown(spellName);

		self:SetCooldownManual(enabledToo, start, duration);
	end

	function b:SetCooldownManual(enable, start, duration)

		if (not enable) then
			self.cooldown:Hide();
			self.cd_start = 0;
			self.cd_duration = 0;
			return;
		end

		if (start == self.cd_start and duration == self.cd_duration) then
			return;
		end

		self.cooldown:SetCooldown(start, duration);
		self.cooldown:Show();
		self.cd_start = start;
		self.cd_duration = duration;
	end


	-- the glow overlay - used to show next shot
	b.glow = CreateFrame("Frame", name.."_glow", UIParent, "ActionBarButtonSpellActivationAlert");
	b.glow:SetParent(b);
	b.glow:ClearAllPoints();
	b.glow:SetPoint("TOPLEFT", b, "TOPLEFT", -w * 0.2, h * 0.2);
	b.glow:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", w * 0.2, -h*0.2);
	b.glow:Hide();
	b.is_glowing = false;

	function b:SetGlow(is_glowing)
		if (is_glowing) then
			if (not self.is_glowing) then
				self.glow.animOut:Stop();
				self.glow.animIn:Play();
				self.is_glowing = true;
			end
			self.glow:Show();
		else
			if (self.is_glowing) then
				self.glow.animIn:Stop();
				self.glow.animOut:Play();
				self.is_glowing = false;
			end
		end
	end



	return b;
end

function ButtonMash.CreateComboBox(parent, x, y, w, h)

	local b = CreateFrame("Button", nil, parent);
	b:SetPoint("TOPLEFT", x, 0-y);
	b:SetWidth(w);
	b:SetHeight(h);

	b:SetBackdrop({
		bgFile		= "Interface/TargetingFrame/UI-StatusBar", --""Interface/Tooltips/UI-Tooltip-Background",
		edgeFile	= "Interface/Tooltips/UI-Tooltip-Border",
		tile		= false,
		tileSize	= 16,
		edgeSize	= 8,
		insets		= {
			left	= 3,
			right	= 3,
			top	= 3,
			bottom	= 3,
		},
	});

	function b:SetState(is_on, is_old)

		if ((self.is_on == is_on) and (self.is_old == is_old)) then
			return;
		end

		self.is_on = is_on;
		self.is_old = is_old;

		if (is_on) then
			if (is_old) then
				self:SetBackdropColor(1,1,0);
			else
				self:SetBackdropColor(0,1,0);
			end
			self:SetBackdropBorderColor(1,1,1);
		else
			self:SetBackdropColor(0,0,0,0.2);
			self:SetBackdropBorderColor(1,1,1,0.2);
		end
	end

	b.is_on = true;
	b.is_old = true;
	b:SetState(false, false);

	return b;
end

function ButtonMash.SetFontSize(string, size)

	local Font, Height, Flags = string:GetFont()
	if (not (Height == size)) then
		string:SetFont(Font, size, Flags)
	end
end

function ButtonMash.OnDragStart(frame)
	ButtonMash.UIFrame:StartMoving();
	ButtonMash.UIFrame.isMoving = true;
	GameTooltip:Hide()
end

function ButtonMash.OnDragStop(frame)
	ButtonMash.UIFrame:StopMovingOrSizing();
	ButtonMash.UIFrame.isMoving = false;
end

function ButtonMash.OnClick(self, aButton)
	if (aButton == "RightButton") then
		print("show menu here!");
	end
end

function ButtonMash.UpdateFrame()

	-- if we're not in combat, dump our bleed list so it doesn't fill up forever
	if (not UnitAffectingCombat("player")) then
		ButtonMash.bleed_mobs = {};
	end

	local status = ButtonMash.GetShotStatus();


	-- set up buttons and boxes

	ButtonMash.SetButtonState(ButtonMash.buttons.ss,  status.shots.ss,  "Sinister Strike");
	ButtonMash.SetButtonState(ButtonMash.buttons.snd, status.shots.snd, "Slice and Dice");
	ButtonMash.SetButtonState(ButtonMash.buttons.rev, status.shots.rev, "Revealing Strike");
	ButtonMash.SetButtonState(ButtonMash.buttons.rup, status.shots.rup, "Rupture");
	ButtonMash.SetButtonState(ButtonMash.buttons.evi, status.shots.evi, "Eviscerate");

	if (status.comboPoints > 0 or status.comboPointsOld == 0) then
		ButtonMash.PointBoxes[1]:SetState(status.comboPoints >= 1, false);
		ButtonMash.PointBoxes[2]:SetState(status.comboPoints >= 2, false);
		ButtonMash.PointBoxes[3]:SetState(status.comboPoints >= 3, false);
		ButtonMash.PointBoxes[4]:SetState(status.comboPoints >= 4, false);
		ButtonMash.PointBoxes[5]:SetState(status.comboPoints >= 5, false);
	else
		ButtonMash.PointBoxes[1]:SetState(status.comboPointsOld >= 1, true);
		ButtonMash.PointBoxes[2]:SetState(status.comboPointsOld >= 2, true);
		ButtonMash.PointBoxes[3]:SetState(status.comboPointsOld >= 3, true);
		ButtonMash.PointBoxes[4]:SetState(status.comboPointsOld >= 4, true);
		ButtonMash.PointBoxes[5]:SetState(status.comboPointsOld >= 5, true);
	end


	-- blade flurry

	local btn = ButtonMash.buttons.bf;
	if (status.bladeFlurry) then
		btn:SetStateColor('normal');
		btn:SetAlpha(1);
		btn:SetGlow(true);
	else
		btn:SetStateColor('off');
		btn:SetAlpha(1);
		btn:SetGlow(false);
	end
	btn:SetCooldown(true, "Blade Flurry");


	-- adrenaline rush

	local btn = ButtonMash.buttons.ar;
	if (status.ksActive) then
		btn:SetAlpha(0.2);
		btn:SetGlow(false);
		btn:SetSpellState("Adrenaline Rush");
	else
		btn:SetAlpha(1);
		if (status.arActive) then
			btn:SetGlow(true);
			btn:SetCooldownManual(true, status.arStart, status.arDuration);
		else
			btn:SetGlow(false);
			btn:SetSpellState("Adrenaline Rush");
		end
	end


	-- killing spree

	local btn = ButtonMash.buttons.ks;
	if (status.arActive or status.energy > 40) then
		btn:SetAlpha(0.2);
		btn:SetGlow(false);
		btn:SetSpellState("Killing Spree");
	else
		btn:SetAlpha(1);
		if (status.ksActive) then
			btn:SetGlow(true);
			btn:SetCooldownManual(true, status.ksStart, status.ksDuration);
		else
			btn:SetGlow(false);
			btn:SetSpellState("Killing Spree");
		end
	end


	-- trinkets & other cooldowns

	local cooldowns = {};	
	local cooldowns_count = 0;

	local t1_item = GetInventoryItemID("player", 13);
	local t2_item = GetInventoryItemID("player", 14);
	local t1_spell = nil;
	local t2_spell = nil;
	if (t1_item) then t1_spell = GetItemSpell(t1_item); end
	if (t2_item) then t2_spell = GetItemSpell(t2_item); end

	if (t1_spell) then
		table.insert(cooldowns, {
			type = "item",
			id = t1_item,
		});
		cooldowns_count = cooldowns_count + 1;
	end
	if (t2_spell) then
		table.insert(cooldowns, {
			type = "item",
			id = t2_item,
		});
		cooldowns_count = cooldowns_count + 1;
	end

	local k,v
	for k,v in pairs(ButtonMash.cooldown_spells) do
		local count = GetSpellCount(v);
		if (count) then
			table.insert(cooldowns, {
				type = "spell",
				id = v,
			});
			cooldowns_count = cooldowns_count + 1;
		end
	end

	local cd_width = (41 * cooldowns_count) - 1;
	local cd_left = (102 - (cd_width / 2)) - 41;

	local i;
	for i=1,ButtonMash.cd_buttons_max do
		local btn = ButtonMash.cd_buttons[i];
		if (i <= cooldowns_count) then
			local info = cooldowns[i];

			local texture, start, duration, enable;

			if (info.type == 'item') then
				_, _, _, _, _, _, _, _, _, texture, _ = GetItemInfo(info.id);
				start, duration, enable = GetItemCooldown(info.id);
			else
				texture = GetSpellTexture(info.id);
				start, duration, enable = GetSpellCooldown(info.id);
			end

			btn:SetPoint("TOPLEFT", cd_left + (i * 41), 0-103);
			btn:Show();
			btn:SetNormalTexture(texture);
			btn:SetCooldownManual(enable, start, duration);
		else
			btn:Hide();
		end
	end

	ButtonMash.Label:SetText(" ");
end

function ButtonMash.SetButtonState(btn, state, spellName)

	-- energy state overlay
	local isUsable, notEnoughMana = IsUsableSpell(spellName);
	if (isUsable) then
		btn:SetStateColor('normal');
	elseif (notEnoughMana) then
		btn:SetStateColor('blue');
	else
		btn:SetStateColor('normal');
	end

	-- glow & cooldown
	if (state == "now") then
		btn:SetGlow(true);
		btn:SetCooldown(true, spellName);		
	else
		btn:SetGlow(false);
		btn:SetCooldown(false);
	end

	-- transparency
	if (state == "off") then
		btn:SetAlpha(0.2);
	else
		btn:SetAlpha(1);
	end

end

function ButtonMash.GetShotStatus()

	local out = {};

	out.label = "";
	out.comboPoints = 0;
	out.bladeFlurry = false;
	out.arActive = false;
	out.ksActive = false;
	out.energy = UnitPower("player");
	out.shots = {
		ss = "off",
		snd = "off",
		rev = "off",
		rup = "off",
		evi = "off",
	};


	-- combo points!

	local comboPoints = GetComboPoints('player', 'target');
	out.comboPoints = comboPoints;
	out.comboPointsOld = 0;

	if (comboPoints > 0) then

		ButtonMash.last_combo_guid = UnitGUID('target');
		ButtonMash.last_combo_count = comboPoints;
	else
		if (not (UnitGUID('target') == ButtonMash.last_combo_guid)) then
			out.comboPointsOld = ButtonMash.last_combo_count;
		end
	end


	-- test auras first
	local test = UnitAura("Player", "Blade Flurry");
	if (test) then
		out.bladeFlurry = true;
	end

	local test,_,_,_,_,duration,expires = UnitAura("Player", "Adrenaline Rush");
	if (test) then
		out.arActive= true;
		out.arStart = expires - duration;
		out.arDuration = duration;
	end

	local test,_,_,_,_,duration,expires = UnitAura("Player", "Killing Spree");
	if (test) then
		out.ksActive= true;
		out.ksStart = expires - duration;
		out.ksDuration = duration;
	end


	-- can we attack anything?
	local can_attack = UnitCanAttack("player", "target");
	if (can_attack and UnitIsDeadOrGhost("target")) then
		can_attack = false;
	end
	if (not can_attack) then
		return out;	
	end

	--are we within range of target?
	local in_range = IsSpellInRange("Sinister Strike");
	if (in_range == 0) then
		out.label = "Too Far";
		out.label_mode = "Warning";
		return out;	
	end


	-- figure out current target debuffs.
	-- we need to check if this target has ever had a bleed on it.

	local ruptureUp = false;
	local ruptureRemain = 0;

	local target_guid = UnitGUID("target");

	local index = 1
	while UnitDebuff("target", index) do
		local name, _, _, count, _, _, buffExpires, caster = UnitDebuff("target", index);
		if (ButtonMash.bleed_debuffs[name]) then
			ButtonMash.bleed_mobs[target_guid] = 1;
		end
		if ((name == "Rupture") and (caster == "player")) then
			ruptureUp = true;
			ruptureRemain = buffExpires - GetTime();
		end
		index = index + 1
	end


	-- check our own buffs

	local hasSnD = false;
	local remainSnD = 0;

	local index = 1;
	while UnitBuff("player", index) do
		local name, _, _, count, _, _, buffExpires, caster = UnitBuff("player", index)
		if (name == "Slice and Dice") then
			hasSnD = true;
			remainSnD = buffExpires - GetTime();
		end
		index = index + 1
	end



	-- energy stuff

	local costs = {
		snd = ButtonMash.GetSpellCost("Slice and Dice"),
		rev = ButtonMash.GetSpellCost("Revealing Strike"),
		rup = ButtonMash.GetSpellCost("Rupture"),
		evi = ButtonMash.GetSpellCost("Eviscerate"),
	};


	-- should we use Rupture?
	-- not if we have blade flurry up!

	local useRupture = true;

	if (out.bladeFlurry) then
		useRupture = false;
	end


	-- main priority list
	-- if slice and dice is down, use with any combo points (1+)
	-- if slice and dice will fall off within X seconds, use 4-5 combo points on it
	-- if we have *exactly* 4 combo points, use revealing strike
	-- if target has bleed debuff
		-- if rupture will fall off within 2 seconds, wait
		-- if rupture is not active, 5 combo rupture
	-- 5 combo eviscerate
	-- sinister strike


	if (not hasSnD) then

		if (comboPoints > 0) then
			if (out.energy < costs.snd) then
				out.shots.snd = "next";
			else
				out.shots.snd = "now";
			end
		else
			out.shots.snd = "next";
			out.shots.ss = "now";
		end
		return out;
	end

	if (remainSnD < 5) then
		if (comboPoints > 3) then
			if (out.energy < costs.snd) then
				out.shots.snd = "next";
			else
				out.shots.snd = "now";
			end
		else
			out.shots.snd = "next";
			out.shots.ss = "now";
		end
		return out;
	end

	if (comboPoints == 4) then
		if (out.energy < costs.rev) then
			out.shots.rev = "next";
		else
			out.shots.rev = "now";
		end
		return out;
	end

	if (useRupture) then

		if (ruptureUp and (ruptureRemain < 2)) then
			out.shots.rup = "next";
			return out;
		end

		if (not ruptureUp) then
			if (comboPoints == 5) then
				if (out.energy < costs.rup) then
					out.shots.rup = "next";
				else
					out.shots.rup = "now";
				end
			else
				out.shots.rup = "next";
				out.shots.ss = "now";
			end
			return out;
		end
	end

	if (comboPoints == 5) then
		if (out.energy < costs.evi) then
			out.shots.evi = "next";
		else
			out.shots.evi = "now";
		end
	else
		out.shots.evi = "next";
		out.shots.ss = "now";
	end

	return out;
end

function ButtonMash.GetSpellCost(spellName)
	local name, rank, icon, cost, isFunnel, powerType, castTime, minRange, maxRange = GetSpellInfo(spellName);
	return cost;
end


ButtonMash.EventFrame = CreateFrame("Frame");
ButtonMash.EventFrame:Show();
ButtonMash.EventFrame:SetScript("OnEvent", ButtonMash.OnEvent);
ButtonMash.EventFrame:SetScript("OnUpdate", ButtonMash.OnUpdate);
ButtonMash.EventFrame:RegisterEvent("ADDON_LOADED");
ButtonMash.EventFrame:RegisterEvent("PLAYER_LOGIN");
ButtonMash.EventFrame:RegisterEvent("PLAYER_LOGOUT");
ButtonMash.EventFrame:RegisterEvent("UNIT_COMBO_POINTS");
