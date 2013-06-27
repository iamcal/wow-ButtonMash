
ButtonMash.BearTank = {};
ButtonMash.RegisterClassSpec('BearTank', 'DRUID', 3);

function ButtonMash.BearTank.CreateUI()

	local cols = 5;
	local rows = 1;

	ButtonMash.ResizeUIFrame((cols*40)+(cols-1), (rows*40)+(rows-1));
	--ButtonMash.UIFrame.texture:SetTexture(1, 0, 0);

	-- main buttons
	ButtonMash.CreateBoundButton('man', 41*0, 0, 40, 40, "Mangle");
	ButtonMash.CreateBoundButton('trs', 41*1, 0, 40, 40, "Thrash");
	ButtonMash.CreateBoundButton('lac', 41*2, 0, 40, 40, "Lacerate");
	ButtonMash.CreateBoundButton('mul', 41*3, 0, 40, 40, "Maul");
	ButtonMash.CreateBoundButton('frf', 41*4, 0, 40, 40, "Faerie Fire");
end

function ButtonMash.BearTank.DestroyUI()

	ButtonMash.DestroyButtons();
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
	end

	local i;
	for i in pairs(ButtonMash.buttons) do
		ButtonMash.buttons[i]:SetAlpha(alpha);
	end


	-- range label

	ButtonMash.Label:SetText(" ");
	if (has_viable_target and (IsSpellInRange("Mangle") ~= 1)) then

		ButtonMash.Label:SetTextColor(1,0,0,1)
		ButtonMash.SetFontSize(ButtonMash.Label, 20);
		ButtonMash.Label:SetText("Too Far");
	end


	-- set spell timers etc
	ButtonMash.UpdateBoundButtons();


	-- everything below here is only for active targets

	if (not has_viable_target) then
		return;
	end


end;
