
ButtonMash.CombatRogue = {};
ButtonMash.RegisterClassSpec('CombatRogue', 'ROGUE', 2);

ButtonMash.combat_rogue = {
	cd_buttons_max = 10,
	last_combo_guid = nil,
	last_combo_count = 0,
	bleed_mobs = {},
	bleed_debuffs = {},
};

ButtonMash.combat_rogue.bleed_debuffs["Mangle"]		= 1; -- bear/cat druid
ButtonMash.combat_rogue.bleed_debuffs["Hemorrhage"]	= 1; -- sub rogue
ButtonMash.combat_rogue.bleed_debuffs["Blood Frenzy"]	= 1; -- arms warrior
ButtonMash.combat_rogue.bleed_debuffs["Tendon Rip"]	= 1; -- hyena pet
ButtonMash.combat_rogue.bleed_debuffs["Gore"]		= 1; -- boar pet
ButtonMash.combat_rogue.bleed_debuffs["Stampede"]	= 1; -- rhino pet

function ButtonMash.CombatRogue.ModuleOnEvent(event, ...)

	if (event == 'UNIT_COMBO_POINTS') then

		ButtonMash.combat_rogue.last_combo_guid = UnitGUID('target');
		ButtonMash.combat_rogue.last_combo_count = 0;
	end
end

function ButtonMash.CombatRogue.CreateUI()

		ButtonMash.EventFrame:RegisterEvent("UNIT_COMBO_POINTS");

		local cols = 5;
		local rows = 3;

		ButtonMash.ResizeUIFrame((cols*40)+(cols-1), (rows*40)+(rows-1)+21);
		--ButtonMash.UIFrame.texture:SetTexture(1, 0, 0);

		-- main buttons
		ButtonMash.CreateButton('ss',  41*0, 0, 40, 40, [[Interface\Icons\spell_shadow_ritualofsacrifice]]);
		ButtonMash.CreateButton('snd', 41*1, 0, 40, 40, [[Interface\Icons\ability_rogue_slicedice]]);
		ButtonMash.CreateButton('rev', 41*2, 0, 40, 40, [[Interface\Icons\inv_sword_97]]);
		ButtonMash.CreateButton('rup', 41*3, 0, 40, 40, [[Interface\Icons\ability_rogue_rupture]]);
		ButtonMash.CreateButton('evi', 41*4, 0, 40, 40, [[Interface\Icons\ability_rogue_eviscerate]]);

		-- combo point boxes
		ButtonMash.PointBoxes = {};
		ButtonMash.PointBoxes[1] = ButtonMash.CombatRogue.CreateComboBox(41*0, 41, 40, 20);
		ButtonMash.PointBoxes[2] = ButtonMash.CombatRogue.CreateComboBox(41*1, 41, 40, 20);
		ButtonMash.PointBoxes[3] = ButtonMash.CombatRogue.CreateComboBox(41*2, 41, 40, 20);
		ButtonMash.PointBoxes[4] = ButtonMash.CombatRogue.CreateComboBox(41*3, 41, 40, 20);
		ButtonMash.PointBoxes[5] = ButtonMash.CombatRogue.CreateComboBox(41*4, 41, 40, 20);

		-- second row buttons
		ButtonMash.CreateButton('ar', 41*1, 62, 40, 40, [[Interface\Icons\spell_shadow_shadowworddominate]]);
		ButtonMash.CreateButton('ks', 41*2, 62, 40, 40, [[Interface\Icons\ability_rogue_murderspree]]);
		ButtonMash.CreateButton('bf', 41*3, 62, 40, 40, [[Interface\Icons\ability_warrior_punishingblow]]);

		-- cooldown buttons
		local i;
		for i=1,ButtonMash.combat_rogue.cd_buttons_max do
			ButtonMash.CreateButton('cd'..i, 0, 103, 40, 40, [[Interface\Icons\spell_shadow_shadowworddominate]]);
		end

		ButtonMash.buttons['ss'].label:SetText("2");
		ButtonMash.buttons['snd'].label:SetText("7");
		ButtonMash.buttons['rev'].label:SetText("1");
		ButtonMash.buttons['rup'].label:SetText("4");
		ButtonMash.buttons['evi'].label:SetText("3");
		ButtonMash.buttons['ar'].label:SetText("ALT-1");
		ButtonMash.buttons['ks'].label:SetText("ALT-2");
		ButtonMash.buttons['bf'].label:SetText("ALT-3");

end;

function ButtonMash.CombatRogue.CreateComboBox(x, y, w, h)

	local b = CreateFrame("Button", nil, ButtonMash.UIFrame);
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

function ButtonMash.CombatRogue.DestroyUI()

		ButtonMash.EventFrame:UnregisterEvent("UNIT_COMBO_POINTS");

		local i;
		for i in pairs(ButtonMash.PointBoxes) do

			ButtonMash.PointBoxes[i]:Hide();
			ButtonMash.PointBoxes[i]:SetParent(nil);
		end

		ButtonMash.PointBoxes = {};
end;

function ButtonMash.CombatRogue.UpdateFrame()

		-- if we're not in combat, dump our bleed list so it doesn't fill up forever
		if (not UnitAffectingCombat("player")) then
			ButtonMash.combat_rogue.bleed_mobs = {};
		end


		local status = ButtonMash.CombatRogue.GetCombatRogueShotStatus();


		-- set up buttons and boxes
		ButtonMash.SetButtonState('ss',  status.shots.ss,  "Sinister Strike");
		ButtonMash.SetButtonState('snd', status.shots.snd, "Slice and Dice");
		ButtonMash.SetButtonState('rev', status.shots.rev, "Revealing Strike");
		ButtonMash.SetButtonState('rup', status.shots.rup, "Rupture");
		ButtonMash.SetButtonState('evi', status.shots.evi, "Eviscerate");

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

		local cds = ButtonMash.GetCooldowns();

		local cd_width = (41 * cds.count) - 1;
		local cd_left = ((204 / 2) - (cd_width / 2)) + 41;

		local i;
		for i=1,ButtonMash.combat_rogue.cd_buttons_max do

			local btn = ButtonMash.buttons['cd'..i];
			if (i <= cds.count) then
				local info = cds.abilities[i];

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
end

function ButtonMash.CombatRogue.GetCombatRogueShotStatus()

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

		ButtonMash.combat_rogue.last_combo_guid = UnitGUID('target');
		ButtonMash.combat_rogue.last_combo_count = comboPoints;
	else
		if (not (UnitGUID('target') == ButtonMash.combat_rogue.last_combo_guid)) then
			out.comboPointsOld = ButtonMash.combat_rogue.last_combo_count;
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
		if (ButtonMash.combat_rogue.bleed_debuffs[name]) then
			ButtonMash.combat_rogue.bleed_mobs[target_guid] = 1;
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
		snd = ButtonMash.CombatRogue.GetSpellCost("Slice and Dice"),
		rev = ButtonMash.CombatRogue.GetSpellCost("Revealing Strike"),
		rup = ButtonMash.CombatRogue.GetSpellCost("Rupture"),
		evi = ButtonMash.CombatRogue.GetSpellCost("Eviscerate"),
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

function ButtonMash.CombatRogue.GetSpellCost(spellName)
	local name, rank, icon, cost, isFunnel, powerType, castTime, minRange, maxRange = GetSpellInfo(spellName);
	return cost;
end
