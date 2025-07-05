local function getMessagesCallBack()
	return lib.callback.await('ps-adminmenu:callback:GetMessages', false)
end

RegisterNUICallback("GetMessages", function(_, cb)
	local data = getMessagesCallBack()
	if next(data) then
		SendNUIMessage({
			action = "setMessages",
			data = data
		})
	end
	cb(1)
end)

RegisterNUICallback("SendMessage", function(msgData, cb)
	local message = msgData.message

	TriggerServerEvent("ps-adminmenu:server:sendMessageServer", message, PlayerData.citizenid, PlayerData.charinfo.firstname .. " " .. PlayerData.charinfo.lastname)

	local data = getMessagesCallBack()
	SendNUIMessage({
		action = "setMessages",
		data = data
	})
	cb(1)
end)