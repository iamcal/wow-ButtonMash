
ButtonMash.Moonkin = {};
ButtonMash.RegisterClassSpec('Moonkin', 'DRUID', 1);

ButtonMash.Moonkin.SUNFIRE	= 93402;
ButtonMash.Moonkin.MOONFIRE	= 8921;
ButtonMash.Moonkin.WRATH	= 5176;
ButtonMash.Moonkin.STARFIRE	= 2912;
ButtonMash.Moonkin.STARSURGE	= 78674;
ButtonMash.Moonkin.STARFALL	= 48505;

ButtonMash.Moonkin.SUNFIRE_NAME = GetSpellInfo(ButtonMash.Moonkin.SUNFIRE);

function ButtonMash.Moonkin.CreateUI()

	local cols = 6;
	local rows = 2;

	ButtonMash.ResizeUIFrame((cols*40)+(cols-1), (rows*40)+(rows-1));
	--ButtonMash.UIFrame.texture:SetTexture(1, 0, 0);

	-- main buttons

	ButtonMash.CreateBoundButton('snf', 41*0, 0, 40, 40, ButtonMash.Moonkin.SUNFIRE);
	ButtonMash.CreateBoundButton('mnf', 41*1, 0, 40, 40, ButtonMash.Moonkin.MOONFIRE);
	ButtonMash.CreateBoundButton('wrt', 41*2, 0, 40, 40, ButtonMash.Moonkin.WRATH);
	ButtonMash.CreateBoundButton('srf', 41*3, 0, 40, 40, ButtonMash.Moonkin.STARFIRE);
	ButtonMash.CreateBoundButton('sts', 41*4, 0, 40, 40, ButtonMash.Moonkin.STARSURGE);
	ButtonMash.CreateBoundButton('stf', 41*5, 0, 40, 40, ButtonMash.Moonkin.STARFALL);

end

function ButtonMash.Moonkin.DestroyUI()

end;

function ButtonMash.Moonkin.UpdateFrame()

	-- dim everything if we don't have a target
	local alpha = 1;
	local has_viable_target = UnitCanAttack("player", "target");
	if (has_viable_target and UnitIsDeadOrGhost("target")) then
		has_viable_target = false;
	end
	if (not has_viable_target) then
		alpha = 0.2;
		--ButtonMash.Moonkin.RageLabel:SetAlpha(0.4);
	else
		--ButtonMash.Moonkin.RageLabel:SetAlpha(1);
	end

	local i;
	for i in pairs(ButtonMash.buttons) do
		ButtonMash.buttons[i]:SetAlpha(alpha);
	end


	-- range label

	ButtonMash.Label:SetText(" ");
	if (has_viable_target and (IsSpellInRange(ButtonMash.Moonkin.SUNFIRE_NAME) ~= 1)) then

		ButtonMash.Label:SetTextColor(1,0,0,1)
		ButtonMash.SetFontSize(ButtonMash.Label, 20);
		ButtonMash.Label:SetText("Too Far");
	end


	-- everything below here is only for active targets

	if (not has_viable_target) then
		return;
	end


	-- main shot state

end;
