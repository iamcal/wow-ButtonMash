
ButtonMash.RetPaly = {};
ButtonMash.RegisterClassSpec('RetPaly', 'PALADIN', 3);

ButtonMash.RetPaly.HAMMER_WRATH	= 24275;
ButtonMash.RetPaly.EXORCISM	= 879;
ButtonMash.RetPaly.CRUSADER	= 35395;
ButtonMash.RetPaly.JUDGEMENT	= 20271;
ButtonMash.RetPaly.INQUISITION	= 84963;
ButtonMash.RetPaly.TEMPLARS	= 85256;

ButtonMash.RetPaly.AVENGING_BUFF	= 31884;

ButtonMash.RetPaly.CRUSADER_NAME = GetSpellInfo(ButtonMash.RetPaly.CRUSADER);

function ButtonMash.RetPaly.CreateUI()

	local cols = 4;
	local rows = 2;

	ButtonMash.ResizeUIFrame((cols*40)+(cols-1), (rows*40)+(rows-1));
	--ButtonMash.UIFrame.texture:SetTexture(1, 0, 0);

	-- main buttons

	ButtonMash.CreateBoundButton('hammer'   , 41*0, 0, 40, 40, ButtonMash.RetPaly.HAMMER_WRATH);
	ButtonMash.CreateBoundButton('exorcism' , 41*1, 0, 40, 40, ButtonMash.RetPaly.EXORCISM);
	ButtonMash.CreateBoundButton('crusader' , 41*2, 0, 40, 40, ButtonMash.RetPaly.CRUSADER);
	ButtonMash.CreateBoundButton('judgement', 41*3, 0, 40, 40, ButtonMash.RetPaly.JUDGEMENT);

	ButtonMash.CreateBoundButton('inquisition', 41*0, 41, 40, 40, ButtonMash.RetPaly.INQUISITION);
	ButtonMash.CreateBoundButton('templars'   , 41*1, 41, 40, 40, ButtonMash.RetPaly.TEMPLARS);

end

function ButtonMash.RetPaly.RetPalyyUI()

end;

function ButtonMash.RetPaly.UpdateFrame()

	-- dim everything if we don't have a target
	local alpha = 1;
	local has_viable_target = UnitCanAttack("player", "target");
	if (has_viable_target and UnitIsDeadOrGhost("target")) then
		has_viable_target = false;
	end
	if (not has_viable_target) then
		alpha = 0.2;
	end

	local i;
	for i in pairs(ButtonMash.buttons) do
		ButtonMash.buttons[i]:SetAlpha(alpha);
	end


	-- range label

	ButtonMash.Label:SetText(" ");
	if (has_viable_target and (IsSpellInRange(ButtonMash.RetPaly.CRUSADER_NAME) ~= 1)) then

		ButtonMash.Label:SetTextColor(1,0,0,1)
		ButtonMash.SetFontSize(ButtonMash.Label, 20);
		ButtonMash.Label:SetText("Too Far");
	end


	-- main shot state
	local state = ButtonMash.RetPaly.GetState();

	for i in pairs(ButtonMash.buttons) do
		if (has_viable_target) then
			if (state.next == i) then
				ButtonMash.buttons[i]:SetGlow(true);
			else
				ButtonMash.buttons[i]:SetGlow(false);
			end
		else
			ButtonMash.buttons[i]:SetGlow(false);
		end
	end

end;

function ButtonMash.RetPaly.GetState()

	local out = {
		next = '',
		holypower = 0,
		inquisition_remain = 0,
		has_avenging = false,
		below_20 = false,
	};


	--
	-- various state things
	--

	out.holypower = UnitPower("player", 9);


	--
	-- buffs & debuffs
	--

	local self_buffs = ButtonMash.Auras("player", "PLAYER HELPFUL");

	if (self_buffs[ButtonMash.RetPaly.INQUISITION]) then

		out.inquisition_remain = self_buffs[ButtonMash.RetPaly.INQUISITION];
	end

	if (self_buffs[ButtonMash.RetPaly.AVENGING_BUFF]) then

		out.has_avenging = true;
	end

	--
	-- regular rotation
	--

	if (out.inquisition_remain <= 1.0 and out.holypower > 0) then

		out.next = 'inquisition';

	elseif (out.holypower == 5) then

		out.next = 'templars';

	elseif (IsUsableSpell(ButtonMash.RetPaly.HAMMER_WRATH) and ButtonMash.CanCast(ButtonMash.RetPaly.HAMMER_WRATH, 0.5)) then

		out.next = 'hammer';

	elseif (ButtonMash.CanCast(ButtonMash.RetPaly.EXORCISM, 0.5)) then

		out.next = 'exorcism';

	elseif (ButtonMash.CanCast(ButtonMash.RetPaly.CRUSADER, 0.5)) then

		out.next = 'crusader';

	elseif (ButtonMash.CanCast(ButtonMash.RetPaly.JUDGEMENT, 0.5)) then

		out.next = 'judgement';

	elseif (out.holypower >= 3) then

		out.next = 'templars';
	end

	return out;
end;

