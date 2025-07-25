RegisterNetEvent('ps-adminmenu:server:unban_cid', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local src = source
    local citizenid = selectedData["cid"].value
    if not citizenid then
        TriggerClientEvent('QBCore:Notify', src, "CID inválido.", "error", 5000)
        return
    end

    -- Busca o license (pode estar com prefixo license2:)
    MySQL.scalar('SELECT license FROM players WHERE citizenid = ?', { citizenid }, function(license)
        if not license then
            TriggerClientEvent('QBCore:Notify', src, ("❌ Nenhum jogador encontrado com CID %s."):format(citizenid), "error", 5000)
            return
        end

        -- Gera as duas versões possíveis de license
        local license1 = license:gsub("^license2:", "license:")
        local license2 = license:gsub("^license:", "license2:")

        -- Deleta qualquer ban que use license:xxx ou license2:xxx
        MySQL.update('DELETE FROM bans WHERE license = ? OR license = ?', { license1, license2 }, function(affectedRows)
            if affectedRows and affectedRows > 0 then
                TriggerClientEvent('QBCore:Notify', src, ("✅ Jogador com CID %s foi desbanido."):format(citizenid), "success", 5000)
            else
                TriggerClientEvent('QBCore:Notify', src, ("⚠️ Nenhum banimento encontrado com as licenças associadas ao CID %s."):format(citizenid), "error", 5000)
            end
        end)
    end)
end)

RegisterNetEvent('ps-adminmenu:server:delete_cid', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local src = source
    local citizenid = selectedData["cid"].value
    if not citizenid then
        TriggerClientEvent('QBCore:Notify', src, "CID inválido.", "error", 5000)
        return
    end

    -- Deleta o jogador usando oxmysql com callback garantido
    MySQL.update('DELETE FROM players WHERE citizenid = ?', { citizenid }, function(affectedRows)

        if affectedRows and affectedRows > 0 then
            TriggerClientEvent('QBCore:Notify', src, ("✅ Jogador com CID %s foi deletado."):format(citizenid), "success", 5000)
            TriggerClientEvent('ps-adminmenu:client:RefreshPlayers', src)
        else
            TriggerClientEvent('QBCore:Notify', src, ("❌ Nenhum jogador encontrado com CID %s."):format(citizenid), "error", 5000)
        end
    end)
end)


-- Ban Player
RegisterNetEvent('ps-adminmenu:server:BanPlayer', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local player = selectedData["Player"].value
    local reason = selectedData["Reason"].value or ""
    local time = tonumber(selectedData["Duração"].value)

    local banTime = time == 2147483647 and 2147483647 or tonumber(os.time() + time)
    local timeTable = os.date('*t', banTime)

    MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)',
        { GetPlayerName(player), QBCore.Functions.GetIdentifier(player, 'license'), QBCore.Functions.GetIdentifier(
            player, 'discord'), QBCore.Functions.GetIdentifier(player, 'ip'), reason, banTime, GetPlayerName(source) })

    if time == 2147483647 then
        DropPlayer(player, locale("banned") .. '\n' .. locale("reason") .. reason .. locale("ban_perm"))
    else
        DropPlayer(player,
            locale("banned") ..
            '\n' ..
            locale("reason") ..
            reason ..
            '\n' ..
            locale("ban_expires") ..
            timeTable['day'] ..
            '/' .. timeTable['month'] .. '/' .. timeTable['year'] .. ' ' .. timeTable['hour'] .. ':' .. timeTable['min'])
    end

    QBCore.Functions.Notify(source, locale("playerbanned", player, banTime, reason), 'success', 7500)
    TriggerClientEvent('ps-adminmenu:client:RefreshPlayers', src)
end)

-- Unban Player
RegisterNetEvent('ps-adminmenu:server:UnbanPlayer', function(data, selectedData)
    local actionData = CheckDataFromKey(data)
    local src = source or 0

    if not actionData then
        return
    end

    if not CheckPerms(src, actionData.perms) then
        return
    end

    local targetId = tonumber(selectedData["Player"] and selectedData["Player"].value)
    if not targetId then
        return
    end

    local license = QBCore.Functions.GetIdentifier(targetId, 'license')

    if not license then
        if src > 0 then
            QBCore.Functions.Notify(src, 'License do jogador não encontrada.', 'error', 7500)
        end
        return
    end

    local result = MySQL.query.await('SELECT * FROM bans WHERE license = ?', { license })

    if result and #result > 0 then
        local deleteResult = MySQL.update.await('DELETE FROM bans WHERE license = ?', { license })

        if src > 0 then
            QBCore.Functions.Notify(src, 'Jogador desbanido com sucesso.', 'success', 7500)
        end
        TriggerClientEvent('ps-adminmenu:client:RefreshPlayers', src)
    else
        if src > 0 then
            QBCore.Functions.Notify(src, 'Nenhum ban ativo encontrado para esse jogador.', 'error', 7500)
        end
    end
end)

-- Warn Player
RegisterNetEvent('ps-adminmenu:server:WarnPlayer', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end
    local targetId = selectedData["Player"].value
    local target = QBCore.Functions.GetPlayer(targetId)
    local reason = selectedData["Reason"].value
    local sender = QBCore.Functions.GetPlayer(source)
    local warnId = 'WARN-' .. math.random(1111, 9999)
    if target ~= nil then
        QBCore.Functions.Notify(target.PlayerData.source,
            locale("warned") .. ", por: " .. locale("reason") .. " " .. reason, 'inform', 60000)
        QBCore.Functions.Notify(source,
            locale("warngiven") .. GetPlayerName(target.PlayerData.source) .. ", por: " .. reason)
        MySQL.insert('INSERT INTO player_warns (senderIdentifier, targetIdentifier, reason, warnId) VALUES (?, ?, ?, ?)',
            {
                sender.PlayerData.license,
                target.PlayerData.license,
                reason, 
                warnId
            })
    else
        TriggerClientEvent('QBCore:Notify', source, locale("not_online"), 'error')
    end
end)

RegisterNetEvent('ps-adminmenu:server:KickPlayer', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end
    local src = source
    local target = QBCore.Functions.GetPlayer(selectedData["Player"].value)
    local reason = selectedData["Reason"].value

    if not target then
        QBCore.Functions.Notify(src, locale("not_online"), 'error', 7500)
        return
    end

    DropPlayer(target.PlayerData.source, locale("kicked") .. '\n' .. locale("reason") .. reason)
    TriggerClientEvent('ps-adminmenu:client:RefreshPlayers', src)
end)

-- Verify Player
RegisterNetEvent('ps-adminmenu:server:verifyPlayer', function(data, selectedData)
	local data = CheckDataFromKey(data)
	if not data or not CheckPerms(source, data.perms) then return end

	local playerId = tonumber(selectedData["Player"].value)
	local Player = QBCore.Functions.GetPlayer(playerId)

	if Player then
		local metadata = Player.PlayerData.metadata or {}
		local currentState = metadata.verified or false

		local newState = not currentState
		Player.Functions.SetMetaData("verified", newState)

		if newState then
			local admin = QBCore.Functions.GetPlayer(source)
			local adminName = admin and admin.PlayerData.charinfo and (admin.PlayerData.charinfo.firstname .. ' ' .. admin.PlayerData.charinfo.lastname) or GetPlayerName(source)
			Player.Functions.SetMetaData("verified_by", adminName)
		else
			Player.Functions.SetMetaData("verified_by", nil)
		end

		local message = newState and "Jogador marcado como verificado." or "Verificação removida do jogador."
		TriggerClientEvent('QBCore:Notify', source, message, newState and "success" or "error")
	end
end)

-- Revive Player
RegisterNetEvent('ps-adminmenu:server:Revive', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end
    local player = selectedData["Player"].value

    if GetResourceState('mri_Qbox') ~= 'started' then
        TriggerClientEvent('hospital:client:Revive', player)
    else
        TriggerClientEvent('ps-adminmenu:client:ExecuteCommand', source, ('revive %s'):format(player))
    end
end)

-- Revive All
RegisterNetEvent('ps-adminmenu:server:ReviveAll', function(data)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    if GetResourceState('mri_Qbox') ~= 'started' then
        TriggerClientEvent('hospital:client:Revive', -1)
    else
        TriggerClientEvent('ps-adminmenu:client:ExecuteCommand', source, ('reviveall %s'):format(player))
    end
end)

-- Revive Radius
RegisterNetEvent('ps-adminmenu:server:ReviveRadius', function(data)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local src = source
    local ped = GetPlayerPed(src)
    local pos = GetEntityCoords(ped)
    local players = QBCore.Functions.GetPlayers()

    for k, v in pairs(players) do
        local target = GetPlayerPed(v)
        local targetPos = GetEntityCoords(target)
        local dist = #(pos - targetPos)

        if dist < 15.0 then
            if GetResourceState('mri_Qbox') ~= 'started' then
                TriggerClientEvent('hospital:client:Revive', v)
            else
                TriggerClientEvent('ps-adminmenu:client:ExecuteCommand', source, ('revive %s'):format(v))
            end
        end
    end
end)

-- Set RoutingBucket
RegisterNetEvent('ps-adminmenu:server:SetBucket', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local src = source
    local player = selectedData["Player"].value
    local bucket = selectedData["Bucket"].value
    local currentBucket = GetPlayerRoutingBucket(player)

    if bucket == currentBucket then
        return QBCore.Functions.Notify(src, locale("target_same_bucket", player), 'error', 7500)
    end

    SetPlayerRoutingBucket(player, bucket)
    QBCore.Functions.Notify(src, locale("bucket_set_for_target", player, bucket), 'success', 7500)
end)

-- Get RoutingBucket
RegisterNetEvent('ps-adminmenu:server:GetBucket', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local src = source
    local player = selectedData["Player"].value
    local currentBucket = GetPlayerRoutingBucket(player)

    QBCore.Functions.Notify(src, locale("bucket_get", player, currentBucket), 'success', 7500)
end)

-- Give Money
RegisterNetEvent('ps-adminmenu:server:GiveMoney', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local src = source
    local target, amount, moneyType = selectedData["Player"].value, selectedData["Amount"].value,
        selectedData["Type"].value
    local Player = QBCore.Functions.GetPlayer(tonumber(target))

    if Player == nil then
        return QBCore.Functions.Notify(src, locale("not_online"), 'error', 7500)
    end

    Player.Functions.AddMoney(tostring(moneyType), tonumber(amount))
    QBCore.Functions.Notify(src,
        locale((moneyType == "crypto" and "give_money_crypto" or "give_money"), tonumber(amount),
            Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname), "success")
end)

-- Give Money to all
RegisterNetEvent('ps-adminmenu:server:GiveMoneyAll', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local src = source
    local amount, moneyType = selectedData["Amount"].value, selectedData["Type"].value
    local players = QBCore.Functions.GetPlayers()

    for _, v in pairs(players) do
        local Player = QBCore.Functions.GetPlayer(tonumber(v))
        Player.Functions.AddMoney(tostring(moneyType), tonumber(amount))
        QBCore.Functions.Notify(src,
            locale((moneyType == "crypto" and "give_money_all_crypto" or "give_money_all"), tonumber(amount)), "success")
    end
end)

-- Take Money
RegisterNetEvent('ps-adminmenu:server:TakeMoney', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local src = source
    local target, amount, moneyType = selectedData["Player"].value, selectedData["Amount"].value,
        selectedData["Type"].value
    local Player = QBCore.Functions.GetPlayer(tonumber(target))

    if Player == nil then
        return QBCore.Functions.Notify(src, locale("not_online"), 'error', 7500)
    end

    if Player.PlayerData.money[moneyType] >= tonumber(amount) then
        Player.Functions.RemoveMoney(moneyType, tonumber(amount), "state-fees")
    else
        QBCore.Functions.Notify(src, locale("not_enough_money"), "primary")
    end

    QBCore.Functions.Notify(src,
        locale((moneyType == "crypto" and "take_money_crypto" or "take_money"), tonumber(amount) .. "R$",
            Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname), "success")
end)

-- Blackout
local Blackout = false
RegisterNetEvent('ps-adminmenu:server:ToggleBlackout', function(data)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end
    Blackout = not Blackout

    local src = source

    if Blackout then
        TriggerClientEvent('QBCore:Notify', src, locale("blackout", "Ativado"), 'primary')
        while Blackout do
            Wait(0)
            exports["qb-weathersync"]:setBlackout(true)
        end
        exports["qb-weathersync"]:setBlackout(false)
        TriggerClientEvent('QBCore:Notify', src, locale("blackout", "Desativado"), 'primary')
    end
end)

-- Toggle Cuffs
RegisterNetEvent('ps-adminmenu:server:CuffPlayer', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local target = tonumber(selectedData["Player"].value)

    if GetResourceState("ND_Police") == "started" then
        local playerIsCuffed = Player(target).state.isCuffed
        local playerCuffType = Player(target).state.cuffType or "cuffs"

        if playerIsCuffed then
            TriggerClientEvent("ND_Police:uncuffPed", target)
            return QBCore.Functions.Notify(source, locale("toggled_cuffs_off"), 'success')
        end
        TriggerClientEvent("ND_Police:syncNormalCuff", target, "front", "cuffs")
        return QBCore.Functions.Notify(source, locale("toggled_cuffs_on"), 'success')
    end

    TriggerClientEvent('ps-adminmenu:client:ToggleCuffs', target)
    QBCore.Functions.Notify(source, locale("toggled_cuffs"), 'success')
end)

-- Give Clothing Menu
RegisterNetEvent('ps-adminmenu:server:ClothingMenu', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local src = source
    local target = tonumber(selectedData["Player"].value)

    if target == nil then
        return QBCore.Functions.Notify(src, locale("not_online"), 'error', 7500)
    end

    if target == src then
        TriggerClientEvent("ps-adminmenu:client:CloseUI", src)
    end

    TriggerClientEvent('qb-clothing:client:openMenu', target)
end)

-- Set Ped
RegisterNetEvent("ps-adminmenu:server:setPed", function(data, selectedData)
    local src = source
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then
        QBCore.Functions.Notify(src, locale("no_perms"), "error", 5000)
        return
    end

    local ped = selectedData["Ped Models"].label
    local tsrc = selectedData["Player"].value
    local Player = QBCore.Functions.GetPlayer(tsrc)

    if not Player then
        QBCore.Functions.Notify(locale("not_online"), "error", 5000)
        return
    end

    TriggerClientEvent("ps-adminmenu:client:setPed", Player.PlayerData.source, ped)
end)

-- Callback para listar todos os bans
lib.callback.register('ps-adminmenu:callback:GetBans', function(source)
    local bans = MySQL.query.await('SELECT * FROM bans') or {}
    return bans
end)

-- Desbanir por ID da linha
RegisterNetEvent('ps-adminmenu:server:unban_rowid', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local src = source
    local banId = selectedData["ban_id"] and tonumber(selectedData["ban_id"].value)
    if not banId then
        TriggerClientEvent('QBCore:Notify', src, "ID do banimento inválido.", "error", 5000)
        return
    end

    local affectedRows = MySQL.update.await('DELETE FROM bans WHERE id = ?', { banId })
    if affectedRows and affectedRows > 0 then
        TriggerClientEvent('QBCore:Notify', src, ("✅ Banimento removido com sucesso (ID %s)."):format(banId), "success", 5000)
        TriggerClientEvent('ps-adminmenu:client:RefreshBans', -1)
    else
        TriggerClientEvent('QBCore:Notify', src, "Nenhum banimento removido.", "error", 5000)
    end
end)
