
ButtonMash.FrostDK = {};
ButtonMash.RegisterClassSpec('FrostDK', 'DEATHKNIGHT', 2);

function ButtonMash.FrostDK.CreateUI()

		local cols = 4;
		local rows = 1;

		ButtonMash.ResizeUIFrame((cols*40)+(cols-1), (rows*40)+(rows-1));
		--ButtonMash.UIFrame.texture:SetTexture(1, 0, 0);

		-- main buttons
		ButtonMash.CreateButton('it', 41*0, 0, 40, 40, [[Interface\Icons\spell_deathknight_icetouch]]);
		ButtonMash.CreateButton('ps', 41*1, 0, 40, 40, [[Interface\Icons\spell_deathknight_empowerruneblade]]);
		ButtonMash.CreateButton('ob', 41*2, 0, 40, 40, [[Interface\Icons\spell_deathknight_classicon]]);
		ButtonMash.CreateButton('fs', 41*3, 0, 40, 40, [[Interface\Icons\spell_deathknight_empowerruneblade2]]);

		ButtonMash.buttons['it'].label:SetText("1");
		ButtonMash.buttons['ps'].label:SetText("2");
		ButtonMash.buttons['ob'].label:SetText("3");
		ButtonMash.buttons['fs'].label:SetText("4");

end;

function ButtonMash.FrostDK.DestroyUI()

end;

function ButtonMash.FrostDK.UpdateFrame()


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
		if (has_viable_target and (IsSpellInRange("Plague Strike") ~= 1)) then

			ButtonMash.Label:SetTextColor(1,0,0,1)
			ButtonMash.SetFontSize(ButtonMash.Label, 20);
			ButtonMash.Label:SetText("Too Far");
		end



		-- set spell timers etc
		ButtonMash.buttons.it:SetSpellState("Icy Touch");
		ButtonMash.buttons.ps:SetSpellState("Plague Strike");
		ButtonMash.buttons.ob:SetSpellState("Obliterate");
		ButtonMash.buttons.fs:SetSpellState("Frost Strike");


		-- everything below here is only for active targets

		if (not has_viable_target) then
			return;
		end


		--
		-- handle the 2 debuffs - if they are missing, they should be next
		--

		local has_ff = false;
		local has_bp = false;

		local index = 1
		while UnitDebuff("target", index) do
			local name, _, _, count, _, _, buffExpires, caster = UnitDebuff("target", index);
			if (name == "Frost Fever") then
				has_ff = true;
			end
			if (name == "Blood Plague") then
				has_bp = true;
			end
			index = index + 1
		end

		if (has_bp) then
			--ButtonMash.buttons.ps:SetGlow(false);
			ButtonMash.buttons.ps:SetAlpha(0.2);
		else
			--ButtonMash.buttons.ps:SetGlow(true);
			ButtonMash.buttons.ps:SetAlpha(1);
		end
		if (has_ff) then
			--ButtonMash.buttons.it:SetGlow(false);
			ButtonMash.buttons.it:SetAlpha(0.2);
		else
			--ButtonMash.buttons.it:SetGlow(true);
			ButtonMash.buttons.it:SetAlpha(1);
		end


		--
		-- next comes oblit & frost strike.
		--
		-- suggest obilt, unless:
		--  * no killing machine AND
		--  * rp is almost capped
		--
		-- don't suggest frost strike if:
		--  * killing machine is up
		--

		local killing_machine = false;
		local aura = UnitAura("Player", "Killing Machine");
		if (aura) then killing_machine = true; end

		local cur_rp = UnitPower("player", 6);
		local max_rp = UnitPowerMax("player", 6);
		local missing_rp = max_rp - cur_rp;

		if ((not killing_machine) and (missing_rp < 21)) then
			ButtonMash.buttons.ob:SetAlpha(0.2);
		else
			ButtonMash.buttons.ob:SetAlpha(1);
		end

		if (killing_machine) then
			ButtonMash.buttons.fs:SetAlpha(0.2);
		else
			ButtonMash.buttons.fs:SetAlpha(1);
		end

end;
