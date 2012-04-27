if select(2, UnitClass('player')) ~= "DEATHKNIGHT" then return end
ButtonMash.enabled_for_class = true;


function ButtonMash.CreateUI()

	if (ButtonMash.current_talent_spec == 2) then

		ButtonMash.enabled_for_spec = true;
		print("ButtonMash: building UI");

		ButtonMash.ResizeUIFrame(50, 50);
		--ButtonMash.UIFrame.texture:SetTexture(1, 0, 0);

		ButtonMash.CreateButton('ob', 0, 0, 40, 40, [[Interface\Icons\spell_deathknight_classicon]]);
	end
end;

function ButtonMash.DestroyUI()

	if (ButtonMash.current_talent_spec == 2) then

		print("ButtonMash: removing UI");

		--ButtonMash.DestroyButtons();

	end
end;