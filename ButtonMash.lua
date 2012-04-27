ButtonMash = {};
ButtonMash.fully_loaded = false;
ButtonMash.default_options = {

	-- main frame position
	frameRef = "CENTER",
	frameX = 0,
	frameY = 0,
	hide = false,
};

ButtonMash.enabled_for_class = false;
ButtonMash.current_talent_spec = 0;
ButtonMash.start_w = 204;
ButtonMash.start_h = 143;


--
-- load and save prefs
--

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


--
-- decide if we need to change modes here
--

function ButtonMash.OnUpdate()

	if (not ButtonMash.enabled_for_class) then
		return;
	end

	if (not ButtonMash.fully_loaded) then
		return;
	end


	--
	-- figure out if talent spec has changed. if so, destroy & create UI
	--

	local spec_now = ButtonMash.GetCurrentTalentSpec();
	if (spec_now ~= ButtonMash.current_talent_spec) then
		if (ButtonMash.DestroyUI) then
			ButtonMash.DestroyUI();
		end
		ButtonMash.current_talent_spec = spec_now;
		if (ButtonMash.CreateUI) then
			ButtonMash.CreateUI();
		end
	end

	if (ButtonMashPrefs.hide) then 
		return;
	end

	if (ButtonMash.UpdateFrame) then
		ButtonMash.UpdateFrame();
	end
end

function ButtonMash.GetCurrentTalentSpec()

	local i;
	for i=1,3 do

		local talentGroup = GetActiveTalentGroup(false, false);
		local _, _, _, _, combatPoints = GetTalentTabInfo(i, false, false, talentGroup);
		if (combatPoints > 11) then
			return i;
		end
	end

	return 0;
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
