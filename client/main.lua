QBCore = exports['qb-core']:GetCoreObject()
PlayerData = {}

-- Functions
local function setupMenu()
	Wait(500)
	PlayerData = QBCore.Functions.GetPlayerData()
	local resources = lib.callback.await('ps-adminmenu:callback:GetResources', false)
	local commands = lib.callback.await('ps-adminmenu:callback:GetCommands', false)
	local items = lib.callback.await('ps-adminmenu:callback:GetItems', false)
	local vehicles = lib.callback.await('ps-adminmenu:callback:GetVehicles', false)
	local server = lib.callback.await('ps-adminmenu:callback:GetServerInfo', false)
	GetData()
	SendNUIMessage({
		action = "setupUI",
		data = {
			actions = Config.Actions,
			resources = resources,
			playerData = PlayerData,
			commands = commands,
			items = items,
			vehicles = vehicles,
			server = server 
		}
	})
end

RegisterNUICallback('getServerInfo', function(_, cb)
    local serverInfo = lib.callback.await('ps-adminmenu:callback:GetServerInfo', false)
    if not serverInfo then
        print("Erro: Nenhum dado recebido do servidor.")
        cb({ error = "Erro ao carregar informações do servidor." })
        return
    end
    cb(serverInfo)
end)

RegisterNUICallback("ps-adminmenu:callback:GetBans", function(data, cb)
    local bans = lib.callback.await('ps-adminmenu:callback:GetBans', false)
    cb(bans)
end)

RegisterNUICallback("sendNUI", function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage(data)
    cb("ok")
end)

-- Event Handlers
AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
	setupMenu()
end)

AddEventHandler("onResourceStart", function(resourceName)
	if (GetCurrentResourceName() == resourceName) then
		setupMenu()
	end
end)

-- NUICallbacks
RegisterNUICallback("hideUI", function()
	ToggleUI(false)
end)

RegisterNUICallback("clickButton", function(data)
	local selectedData = data.selectedData
	local key = data.data
	local data = CheckDataFromKey(key)
	if not data or not CheckPerms(data.perms) then return end

	if data.type == "client" then
		TriggerEvent(data.event, key, selectedData)
	elseif data.type == "server" then
		TriggerServerEvent(data.event, key, selectedData)
	elseif data.type == "command" then
		ExecuteCommand(data.event)
	end

	Log("Action Used: " .. key,
            PlayerData.name ..
            " (" ..
            PlayerData.citizenid ..
            ") - Used: " .. key .. (selectedData and (" with args: " .. json.encode(selectedData)) or ""))
	TriggerEvent('ps-adminmenu:client:PlayHUDSound', 'success')
end)

-- Open UI Event
RegisterNetEvent('ps-adminmenu:client:OpenUI', function()
	if not CheckPerms(Config.OpenPanelPerms) then return end
	ToggleUI(true)
end)

-- Close UI Event
RegisterNetEvent('ps-adminmenu:client:CloseUI', function()
	ToggleUI(false)
end)

-- Change resource state
RegisterNUICallback("setResourceState", function(data, cb)
	local resources = lib.callback.await('ps-adminmenu:callback:ChangeResourceState', false, data)
	cb(resources)
end)

-- Get players
RegisterNUICallback("getPlayers", function(data, cb)
	local players = lib.callback.await('ps-adminmenu:callback:GetPlayers', false)
	cb(players)
end)

-- Get Groups
RegisterNUICallback("getGroupsData", function(data, cb)
	local groups = lib.callback.await('ps-adminmenu:callback:GetGroupsData', false)
	cb(groups)
end)

-- ExecuteCommand
RegisterNetEvent('ps-adminmenu:client:ExecuteCommand', function(data)
	ExecuteCommand(data)
end)

RegisterNUICallback("executeCommand", function(data, cb)
	local command = data.command
	local args = data.args
	ExecuteCommand(command, args)
	cb(command)
end)

RegisterNetEvent('ps-adminmenu:client:RefreshBans', function()
    SendNUIMessage({ action = 'refreshBans' })
end)

RegisterNetEvent('ps-adminmenu:client:RefreshPlayers', function()
    SendNUIMessage({ action = 'refreshPlayers' })
end)