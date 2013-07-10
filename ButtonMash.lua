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
ButtonMash.enabled_for_spec = false;
ButtonMash.current_talent_spec = 0;

ButtonMash.current_module_id = nil;
ButtonMash.current_module = nil;
ButtonMash.modules = {};

ButtonMash.start_w = 200;
ButtonMash.start_h = 200;
ButtonMash.misc_counter = 0;

ButtonMash.buttons = {};
ButtonMash.labels = {};

ButtonMash.free_buttons = {};
ButtonMash.free_labels = {};


--
-- module registration
--

function ButtonMash.RegisterClassSpec(name, class_id, spec_id)

	ButtonMash.modules[class_id..'-'..spec_id] = name;
end


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

	if (not ButtonMash.fully_loaded) then
		return;
	end


	--
	-- figure out if talent spec has changed. if so, destroy & create UI
	--

	local class_id = select(2, UnitClass('player'));
	local spec_id = ButtonMash.GetCurrentTalentSpec();
	spec_id = spec_id or 0;
	local key = class_id..'-'..spec_id;
	local module_id = ButtonMash.modules[key];

	if (module_id ~= ButtonMash.current_module_id) then

		if (ButtonMash.current_module) then
			if (ButtonMash.current_module.DestroyUI) then
				ButtonMash.current_module.DestroyUI();
			end
			ButtonMash.DestroyControls();
			ButtonMash.UIFrame:Hide();
		end

		ButtonMash.current_module_id = module_id;
		ButtonMash.current_module = ButtonMash[module_id];

		if (ButtonMash.current_module) then
			if (ButtonMash.current_module.CreateUI) then
				ButtonMash.current_module.CreateUI();
			end
			if (not ButtonMashPrefs.hide) then
				ButtonMash.UIFrame:Show();
			end
		end
	end

	if (ButtonMashPrefs.hide) then 
		return;
	end

	if (ButtonMash.current_module) then
		ButtonMash.UpdateBoundButtons();
		if (ButtonMash.current_module.UpdateFrame) then
			ButtonMash.current_module.UpdateFrame();
		end
	end
end

function ButtonMash.GetCurrentTalentSpec()

	local activeSpec = GetActiveSpecGroup(false);
	local spec = GetSpecialization(false, false, activeSpec);

	return spec;
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

	if (ButtonMash.current_module and ButtonMash.current_module.ModuleOnEvent) then
		ButtonMash.current_module.ModuleOnEvent(event, ...);
	end
end

function ButtonMash.CreateUIFrame()

	-- create the UI frame
	ButtonMash.UIFrame = CreateFrame("Frame",nil,UIParent);
	ButtonMash.UIFrame:SetFrameStrata("BACKGROUND")
	ButtonMash.UIFrame:SetWidth(ButtonMash.start_w);
	ButtonMash.UIFrame:SetHeight(ButtonMash.start_h);

	-- make it black
	ButtonMash.UIFrame.texture = ButtonMash.UIFrame:CreateTexture();
	ButtonMash.UIFrame.texture:SetAllPoints(ButtonMash.UIFrame);
	ButtonMash.UIFrame.texture:SetTexture(0, 0, 0, 0);

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

	ButtonMash.UIFrame:Hide();
end

function ButtonMash.ResizeUIFrame(w, h)

	ButtonMash.UIFrame:SetWidth(w);
	ButtonMash.UIFrame:SetHeight(h);

	ButtonMash.Cover:SetWidth(w);
	ButtonMash.Cover:SetHeight(h);
end

function ButtonMash.CreateButton(short_id, x, y, w, h, texture)

	local b = ButtonMash.GetButton();

	b:SetParent(ButtonMash.UIFrame);
	b:SetPoint("TOPLEFT", x, 0-y);
	b:SetWidth(w);
	b:SetHeight(h);
	b:SetNormalTexture(texture);
	b:Show();

	b.glow:SetPoint("TOPLEFT", b, "TOPLEFT", -w * 0.2, h * 0.2);
	b.glow:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", w * 0.2, -h*0.2);

	-- reset bound spell, in case we recycle a bound button into
	-- a non-bound one.
	b.bound_spell = nil;

	b.short_id = short_id;
	ButtonMash.buttons[short_id] = b;

	return b;
end

function ButtonMash.CreateLabel(x, y)

	local l = ButtonMash.GetLabel();

	l:SetPoint("CENTER", ButtonMash.UIFrame, "TOPLEFT", x, 0-y);
	l:Show();

	table.insert(ButtonMash.labels, l);

	return l;
end

function ButtonMash.DestroyControls()

	local i;

	for i in pairs(ButtonMash.buttons) do

		-- add to free buttons list
		table.insert(ButtonMash.free_buttons, ButtonMash.buttons[i]);

		-- hide it
		ButtonMash.buttons[i]:Hide();
		ButtonMash.buttons[i]:SetParent(nil);		
	end

	for i in pairs(ButtonMash.labels) do

		-- add to free labels list
		table.insert(ButtonMash.free_labels, ButtonMash.labels[i]);

		-- hide it
		ButtonMash.labels[i]:Hide();
	end

	ButtonMash.buttons = {};
	ButtonMash.labels = {};
end

function ButtonMash.GetButton()

	--
	-- take one from the cache if we can
	--

	if (#ButtonMash.free_buttons > 0) then
		return table.remove(ButtonMash.free_buttons);
	end


	--
	-- need to create a new one
	--

	ButtonMash.misc_counter = ButtonMash.misc_counter + 1;
	local name = "ButtonMashBtn"..ButtonMash.misc_counter;

	-- the actual button
	local b = CreateFrame("Button", name, ButtonMash.UIFrame);

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
	b.label:SetFont([[Fonts\FRIZQT__.TTF]], 10, "OUTLINE");
	b.label:SetPoint("TOPRIGHT", b, -4, -4);


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
	b.glow:Hide();
	b.is_glowing = false;

	function b:SetGlow(is_glowing)
		if (is_glowing) then
			self.glow:Show();
			if (not self.is_glowing) then
				self.glow.animOut:Stop();
				self.glow.animIn:Play();
				self.is_glowing = true;
			end
		else
			self.glow:Hide();
			if (self.is_glowing) then
				self.glow.animIn:Stop();
				self.glow.animOut:Play();
				self.is_glowing = false;
			end
		end
	end

	return b;
end

function ButtonMash.GetLabel()

	--
	-- take one from the cache if we can
	--

	if (#ButtonMash.free_labels > 0) then
		return table.remove(ButtonMash.free_labels);
	end


	--
	-- need to create a new one
	--

	local l = ButtonMash.Cover:CreateFontString(nil, "OVERLAY");
	l:SetFont([[Fonts\FRIZQT__.TTF]], 12, "OUTLINE");
	l:SetText("");
	l:SetTextColor(1,1,1,1);

	return l;
end

function ButtonMash.CreateBoundButton(short_id, x, y, w, h, spell)

	local name, _, icon = GetSpellInfo(spell);
	local btn = ButtonMash.CreateButton(short_id, x, y, w, h, icon);
	btn.bound_spell = spell;

	btn.label:SetText("?");

	return btn;
end

function ButtonMash.UpdateBoundButtons()

	for i in pairs(ButtonMash.buttons) do
		local btn = ButtonMash.buttons[i];
		if (btn.bound_spell) then

			btn:SetSpellState(btn.bound_spell);
			btn.label:SetText(ButtonMashBinds.CurrentKey("SPELL_"..btn.bound_spell));
		end
	end
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

function ButtonMash.SetButtonState(btn_id, state, spellName)

	local btn = ButtonMash.buttons[btn_id];

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

function ButtonMash.GetSpellCost(spellName)
	local name, rank, icon, cost, isFunnel, powerType, castTime, minRange, maxRange = GetSpellInfo(spellName);
	return cost;
end


ButtonMash.cooldown_spells = {
	"Lifeblood",		-- herbalists
	"Rocket Barrage",	-- goblins
	"Blood Fury",		-- orcs
	"War Stomp",		-- tauren
	"Berserking",		-- trolls
};

function ButtonMash.GetCooldowns()

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

	return {
		count = cooldowns_count,
		abilities = cooldowns,
	};	
end


ButtonMash.EventFrame = CreateFrame("Frame");
ButtonMash.EventFrame:Show();
ButtonMash.EventFrame:SetScript("OnEvent", ButtonMash.OnEvent);
ButtonMash.EventFrame:SetScript("OnUpdate", ButtonMash.OnUpdate);
ButtonMash.EventFrame:RegisterEvent("ADDON_LOADED");
ButtonMash.EventFrame:RegisterEvent("PLAYER_LOGIN");
ButtonMash.EventFrame:RegisterEvent("PLAYER_LOGOUT");

