Config = {} -- 2819.4287, -742.3105, 2.2250, 274.6515
Config.NPCLocation = vector4(-1000.84, 4853.27, 274.61, 164.6)
Config.SpawnLocations = {
    [1] = { name = 'HLR', coords = vector3(3568.82, 3787.15, 29.99)},
    [2] = { name = 'Raton Canyon', coords = vector3(-382.27, 4307.12, 53.41)},
    [3] = { name = 'Grapeseed', coords = vector3(1852.99, 4925.23, 46.18)},
    [4] = { name = 'Chiliad Mountain', coords = vector3(-1632.52, 4739.04, 53.18)},
    [5] = { name = 'Paleto Cove', coords = vector3(-1373.15, 5349.28, 3.18)},
    [6] = { name = 'Raton Canyon Trail', coords = vector3(-1351.3, 4471.83, 23.32)},
}
Config.LevelsPrice = {
    ['Small'] = 1000000,
    ['Medium'] = 1500000,
    ['Large'] = 2000000,
}

Config.Objects = {
    ['Large'] = `prop_container_01mb`,
    ['Small'] = `prop_container_05mb`,
    ['Medium'] = `prop_container_03mb`,
}

Config.Items = {
    ['Small'] = {
        {name = 'WEAPON_CARBINERIFLE', length = 1},
    },
    ['Medium'] = {
        {name = 'WEAPON_CARBINERIFLE', length = 1},
    },
    ['Large'] = {
        {name = 'WEAPON_CARBINERIFLE', length = 1},
    }
}

Config.NPCModel = `u_m_m_streetart_01`