local cargoObject
local npc 
Citizen.CreateThread(function()
    CreateNPC(Config.NPCLocation)
    AddTargetNPC()
end)




function OpenMenu()
    local elements = {
        { label = 'Order Cargo Size Small ($' .. Config.LevelsPrice['Small'] .. ')', name = '', size = 'Small' },
        { label = 'Order Cargo Size Medium ($' .. Config.LevelsPrice['Medium'] .. ')', name = '', size = 'Medium' },
        { label = 'Order Cargo Size Large ($' .. Config.LevelsPrice['Large'] .. ')', name = '', size = 'Large' },
    }
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'open_ahmad_menu', {
        title    = 'Choose Your Cargo',
        align    = 'top-left',
        elements = elements

    }, function(data, menu)
        local elements <const> = {
            { label = 'Yes ', value = 'accept' },
            { label = 'No ', value = 'deny' },
        }
        ESX.UI.Menu.Open("default", GetCurrentResourceName(), "ahmad_buy_question",
            {
                title = "Aya Mikhahid Cargo " .. data.current.size .. " Order Konid?",
                align = "top-left",
                elements = elements
            },
            function(data1, menu1)
                if data1.current.value == 'accept' then
                    BoughtTicket(data.current.size)
                end
                menu1.close()
                menu.close()
            end,
            function(data, menu1)
                menu1.close()
            end)
    end, function(data, menu)
        menu.close()
    end)
end

RegisterNetEvent('hz_cargo:cargoStarted')
AddEventHandler('hz_cargo:cargoStarted', function(size)
    local random = math.random(1, #Config.SpawnLocations)
    local table = Config.SpawnLocations[random]
    if table then
        ESX.ShowNotification('Moghiat Drop Dar Naghshe Neshan Dade Shode Ast Va Ta 10 Min Digar Drop Mishavad')
        TriggerServerEvent('hz_cargo:whereStarted', table.name)
        SetNewWaypoint(table.coords.x, table.coords.y)
        CreateRadiusBlip(table.coords)
        CargoThread(table.coords, size)
    end
end)

function getNextPosition(coords)
    local x = coords.x
    local y = coords.y - 100
    local z = coords.z + 100
    return vector3(x, y, z)
end

function CargoThread(coords, size)
    SetTimeout(10 * 1000 * 60, function()
        ESX.Game.SpawnVehicle('cargoplane', getNextPosition(coords), 0.0, function(plane)
            SetEntityDynamic(plane, true)

            ActivatePhysics(plane)

            SetVehicleForwardSpeed(plane, 100.0)

            SetHeliBladesFullSpeed(plane)

            SetEntityCollision(plane, false, true)

            SetVehicleEngineOn(plane, true, true, false)

            ControlLandingGear(plane, 0)

            OpenBombBayDoors(plane)

            SetEntityProofs(plane, true, false, true, false, false, false, false, false)

            local pilot = CreatePedInsideVehicle(plane, 1, GetHashKey("mp_m_freemode_01"), -1, false, true)

            SetBlockingOfNonTemporaryEvents(pilot, true)

            SetPedKeepTask(pilot, true)

            SetPlaneMinHeightAboveTerrain(plane, 50)

            TaskVehicleDriveToCoord(pilot, plane, coords.x, coords.y + 300, coords.z + 100, 30.0, 30.0, `cargoplane`,
                16777216,
                1.0, 1)

            SetTimeout(10000, function()
                ESX.Game.DeleteVehicle(plane)
                DeleteEntity(pilot)
            end)
        end)
        RequestModel(Config.Objects[size])
	
        while not HasModelLoaded(Config.Objects[size]) do
            Citizen.Wait(1)
        end
        local object = CreateObjectNoOffset(Config.Objects[size], coords.x, coords.y, coords.z + 50, true, true, false)
        SetEntityCollision(object, false, true)
        local parachute = CreateObject(`p_parachute1_mp_dec`, coords.x, coords.y, coords.z + 55, true, true, true)
        SetEntityCollision(parachute, false, true)
        AttachEntityToEntity(parachute, object, 0, 0.0, 0.0, 5.0, 0.0, 0.0, 0.0, false, false, true, false, 2, true)
        local descendSpeed = 0.03
        while GetEntityCoords(object).z > coords.z do
            SetEntityCoordsNoOffset(object, GetEntityCoords(object).x, GetEntityCoords(object).y, GetEntityCoords(object).z - descendSpeed)
            Citizen.Wait(5)
        end
        SetEntityCollision(object, true, false)
        PlaceObjectOnGroundProperly(object)
        FreezeEntityPosition(object, true)
        SetModelAsNoLongerNeeded(Config.Objects[size])
        cargoObject = object
        local netId = NetworkGetNetworkIdFromEntity(object)
        TriggerServerEvent('hz_cargo:cargoObject', netId)
        DeleteEntity(parachute)
        
    end)
end

ESX.RegisterInput('cargo:pickuploot', 'Cargo', 'keyboard', 'E', function()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local myVehicle = GetVehiclePedIsIn(ped, false)
        local myVehHash = GetEntityModel(myVehicle)
        if myVehHash == `skylift` then
            if not IsEntityAttachedToAnyVehicle(cargoObject) then
                local vehPos = GetEntityCoords(myVehicle)
                local dist = #(vehPos - GetEntityCoords(cargoObject))
                if dist <= 7 then
                    NetworkRequestControlOfEntity(cargoObject)
                    AttachEntityToEntity(cargoObject, myVehicle, 0, 0.0, -3.5, -2.0, 0.0, 0.0, 0.0, true, true, false,
                        true, 1, true)
                end
            end
        end
    end
end)


RegisterNetEvent('hz_cargo:cargoObject')
AddEventHandler('hz_cargo:cargoObject', function(netId)
    cargoObject = NetworkGetEntityFromNetworkId(netId)
end)


function CreateRadiusBlip(coords)
    local blip = AddBlipForRadius(coords, 150.0)
    SetBlipHighDetail(blip, true)
    SetBlipColour(blip, 3)
    SetBlipAlpha(blip, 128)
    SetTimeout(15 * 1000 * 60, function()
        RemoveBlip(blip)
    end)
end

function BoughtTicket(size)
    TriggerServerEvent('hz_cargo:boughtTicket', size)
end

function AddTargetNPC()
    exports.ox_target:addModel(Config.NPCModel, {
        label = 'Talk to Ahmad',
        name = 'intract',
        distance = 2,
        icon = 'fa-solid fa-comment',
        onSelect = function(data)
            OpenMenu()
        end
    })
end

function CreateNPC(coords)
    RequestModel(Config.NPCModel)
    while not HasModelLoaded(Config.NPCModel) do
        Citizen.Wait(20)
    end
    local npcSpawn = CreatePed(4, Config.NPCModel, coords.x, coords.y, coords.z - 1, coords.w, false, true)
    SetModelAsNoLongerNeeded(Config.NPCModel)
    SetEntityAsMissionEntity(npcSpawn, true, true)
    SetNetworkIdExistsOnAllMachines(netid, true)
    SetEntityProofs(npcSpawn, true, true, true, false, true, true, true, true)
    FreezeEntityPosition(npcSpawn, true)
    SetBlockingOfNonTemporaryEvents(npcSpawn, true)
    SetPedFleeAttributes(npcSpawn, 0, 0)
end
