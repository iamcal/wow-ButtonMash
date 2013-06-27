
ButtonMash.BearTank = {};
ButtonMash.RegisterClassSpec('BearTank', 'DRUID', 3);

function ButtonMash.BearTank.CreateUI()

	local cols = 5;
	local rows = 2;

	ButtonMash.ResizeUIFrame((cols*40)+(cols-1), (rows*40)+(rows-1));
	--ButtonMash.UIFrame.texture:SetTexture(1, 0, 0);

	-- main buttons

	ButtonMash.CreateBoundButton('frn', 41*1, 0, 40, 40, "Frenzied Regeneration");
	ButtonMash.CreateBoundButton('sav', 41*3, 0, 40, 40, "Savage Defense");

	ButtonMash.CreateBoundButton('man', 41*0, 41, 40, 40, "Mangle");
	ButtonMash.CreateBoundButton('trs', 41*1, 41, 40, 40, "Thrash");
	ButtonMash.CreateBoundButton('lac', 41*2, 41, 40, 40, "Lacerate");
	ButtonMash.CreateBoundButton('mul', 41*3, 41, 40, 40, "Maul");
	ButtonMash.CreateBoundButton('frf', 41*4, 41, 40, 40, "Faerie Fire");


	ButtonMash.BearTank.RageLabel = ButtonMash.Cover:CreateFontString(nil, "OVERLAY");
	ButtonMash.BearTank.RageLabel:SetPoint("CENTER", ButtonMash.UIFrame, "TOPLEFT", (41*2)+20, -20);
	ButtonMash.BearTank.RageLabel:SetFont([[Fonts\FRIZQT__.TTF]], 12, "OUTLINE");
	ButtonMash.BearTank.RageLabel:SetText("100");
	ButtonMash.BearTank.RageLabel:SetTextColor(0,1,0,1);
	ButtonMash.SetFontSize(ButtonMash.BearTank.RageLabel, 22);

end

function ButtonMash.BearTank.DestroyUI()

end;

function ButtonMash.BearTank.UpdateFrame()

	-- dim everything if we don't have a target
	local alpha = 1;
	local has_viable_target = UnitCanAttack("player", "target");
	if (has_viable_target and UnitIsDeadOrGhost("target")) then
		has_viable_target = false;
	end
	if (not has_viable_target) then
		alpha = 0.2;
		ButtonMash.BearTank.RageLabel:SetAlpha(0.4);
	else
		ButtonMash.BearTank.RageLabel:SetAlpha(1);
	end

	local i;
	for i in pairs(ButtonMash.buttons) do
		ButtonMash.buttons[i]:SetAlpha(alpha);
	end

	ButtonMash.BearTank.RageLabel:SetText(UnitPower("player", "RAGE"));


	-- range label

	ButtonMash.Label:SetText(" ");
	if (has_viable_target and (IsSpellInRange("Mangle") ~= 1)) then

		ButtonMash.Label:SetTextColor(1,0,0,1)
		ButtonMash.SetFontSize(ButtonMash.Label, 20);
		ButtonMash.Label:SetText("Too Far");
	end


	-- everything below here is only for active targets

	if (not has_viable_target) then
		return;
	end


	-- main shot state + maul proc

	local state = ButtonMash.BearTank.GetState();

	ButtonMash.buttons.mul:SetGlow(state.maul);

	ButtonMash.buttons.man:SetGlow(state.next == 'Mangle');
	ButtonMash.buttons.trs:SetGlow(state.next == 'Thrash');
	ButtonMash.buttons.lac:SetGlow(state.next == 'Lacerate');
	ButtonMash.buttons.frf:SetGlow(state.next == 'Faerie Fire');


end;

function ButtonMash.BearTank.GetState()

	local out = {
		next = '',
		maul = false,
		mangle = 0,
		thrash = 0,
		lacerate = 0,
		ffire = 0,
	};


	--
	-- if tooth and claw is up, and maul is off cooldown...
	--

	local test = UnitAura("Player", "Tooth and Claw");
	if (test) then
		local start, duration = GetSpellCooldown("Maul");
		if (start == 0) then
			out.maul = true;
		end
	end


	--
	-- get target debuffs
	--

	local debuffs = {};
	local index = 1
	while UnitDebuff("target", index) do
		local name, _, _, count, _, _, buffExpires, caster = UnitDebuff("target", index);
		debuffs[name] = buffExpires - GetTime();
		index = index + 1
	end


	--
	-- main shot priority
	-- find out time until a shot can be done, then we'll decide what's
	-- coming next.
	--

	out.mangle = ButtonMash.BearTank.TimeUntil("Mangle");
	out.thrash = ButtonMash.BearTank.TimeUntil("Thrash");
	out.lacerate = ButtonMash.BearTank.TimeUntil("Lacerate");
	out.ffire = ButtonMash.BearTank.TimeUntil("Faerie Fire");

	local time_until_wb_off = 0;
	local time_until_th_off = 0;
	if (debuffs['Weakened Blows']) then
		time_until_wb_off = debuffs['Weakened Blows'];
	end
	if (debuffs['Thrash']) then
		time_until_th_off = debuffs['Thrash'];
	end
	local soonest_refresh_needed = time_until_th_off;
	if (time_until_wb_off < time_until_th_off) then
		soonest_refresh_needed = time_until_wb_off;
	end
	if (soonest_refresh_needed > out.thrash) then
		out.thrash = soonest_refresh_needed;
	end

	if (debuffs['Weakened Armor']) then
		if (debuffs['Weakened Armor'] > out.ffire) then
			out.ffire = debuffs['Weakened Armor'];
		end
	end


	-- in decreasing order, if we need it now
	if (out.ffire < 1) then out.next = 'Faerie Fire'; end
	if (out.lacerate < 1) then out.next = 'Lacerate'; end
	if (out.thrash < 1) then out.next = 'Thrash'; end
	if (out.mangle < 1) then out.next = 'Mangle'; end
	


	return out;
end;

function ButtonMash.BearTank.TimeUntil(spell)

	local start, duration, enabled = GetSpellCooldown(spell);
	if (start>0 and duration>0) then
		return start + duration - GetTime();
	end
	return 0;
end
