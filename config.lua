Config = {}

-- Parking spot for delivery vehicle
Config.EndPoint = vector3(28.71, -1110.68, 29.31)

--counter the delivery driver will walk up to
Config.AmmunationCounter = vector3(22.68, -1106.99, 29.8)

-- Places the delivery vehicle spawns at
Config.VehicleSpawns = {
    vector4(-871.33, -2586.55, 13.83, 59.3),
    vector4(240.45, -2177.69, 10.41, 221.37),
    vector4(-323.21, -751.94, 33.97, 157.55),
}

-- Vehicles that can be used in delivery
Config.TransportModels = {
    'burrito'
}

-- Loot Possible to get from robbery
Config.Loot = {
    'weapon_pistol'
}

--Time Between Deliveries
Config.Timer = 3600000 * 1
