-- Load the config
local Config = Config or {}

-- Initialize ESX or QB-Core
local ESX = nil
local QBCore = nil

if Config.Framework == 'ESX' then
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
elseif Config.Framework == 'QB' then
    QBCore = exports['qb-core']:GetCoreObject()
end

-- Table to keep track of active performances
local activePerformances = {}

-- Table to keep track of player tips
local playerTips = {}

-- Function to add money to a player's account
local function addMoney(playerId, amount)
    if Config.Framework == 'ESX' then
        if ESX then
            local xPlayer = ESX.GetPlayerFromId(playerId)
            if xPlayer then
                xPlayer.addMoney(amount)
                print('ESX: Player ' .. playerId .. ' earned $' .. amount .. ' in tips.')
            else
                print('ESX: Failed to find player ' .. playerId)
            end
        else
            print('ESX: ESX object not found.')
        end
    elseif Config.Framework == 'QB' then
        if QBCore then
            local Player = QBCore.Functions.GetPlayer(playerId)
            if Player then
                Player.Functions.AddMoney('cash', amount)
                print('QB: Player ' .. playerId .. ' earned $' .. amount .. ' in tips.')
            else
                print('QB: Failed to find player ' .. playerId)
            end
        else
            print('QB: QBCore object not found.')
        end
    else
        -- Standalone or unknown framework (just print the amount)
        print('Standalone: Player ' .. playerId .. ' earned $' .. amount .. ' in tips.')
    end
end

-- Event to start a performance
RegisterServerEvent('streetPerformer:startPerformance')
AddEventHandler('streetPerformer:startPerformance', function(coords)
    local playerId = source
    if activePerformances[playerId] then
        TriggerClientEvent('streetPerformer:notify', playerId, 'You are already performing!')
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
        local tipAmount = math.random(Config.MinTipAmount, Config.MaxTipAmount) 
        playerTips[playerId] = (playerTips[playerId] or 0) + tipAmount

        -- Add money to player's account based on framework
        addMoney(playerId, tipAmount)
        TriggerClientEvent('streetPerformer:notify', playerId, 'You earned $' .. tipAmount .. ' in tips! Total tips: $' .. playerTips[playerId])
    else
        print('Player ' .. playerId .. ' is not performing.')
    end
end)

-- Command to check total tips (optional)
RegisterCommand('checktips', function(source, args, rawCommand)
    local playerId = source
    local totalTips = playerTips[playerId] or 0
    TriggerClientEvent('streetPerformer:notify', playerId, 'Your total tips: $' .. totalTips)
end, false)
