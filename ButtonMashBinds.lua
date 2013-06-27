-- keep track of which spells are bound to which keys

ButtonMashBinds = {};
ButtonMashBinds.Keys = {};
ButtonMashBinds.Spells = {};

function ButtonMashBinds.OnEvent(frame, event, ...)

	-- in this one case, we can update a single slot

	if (event == "ACTIONBAR_SLOT_CHANGED") then
		local slot = ...;
		if (slot > 0) then
			ButtonMashBinds.UpdateSlot(tonumber(slot), true);
			return;
		end
	end


	-- else we'll be updating every slot

	ButtonMashBinds.UpdateAll();
end

function ButtonMashBinds.UpdateAll()

	ButtonMashBinds.Keys = {};
	ButtonMashBinds.Spells = {};

	local i;
	for i=1,120 do
		ButtonMashBinds.UpdateSlot(i, false);
	end
end

function ButtonMashBinds.UpdateSlot(index, wipe_previous)

	-- what key is bound to this slot?

	ButtonMashBinds.Keys[index] = ButtonMashBinds.GetKey(index);


	-- wipe any previous abilities from this slot?

	if (wipe_previous) then

		local i,v;
		for i,v in pairs(ButtonMashBinds.Spells) do
			if (v == index) then
				ButtonMashBinds.Spells[i] = nil;
			end
		end
	end


	-- assign macro/item/spell

	local text = GetActionText(index);
	if (text) then
		ButtonMashBinds.Spells['MACRO_'..text] = index;
	else
		local type, id = GetActionInfo(index);

		if (type == "spell") then
			ButtonMashBinds.Spells['SPELL_'..id] = index;
		end
		if (type == "item") then
			ButtonMashBinds.Spells['ITEM_'..id] = index;
		end
	end
end

function ButtonMashBinds.GetKey(index)

	if (index<=24 or index>72) then
		return GetBindingKey("ACTIONBUTTON"..(((index-1)%12)+1));
	end

	if (index<=36) then
		GetBindingKey("MULTIACTIONBAR3BUTTON"..(index-24));
	end

	if (index<=48) then
		GetBindingKey("MULTIACTIONBAR4BUTTON"..(index-36));
	end

	if (index<=60) then
		GetBindingKey("MULTIACTIONBAR2BUTTON"..(index-48));
	end

	return GetBindingKey("MULTIACTIONBAR1BUTTON"..(index-60));
end

function ButtonMashBinds.CurrentKey(idx)

	local index = ButtonMashBinds.Spells[idx];
	if (not index) then
		return nil;
	end

	return ButtonMashBinds.Keys[index];
end

function ButtonMashBinds.Test()

	local num_spells = 0;
	local num_keys = 0;

	local i,v;
	for i,v in pairs(ButtonMashBinds.Spells) do
		num_spells = num_spells + 1;
	end
	for i,v in pairs(ButtonMashBinds.Keys) do
		num_keys = num_keys + 1;
	end

	print("ButtonMashBinds: "..num_spells.." spells & "..num_keys.." keys");
end



ButtonMashBinds.EventFrame = CreateFrame("Frame");
ButtonMashBinds.EventFrame:Show();
ButtonMashBinds.EventFrame:SetScript("OnEvent", ButtonMashBinds.OnEvent);
ButtonMashBinds.EventFrame:RegisterEvent("ACTIONBAR_SLOT_CHANGED");
ButtonMashBinds.EventFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
ButtonMashBinds.EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
ButtonMashBinds.EventFrame:RegisterEvent("PLAYER_TALENT_UPDATE");
ButtonMashBinds.EventFrame:RegisterEvent("UPDATE_BINDINGS");
