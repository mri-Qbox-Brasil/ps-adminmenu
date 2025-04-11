QBCore = exports["qb-core"]:GetCoreObject()

lib.callback.register(
    "ps-adminmenu:callback:GetServerInfo",
    function(source, cb)
        local totalCash, totalBank, totalCrypto = 0, 0, 0
        local vehicleCount = MySQL.scalar.await("SELECT COUNT(1) FROM player_vehicles") or 0
        local bansCount = MySQL.scalar.await("SELECT COUNT(1) FROM bans") or 0
        local characterCount = MySQL.scalar.await("SELECT COUNT(1) FROM players") or 0

        local playerMoneyData = MySQL.query.await(
            [[
            select
                sum(JSON_UNQUOTE(JSON_EXTRACT(money, '$.cash'))) as cash,
                sum(JSON_UNQUOTE(JSON_EXTRACT(money, '$.bank'))) as bank,
                sum(JSON_UNQUOTE(JSON_EXTRACT(money, '$.crypto'))) as crypto
            from
                players
            ]]
        )
        totalCash = playerMoneyData[1].cash or 0
        totalBank = playerMoneyData[1].bank or 0
        totalCrypto = playerMoneyData[1].crypto or 0

        local players =
            MySQL.query.await(
            [[
        select sum(qtd) as qtd from (select count(1) as qtd from players group by license) as b
    ]]
        )

        local serverInfo = {
            totalCash = totalCash,
            totalBank = totalBank,
            totalCrypto = totalCrypto,
            uniquePlayers = players[1].qtd or 0,
            vehicleCount = vehicleCount,
            bansCount = bansCount,
            characterCount = characterCount
        }

        return serverInfo
    end
)
