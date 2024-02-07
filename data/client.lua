local Framework = exports['710-lib']:GetFrameworkObject()
local GConfig = Framework.Config()


local function getStock(machine)
    local stock = lib.callback.await('710-vendingMachines:getVendingMachineStock', false, machine)
    if stock then
        return stock
    else
        return false
    end
end

--- Menu for vending machines
RegisterNetEvent('710-vendingMachines:openMenu', function(data)
    local machine = data.machine
    local stock = getStock(machine)
    local Player = Framework.PlayerDataC()
    local stockLabel = Config.VendingMachines[machine].label
    if stock ~= nil then
       --print(json.encode(stock))
       local stockData = json.decode(stock.data)
       print(stockData)
        local menu = {}
        for k, v in pairs(stockData) do
            table.insert(menu, {
                title = v.label,
                icon = Config.ImagePath..k..'.png',
                itemname = k,
                description = "$"..v.price.." - "..v.amount.." in stock",
                onSelect = function()
                    local input = lib.inputDialog('How many '..v.label.." would you like?", {
                        {type = 'slider', label = 'Amount', min = 1, max = v.amount},
                    })
 
                    if not input then return end
                    local amount = input[1]
                    TriggerServerEvent('710-vendingMachines:buyItem', k, amount, machine)
                end,
            })
        end
        if Player.Job.name == machine then
            table.insert(menu, {
                title = 'Stock Vending Machine',
                icon = 'fas fa-box-open',
                onSelect = function()
                    local inventory = lib.callback.await('710-vendingMachine:getEmployeeInventory', false)
                    local inventoryItemAmounts = {}
                    for k, v in pairs(inventory) do
                        inventoryItemAmounts[#inventoryItemAmounts+1] = {
                            value = v.name,
                            label = v.label.." - "..v.amount.." in pockets.",
                        }
                    end
                    local input = lib.inputDialog('Add A New Item', {
                        {type = 'select', label = 'Item to add', options = inventoryItemAmounts, required = true},
                        {type = 'number', label = 'Amount to add', description = '#', icon = 'hashtag', required = true},
                        {type = 'number', label = 'Price', description = '$', icon = 'dollarsign', required = true},
                      })
                    if not input then return end
                    local item = input[1]
                    local amount = input[2]
                    local price = input[3]
                    TriggerServerEvent('710-vendingMachines:addItemToStock', item, amount, price)
                end,
            })
            lib.registerContext({
                id = '710vendmach_menu',
                title = stockLabel,
                options = menu,
            })
         
            lib.showContext('710vendmach_menu')
        else
            lib.registerContext({
                id = '710vendmach_menu',
                title = stockLabel,
                options = menu,
            })
         
          lib.showContext('710vendmach_menu')
        end
        
        --TriggerClientEvent('710-vendingMachines:openMenu', source, menu, machine)
    else
        local menu = {}
        if Player.Job.name == machine then
            table.insert(menu, {
                title = 'Stock Vending Machine',
                icon = 'fas fa-box-open',
                onSelect = function()
                    local inventory = lib.callback.await('710-vendingMachine:getEmployeeInventory', false)
                    local inventoryItemAmounts = {}
                    for k, v in pairs(inventory) do
                        inventoryItemAmounts[#inventoryItemAmounts+1] = {
                            value = v.name,
                            label = v.label.." - "..v.amount.." in pockets.",
                        }
                    end
                    local input = lib.inputDialog('Add A New Item', {
                        {type = 'select', label = 'Item to add', options = inventoryItemAmounts, required = true},
                        {type = 'number', label = 'Amount to add', description = '#', icon = 'hashtag', required = true},
                        {type = 'number', label = 'Price', description = '$', icon = 'dollarsign', required = true},
                      })
                    if not input then return end
                    local item = input[1]
                    local amount = input[2]
                    local price = input[3]
                    TriggerServerEvent('710-vendingMachines:addItemToStock', item, amount, price)
                end,
            })
            lib.registerContext({
                id = '710vendmach_menu',
                title = Config.VendingMachines[machine].label,
                options = menu,
            })
         
            lib.showContext('710vendmach_menu')
        else
            Player.Notify('This vending machine is empty')
        end
    end
end)

--- Spawn vending machines and attach ox_target to it
CreateThread(function()
    for k, v in pairs(Config.VendingMachines) do
        local prop = GetHashKey(v.prop)
        RequestModel(prop)
        while not HasModelLoaded(prop) do
            Wait(1)
        end
        local machine = CreateObject(prop, v.coords.x, v.coords.y, v.coords.z - 1, false, false, false)
        SetEntityHeading(machine, v.coords.w)
        FreezeEntityPosition(machine, true)
        SetEntityAsMissionEntity(machine, true, true)
        SetModelAsNoLongerNeeded(prop)
        local options = {
                {
                    event = '710-vendingMachines:openMenu',
                    icon = 'fas fa-shopping-cart',
                    label = 'Buy From Vending Machine',
                    machine = k,
                },
            }
        exports.ox_target:addLocalEntity(machine, options)
    end
end)