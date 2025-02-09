local isPerforming = false
local performanceCoords = nil

-- Function to start performing
RegisterNetEvent('streetPerformer:startPerformance')
AddEventHandler('streetPerformer:startPerformance', function(playerId, coords)
    if GetPlayerServerId(PlayerId()) == playerId then
        isPerforming = true
        performanceCoords = coords
        TriggerEvent('streetPerformer:notify', 'You started performing!')

        -- Trigger emote (assuming 'WORLD_HUMAN_MUSICIAN' is the desired emote)
        TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_MUSICIAN', 0, true)

        Citizen.CreateThread(function()
            while isPerforming do
                Citizen.Wait(10000) -- Every 10 seconds
                TriggerServerEvent('streetPerformer:earnTips')
            end
        end)

        -- Key press detection for stopping performance
        Citizen.CreateThread(function()
            while isPerforming do
                Citizen.Wait(0)
                if IsControlJustPressed(0, 73) then -- 'X' key
                    ClearPedTasksImmediately(PlayerPedId())
                    TriggerServerEvent('streetPerformer:stopPerformance')
                    TriggerEvent('streetPerformer:notify', 'You stopped performing!')
                end
            end
        end)
    else
        -- Spawn NPC audience
        local audience = CreatePed(4, GetHashKey('a_m_m_business_01'), coords.x, coords.y, coords.z, 0.0, true, true)
        TaskStartScenarioInPlace(audience, 'WORLD_HUMAN_CHEERING', 0, true)
    end
end)

-- Function to stop performing
RegisterNetEvent('streetPerformer:stopPerformance')
AddEventHandler('streetPerformer:stopPerformance', function(playerId)
    if GetPlayerServerId(PlayerId()) == playerId then
        isPerforming = false
        performanceCoords = nil
        TriggerEvent('streetPerformer:notify', 'You stopped performing!')
        ClearPedTasksImmediately(PlayerPedId()) -- Ensure the emote is stopped
    else
        -- Remove NPC audience
        local playerPed = GetPlayerPed(GetPlayerFromServerId(playerId))
        ClearPedTasksImmediately(playerPed)
        DeletePed(playerPed)
    end
end)

-- Function to notify players
RegisterNetEvent('streetPerformer:notify')
AddEventHandler('streetPerformer:notify', function(message)
    ShowNotification(message)
end)

-- Helper function to show notifications
function ShowNotification(text)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(text)
    DrawNotification(false, true)
end

-- Command to start performance
RegisterCommand('perform', function(source, args, rawCommand)
    if isPerforming then
        TriggerServerEvent('streetPerformer:stopPerformance')
    else
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        TriggerServerEvent('streetPerformer:startPerformance', coords)
    end
end, false)
