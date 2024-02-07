local Framework = exports['710-lib']:GetFrameworkObject()
local GConfig = Framework.Config()


lib.callback.register('710-vendingMachines:getVendingMachineStock', function(source, id)
    local source = source
    local stock = MySQL.query.await('SELECT * FROM 710_vending_machines WHERE id = @id', {
        ['@id'] = id
    })
    if (stock[1] ~= nil) then
        print(stock[1])
        local data = stock[1]
        return data
    else
        return false
    end
end)

lib.callback.register('710-vendingMachine:getEmployeeInventory', function(source)
    local source = source
    local invItems = {}
    local Player = Framework.PlayerDataS(source)
    if GetResourceState('ox_inventory') == "started" then
        local playerItems = exports.ox_inventory:GetInventoryItems(source)
        for k, v in pairs(playerItems) do
            invItems[#invItems + 1] = {
                name = v.name,
                label = v.label,
                amount = v.count,
            }
        end
    elseif GConfig.Framework == 'qbcore' then
        local playerItems = Player.Inventory
        for k, v in pairs(playerItems) do 
            invItems[#invItems + 1] = {
                name = v.name,
                label = v.label,
                amount = v.amount,
            }
        end
    elseif GConfig.Framework == 'esx' then
        local playerItems = Player.Inventory
        for k, v in pairs(playerItems) do 
            invItems[#invItems + 1] = {
                name = v.name,
                label = v.label,
                amount = v.count,
            }
        end
    end
    return invItems
end)

--- Add Item to stock
RegisterNetEvent('710-vendingMachines:addItemToStock', function(item, amount, price)
    local source = source
    local Player = Framework.PlayerDataS(source)
    local Machine = Player.Job.name
    local MachineConfig = Config.VendingMachines[Machine]
    if Config.BlacklistAllWeapons then
    --- Check if item name starts with WEAPON_ 
        if string.find(item, 'WEAPON_') then
            Player.Notify('You cannot add weapons to the vending machine')
            return
        end
    end
    --- check if item is on blacklist
    for k, v in pairs(Config.BlacklistedItems) do
        if v == item then
            Player.Notify('You cannot add '..Framework.GetItemLabel(source, item)..' to the vending machine')
            return
        end
    end
    local data = {}
    MySQL.Async.fetchAll('SELECT * FROM 710_vending_machines WHERE id = @id', {
        ['@id'] = Machine
    }, function(result)
        if (result[1] ~= nil) then
            print(result[1].data)
            if result[1].data ~= nil then 
                 data = json.decode(result[1].data)
                if data[item] ~= nil then
                    data[item].amount = data[item].amount + amount
                    data[item].price = price
                    data[item].label = Framework.GetItemLabel(source, item)
                else
                    data[item] = {
                        amount = amount,
                        price = price,
                        label = Framework.GetItemLabel(source, item),
                    }
                end
            else
                
                data[item] = {
                    amount = amount,
                    price = price,
                    label = Framework.GetItemLabel(source, item),
                }
            end
            MySQL.Async.execute('UPDATE 710_vending_machines SET data = @data WHERE id = @id', {
                ['@id'] = Machine,
                ['@data'] = json.encode(data),
            })
            Player.RemoveItem(item, amount)
            Player.Notify('Added '..amount..' '..item..' to '..MachineConfig.label..' for $'..price)
        end
    end)
end)


--- Buy item from vending machine
RegisterNetEvent('710-vendingMachines:buyItem', function(item, amount, machine)
    local source = source
    local Player = Framework.PlayerDataS(source)
    local Machine = machine
    local MachineConfig = Config.VendingMachines[Machine]
    MySQL.Async.fetchAll('SELECT * FROM 710_vending_machines WHERE id = @id', {
        ['@id'] = Machine
    }, function(result)
        if (result[1] ~= nil) then
            local data = json.decode(result[1].data)
            if data[item] ~= nil then
                if data[item].amount >= amount then
                    local price = data[item].price * amount
                    if Player.Cash >= price then
                        Player.RemoveCash(price)
                        Player.Notify('You bought '..amount..' '..item..' for $'..price)
                        data[item].amount = data[item].amount - amount
                        MySQL.Async.execute('UPDATE 710_vending_machines SET data = @data WHERE id = @id', {
                            ['@id'] = Machine,
                            ['@data'] = json.encode(data),
                        })
                        exports['Renewed-Banking']:addAccountMoney(MachineConfig.paymentAccount, price)
                        --[[TriggerEvent('esx_addonaccount:getSharedAccount', MachineConfig.paymentAccount, function(account)
                            account.addMoney(price)
                        end)]]
                        Player.AddItem(item, amount)
                    elseif Player.Bank >= price then
                        Player.RemoveBankMoney(price)
                        Player.Notify('You bought '..amount..' '..item..' for $'..price)
                        data[item].amount = data[item].amount - amount
                        MySQL.Async.execute('UPDATE 710_vending_machines SET data = @data WHERE id = @id', {
                            ['@id'] = Machine,
                            ['@data'] = json.encode(data),
                        })
                        exports['Renewed-Banking']:addAccountMoney(MachineConfig.paymentAccount, price)
                        Player.AddItem(item, amount)
                    else
                        Player.Notify('You do not have enough money to buy '..amount..' '..item..' for $'..price)
                    end
                else
                    Player.Notify('There is not enough '..item..' in the vending machine')
                end
            else
                Player.Notify('There is no '..item..' in the vending machine')
            end
        end
    end)
end)



local function CreateSqlTable()
    MySQL.query('CREATE TABLE IF NOT EXISTS 710_vending_machines (id VARCHAR(255) PRIMARY KEY, machine_name VARCHAR(255), data LONGTEXT)')
    
end
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    Wait(25 * 1000)
    print('^2[710-vending-machines] Checking if SQL table exists, if not creating it.^7')
    CreateSqlTable()
    Wait(5 * 1000)
    --- Check config for vending mmachines see if they are in the table if not add them 
    for k, v in pairs(Config.VendingMachines) do
        MySQL.Async.fetchAll('SELECT * FROM 710_vending_machines WHERE id = @id', {
            ['@id'] = k
        }, function(result)
            if (result[1] == nil) then
                print('^2[710-vending-machines] Adding vending machine for '..v.label..' to SQL table.^7')
                MySQL.Async.execute('INSERT INTO 710_vending_machines (id, machine_name) VALUES (@id, @machine_name)', {
                    ['@id'] = k,
                    ['@machine_name'] = v.label,
                })
            end
        end)
    end
end)

