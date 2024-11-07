local cargoStarted, cargoNetid, cargoStartedbyGang, startedCargoType, whereStarted = false, nil, nil, nil, nil
RegisterNetEvent('hz_cargo:boughtTicket')
AddEventHandler('hz_cargo:boughtTicket', function(size)
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if cargoStarted then
        xPlayer.showNotification('Yek drop dar hal hazer hast', 'error')
        return
    end
    if xPlayer.gang.name == 'nogang' then
        xPlayer.showNotification('Shoma gang nadarid', 'error')
        return
    end
    if xPlayer.getAccount('bank').money >= Config.LevelsPrice[size] then
        xPlayer.removeAccountMoney('bank', Config.LevelsPrice[size])
        TriggerClientEvent('hz_cargo:cargoStarted', xPlayer.source, size)
        cargoStarted = true
        cargoStartedbyGang = xPlayer.gang.name
        startedCargoType = size
        SetTimeout(5* 1000 * 60, function()
            local chance = math.random(1, 100)
            if chance > 50 then
                SendAlarmToGangs()
                local gang = exports['hz_gang']:GetGangWithName(cargoStartedbyGang)
                gang.triggerClientEventMembers('chat:addMessage', {
                    args = {'^1SYSTEM', 'Alarm baraye gang ha ferestade shod'}
                })
            elseif chance <= 50 and chance >= 30 then
                local gang = exports['hz_gang']:GetGangWithName(cargoStartedbyGang)
                gang.triggerClientEventMembers('chat:addMessage', {
                    args = {'^1SYSTEM', 'Alarm baraye police ha ferestade shod'}
                })
                SendAlarmToPolice()
            elseif chance < 30 then
                local gang = exports['hz_gang']:GetGangWithName(cargoStartedbyGang)
                gang.triggerClientEventMembers('chat:addMessage', {
                    args = {'^1SYSTEM', 'Alarm baraye kasi ferestade nashod'}
                })
            end
        end)
    else
        xPlayer.showNotification('Shoma pool kafi nadarid', 'error')
    end
end)

RegisterNetEvent('hz_cargo:cargoObject')
AddEventHandler('hz_cargo:cargoObject', function(netId)
    cargoNetid = netId
    CheckCargoObjectCoords()
    TriggerClientEvent('hz_cargo:cargoObject', -1, netId)
end)

RegisterNetEvent('hz_cargo:whereStarted')
AddEventHandler('hz_cargo:whereStarted', function(name)
    whereStarted = name
end)


AddEventHandler('hz_cargo:giveRewardToGang', function(gang)
    if gang == cargoStartedbyGang then
        Reward()
        ResetCargo()
    else
        local gang = exports['hz_gang']:GetGangWithName(gang)
        gang.sendMessageToMembers({'^1SYSTEM', 'In loot male shoma nabod :)'})
    end
end)

function SendAlarmToPolice()
    local players = ESX.GetPlayers()
    for k, v in pairs(players) do
        local xPlayer = ESX.GetPlayerFromId(v)
        if xPlayer then
            if xPlayer.job.name == 'police' then
                TriggerClientEvent('chat:addMessage', xPlayer.source, {
                    args = { '^1SYSTEM', 'Yek cargo dar hal drop ast dar manteghe' ..whereStarted }
                })
            end
        end
    end
end

function SendAlarmToGangs()
    local gangs = exports['hz_gang']:getGangs()
    for k, v in pairs(gangs) do
        if k ~= cargoStartedbyGang then
            v.sendMessageToMembers({'^1SYSTEM', 'Yek cargo dar hal drop ast dar mantaghe '..whereStarted})
        end
    end
end

function ResetCargo()
    cargoStarted, cargoNetid, cargoStartedbyGang, startedCargoType, whereStarted = false, nil, nil, nil, nil
end

function Reward()
    local gang = exports['hz_gang']:GetGangWithName(cargoStartedbyGang)
    gang.triggerClientEventMembers('chat:addMessage', {
        args = {'^1SYSTEM', 'Reward cargo be gang shoma dade shod! (' .. startedCargoType .. ')'}
    })
    for k, v in pairs(Config.Items[startedCargoType]) do
        exports.ox_inventory:AddItem(cargoStartedbyGang, v.name, v.length)
    end
end

function CheckCargoObjectCoords()
    local object = NetworkGetEntityFromNetworkId(cargoNetid)
    local gangs = exports['hz_gang']:getGangs()
    Citizen.CreateThread(function()
        while true do
            local coords = GetEntityCoords(object)
            for k, v in pairs(gangs) do
                if next(v.positions.blipPos) ~= nil then
                    if #(vector3(v.positions.blipPos.x, v.positions.blipPos.y, v.positions.blipPos.z) - coords) < 30.0 then
                        TriggerEvent('hz_cargo:giveRewardToGang', k)
                        DeleteEntity(object)
                        break
                    end
                end
            end
            Wait(5000)
        end
    end)
end
