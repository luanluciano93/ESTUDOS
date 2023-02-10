local itemId = 11372
local horasRestaurar = 40

macro(1000, "use stamina restore",  function()
	if not isInPz() then
		if stamina() < (storage.horasRestore * 60) then
			use(storage.staminaItem)
		end
	end
end)

UI.Label("Stamina Restore ITEM:")
UI.TextEdit(storage.staminaItem or itemId, function(widget, newText)
	storage.staminaItem = newText
end)

UI.Label("Stamina Restore HORAS:")
UI.TextEdit(storage.horasRestore or horasRestaurar, function(widget, newText)
	storage.horasRestore = newText
end)
