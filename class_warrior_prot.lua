
ButtonMash.ProtWarrior = {};
ButtonMash.RegisterClassSpec('ProtWarrior', 'WARRIOR', 3);

function ButtonMash.ProtWarrior.CreateUI()

	local cols = 6;
	local rows = 2;

	ButtonMash.ResizeUIFrame((cols*40)+(cols-1), (rows*40)+(rows-1));
	--ButtonMash.UIFrame.texture:SetTexture(1, 0, 0);

	-- main buttons
	ButtonMash.CreateButton('ss', 41*0, 0, 40, 40, [[Interface\Icons\inv_shield_05]]);
	ButtonMash.CreateButton('rv', 41*1, 0, 40, 40, [[Interface\Icons\ability_warrior_revenge]]);
	ButtonMash.CreateButton('dv', 41*2, 0, 40, 40, [[Interface\Icons\inv_sword_11]]);
	ButtonMash.CreateButton('bs', 41*3, 0, 40, 40, [[Interface\Icons\ability_warrior_battleshout]]);
	ButtonMash.CreateButton('tc', 41*4, 0, 40, 40, [[Interface\Icons\spell_nature_thunderclap]]);
	ButtonMash.CreateButton('hs', 41*5, 0, 40, 40, [[Interface\Icons\ability_rogue_ambush]]);

	ButtonMash.CreateButton('aoe_tc', 41*0, 41, 40, 40, [[Interface\Icons\spell_nature_thunderclap]]);
	ButtonMash.CreateButton('aoe_ss', 41*1, 41, 40, 40, [[Interface\Icons\inv_shield_05]]);
	ButtonMash.CreateButton('aoe_rv', 41*2, 41, 40, 40, [[Interface\Icons\ability_warrior_revenge]]);
	ButtonMash.CreateButton('aoe_dv', 41*3, 41, 40, 40, [[Interface\Icons\inv_sword_11]]);
	ButtonMash.CreateButton('aoe_bs', 41*4, 41, 40, 40, [[Interface\Icons\ability_warrior_battleshout]]);
	ButtonMash.CreateButton('aoe_cl', 41*5, 41, 40, 40, [[Interface\Icons\ability_warrior_cleave]]);

	ButtonMash.buttons['ss'].label:SetText("1");
	ButtonMash.buttons['rv'].label:SetText("2");
	ButtonMash.buttons['dv'].label:SetText("3");
	ButtonMash.buttons['bs'].label:SetText("4");
	ButtonMash.buttons['tc'].label:SetText("5");
	ButtonMash.buttons['hs'].label:SetText("6");

	ButtonMash.buttons['aoe_tc'].label:SetText("5");
	ButtonMash.buttons['aoe_ss'].label:SetText("1");
	ButtonMash.buttons['aoe_rv'].label:SetText("2");
	ButtonMash.buttons['aoe_dv'].label:SetText("3");
	ButtonMash.buttons['aoe_bs'].label:SetText("4");
	ButtonMash.buttons['aoe_cl'].label:SetText("7");
end

function ButtonMash.ProtWarrior.DestroyUI()

end;

function ButtonMash.ProtWarrior.UpdateFrame()

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
	if (has_viable_target and (IsSpellInRange("Shield Slam") ~= 1)) then

		ButtonMash.Label:SetTextColor(1,0,0,1)
		ButtonMash.SetFontSize(ButtonMash.Label, 20);
		ButtonMash.Label:SetText("Too Far");
	end


	-- set spell timers etc
	ButtonMash.buttons.ss:SetSpellState("Shield Slam");
	ButtonMash.buttons.rv:SetSpellState("Revenge");
	ButtonMash.buttons.dv:SetSpellState("Devastate");
	ButtonMash.buttons.bs:SetSpellState("Battle Shout");
	ButtonMash.buttons.tc:SetSpellState("Thunder Clap");
	ButtonMash.buttons.hs:SetSpellState("Heroic Strike");

	ButtonMash.buttons.aoe_tc:SetSpellState("Thunder Clap");
	ButtonMash.buttons.aoe_ss:SetSpellState("Shield Slam");
	ButtonMash.buttons.aoe_rv:SetSpellState("Revenge");
	ButtonMash.buttons.aoe_dv:SetSpellState("Devastate");
	ButtonMash.buttons.aoe_bs:SetSpellState("Battle Shout");
	ButtonMash.buttons.aoe_cl:SetSpellState("Cleave");



	-- everything below here is only for active targets

	if (not has_viable_target) then
		return;
	end


end;
