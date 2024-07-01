
-- Table to keep track of active performances
local activePerformances = {}


-- Event to start a performance
RegisterServerEvent('streetPerformer:startPerformance')
AddEventHandler(streetPerformer:startPerformance, function(coords)
    local PlayerId = source
    if activePerformances[PlayerId] then
        TriggerClientEvent(streetPerformer:notify, playerId, 'You are already performing!')
        return
    end

    activePerformances[playerId] = coords
    TriggerClientEvent('streetPerformer:startPerformance', -1, playerId, coords)
end)


-- Event to stop a performance
RegisterServerEvent('streetPerformer:stopPerformance')
AddEventHandler('streetPerformer:stopPerformance', function()
    local playerId = source
    if not activePerformances[playerId] then
        TriggerClientEvent('streetPerformer:notify', playerId, 'You are not performing!')
        return
    end

    activePerformances[playerId] = nil
    TriggerClientEvent('streetPerformer:stopPerformance', -1, playerId)
end)

-- Event to earn tips
RegisterServerEvent('streetPerformer:earnTips')
AddEventHandler('streetPerformer:earnTips', function()
    local playerId = source
    if activePerformances[playerId] then
        local tipAmount = math.random(10, 50) -- Random tip amount
        TriggerClientEvent('streetPerformer:notify', playerId, 'You earned $' .. tipAmount .. ' in tips!')
        -- Add logic to give the player the tip amount, e.g., using your server's money system
    end
end)

