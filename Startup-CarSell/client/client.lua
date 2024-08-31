local pedCoords = Config.pedcoord
local pedModel = "a_m_y_smartcaspat_01"
local missionActive = false
local missionCompleted = false
local Alreadyinmission = Config.messages.alreadyInMission
local Startingmission = Config.messages.startMission
local needmissioncar = Config.messages.carmission
local vehicleBlip = nil
local destroyBlip = nil
local pedBlip = nil

local vehicleDestroyCoords = Config.vehicleDestroyCoords

function LoadModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Wait(10)
    end
end

function CreateMissionPed()
    local npcConfig = Config.NPC

    LoadModel(npcConfig.Model)
    
    -- Créer le PNJ avec le modèle spécifié et la position
    local ped = CreatePed(npcConfig.PedType, npcConfig.Model, npcConfig.x, npcConfig.y, npcConfig.z, npcConfig.h, false, true)
    
    SetEntityAsMissionEntity(ped, true, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    if not pedBlip or not DoesBlipExist(pedBlip) then
        pedBlip = AddBlipForCoord(npcConfig.x, npcConfig.y, npcConfig.z)
        SetBlipSprite(pedBlip, Config.pedBlip.sprite)
        SetBlipColour(pedBlip, Config.pedBlip.color)
        SetBlipScale(pedBlip, Config.pedBlip.scale)
        SetBlipAsShortRange(pedBlip, true)  -- Rendre le blip visible à longue distance
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.pedBlip.name)
        EndTextCommandSetBlipName(pedBlip)
    end

    return ped
end

local missionPed = CreateMissionPed()

function PlayAnimation(ped)
    local animDict = Config.Animation.dict
    local animName = Config.Animation.anim
    local duration = Config.Animation.duration

    -- Charger le dictionnaire d'animation
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(100)
    end

    -- Jouer l'animation
    TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, duration / 1000, 0, 0, false, false, false)

    -- Attendre la fin de l'animation
    Citizen.Wait(duration)
    
    -- Réinitialiser l'animation
    StopAnimTask(ped, animDict, animName, 1.0)
end

function DisplayHelpText(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local pedCoords = vector3(Config.NPC.x, Config.NPC.y, Config.NPC.z)
        local distance = #(playerCoords - pedCoords)  -- Utilisation correcte pour la distance

        if distance < 2.0 then
            DisplayHelpText(Config.messages.interactWithPed)
            if IsControlJustReleased(0, 38) then
                if not missionActive then
                    StartMission()
                else
                    if Config.OKOKNotify and not Config.UseESXDefaultNotify then
                        exports['okokNotify']:Alert("", Alreadyinmission, 5000, 'error')
                    elseif Config.UseESXDefaultNotify and not Config.OKOKNotify then
                        ESX.ShowNotification(Alreadyinmission)
                    end
                end

                -- Jouer l'animation
                PlayAnimation(missionPed)
            end
        end
    end
end)

function GetRandomSpawnCoord()
    local index = math.random(#Config.vehicleSpawnCoords)
    return Config.vehicleSpawnCoords[index]
end

function UpdateVehicleBlip(vehicle, blip)
    if DoesBlipExist(blip) then
        local vehicleCoords = GetEntityCoords(vehicle)
        SetBlipCoords(blip, vehicleCoords.x, vehicleCoords.y, vehicleCoords.z)
    end
end

local messageDisplayed = false

function StartMission()
    if missionActive then
        return
    end

    missionActive = true
    missionCompleted = false

    if Config.OKOKNotify and not Config.UseESXDefaultNotify then
        exports['okokNotify']:Alert("", Startingmission, 5000, 'success')
    elseif Config.UseESXDefaultNotify and not Config.OKOKNotify then
        ESX.ShowNotification(Startingmission)
    end

    if vehicleBlip and DoesBlipExist(vehicleBlip) then
        RemoveBlip(vehicleBlip)
    end

    local spawnCoords = GetRandomSpawnCoord()
    local vehicleModel = GetHashKey(Config.vehicleModel)
    LoadModel(vehicleModel)
    local missionVehicle = CreateVehicle(vehicleModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, true, false)
    SetVehicleAsNoLongerNeeded(missionVehicle)
    SetEntityAsMissionEntity(missionVehicle, true, true)
    vehicleBlip = AddBlipForEntity(missionVehicle)
    SetBlipSprite(vehicleBlip, Config.vehicleBlip.sprite)
    SetBlipColour(vehicleBlip, Config.vehicleBlip.color)
    SetBlipScale(vehicleBlip, Config.vehicleBlip.scale)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.vehicleBlip.name)
    EndTextCommandSetBlipName(vehicleBlip)

    local missionVehiclePlate = GetVehicleNumberPlateText(missionVehicle)

    Citizen.CreateThread(function()
        while missionActive do
            Citizen.Wait(500)
            if DoesEntityExist(missionVehicle) then
                UpdateVehicleBlip(missionVehicle, vehicleBlip)

                local playerVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                if playerVehicle ~= 0 and GetVehicleNumberPlateText(playerVehicle) == missionVehiclePlate then
                    if destroyBlip and DoesBlipExist(destroyBlip) then
                        RemoveBlip(destroyBlip)
                    end
                    
                    destroyBlip = AddBlipForCoord(vehicleDestroyCoords.x, vehicleDestroyCoords.y, vehicleDestroyCoords.z)
                    SetBlipSprite(destroyBlip, Config.destroyBlip.sprite)
                    SetBlipColour(destroyBlip, Config.destroyBlip.color)
                    SetBlipScale(destroyBlip, Config.destroyBlip.scale)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString(Config.destroyBlip.name)
                    EndTextCommandSetBlipName(destroyBlip)

                    Citizen.CreateThread(function()
                        while missionActive do
                            Citizen.Wait(0)
                            local playerCoords = GetEntityCoords(PlayerPedId())
                            local distanceToDestroyPoint = #(playerCoords - vehicleDestroyCoords)
                            if distanceToDestroyPoint < 2.0 then
                                DisplayHelpText(Config.messages.destroyVehicle)
                                if IsControlJustReleased(0, 38) then
                                    if GetVehiclePedIsIn(PlayerPedId(), false) == playerVehicle then
                                        DeleteVehicle(playerVehicle)
                                        if destroyBlip and DoesBlipExist(destroyBlip) then
                                            RemoveBlip(destroyBlip)
                                        end
                                        if not missionCompleted then
                                            GiveReward()
                                            missionCompleted = true
                                            ResetMission()
                                            DisplayHelpText(Config.messages.missionCompleted)
                                        end
                                    else
                                        if not messageDisplayed then
                                            messageDisplayed = true
                                            if Config.OKOKNotify and not Config.UseESXDefaultNotify then
                                                exports['okokNotify']:Alert("", needmissioncar, 5000, 'error')
                                            elseif Config.UseESXDefaultNotify and not Config.OKOKNotify then
                                                ESX.ShowNotification(needmissioncar)
                                            end
                                        end
                                    end
                                end
                            else
                                messageDisplayed = false
                            end
                        end
                    end)
                end
            else
                ResetMission()
                break
            end
        end
    end)
end

function ResetMission()
    missionActive = false
    if vehicleBlip and DoesBlipExist(vehicleBlip) then
        RemoveBlip(vehicleBlip)
    end
end

function GiveReward()
    local rewardItem = Config.reward.item
    local rewardQuantity = Config.reward.quantity
    local rewardMessage = string.format(Config.reward.message, rewardItem)

    if ESX == nil and not Config.UseOxInventory then
        GiveWeaponToPed(PlayerPedId(), GetHashKey(rewardItem), 100, false, true)
        if Config.OKOKNotify and not Config.UseESXDefaultNotify then
            exports['okokNotify']:Alert("", rewardMessage, 5000, 'success')
        elseif Config.UseESXDefaultNotify and not Config.OKOKNotify then
            ESX.ShowNotification(rewardMessage)
        end
    elseif Config.UseOxInventory then
        TriggerServerEvent('Startup_Giveitem')
        if Config.OKOKNotify and not Config.UseESXDefaultNotify then
            exports['okokNotify']:Alert("", rewardMessage, 5000, 'success')
        elseif Config.UseESXDefaultNotify and not Config.OKOKNotify then
            ESX.ShowNotification(rewardMessage)
        end
    end
end
