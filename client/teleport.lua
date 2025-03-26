local lastCoords

local function teleport(x, y, z)
    if cache.vehicle then
        return SetPedCoordsKeepVehicle(cache.ped, x, y, z)
    end

    SetEntityCoords(cache.ped, x, y, z, false, false, false, false)
end

-- Teleport to player
RegisterNetEvent('ps-adminmenu:client:TeleportToPlayer', function(coords)
    lastCoords = GetEntityCoords(cache.ped)
    SetPedCoordsKeepVehicle(cache.ped, coords.x, coords.y, coords.z)
end)

-- Teleport to coords
RegisterNetEvent('ps-adminmenu:client:TeleportToCoords', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(data.perms) then return end

    local coordsData = selectedData["Coordenadas"]
    if not coordsData or not coordsData['value'] then return end

    local coordsStr = tostring(coordsData.value)
    local x, y, z, heading

    local matches = { coordsStr:match("^%s*(-?[%d%.]+),%s*(-?[%d%.]+),%s*(-?[%d%.]+),?%s*(-?[%d%.]*)%s*$") }

    if matches and #matches >= 3 then
        x, y, z, heading = tonumber(matches[1]), tonumber(matches[2]), tonumber(matches[3]), tonumber(matches[4] or 0)
    end

    if not x or not y or not z then return end

    lastCoords = GetEntityCoords(cache.ped)
    SetPedCoordsKeepVehicle(cache.ped, x, y, z)

    if heading and heading ~= 0 then
        SetEntityHeading(cache.ped, heading)
    end
end)

-- Teleport to Locaton
RegisterNetEvent('ps-adminmenu:client:TeleportToLocation', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(data.perms) then return end
    local coords = selectedData["Location"].value

    lastCoords = GetEntityCoords(cache.ped)
    SetPedCoordsKeepVehicle(cache.ped, coords.x, coords.y, coords.z)
end)

-- Teleport back
RegisterNetEvent('ps-adminmenu:client:TeleportBack', function(data)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(data.perms) then return end

    if lastCoords then
        local coords = GetEntityCoords(cache.ped)
        teleport(lastCoords.x, lastCoords.y, lastCoords.z)
        lastCoords = coords
    end
end)
