Config = {}
Config.ImagePath = 'nui://ox_inventory/web/images/' --- path for images for the items.
-- ox_inventory - 'nui://ox_inventory/web/images/'
-- qb-inventory - 'nui://qb-inventory/html/images/'
-- Others just put the path with nui:// at the start. Make sure they are all pngs like you already should be doing.
Config.BlacklistedItems = {'WEAPON_PISTOL', 'money', 'markedbills'} --- make list of items that you dont want sold here, or just have server rules. 
Config.BlacklistAllWeapons = true -- if true all weapons wont be able to be sold at any vending machine.

Config.VendingMachines = {
    ['hongyoung'] = { --- Job name of the job that this vending machine belongs to
        label = 'Hong Young', --- Label at top of vending machine menu
        prop = 'prop_vend_snak_01_tu', ---- Prop name of the "vending machine" find more here - https://forge.plebmasters.de/
        coords = vector4(-655.142, -889.007, 24.777, 49.5),
        paymentAccount = 'hongyoung', --- account to pay money to when buying from the vending machine
    },
    ['blantern'] = {
        label = 'Black Lantern',
        prop = 'prop_bar_beerfridge_01', -- https://forge.plebmasters.de/
        coords = vector4(1645.890, 4851.1269, 41.237, 96.0),
        paymentAccount = 'blantern', --- account to pay money to when buying from the vending machine
    },
    ['lspizza'] = {
        label = 'Pizza This',
        prop = 'prop_vend_snak_01_tu', -- - https://forge.plebmasters.de/
        coords = vector4(795.143, -754.521, 26.9056, 90.00),
        paymentAccount = 'lspizza', --- account to pay money to when buying from the vending machine
    },
    ['beanmachine'] = {
        label = 'Bean Machine',
        prop = 'prop_vend_coffe_01', -- https://forge.plebmasters.de/
        coords = vector4(128.181, -1031.148, 28.391, 250.5),
        paymentAccount = 'beanmachine', --- account to pay money to when buying from the vending machine
    },
    ['catcafe'] = {
        label = 'UwU Cat Cafe',
        prop = 'prop_vend_snak_01_tu', -- https://forge.plebmasters.de/
        coords = vector4(-585.519, -1052.001, 22.519, 0.0),
        paymentAccount = 'catcafe', --- account to pay money to when buying from the vending machine
    },
    ['upnatom'] = {
        label = 'Up n Atom',
        prop = 'prop_vend_snak_01_tu', -- https://forge.plebmasters.de/
        coords = vector4(91.417, 281.878, 110.625, 246.0),
        paymentAccount = 'upnatom', --- account to pay money to when buying from the vending machine
    },
}
