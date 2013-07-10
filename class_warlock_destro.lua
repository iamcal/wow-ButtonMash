
ButtonMash.Destro = {};
ButtonMash.RegisterClassSpec('Destro', 'WARLOCK', 3);

ButtonMash.Destro.CURSE_OF_ELEMENTS	= 1490;
ButtonMash.Destro.MASTER_POISONER	= 58410;

ButtonMash.Destro.SHADOWBURN	= 17877;
ButtonMash.Destro.IMMOLATE	= 348;
ButtonMash.Destro.CONFLAGRATE	= 17962;
ButtonMash.Destro.RAIN_OF_FIRE	= 5740;
ButtonMash.Destro.CHAOS_BOLT	= 116858;
ButtonMash.Destro.INCINERATE	= 29722;
ButtonMash.Destro.FEL_FLAME	= 77799;
ButtonMash.Destro.DARK_SOUL	= 113858;
ButtonMash.Destro.SUMMON	= 1122;

ButtonMash.Destro.BACKDRAFT_BUFF	= 117828;
ButtonMash.Destro.RAIN_OF_FIRE_BUFF	= 104232;
ButtonMash.Destro.DARK_SOUL_BUFF	= 113858;


function ButtonMash.Destro.CreateUI()

	local cols = 4;
	local rows = 3;

	ButtonMash.ResizeUIFrame((cols*40)+(cols-1), (rows*40)+(rows-1));
	--ButtonMash.UIFrame.texture:SetTexture(1, 0, 0);

	-- main buttons

	ButtonMash.CreateBoundButton('shadow'    , 41*1, 0, 40, 40, ButtonMash.Destro.SHADOWBURN);
	ButtonMash.CreateBoundButton('chaos'     , 41*2, 0, 40, 40, ButtonMash.Destro.CHAOS_BOLT);

	ButtonMash.CreateBoundButton('immolate'  , 41*0, 41, 40, 40, ButtonMash.Destro.IMMOLATE);
	ButtonMash.CreateBoundButton('conflag'   , 41*1, 41, 40, 40, ButtonMash.Destro.CONFLAGRATE);
	ButtonMash.CreateBoundButton('rain'      , 41*2, 41, 40, 40, ButtonMash.Destro.RAIN_OF_FIRE);
	ButtonMash.CreateBoundButton('incinerate', 41*3, 41, 40, 40, ButtonMash.Destro.INCINERATE);

	ButtonMash.CreateBoundButton('curse'    , 20+(41*0), 82, 40, 40, ButtonMash.Destro.CURSE_OF_ELEMENTS);
	ButtonMash.CreateBoundButton('darksoul' , 20+(41*1), 82, 40, 40, ButtonMash.Destro.DARK_SOUL);
	ButtonMash.CreateBoundButton('summon'   , 20+(41*2), 82, 40, 40, ButtonMash.Destro.SUMMON);

end

function ButtonMash.Destro.DestroyUI()

end;

function ButtonMash.Destro.UpdateFrame()

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
	if (has_viable_target and (IsSpellInRange("Conflagrate") ~= 1)) then

		ButtonMash.Label:SetTextColor(1,0,0,1)
		ButtonMash.SetFontSize(ButtonMash.Label, 20);
		ButtonMash.Label:SetText("Too Far");
	end


	-- main shot state
	local state = ButtonMash.Destro.GetState();

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

function ButtonMash.Destro.GetState()

	local out = {
		next = '',
		embers = 0,
		below_20 = false, -- TODO
		got_coe = false,
		immolate_remain = 0,
		rain_remain = 0,
		has_backdraft = false,
		has_dark_soul = false,
	};


	--
	-- various state things
	--

	out.embers = UnitPower("player", 14);


	--
	-- buffs & debuffs
	--

	local i;

	for i=1,40 do
		local id = select(11, UnitAura("target", i, "HARMFUL"));
		if (id == ButtonMash.Destro.CURSE_OF_ELEMENTS) then out.got_coe = true; end
		if (id == ButtonMash.Destro.MASTER_POISONER  ) then out.got_coe = true; end
	end

	for i=1,40 do
		local id = select(11, UnitAura("target", i, "PLAYER HARMFUL"));

		if (id and id == ButtonMash.Destro.IMMOLATE) then
			local expire = select(7, UnitAura("target", i, "PLAYER HARMFUL"));
			out.immolate_remain = expire - GetTime();
		end
	end

	local self_buffs = ButtonMash.Auras("player", "PLAYER HELPFUL");

	if (self_buffs[ButtonMash.Destro.RAIN_OF_FIRE_BUFF]) then

		out.rain_remain = self_buffs[ButtonMash.Destro.RAIN_OF_FIRE_BUFF];
	end

	if (self_buffs[ButtonMash.Destro.BACKDRAFT_BUFF]) then

		out.has_backdraft = true;
	end

	if (self_buffs[ButtonMash.Destro.DARK_SOUL_BUFF]) then

		out.has_dark_soul = true;
	end


	--
	-- regular rotation
	--

	if (not out.got_coe) then
		out.next = 'curse';
		return out;
	end

	if (out.below_20 and out.embers > 0) then
		out.next = 'shadow';
		return out;
	end

	if (out.immolate_remain < 2) then
		out.next = 'immolate';
		return out;
	end

	if (out.embers > 0 and out.has_dark_soul) then
		out.next = 'chaos';
		return out;
	end

	if (ButtonMash.TimeUntil(ButtonMash.Destro.CONFLAGRATE) < 0.5) then
		out.next = 'conflag';
		return out;
	end

	if (out.rain_remain <= 1.5) then
		out.next = 'rain';
		return out;
	end

	if (out.has_backdraft and out.embers < 4) then
		out.next = 'incinerate';
		return out;
	end

	if (out.embers > 0) then
		out.next = 'chaos';
		return out;
	end

	out.next = 'incinerate';
	return out;
end;

