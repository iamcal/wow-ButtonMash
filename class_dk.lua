if select(2, UnitClass('player')) ~= "DEATHKNIGHT" then return end
ButtonMash.enabled_for_class = true;


function ButtonMash.CreateUI()

	if (ButtonMash.current_talent_spec == 2) then

		print("ButtonMash: building UI");

	end
end;

function ButtonMash.DestroyUI()

	if (ButtonMash.current_talent_spec == 2) then

		print("ButtonMash: removing UI");

	end
end;