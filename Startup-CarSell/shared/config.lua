
Config = {}


Config.Animation = {
    dict = "anim@mp_player_intcelebrationmale@wave", 
    anim = "wave", 
    duration = 3000 
}


Config.NPC = {
    PedType = 26,
    Model = 'a_m_y_smartcaspat_01',
    x = -536.4543, 
    y = -132.7186, 
    z = 37.6031, 
    h = 202.5969 
}

Config.vehicleModel = "adder"  
Config.vehicleSpawnCoords = {
    vector3(387.6347, -766.2678, 29.4490), 
    vector3(-334.6449, -750.3797, 33.9685), 
    vector3(-1243.5709, -1411.1676, 4.3231), 
    vector3(-694.6086, -1119.0308, 14.5251), 
    vector3(35.6762, -1082.2362, 38.1521)  
}

Config.vehicleDestroyCoords = vector3(-657.2047, 903.3781, 228.5506)


Config.pedBlip = {
    sprite = 1,
    color = 3,
    scale = 1.0,
    name = "Mission NPC"
}

Config.vehicleBlip = {
    sprite = 225,
    color = 3,
    scale = 1.0,
    name = "Vehicle to Retrieve"
}

Config.destroyBlip = {
    sprite = 225,
    color = 1,
    scale = 1.0,
    name = "Drop Off Vehicle"
}

-- Messages
Config.messages = {
    alreadyInMission = "You are already on a mission.",
    startMission = "Mission started!",
    interactWithPed = "Press ~INPUT_CONTEXT~ to talk to the NPC",
    destroyVehicle = "Press ~INPUT_CONTEXT~ to destroy the vehicle",
    carmission = "You need to be in the mission car !",
    missionCompleted = "Mission accomplished!"
}

-- Notifications
Config.OKOKNotify = true
Config.UseESXDefaultNotify = false


--OX ITEMS--
Config.UseOxInventory = false

Config.ItemsOX = { 
    {item = "money", amount = 50}
}

--NON OX ITEMS--
Config.reward = {
    item = "weapon_pistol",  -- Replace with the desired item name
    quantity = 1,            -- Quantity of the item to give
    message = "You have received your rewards!" -- Notification message with a placeholder for the item
}