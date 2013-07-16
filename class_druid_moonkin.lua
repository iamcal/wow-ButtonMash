
ButtonMash.Moonkin = {};
ButtonMash.RegisterClassSpec('Moonkin', 'DRUID', 1);

ButtonMash.Moonkin.SUNFIRE		= 93402;
ButtonMash.Moonkin.MOONFIRE		= 8921;
ButtonMash.Moonkin.WRATH		= 5176;
ButtonMash.Moonkin.STARFIRE		= 2912;
ButtonMash.Moonkin.STARSURGE		= 78674;
ButtonMash.Moonkin.STARFALL		= 48505;

ButtonMash.Moonkin.FORCE_OF_NATURE	= 106737;
ButtonMash.Moonkin.CELESTIAL_ALIGNMENT	= 112071;
ButtonMash.Moonkin.INNERVATE		= 29166;
ButtonMash.Moonkin.MIRROR_IMAGE		= 110621;

ButtonMash.Moonkin.ECLIPSE_LUNAR	= 48518;
ButtonMash.Moonkin.ECLIPSE_SOLAR	= 48517;

ButtonMash.Moonkin.SUNFIRE_NAME = GetSpellInfo(ButtonMash.Moonkin.SUNFIRE);

function ButtonMash.Moonkin.CreateUI()

	local cols = 6;
	local rows = 2;

	ButtonMash.ResizeUIFrame((cols*40)+(cols-1), (rows*40)+(rows-1));
	--ButtonMash.UIFrame.texture:SetTexture(1, 0, 0);

	-- main buttons

	ButtonMash.CreateBoundButton('sunfire'  , 41*0, 0, 40, 40, ButtonMash.Moonkin.SUNFIRE);
	ButtonMash.CreateBoundButton('moonfire' , 41*1, 0, 40, 40, ButtonMash.Moonkin.MOONFIRE);
	ButtonMash.CreateBoundButton('wrath'    , 41*2, 0, 40, 40, ButtonMash.Moonkin.WRATH);
	ButtonMash.CreateBoundButton('starfire' , 41*3, 0, 40, 40, ButtonMash.Moonkin.STARFIRE);
	ButtonMash.CreateBoundButton('starsurge', 41*4, 0, 40, 40, ButtonMash.Moonkin.STARSURGE);
	ButtonMash.CreateBoundButton('starfall' , 41*5, 0, 40, 40, ButtonMash.Moonkin.STARFALL);

	ButtonMash.CreateBoundButton('cd_1', 41*1, 41, 40, 40, ButtonMash.Moonkin.FORCE_OF_NATURE);
	ButtonMash.CreateBoundButton('cd_2', 41*2, 41, 40, 40, ButtonMash.Moonkin.CELESTIAL_ALIGNMENT);
	ButtonMash.CreateBoundButton('cd_3', 41*3, 41, 40, 40, ButtonMash.Moonkin.INNERVATE);
	ButtonMash.CreateBoundButton('cd_4', 41*4, 41, 40, 40, ButtonMash.Moonkin.MIRROR_IMAGE);
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
	local state = ButtonMash.Moonkin.GetState();

	for i in pairs(ButtonMash.buttons) do
		if (state.next == i) then
			ButtonMash.buttons[i]:SetGlow(true);
		else
			ButtonMash.buttons[i]:SetGlow(false);
		end
	end

	if (state.favored == 'starfire') then ButtonMash.buttons.wrath:SetAlpha(0.4); end
	if (state.favored == 'wrath'   ) then ButtonMash.buttons.starfire:SetAlpha(0.4); end

end;

function ButtonMash.Moonkin.GetState()

	local out = {
		next = '',
		favored = '',
	};


	-- find out power level and any eclipses

	local pow = UnitPower("player", 8);
	local eclipse_solar = false;
	local eclipse_lunar = false;

	local i;
	for i=1,40 do
		local id = select(11, UnitAura("player", i));
		if (id and id == ButtonMash.Moonkin.ECLIPSE_SOLAR) then eclipse_solar = true; end
		if (id and id == ButtonMash.Moonkin.ECLIPSE_LUNAR) then eclipse_lunar = true; end
	end


	-- find out if our debuffs are on the target

	local sunfire_remain = 0;
	local moonfire_remain = 0;

	for i=1,40 do
		local id = select(11, UnitAura("target", i, "PLAYER HARMFUL"));

		if (id and id == ButtonMash.Moonkin.SUNFIRE) then
			local expire = select(7, UnitAura("target", i, "PLAYER HARMFUL"));
			sunfire_remain = expire - GetTime();
		end

		if (id and id == ButtonMash.Moonkin.MOONFIRE) then
			local expire = select(7, UnitAura("target", i, "PLAYER HARMFUL"));
			moonfire_remain = expire - GetTime();
		end
	end


	-- favoring wrath or starfire?

	if (eclipse_solar) then

		out.favored = 'wrath';

	elseif (eclipse_lunar) then

		out.favored = 'starfire';

	elseif (pow > 0) then

		out.favored = 'starfire';

	else
		out.favored = 'wrath';
	end


	-- main spell priority

	if (sunfire_remain < 1.5) then

		out.next = 'sunfire';

	elseif (moonfire_remain < 1.5) then

		out.next = 'moonfire';

	elseif (ButtonMash.Moonkin.TimeUntil(ButtonMash.Moonkin.STARSURGE) < 1.5) then

		out.next = 'starsurge';

	elseif (ButtonMash.Moonkin.TimeUntil(ButtonMash.Moonkin.STARFALL) < 1.5) then

		out.next = 'starfall';

	else
		out.next = out.favored;
	end

	return out;
end;

function ButtonMash.Moonkin.TimeUntil(spell)

	local start, duration, enabled = GetSpellCooldown(spell);
	if (start>0 and duration>0) then
		return start + duration - GetTime();
	end
	return 0;
end
