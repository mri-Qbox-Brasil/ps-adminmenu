local function getVehicles(cid)
    local result = MySQL.query.await(
        'SELECT vehicle, plate, fuel, engine, body FROM player_vehicles WHERE citizenid = ?', { cid }
    )
    local vehicles = {}

    for k, v in pairs(result) do
        local vehicleData = QBCore.Shared.Vehicles[v.vehicle]

        if not vehicleData then
            vehicleData = {
                name = ("Veículo Desconhecido (%s)"):format(v.vehicle or "N/A"),
                brand = "N/A",
                model = v.vehicle or "N/A"
            }
        end

        vehicles[#vehicles + 1] = {
            id = k,
            cid = cid,
            label = vehicleData.name,
            brand = vehicleData.brand,
            model = vehicleData.model,
            plate = v.plate,
            fuel = v.fuel,
            engine = v.engine,
            body = v.body
        }
    end

    return vehicles
end

local function getPlayers()
    local players = {}
    local GetPlayers = QBCore.Functions.GetQBPlayers()

    local allJobs
    if GetResourceState('qbx_core') == 'started' then allJobs = exports.qbx_core:GetJobs() else allJobs = QBCore.Shared.Jobs end

    local allGangs
    if GetResourceState('qbx_core') == 'started' then allGangs = exports.qbx_core:GetGangs() else allGangs = QBCore.Shared.Gangs end

    for k, v in pairs(GetPlayers) do
        local playerData = v.PlayerData
        local vehicles = getVehicles(playerData.citizenid)

        players[#players + 1] = {
            id = k,
            name = playerData.charinfo.firstname .. ' ' .. playerData.charinfo.lastname,
            cid = playerData.citizenid,
            license = QBCore.Functions.GetIdentifier(k, 'license'),
            discord = QBCore.Functions.GetIdentifier(k, 'discord'),
            steam = QBCore.Functions.GetIdentifier(k, 'steam'),
            job = playerData.job.label,
            job_grade = playerData.job.grade.name or "Desconhecido",
            gang = playerData.gang.label,
            gang_grade = playerData.gang.grade.name or "Desconhecido",
            dob = playerData.charinfo.birthdate,
            cash = playerData.money.cash,
            bank = playerData.money.bank,
            crypto = playerData.money.crypto,
            phone = playerData.charinfo.phone,
            vehicles = vehicles,
            metadata = playerData.metadata,
            online = true
        }
    end

    local result = MySQL.Sync.fetchAll("SELECT * FROM players")
    for _, player in ipairs(result) do
        local isOnline = false

        for _, onlinePlayer in ipairs(players) do
            if onlinePlayer.cid == player.citizenid then
                isOnline = true
                break
            end
        end

        if not isOnline then
            local vehicles = getVehicles(player.citizenid)

            local charinfo = json.decode(player.charinfo) or {}
            local jobinfo = json.decode(player.job) or {}
            local ganginfo = json.decode(player.gang) or {}
            local moneyinfo = player.money and json.decode(player.money) or {}

            local job_label = (jobinfo.name and allJobs[jobinfo.name] and allJobs[jobinfo.name].label) or "Desempregado"
            local job_grade = "Desconhecido"

            if jobinfo.name and allJobs[jobinfo.name] and jobinfo.grade then
                if type(jobinfo.grade) == "table" then
                    job_grade = jobinfo.grade.name or "Desconhecido"
                else
                    local gradeKey = tostring(jobinfo.grade)
                    local gradeData = allJobs[jobinfo.name].grades[gradeKey]
                    job_grade = gradeData and gradeData.name or "Desconhecido"
                end
            end

            local gang_label = (ganginfo.name and allGangs[ganginfo.name] and allGangs[ganginfo.name].label) or "Sem filiação"
            local gang_grade = "Desconhecido"

            if ganginfo.name and allGangs[ganginfo.name] and ganginfo.grade then
                if type(ganginfo.grade) == "table" then
                    gang_grade = ganginfo.grade.name or "Desconhecido"
                else
                    local gradeKey = tostring(ganginfo.grade)
                    local gradeData = allGangs[ganginfo.name].grades[gradeKey]
                    gang_grade = gradeData and gradeData.name or "Desconhecido"
                end
            end

            players[#players + 1] = {
                id = nil,
                name = (charinfo.firstname or "N/A") .. ' ' .. (charinfo.lastname or ""),
                cid = player.citizenid,
                license = player.license,
                discord = nil,
                steam = nil,
                job = job_label,
                job_grade = job_grade,
                gang = gang_label,
                gang_grade = gang_grade,
                dob = charinfo.birthdate or "Desconhecido",
                cash = moneyinfo.cash or 0,
                crypto = moneyinfo.crypto or 0,
                bank = moneyinfo.bank or 0,
                phone = charinfo.phone or "Desconhecido",
                vehicles = vehicles,
                metadata = player.metadata,
                online = false
            }
        end
    end

    table.sort(players, function(a, b)
        if a.online == b.online then
            return a.name < b.name
        end
        return a.online and not b.online
    end)

    return players
end

lib.callback.register('ps-adminmenu:callback:GetPlayers', function(source)
    return getPlayers()
end)

RegisterNetEvent('ps-adminmenu:server:SetJob', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end
    local src = source

    local playerId, Job, Grade = selectedData["Player"].value, selectedData["Job"].value, selectedData["Grade"].value
    local Player = QBCore.Functions.GetPlayer(tonumber(playerId))
    if not Player then
        print(playerId)
        Player = QBCore.Functions.GetOfflinePlayerByCitizenId(playerId)
        if not Player then
            TriggerClientEvent('QBCore:Notify', src, 'Jogador offline não encontrado.', 'error')
            return
        end
    end
    local name, citizenid, jobInfo, grade

    local JOBS
    if GetResourceState('qbx_core') == 'started' then JOBS = exports.qbx_core:GetJobs() else JOBS = QBCore.Shared.Jobs end
    jobInfo = JOBS[Job]
    if not jobInfo then
        TriggerClientEvent('QBCore:Notify', src, 'Trabalho inválido.', 'error')
        return
    end

    for searchgrade, info in pairs(jobInfo["grades"]) do
        if tonumber(searchgrade) == tonumber(Grade) then
            grade = info
            break
        end
    end

    if not grade then
        TriggerClientEvent('QBCore:Notify', src, 'Cargo inválido.', 'error')
        return
    end

    if Player then
        name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
        citizenid = Player.PlayerData.citizenid

        if GetResourceState('qbx_core') == 'started' then
            exports.qbx_core:SetJob(tostring(citizenid), tostring(Job), tonumber(Grade))
        else
            Player.Functions.SetJob(tostring(Job), tonumber(Grade))
            Player.Functions.Save()
        end

        if Config.RenewedPhone then
            exports['qb-phone']:hireUser(tostring(Job), citizenid, tonumber(Grade))
        end

        QBCore.Functions.Notify(src, locale("jobset", name, Job, grade.name), 'success', 5000)
    end
end)


-- Set Gang
RegisterNetEvent('ps-adminmenu:server:SetGang', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end
    local src = source

    local playerId, Gang, Grade = selectedData["Player"].value, selectedData["Gang"].value, selectedData["Grade"].value
    local Player = QBCore.Functions.GetPlayer(tonumber(playerId))
    if not Player then
        Player = QBCore.Functions.GetOfflinePlayerByCitizenId(playerId)
        if not Player then
            TriggerClientEvent('QBCore:Notify', src, 'Jogador offline não encontrado.', 'error')
            return
        end
    end
    local name, citizenid, GangInfo, grade

    local GANGS
    if GetResourceState('qbx_core') == 'started' then GANGS = exports.qbx_core:GetGangs() else GANGS = QBCore.Shared.Gangs end
    GangInfo = GANGS[Gang]
    if not GangInfo then
        TriggerClientEvent('QBCore:Notify', src, 'Gangue inválida.', 'error')
        return
    end

    for searchgrade, info in pairs(GangInfo["grades"]) do
        if tonumber(searchgrade) == tonumber(Grade) then
            grade = info
            break
        end
    end

    if not grade then
        TriggerClientEvent('QBCore:Notify', src, 'Cargo inválido.', 'error')
        return
    end

    if Player then
        name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
        citizenid = Player.PlayerData.citizenid

        if GetResourceState('qbx_core') == 'started' then
            exports.qbx_core:SetGang(tostring(citizenid), tostring(Gang), tonumber(Grade))
        else
            Player.Functions.SetGang(tostring(Gang), tonumber(Grade))
            Player.Functions.Save()
        end

        QBCore.Functions.Notify(src, locale("gangset", name, Gang, grade.name), 'success', 5000)
    end
end)


-- Set Perms
RegisterNetEvent("ps-adminmenu:server:SetPerms", function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end
    local src = source
    local rank = selectedData["Permissions"].value
    local targetId = selectedData["Player"].value
    local tPlayer = QBCore.Functions.GetPlayer(tonumber(targetId))

    if not tPlayer then
        QBCore.Functions.Notify(src, locale("not_online"), "error", 5000)
        return
    end

    local name = tPlayer.PlayerData.charinfo.firstname .. ' ' .. tPlayer.PlayerData.charinfo.lastname

    QBCore.Functions.AddPermission(tPlayer.PlayerData.source, tostring(rank))
    QBCore.Functions.Notify(tPlayer.PlayerData.source, locale("player_perms", name, rank), 'success', 5000)
end)

-- Remove Stress
RegisterNetEvent("ps-adminmenu:server:RemoveStress", function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end
    local src = source
    local targetId = selectedData['Player (Optional)'] and tonumber(selectedData['Player (Optional)'].value) or src
    local tPlayer = QBCore.Functions.GetPlayer(tonumber(targetId))

    if not tPlayer then
        QBCore.Functions.Notify(src, locale("not_online"), "error", 5000)
        return
    end

    TriggerClientEvent('ps-adminmenu:client:removeStress', targetId)

    QBCore.Functions.Notify(tPlayer.PlayerData.source, locale("removed_stress_player"), 'success', 5000)
end)
