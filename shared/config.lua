Config = Config or {}

Config.Fuel = "cdn-fuel"        -- "ps-fuel", "LegacyFuel", "ox_fuel"
Config.ResourcePerms = 'admin' -- permission to control resource(start stop restart)
Config.ShowCommandsPerms = 'admin' -- permission to show all commands
Config.OpenPanelPerms = { 'admin', 'mod', 'support' }
Config.RenewedPhone = false    -- if you use qb-phone from renewed. (multijob)

-- Key Bindings
Config.Keybindings = true
Config.AdminKey = "0"
Config.NoclipKey = "9"

-- Give Car
Config.DefaultGarage = "Pillbox Garage Parking"

Config.Actions = {
    ["admin_car"] = {
        label = "/admincar",
        type = "client",
        event = "ps-adminmenu:client:Admincar",
        perms = "mod",
    },

    ["ban_player"] = {
        label = "Banir Jogador",
        perms = "mod",
        dropdown = {
            { label = "Player", option = "dropdown", data = "players" },
            { label = "Reason", option = "text" },
            {
                label = "Duração",
                option = "dropdown",
                data = {
                    { label = "Permanente",  value = "2147483647" },
                    { label = "10 Minutos", value = "600" },
                    { label = "30 Minutos", value = "1800" },
                    { label = "1 Hora",     value = "3600" },
                    { label = "6 Horas",    value = "21600" },
                    { label = "12 Horas",   value = "43200" },
                    { label = "1 Dia",      value = "86400" },
                    { label = "3 Dias",     value = "259200" },
                    { label = "1 Semana",   value = "604800" },
                    { label = "3 Semanas",  value = "1814400" },
                },
            },
            { label = "Confirmar", option = "button", type = "server", event = "ps-adminmenu:server:BanPlayer" },
        },
    },

    ["bring_player"] = {
        label = "Puxar Jogador",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirmar", option = "button",   type = "server", event = "ps-adminmenu:server:BringPlayer" },
        },
    },

    ["change_weather"] = {
        label = "Alterar Clima",
        perms = "mod",
        dropdown = {
            {
                label = "Weather",
                option = "dropdown",
                data = {
                    { label = "Extraensolarado", value = "Extrasunny" },
                    { label = "Limpo",      value = "Clear" },
                    { label = "Neutro",     value = "Neutral" },
                    { label = "Nevoeiro",   value = "Smog" },
                    { label = "Neblina",    value = "Foggy" },
                    { label = "Nublado",    value = "Overcast" },
                    { label = "Nuvens",     value = "Clouds" },
                    { label = "Limpeza",    value = "Clearing" },
                    { label = "Chuva",      value = "Rain" },
                    { label = "Trovão",     value = "Thunder" },
                    { label = "Neve",       value = "Snow" },
                    { label = "Tempestade de Neve", value = "Blizzard" },
                    { label = "Neve Leve",  value = "Snowlight" },
                    { label = "Natal",      value = "Xmas" },
                    { label = "Halloween",  value = "Halloween" },
                },
            },
            { label = "Confirmar", option = "button", type = "client", event = "ps-adminmenu:client:ChangeWeather" },
        },
    },

    ["change_time"] = {
        label = "Alterar Horário",
        perms = "mod",
        dropdown = {
            {
                label = "Time Events",
                option = "dropdown",
                data = {
                    { label = "Amanhecer", value = "06" },
                    { label = "Manhã", value = "09" },
                    { label = "Meio-dia",    value = "12" },
                    { label = "Pôr do Sol",  value = "21" },
                    { label = "Entardecer", value = "22" },
                    { label = "Noite",   value = "24" },
                },
            },
            { label = "Confirmar", option = "button", type = "client", event = "ps-adminmenu:client:ChangeTime" },
        },
    },

    ["change_plate"] = {
        label = "Alterar Placa",
        perms = "mod",
        dropdown = {
            { label = "Plate",   option = "text" },
            { label = "Confirmar", option = "button", type = "client", event = "ps-adminmenu:client:ChangePlate" },
        },
    },

    ["clear_inventory"] = {
        label = "Limpar Inventário",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirmar", option = "button",   type = "server", event = "ps-adminmenu:server:ClearInventory" },
        },
    },

    ["clear_inventory_offline"] = {
        label = "Limpar Inventário Offline",
        perms = "mod",
        dropdown = {
            { label = "Citizen ID", option = "text",   data = "players" },
            { label = "Confirmar",    option = "button", type = "server", event = "ps-adminmenu:server:ClearInventoryOffline" },
        },
    },

    ["clothing_menu"] = {
        label = "Dar Menu de Roupas",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirmar", option = "button",   type = "server", event = "ps-adminmenu:server:ClothingMenu" },
        },
    },

    ["set_ped"] = {
        label = "Definir Ped",
        perms = "mod",
        dropdown = {
            { label = "Player",     option = "dropdown", data = "players" },
            { label = "Ped Models", option = "dropdown", data = "pedlist" },
            { label = "Confirmar",    option = "button",   type = "server", event = "ps-adminmenu:server:setPed" },
        },
    },

    ["copy_coords"] = {
        label = "Copiar Coordenadas",
        perms = "mod",
        dropdown = {
            {
                label = "Copy Coords",
                option = "dropdown",
                data = {
                    { label = "Copiar Vector2", value = "vector2" },
                    { label = "Copiar Vector3", value = "vector3" },
                    { label = "Copiar Vector4", value = "vector4" },
                    { label = "Copiar Direção", value = "heading" },
                },
            },
            { label = "Copiar para Área de Transferência", option = "button", type = "client", event = "ps-adminmenu:client:copyToClipboard"},
        },
    },

    ["delete_vehicle"] = {
        label = "Deletar Veículo",
        type = "command",
        event = "dv",
        perms = "mod",
    },

    ["freeze_player"] = {
        label = "Congelar Jogador",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirmar", option = "button",   type = "server", event = "ps-adminmenu:server:FreezePlayer" },
        },
    },
    
    ["kill_player"] = {
        label = "Matar Jogador",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirmar", option = "button",   type = "client", event = "ps-adminmenu:client:KillPlayer" },
        },
    },

    ["drunk_player"] = {
        label = "Deixar Jogador Bêbado",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirmar", option = "button",   type = "server", event = "ps-adminmenu:server:DrunkPlayer" },
        },
    },

    ["remove_stress"] = {
        label = "Remover Estresse",
        perms = "mod",
        dropdown = {
            { label = "Jogador (Opcional)", option = "dropdown", data = "players" },
            { label = "Confirmar",           option = "button",   type = "server", event = "ps-adminmenu:server:RemoveStress" },
        },
    },

    ["set_ammo"] = {
        label = "Definir Munição",
        perms = "mod",
        dropdown = {
            { label = "Quantidade de Munição", option = "text" },
            { label = "Confirmar",      option = "button", type = "client", event = "ps-adminmenu:client:SetAmmo" },
        },
    },

    ["god_mode"] = {
        label = "Modo Deus",
        type = "client",
        event = "ps-adminmenu:client:ToggleGodmode",
        perms = "mod",
    },

    ["give_car"] = {
        label = "Dar Carro",
        perms = "mod",
        dropdown = {
            { label = "Vehicle",           option = "dropdown", data = "vehicles" },
            { label = "Player",            option = "dropdown", data = "players" },
            { label = "Placa (Opcional)",  option = "text" },
            { label = "Garagem (Opcional)", option = "text" },
            { label = "Confirmar",           option = "button",   type = "server",  event = "ps-adminmenu:server:givecar" },
        }
    },

    ["invisible"] = {
        label = "Invisível",
        type = "client",
        event = "ps-adminmenu:client:ToggleInvisible",
        perms = "mod",
    },

    ["blackout"] = {
        label = "Ativar/Desativar Queda de Energia",
        type = "server",
        event = "ps-adminmenu:server:ToggleBlackout",
        perms = "mod",
    },

    ["toggle_duty"] = {
        label = "Ativar/Desativar Serviço",
        type = "server",
        event = "QBCore:ToggleDuty",
        perms = "mod",
    },

    ["toggle_laser"] = {
        label = "Ativar/Desativar Laser",
        type = "client",
        event = "ps-adminmenu:client:ToggleLaser",
        perms = "mod",
    },

    -- ["set_perms"] = {
    --     label = "Definir Permissões",
    --     perms = "mod",
    --     dropdown = {
    --         { label = "Player",  option = "dropdown", data = "players" },
    --         {
    --             label = "Permissões",
    --             option = "dropdown",
    --             data = {
    --                 { label = "Moderador", value = "mod" },
    --                 { label = "Administrador", value = "admin" },
    --                 { label = "Deus", value = "god" },
    --             },
    --         },
    --         { label = "Confirmar", option = "button",   type = "server", event = "ps-adminmenu:server:SetPerms" },
    --     },
    -- },

    ["set_bucket"] = {
        label = "Definir Bucket de Roteamento",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Bucket",  option = "text" },
            { label = "Confirmar", option = "button",   type = "server", event = "ps-adminmenu:server:SetBucket" },
        },
    },

    ["get_bucket"] = {
        label = "Obter Bucket de Roteamento",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirmar", option = "button",   type = "server", event = "ps-adminmenu:server:GetBucket" },
        },
    },

    ["mute_player"] = {
        label = "Silenciar Jogador",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirmar", option = "button",   type = "client", event = "ps-adminmenu:client:MutePlayer" },
        },
    },

    ["noclip"] = {
        label = "Noclip",
        type = "client",
        event = "ps-adminmenu:client:ToggleNoClip",
        perms = "mod",
    },

    ["open_inventory"] = {
        label = "Abrir Inventário",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirmar", option = "button",   type = "client", event = "ps-adminmenu:client:openInventory" },
        },
    },

    ["open_stash"] = {
        label = "Abrir Depósito",
        perms = "mod",
        dropdown = {
            { label = "Stash",   option = "text" },
            { label = "Confirmar", option = "button", type = "client", event = "ps-adminmenu:client:openStash" },
        },
    },

    ["open_trunk"] = {
        label = "Abrir Porta-malas",
        perms = "mod",
        dropdown = {
            { label = "Plate",   option = "text" },
            { label = "Confirmar", option = "button", type = "client", event = "ps-adminmenu:client:openTrunk" },
        },
    },

    ["change_vehicle_state"] = {
        label = "Definir Estado do Veículo na Garagem",
        perms = "mod",
        dropdown = {
            { label = "Plate",   option = "text" },
            {
                label = "Estado",
                option = "dropdown",
                data = {
                    { label = "Dentro",  value = "1" },
                    { label = "Fora", value = "0" },
                },
            },
            { label = "Confirmar", option = "button", type = "server", event = "ps-adminmenu:server:SetVehicleState" },
        },
    },

    ["revive_all"] = {
        label = "Reviver Todos",
        type = "server",
        event = "ps-adminmenu:server:ReviveAll",
        perms = "mod",
    },

    ["revive_player"] = {
        label = "Reviver Jogador",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirmar", option = "button",   type = "server", event = "ps-adminmenu:server:Revive" },
        },
    },

    ["revive_radius"] = {
        label = "Reviver Raio",
        type = "server",
        event = "ps-adminmenu:server:ReviveRadius",
        perms = "mod",
    },

    ["refuel_vehicle"] = {
        label = "Reabastecer Veículo",
        type = "client",
        event = "ps-adminmenu:client:RefuelVehicle",
        perms = "mod",
    },

    ["set_job"] = {
        label = "Definir Emprego",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Job", option = "dropdown", data = "jobs" },
            { label = "Confirmar", option = "button",   type = "client", event = "ps-adminmenu:client:SetJob" },
        },
    },

    ["fire_job"] = {
        label = "Demitir do Emprego",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            {    
                label = "Job",
                option = "dropdown",
                data = {
                    { label = "Desempregado",      value = "unemployed" },
                },
            },
            {    
                label = "Grade",
                option = "dropdown",
                data = {
                    { label = "Civil",      value = 0 },
                },
            },
            { label = "Confirmar", option = "button",   type = "server", event = "ps-adminmenu:server:SetJob" },
        },
    },

    ["fire_gang"] = {
        label = "Demitir da Gangue",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            {    
                label = "Gang",
                option = "dropdown",
                data = {
                    { label = "Sem gangue",      value = "none" },
                },
            },
            {    
                label = "Grade",
                option = "dropdown",
                data = {
                    { label = "Civil",      value = 0 },
                },
            },
            { label = "Confirmar", option = "button",   type = "server", event = "ps-adminmenu:server:SetGang" },
        },
    },

    ["set_gang"] = {
        label = "Definir Gangue",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Gang",    option = "dropdown", data = "gangs" },
            { label = "Confirmar", option = "button",   type = "client", event = "ps-adminmenu:client:SetGang" },
        },
    },

    ["give_money"] = {
        label = "Dar Dinheiro",
        perms = "mod",
        dropdown = {
            { label = "Player", option = "dropdown", data = "players" },
            { label = "Amount", option = "text" },
            {
                label = "Type",
                option = "dropdown",
                data = {
                    { label = "Dinheiro",   value = "cash" },
                    { label = "Banco",   value = "bank" },
                    { label = "Cripto", value = "crypto" },
                },
            },
            { label = "Confirmar", option = "button", type = "server", event = "ps-adminmenu:server:GiveMoney" },
        },
    },

    ["give_money_all"] = {
        label = "Dar Dinheiro para Todos",
        perms = "mod",
        dropdown = {
            { label = "Amount",  option = "text" },
            {
                label = "Type",
                option = "dropdown",
                data = {
                    { label = "Dinheiro",   value = "cash" },
                    { label = "Banco",   value = "bank" },
                    { label = "Cripto", value = "crypto" },
                },
            },
            { label = "Confirmar", option = "button", type = "server", event = "ps-adminmenu:server:GiveMoneyAll" },
        },
    },

    ["remove_money"] = {
        label = "Remover Dinheiro",
        perms = "mod",
        dropdown = {
            { label = "Player", option = "dropdown", data = "players" },
            { label = "Amount", option = "text" },
            {
                label = "Type",
                option = "dropdown",
                data = {
                    { label = "Dinheiro", value = "cash" },
                    { label = "Banco", value = "bank" },
                },
            },
            { label = "Confirmar", option = "button", type = "server", event = "ps-adminmenu:server:TakeMoney" },
        },
    },

    ["give_item"] = {
        label = "Dar Item",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Item",    option = "dropdown", data = "items" },
            { label = "Amount",  option = "text" },
            { label = "Confirmar", option = "button",   type = "server", event = "ps-adminmenu:server:GiveItem" },
        },
    },

    ["give_item_all"] = {
        label = "Dar Item para Todos",
        perms = "mod",
        dropdown = {
            { label = "Item",    option = "dropdown", data = "items" },
            { label = "Amount",  option = "text" },
            { label = "Confirmar", option = "button",   type = "server", event = "ps-adminmenu:server:GiveItemAll" },
        },
    },

    ["spawn_vehicle"] = {
        label = "Gerar Veículo",
        perms = "mod",
        dropdown = {
            { label = "Vehicle", option = "dropdown", data = "vehicles" },
            { label = "Confirmar", option = "button",   type = "client",  event = "ps-adminmenu:client:SpawnVehicle" },
        },
    },

    ["fix_vehicle"] = {
        label = "Consertar Veículo",
        type = "command",
        event = "fix",
        perms = "mod",
    },

    ["fix_vehicle_for"] = {
        label = "Consertar Veículo para jogador",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirmar", option = "button",   type = "server", event = "ps-adminmenu:server:FixVehFor" },
        },
    },

    ["spectate_player"] = {
        label = "Espectar Jogador",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirmar", option = "button",   type = "server", event = "ps-adminmenu:server:SpectateTarget" },
        },
    },

    ["telport_to_player"] = {
        label = "Teleportar para Jogador",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirmar", option = "button",   type = "server", event = "ps-adminmenu:server:TeleportToPlayer" },
        },
    },

    ["telport_to_coords"] = {
        label = "Teleportar para Coordenadas",
        perms = "mod",
        dropdown = {
            { label = "Coordenadas",  option = "text" },
            { label = "Confirmar", option = "button", type = "client", event = "ps-adminmenu:client:TeleportToCoords" },
        },
    },

    ["teleport_to_location"] = {
        label = "Teleportar para Localização",
        perms = "mod",
        dropdown = {
            { label = "Location", option = "dropdown", data = "locations" },
            { label = "Confirmar",  option = "button",   type = "client",   event = "ps-adminmenu:client:TeleportToLocation" },
        },
    },

    ["teleport_to_marker"] = {
        label = "Teleportar para Marcador",
        type = "command",
        event = "tpm",
        perms = "mod",
    },

    ["teleport_back"] = {
        label = "Teleportar de Volta",
        type = "client",
        event = "ps-adminmenu:client:TeleportBack",
        perms = "mod",
    },

    ["vehicle_dev"] = {
        label = "Menu de Desenvolvimento de Veículos",
        type = "client",
        event = "ps-adminmenu:client:ToggleVehDevMenu",
        perms = "mod",
    },

    ["toggle_coords"] = {
        label = "Ativar/Desativar Coordenadas",
        type = "client",
        event = "ps-adminmenu:client:ToggleCoords",
        perms = "mod",
    },

    ["toggle_blips"] = {
        label = "Ativar/Desativar Blips",
        type = "client",
        event = "ps-adminmenu:client:toggleBlips",
        perms = "mod",
    },

    ["toggle_names"] = {
        label = "Ativar/Desativar Nomes",
        type = "client",
        event = "ps-adminmenu:client:toggleNames",
        perms = "mod",
    },

    ["toggle_cuffs"] = {
        label = "Ativar/Desativar Algemas",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirmar", option = "button",   type = "server", event = "ps-adminmenu:server:CuffPlayer" },
        },
    },

    ["max_mods"] = {
        label = "Maximizar Mods do Veículo",
        type = "client",
        event = "ps-adminmenu:client:maxmodVehicle",
        perms = "mod",
    },

    ["warn_player"] = {
        label = "Alertar Jogador",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Reason",  option = "text" },
            { label = "Confirmar", option = "button",   type = "server", event = "ps-adminmenu:server:WarnPlayer" },
        },
    },

    ["infinite_ammo"] = {
        label = "Munição Infinita",
        type = "client",
        event = "ps-adminmenu:client:setInfiniteAmmo",
        perms = "mod",
    },

    ["kick_player"] = {
        label = "Expulsar Jogador",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Reason",  option = "text" },
            { label = "Confirmar", option = "button",   type = "server", event = "ps-adminmenu:server:KickPlayer" },
        },
    },

    ["play_sound"] = {
        label = "Tocar Som",
        perms = "mod",
        dropdown = {
            { label = "Player",     option = "dropdown", data = "players" },
            {
                label = "Sound",
                option = "dropdown",
                data = {
                    { label = "Alerta",      value = "alert" },
                    { label = "Algema",       value = "cuff" },
                    { label = "Chave de Ar", value = "airwrench" },
                },
            },
            { label = "Tocar Som", option = "button",   type = "client", event = "ps-adminmenu:client:PlaySound" },
        },
    },

    ["unbanPlayer"] = {
        label = "Desbanir Jogador",
        event = "ps-adminmenu:server:UnbanPlayer",
        perms = "mod",
        type = "server"
    }
}

Config.PlayerActions = {
    ["teleportToPlayer"] = {
        label = "Teleportar",
        type = "server",
        event = "ps-adminmenu:server:TeleportToPlayer",
        perms = "mod",
    },
    ["bringPlayer"] = {
        label = "Puxar",
        type = "server",
        event = "ps-adminmenu:server:BringPlayer",
        perms = "mod",
    },
    ["sendPlayerBack"] = {
        label = "Enviar de Volta",
        type = "server",
        event = "ps-adminmenu:server:SendPlayerBack",
        perms = "mod",
    },
    ["revivePlayer"] = {
        label = "Reviver",
        event = "ps-adminmenu:server:Revive",
        perms = "mod",
        type = "server"
    },
    ["verifyPlayer"] = {
        label = "Verificar Jogador",
        event = "ps-adminmenu:server:verifyPlayer",
        perms = "mod",
        type = "server"
    },
    ["givePlayerMoney"] = {
        label = "Dar Dinheiro",
        event = "ps-adminmenu:server:givePlayerMoney",
        perms = "mod",
        type = "server"
    },
    ["removePlayerMoney"] = {
        label = "Remover Dinheiro",
        event = "ps-adminmenu:server:removePlayerMoney",
        perms = "mod",
        type = "server"
    },
    ["clothesMenu"] = {
        label = "Remover Dinheiro",
        event = "ps-adminmenu:server:clothesMenu",
        perms = "mod",
        type = "server"
    },
    ["spawnPersonalVehicle"] = {
        label = "Gerar Veículo Pessoal",
        event = "ps-adminmenu:client:SpawnPersonalVehicle",
        perms = "mod",
        type = "client"
    },
    ["deletePersonalVehicle"] = {
        label = "Deletar Veículo Pessoal",
        event = "ps-adminmenu:server:DeleteVehicleByPlate",
        perms = "mod",
        type = "server"
    },
    ["banPlayer"] = {
        label = "Banir Jogador",
        event = "ps-adminmenu:server:BanPlayer",
        perms = "mod",
        type = "server"
    },
    ["kickPlayer"] = {
        label = "Expulsar Jogador",
        event = "ps-adminmenu:server:KickPlayer",
        perms = "mod",
        type = "server"
    },
    ["unban_cid"] = {
        label = "Banir Jogador",
        event = "ps-adminmenu:server:unban_cid",
        perms = "mod",
        type = "server"
    },
    ["delete_cid"] = {
        label = "Excluir Jogador",
        event = "ps-adminmenu:server:delete_cid",
        perms = "mod",
        type = "server"
    },
    ["unban_rowid"] = {
        label = "Desbanir Jogador",
        event = "ps-adminmenu:server:unban_rowid",
        perms = "mod",
        type = "server"
    },
}

Config.OtherActions = {
    ["toggleDevmode"] = {
        type = "client",
        event = "ps-adminmenu:client:ToggleDev",
        perms = "mod",
        label = "Ativar/Desativar Modo Desenvolvedor"
    }
}

AddEventHandler("onResourceStart", function()
    Wait(100)
    if GetResourceState('ox_inventory') == 'started' then
        Config.Inventory = 'ox_inventory'
    elseif GetResourceState('ps-inventory') == 'started' then
        Config.Inventory = 'ps-inventory'
    elseif GetResourceState('lj-inventory') == 'started' then
        Config.Inventory = 'lj-inventory'
    elseif GetResourceState('qb-inventory') == 'started' then
        Config.Inventory = 'qb-inventory'
    end
end)
