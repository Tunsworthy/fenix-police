Config = {}


-- **CONFIG SETTINGS** --

-- Can enable this to print debug messages to client consoles and server console.
Config.isDebug = false 


-- DISPATCH SERVICES --

-- This toggle will enable functionality that checks if any players logged on have the Police job
-- and disables wanted levels and dispatching if there are. 
-- Setting this to true will only allow AI police when no player police are online.
-- Setting this to false will always have AI police even if player police are online.
Config.onlyWhenPlayerPoliceOffline = false

-- This setting works with the above toggle, how many police online are required before AI police are turned off?
Config.numberOfPoliceRequired = 1
-- Which Jobs count as "Police" jobs?
Config.PoliceJobsToCheck = {
    [1] = {
        jobName = 'police',
        onDutyOnly = true, -- Only counts if on Duty, if this is false any online police count even if off-duty. 
    },
    -- Can check additional police jobs by adding to this table.
}

-- Are players with police jobs in the list above protected from becoming wanted?
Config.PoliceWantedProtection = true

-- 1.0.1 Are players treated as police (and protected from being wanted) only when on-duty?
Config.PlayerPoliceOnlyOnDuty = false

-- 1.0.1 This removes vehicles from generating at PDs when police are online. 
Config.RemoveVehicleGenerators = true

-- This sets which dispatch services the game will handle using base game logic.
-- IMPORTANT: Turning on regular police dispatches will cause this mod to spawn more police in addition to base game police.
Config.AIResponse = {
    wantedLevels = true, -- if true, you will recieve wanted levels
    dispatchServices = {  -- AI dispatch services
        [1] = false,      -- Police Vehicles
        [2] = false,      -- Police Helicopters
        [3] = true,      -- Fire Department Vehicles
        [4] = false,      -- Swat Vehicles
        [5] = true,      -- Ambulance Vehicles
        [6] = false,      -- Police Motorcycles
        [7] = false,      -- Police Backup
        [8] = false,      -- Police Roadblocks
        [9] = false,      -- PoliceAutomobileWaitPulledOver
        [10] = false,     -- PoliceAutomobileWaitCruising
        [11] = true,     -- Gang Members
        [12] = false,     -- Swat Helicopters
        [13] = false,     -- Police Boats
        [14] = false,     -- Army Vehicles
        [15] = true      -- Biker Backup
    }
}

-- Define the evasion times for each wanted level (in milliseconds)
Config.evasionTimes = {
    [1] = 60000, -- 1 minute for wanted level 1
    [2] = 90000, -- 1.5 minutes for wanted level 2
    [3] = 120000, -- 2 minutes for wanted level 3
    [4] = 120000, -- 2 minutes for wanted level 4
    [5] = 150000  -- 2.5 minutes for wanted level 5
}




---------------------------------


-- SCRIPT CYCLE TIME--

-- IMPORTANT: This is the number of miliseconds between cycles in the script.
-- Default is 1000 ms, this means every second the script will check if the player wanted level is greater than 0.
-- If the player is wanted it will check the currently spawned unit count vs the max for that wanted level and spawn one unit if required.
-- It will not spawn another unit until the script cycles again. This means at 1000 ms this will spawn one cop per second if the player is wanted.
-- All of the handling of currently spawned units occurs for all of them every cycle. With the default setting this means every second it checks all the spawned
-- vehicles and officers to see if they are dead or too far away and starts timers to remove them if they remain that way. 
-- It checks if the player is on foot or in a vehicle and adjusts ALL of the spawned officers accordingly every cycle making them get out and pursue on foot or get back
-- into a nearby vehicle if the player gets in a vehicle and flees etc.
Config.scriptFrequency = 1000 --miliseconds

-- This modulus is used when the cleanup/removal timers are checked in the code to ensure that they are not treated as the 
-- number of cycles to pass before removing an officer, but as the number of seconds. 
-- eg. if the timer is 20 and is supposed to be seconds but your scriptFrequency has been changed to 500 ms as in it runs once every 0.5 seconds
-- the modulus will be (500 / 1000) = 0.5, when called in code I will take (timer/modulus) as the number of cycles to pass before removing the officer.
-- this means 20/0.5 = 40 cycles at 0.5 seconds per cycle this ensures the timer is still treated as 20 seconds. 
-- DO NOT CHANGE THIS, there should be no need to change this calculation. 
Config.scriptFrequencyModulus = (Config.scriptFrequency / 1000)

-- Wait time used for NetToVeh or NetToPed calls until they return a value.
Config.netWaitTime = 100

-- WAIT COUNT LOOPS--

-- Wait Count used by spawning scripts, this is the # of retries before it gives up for various loops.
Config.spawnWaitCount = 10

-----------------------------------------
-- UPDATE: This didn't work as intended, in my testing if the first ped fails to warp into a vehicle they ALL will fail.
-- And spawning new vehicles at the same spawn point, even if different vehicle models each time, will still fail over and over.
-- It seems that the spawn location is the problem more than anything. Randomizing it each time did fix it, but then they were all over the place including invalid spots.
-- Setting warpWaitCount = 1 and hasDriverWaitCount = 1 effectively means it will try to create the ped and try to warp them spawnWaitCount # of times once. If that fails it breaks the loop.
-- Then it deletes the vehicle and goes to re-try, but because hasDriverWaitCount = 1 it just exits returning nil to the client and the client will pick a new random spawn point and ask for another unit
-- next cycle. That seems to work the most reliably. 
-- These wait counts are used for re-tries. The logic is something like this:
-- 1) Spawn vehicle, if failed retry spawning vehicle spawnWaitCount # of times. 
-- 2) If vehicle has spawned then spawn a ped, if failed retry spawning ped spawnWaitCount # of times.
-- 3) If ped has spawned try warping into vehicle, if failed retry warping ped spawnWaitCount # of times.
-- 4) If ped still not warped delete ped entity and spawn a new one starting back at step 3. Do this warpWaitCount # of times.
-- 5) If we still don't have a ped in the driver seat of the vehicle delete the vehicle entity and start back at step 1. Do this hasDriverWaitCount # of times.
-- 6) If we STILL haven't properly spawned a vehicle exit the function and send the client a response, it will be empty, so the client will start over trying to add one more unit again. 

-- DO NOT EDIT Wait Count used by spawning scripts for warping peds into vehicles, this is the # of times it will start over with a fresh ped and attempt to warp the new ped.
Config.warpWaitCount = 1

-- DO NOT EDIT Wait Count used by spawning scripts for generating a vehicle with a driver, this is the number of times it starts over with a fresh vehicle if it still has no driver at end of ped loop.
Config.hasDriverWaitCount = 1
------------------------------------------

-- Wait Count used by handling scripts, ie. to send police to coords, to check if they are dead, too far away, stuck etc. 
-- Anything that requires the entity to exist locally. I want this lower so it doesn't spend so long checking over and over
-- for an entity that might be too far away to exist on the local client.
-- This is the # of retries before it gives up.
Config.controlWaitCount = 2

--------------------------

-- WANTED LEVEL UNIT COUNTS --
Config.maxUnitsPerLevel = {2, 4, 6, 8, 10} -- Maximum ground units for each wanted level
Config.maxHeliUnitsPerLevel = {0, 0, 0, 1, 2} -- Maximum heli units for each wanted level
Config.maxAirUnitsPerLevel = {0, 0, 0, 0, 1} -- Maximum plane units for each wanted level

-- This controls whether ground units will spawn if the player is in a helicopter, already spawned units aren't removed.
Config.spawnGroundUnitsInHeli = true

-- This controls whether ground units will spawn if the player is in a plane, already spawned units aren't removed.
Config.spawnGroundUnitsInPlane = true


-- SPAWN DISTANCES ETC --

Config.maxPoliceSpawnDistance = 300.0 -- This is the max distance around the player the spawn point for a new unit must be.
Config.minPoliceSpawnDistance = 200.0 -- This is the min distance from the player a spawn point for a new unit must be. 

Config.maxHeliSpawnDistance = 500.0 -- This is the max distance around the player the spawn point for a new heli must be.
Config.minHeliSpawnDistance = 300.0 -- This is the min distance from the player a spawn point for a new heli must be. 
Config.maxHeliSpawnHeight = 200.0 -- This is the max height the spawn point for a new heli must be.
Config.minHeliSpawnHeight = 150.0 -- This is the min height the spawn point for a new heli must be.

Config.maxAirSpawnDistance = 600.0 -- This is the max distance around the player the spawn point for a new plane must be.
Config.minAirSpawnDistance = 400.0 -- This is the min distance from the player a spawn point for a new plane must be. 
Config.maxAirSpawnHeight = 300.0 -- This is the max height the spawn point for a new plane must be.
Config.minAirSpawnHeight = 150.0 -- This is the min height the spawn point for a new plane must be.

-- This is the distance an officer operating a vehicle has to be from a player that is on foot before they get out to chase the player on foot.
-- This means they will drive to the player and get within this distance before getting out. If it is too small they will not be able to get out
-- and chase players that went down alley ways / into buildings. If it is too large they will get out too soon.
Config.footChaseDistance = 30.0
---------------------


-- OFFICER CLEANUP TIMERS AND DISTANCES --

-- NOTE: Police vehicles will not be cleaned up if a player is currently occupying them at the time the script attempts to remove them.
-- However it will remove the vehicle from the script's tracking at this time so the currently spawned count is decreased and a replacement can spawn. 
-- This means the vehicle will never be deleted after this.
-- This is to allow the player to steal a police vehicle and not have it disappear mid chase. Or to keep it and use it for any length of time
-- after the chase. If too many vehicles are left in the world it could cause performance issues. 

-- This is the number of seconds that must pass after an officer has died before they are deleted. Officers are tied to their vehicles.
-- A vehicle will only be deleted if all officers assigned to that vehicle are removed. 
Config.deadOfficerCleanupTimer = 45

-- This is how far away an officer must be from the player before the timer to remove them due to distance starts counting down. 
-- The timer will be re-set when they get back within this distance. This is to allow for new units to spawn and chase the player if police get
-- stuck or too far away for too long. The combination of cleanup timers, spawn distances, and cleanup distances will create the police chase experience you get.
-- My default values are to give a more realistic sense. 
-- The randomness of spawn points means reinforcements can still spawn ahead of you and cut you off, but they won't ALWAYS do it like base game.
Config.officerTooFarDistance = 500.0

-- This is the number of seconds that must pass while an officer is too far away from the player before they are deleted. Officers are tied to their vehicles.
-- A vehicle will only be deleted if all officers assigned to that vehicle are removed. 
Config.farOfficerCleanupTimer = 45




-- AIR UNIT CLEANUP TIMERS AND DISTANCES --

-- HELICOPTERS --
-- This is the number of seconds that must pass after a helicopter crew has died before they are deleted. 
Config.deadHeliPilotCleanupTimer = 120 

-- This is how far away a heli crew must be from the player before the timer to remove them due to distance starts counting down.
-- The timer will be re-set when they get back within this distance. 
Config.heliTooFarDistance = 600.0

-- This is the number of seconds that must pass while a heli crew is too far away from the player before they are deleted.
Config.farHeliPilotCleanupTimer = 120 


-- PLANES --
-- This is the number of seconds that must pass after a plane crew has died before they are deleted. 
Config.deadAirPilotCleanupTimer = 120 

-- This is how far away a plane crew must be from the player before the timer to remove them due to distance starts counting down.
-- The timer will be re-set when they get back within this distance. 
Config.planeTooFarDistance = 800.0

-- This is the number of seconds that must pass while a plane crew is too far away from the player before they are deleted.
Config.farAirPilotCleanupTimer = 120 

-- This is the number of seconds that must pass after the player is no longer wanted before officers are deleted.
Config.endWantedCleanupTimer = 20

-- This is the number of times a driver will try to unstick a vehicle before being teleported to the nearest road. 
Config.maxCloseUnstuckAttempts = 4 
Config.maxFarUnstuckAttempts = 4
--------------------



-- ZONE LIST -- 

-- This list maps zones by code to a region and also includes their names. This is used to setup 'districts' and determine what units are dispatched when a player is wanted.
-- This is done using the enum table below this. For eg. we check the player zone, it returns AIRP and we lookup the location and get 'Los Santos.' We check the
-- enum table and get losSantos as the region code using getZoneKey.
-- This can then be used to access the vehiclesByRegion table and select a random vehicle from it that should respond in Los Santos. That vehicle data object has all the info required
-- to spawn the unit and officers.
Config.zones = {
    AIRP = { name = 'Los Santos International Airport', location = 'Los Santos' },
    ALAMO = { name = 'Alamo Sea', location = 'Countryside' },
    ALTA = { name = 'Alta', location = 'Los Santos' },
    ARMYB = { name = 'Fort Zancudo', location = 'Countryside' },
    BANHAMC = { name = 'Banham Canyon Dr', location = 'Countryside' },
    BANNING = { name = 'Banning', location = 'Los Santos' },
    BEACH = { name = 'Vespucci Beach', location = 'Los Santos' },
    BHAMCA = { name = 'Banham Canyon', location = 'Countryside' },
    BRADP = { name = 'Braddock Pass', location = 'Countryside' },
    BRADT = { name = 'Braddock Tunnel', location = 'Countryside' },
    BURTON = { name = 'Burton', location = 'Los Santos' },
    CALAFB = { name = 'Calafia Bridge', location = 'Countryside' },
    CANNY = { name = 'Raton Canyon', location = 'Countryside' },
    CCREAK = { name = 'Cassidy Creek', location = 'Countryside' },
    CHAMH = { name = 'Chamberlain Hills', location = 'Los Santos' },
    CHIL = { name = 'Vinewood Hills', location = 'Los Santos' },
    CHU = { name = 'Chumash', location = 'Countryside' },
    CMSW = { name = 'Chiliad Mountain State Wilderness', location = 'Countryside' },
    CYPRE = { name = 'Cypress Flats', location = 'Los Santos' },
    DAVIS = { name = 'Davis', location = 'Los Santos' },
    DELBE = { name = 'Del Perro Beach', location = 'Los Santos' },
    DELPE = { name = 'Del Perro', location = 'Los Santos' },
    DELSOL = { name = 'La Puerta', location = 'Los Santos' },
    DESRT = { name = 'Grand Senora Desert', location = 'Countryside' },
    DOWNT = { name = 'Downtown', location = 'Los Santos' },
    DTVINE = { name = 'Downtown Vinewood', location = 'Los Santos' },
    EAST_V = { name = 'East Vinewood', location = 'Los Santos' },
    EBuro = { name = 'El Burro Heights', location = 'Los Santos' },
    ELGORL = { name = 'El Gordo Lighthouse', location = 'Countryside' },
    ELYSIAN = { name = 'Elysian Island', location = 'Los Santos' },
    GALFISH = { name = 'Galilee', location = 'Countryside' },
    GOLF = { name = 'GWC and Golfing Society', location = 'Los Santos' },
    GRAPES = { name = 'Grapeseed', location = 'Countryside' },
    GREATC = { name = 'Great Chaparral', location = 'Countryside' },
    HARMO = { name = 'Harmony', location = 'Countryside' },
    HAWICK = { name = 'Hawick', location = 'Los Santos' },
    HORS = { name = 'Vinewood Racetrack', location = 'Los Santos' },
    HUMLAB = { name = 'Humane Labs and Research', location = 'Countryside' },
    JAIL = { name = 'Bolingbroke Penitentiary', location = 'Countryside' },
    KOREAT = { name = 'Little Seoul', location = 'Los Santos' },
    LACT = { name = 'Land Act Reservoir', location = 'Countryside' },
    LAGO = { name = 'Lago Zancudo', location = 'Countryside' },
    LDAM = { name = 'Land Act Dam', location = 'Countryside' },
    LEGSQU = { name = 'Legion Square', location = 'Los Santos' },
    LMESA = { name = 'La Mesa', location = 'Los Santos' },
    LOSPUER = { name = 'La Puerta', location = 'Los Santos' },
    MIRR = { name = 'Mirror Park', location = 'Los Santos' },
    MORN = { name = 'Morningwood', location = 'Los Santos' },
    MOVIE = { name = 'Richards Majestic', location = 'Los Santos' },
    MTCHIL = { name = 'Mount Chiliad', location = 'Countryside' },
    MTGORDO = { name = 'Mount Gordo', location = 'Countryside' },
    MTJOSE = { name = 'Mount Josiah', location = 'Countryside' },
    MURRI = { name = 'Murrieta Heights', location = 'Los Santos' },
    NCHU = { name = 'North Chumash', location = 'Countryside' },
    NOOSE = { name = 'N.O.O.S.E', location = 'Countryside' },
    OCEANA = { name = 'Pacific Ocean', location = 'Countryside' },
    PALCOV = { name = 'Paleto Cove', location = 'Countryside' },
    PALETO = { name = 'Paleto Bay', location = 'Paleto Bay' },
    PALFOR = { name = 'Paleto Forest', location = 'Countryside' },
    PALHIGH = { name = 'Palomino Highlands', location = 'Countryside' },
    PALMPOW = { name = 'Palmer-Taylor Power Station', location = 'Countryside' },
    PBLUFF = { name = 'Pacific Bluffs', location = 'Los Santos' },
    PBOX = { name = 'Pillbox Hill', location = 'Los Santos' },
    PROCOB = { name = 'Procopio Beach', location = 'Countryside' },
    RANCHO = { name = 'Rancho', location = 'Los Santos' },
    RGLEN = { name = 'Richman Glen', location = 'Los Santos' },
    RICHM = { name = 'Richman', location = 'Los Santos' },
    ROCKF = { name = 'Rockford Hills', location = 'Los Santos' },
    RTRAK = { name = 'Redwood Lights Track', location = 'Countryside' },
    SANAND = { name = 'San Andreas', location = 'Los Santos' },
    SANCHIA = { name = 'San Chianski Mountain Range', location = 'Countryside' },
    SANDY = { name = 'Sandy Shores', location = 'Sandy Shores' },
    SKID = { name = 'Mission Row', location = 'Los Santos' },
    SLAB = { name = 'Stab City', location = 'Countryside' },
    STAD = { name = 'Maze Bank Arena', location = 'Los Santos' },
    STRAW = { name = 'Strawberry', location = 'Los Santos' },
    TATAMO = { name = 'Tataviam Mountains', location = 'Countryside' },
    TERMINA = { name = 'Terminal', location = 'Los Santos' },
    TEXTI = { name = 'Textile City', location = 'Los Santos' },
    TONGVAH = { name = 'Tongva Hills', location = 'Countryside' },
    TONGVAV = { name = 'Tongva Valley', location = 'Countryside' },
    VCANA = { name = 'Vespucci Canals', location = 'Los Santos' },
    VESP = { name = 'Vespucci', location = 'Los Santos' },
    VINE = { name = 'Vinewood', location = 'Los Santos' },
    WINDF = { name = 'RON Alternates Wind Farm', location = 'Countryside' },
    WVINE = { name = 'West Vinewood', location = 'Los Santos' },
    ZANCUDO = { name = 'Zancudo River', location = 'Countryside' },
    ZP_ORT = { name = 'Port of South Los Santos', location = 'Los Santos' },
    ZQ_UAR = { name = 'Davis Quartz', location = 'Countryside' }
}

-- The ZoneEnum maps location names from the above table to the Config.vehiclesByRegion key from the table below. 
-- This shouldn't be changed unless you know what you're doing. The location names above, enum list, and Config.vehiclesByRegion must be kept in sync.
-- Make sure any changes you make are reflected in all three. 
Config.ZoneEnum = {
    ['Los Santos'] = 'losSantos',
    ['Paleto Bay'] = 'paletoBay',
    ['Sandy Shores'] = 'sandyShores',
    ['Countryside'] = 'countryside'
}


------------------------


-- VEHICLE AND PED LISTS BY JURISDICTION / REGION --

-- Defines the list of vehicles by region with wanted levels, peds, and spawn chance.
-- The model value should be the model code from the game files. This will be spawned by getting the hash from the model code later.
-- Possible officers to spawn for a vehicle are attached to that car model entry. 
-- Peds should include the model codes for peds you want to possibly spawn with the car, they are selected randomly.
-- primaryWeaponGroup corresponds to the weapon table you'd like the primary weapon from. Peds will always have a primary weapon.
-- secondaryWeaponGroup corresponds to the weapon table you'd like the 
Config.vehiclesByRegion = {
    losSantos = {
        { model = 'police', peds = {'s_m_y_cop_01', 's_f_y_cop_01'}, wantedLevel = 1, spawnChance = 3, numPeds = 2, loadout = 'patrol' },
        { model = 'police2', peds = {'s_m_y_cop_01', 's_f_y_cop_01'}, wantedLevel = 1, spawnChance = 3, numPeds = 2, loadout = 'patrol'  },
        { model = 'police3', peds = {'s_m_y_cop_01', 's_f_y_cop_01'}, wantedLevel = 1, spawnChance = 1, numPeds = 2, loadout = 'patrol'  },
        { model = 'police4', peds = {'S_M_M_CIASec_01'}, wantedLevel = 2, spawnChance = 2, numPeds = 2, loadout = 'undercover'  },
        { model = 'policet', peds = {'s_m_y_cop_01', 's_f_y_cop_01'}, wantedLevel = 3, spawnChance = 1, numPeds = 2, loadout = 'patrol' },
        { model = 'police3', peds = {'S_M_M_CIASec_01'}, wantedLevel = 2, spawnChance = 3, numPeds = 2, loadout = 'undercover' },
        { model = 'riot', peds = {'S_M_Y_Swat_01'}, wantedLevel = 3, spawnChance = 10, numPeds = 4, loadout = 'riot' },
        { model = 'fbi', peds = {'S_M_M_FIBSec_01'}, wantedLevel = 5, spawnChance = 15, numPeds = 2, loadout = 'fbi' },
        { model = 'fbi2', peds = {'S_M_M_FIBSec_01'}, wantedLevel = 5, spawnChance = 15, numPeds = 4, loadout = 'fbi' },
        
    },
    paletoBay = {
        { model = 'policeb', peds = {'S_M_Y_HwayCop_01'}, wantedLevel = 1, spawnChance = 1, numPeds = 1, loadout = 'bike' },
        { model = 'sheriff', peds = {'s_m_y_sheriff_01', 's_f_y_sheriff_01'}, wantedLevel = 1, spawnChance = 3, numPeds = 2, loadout = 'sheriff' },
        { model = 'sheriff2', peds = {'s_m_y_sheriff_01', 's_f_y_sheriff_01'}, wantedLevel = 1, spawnChance = 3, numPeds = 2, loadout = 'sheriff' },
        { model = 'police3', peds = {'S_M_M_CIASec_01'}, wantedLevel = 2, spawnChance = 2, numPeds = 2, loadout = 'undercover' },
        { model = 'riot', peds = {'S_M_Y_Swat_01'}, wantedLevel = 3, spawnChance = 10, numPeds = 4, loadout = 'riot' },
        { model = 'fbi', peds = {'S_M_M_FIBSec_01'}, wantedLevel = 5, spawnChance = 15, numPeds = 2, loadout = 'fbi' },
        { model = 'fbi2', peds = {'S_M_M_FIBSec_01'}, wantedLevel = 5, spawnChance = 15, numPeds = 4, loadout = 'fbi' },
    },
    sandyShores = {
        { model = 'policeb', peds = {'S_M_Y_HwayCop_01'}, wantedLevel = 1, spawnChance = 1, numPeds = 1, loadout = 'bike' },
        { model = 'sheriff', peds = {'s_m_y_sheriff_01', 's_m_y_sheriff_01'}, wantedLevel = 1, spawnChance = 3, numPeds = 2, loadout = 'sheriff' },
        { model = 'sheriff2', peds = {'s_m_y_sheriff_01', 's_m_y_sheriff_01'}, wantedLevel = 1, spawnChance = 3, numPeds = 2, loadout = 'sheriff' },
        { model = 'police3', peds = {'S_M_M_CIASec_01'}, wantedLevel = 2, spawnChance = 2, numPeds = 2, loadout = 'undercover' },
        { model = 'riot', peds = {'S_M_Y_Swat_01'}, wantedLevel = 3, spawnChance = 10, numPeds = 4, loadout = 'riot' },
        { model = 'fbi', peds = {'S_M_M_FIBSec_01'}, wantedLevel = 5, spawnChance = 15, numPeds = 2, loadout = 'fbi' },
        { model = 'fbi2', peds = {'S_M_M_FIBSec_01'}, wantedLevel = 5, spawnChance = 15, numPeds = 4, loadout = 'fbi' },
    },
    countryside = {
        { model = 'policeb', peds = {'S_M_Y_HwayCop_01'}, wantedLevel = 1, spawnChance = 2, numPeds = 1, loadout = 'bike' },
        { model = 'sheriff', peds = {'s_m_y_sheriff_01', 's_f_y_sheriff_01'}, wantedLevel = 1, spawnChance = 2, numPeds = 2, loadout = 'sheriff' },
        { model = 'sheriff2', peds = {'s_m_y_sheriff_01', 's_f_y_sheriff_01'}, wantedLevel = 1, spawnChance = 2, numPeds = 2, loadout = 'sheriff' },
        { model = 'pranger', peds = { 's_m_y_ranger_01', 's_f_y_ranger_01'}, wantedLevel = 1, spawnChance = 8, numPeds = 2, loadout = 'ranger' },
        { model = 'police4', peds = {'S_M_M_CIASec_01'}, wantedLevel = 2, spawnChance = 2, numPeds = 2, loadout = 'undercover' },
        { model = 'police3', peds = {'S_M_M_CIASec_01'}, wantedLevel = 2, spawnChance = 4, numPeds = 2, loadout = 'undercover' },
        { model = 'riot', peds = {'S_M_Y_Swat_01'}, wantedLevel = 3, spawnChance = 10, numPeds = 4, loadout = 'riot' },
        { model = 'fbi', peds = {'S_M_M_FIBSec_01'}, wantedLevel = 5, spawnChance = 15, numPeds = 2, loadout = 'fbi' },
        { model = 'fbi2', peds = {'S_M_M_FIBSec_01'}, wantedLevel = 5, spawnChance = 15, numPeds = 4, loadout = 'fbi' },
    }
}

Config.polHelis = {
    { model = 'polmav', pilots = {"S_M_M_Pilot_02"}, numPilots = 2, peds = {'s_m_y_cop_01', 's_f_y_cop_01'}, numPeds = 2, wantedLevel = 3, spawnChance = 1, loadout = 'airPatrol' },   
    { model = 'buzzard2', pilots = {"S_M_M_Pilot_02"}, numPilots = 2, peds = {'S_M_M_CIASec_01'}, numPeds = 2, wantedLevel = 3, spawnChance = 1, loadout = 'airPatrol' },   
    { model = 'polmav', pilots = {"S_M_M_Pilot_02"}, numPilots = 2, peds = {'S_M_Y_Swat_01'}, numPeds = 2, wantedLevel = 4, spawnChance = 1, loadout = 'airPatrol' }, 
}

Config.milHelis = {
    { model = 'hunter', pilots = {"S_M_M_Pilot_02"}, numPilots = 2, peds = {}, numPeds = 0, wantedLevel = 4, spawnChance = 1, loadout = 'airPatrol' },   
}

Config.milPlanes = {
    { model = 'lazer', pilots = {"S_M_M_Pilot_02"}, numPilots = 1, peds = {}, numPeds = 0, wantedLevel = 4, spawnChance = 1, loadout = 'airPatrol' }, 
}




-- OFFICER LOADOUTS --

Config.loadouts = {
    patrol = {
        primaryWeapons = {
            { name = 'weapon_pistol', weight = 3 },
            { name = 'weapon_combatpistol', weight = 1 },
        },
        secondaryWeapons = {
            { name = 'weapon_pumpshotgun', weight = 4 },
            { name = 'weapon_carbinerifle', weight = 1 },
            { name = 'weapon_smg', weight = 1 },
        },
        secondaryChance = 0.15,
        armorChance = 0.5,
        armorValue = 40,
        armorModel = 'prop_bodyarmour_03',
        helmetChance = 0.0,
        helmetModel = 0,
    },
    sheriff = {
        primaryWeapons = {
            { name = 'weapon_pistol', weight = 3 },
            { name = 'weapon_heavypistol', weight = 1 },
        },
        secondaryWeapons = {
            { name = 'weapon_pumpshotgun', weight = 4 },
            { name = 'weapon_carbinerifle', weight = 1 },
        },
        secondaryChance = 0.15,
        armorChance = 0.5,
        armorValue = 40,
        armorModel = 'prop_bodyarmour_04',
        helmetChance = 0.0,
        helmetModel = 0,
    },
    undercover = {
        primaryWeapons = {
            { name = 'weapon_pistol_mk2', weight = 2 },
            { name = 'weapon_heavypistol', weight = 1 },
            { name = 'weapon_snspistol', weight = 2 },
            { name = 'weapon_pistol50', weight = 1 },
        },
        secondaryWeapons = {
            { name = 'weapon_pumpshotgun', weight = 1 },
            { name = 'weapon_carbinerifle', weight = 2 },
            { name = 'weapon_smg', weight = 2 },
        },
        secondaryChance = 0.25,
        armorChance = 1.0,
        armorValue = 40,
        armorModel = 'prop_bodyarmour_04',
        helmetChance = 0.0,
        helmetModel = 0,
    },
    bike = {
        primaryWeapons = {
            { name = 'weapon_revolver', weight = 1 },
            { name = 'weapon_combatpistol', weight = 1 },
            { name = 'weapon_snspistol', weight = 1 },
            { name = 'weapon_doubleaction', weight = 1 },
        },
        secondaryWeapons = {},
        secondaryChance = 0.0,
        armorChance = 0.0,
        armorValue = 40,
        armorModel = 'prop_bodyarmour_03',
        helmetChance = 1.0,
        helmetModel = 0, -- In theory -1 is disabled, 0 would be the first variation. The bike model should have only one helmet variation and thus 0 should work. 
    },
    ranger = {
        primaryWeapons = {
            { name = 'weapon_heavypistol', weight = 3 },
            { name = 'weapon_pistol_mk2', weight = 1 },
        },
        secondaryWeapons = {
            { name = 'weapon_pumpshotgun', weight = 6 },
            { name = 'weapon_carbinerifle', weight = 2 },
            { name = 'weapon_marksmanrifle', weight = 1 },
        },
        secondaryChance = 0.5,
        armorChance = 0.5,
        armorValue = 40,
        armorModel = 'prop_bodyarmour_04',
        helmetChance = 0.0,
        helmetModel = 0,
    },
    fbi = {
        primaryWeapons = {
            { name = 'weapon_pistol_mk2', weight = 3 },
            { name = 'weapon_heavypistol', weight = 1 },
        },
        secondaryWeapons = {
            { name = 'weapon_combatpdw', weight = 2 },
            { name = 'weapon_carbinerifle_mk2', weight = 1 },
            { name = 'weapon_assaultshotgun', weight = 1 },
            
        },
        secondaryChance = 0.8,
        armorChance = 1.0,
        armorValue = 60,
        armorModel = 'prop_bodyarmour_03',
        helmetChance = 0.0,
        helmetModel = 0,
    },
    riot = {
        primaryWeapons = {
            { name = 'weapon_combatpistol', weight = 2 },
            { name = 'weapon_heavypistol', weight = 1 },
        },
        secondaryWeapons = {
            { name = 'weapon_carbinerifle', weight = 2 },
            { name = 'weapon_smg', weight = 3 },
            { name = 'weapon_combatshotgun', weight = 2 },
            { name = 'weapon_marksmanrifle', weight = 1 },
        },
        secondaryChance = 1.0,
        armorChance = 1.0,
        armorValue = 80,
        armorModel = 'prop_bodyarmour_03',
        helmetChance = 1.0,
        helmetModel = 0, -- In theory -1 is disabled, 0 would be the first variation. The SWAT model should have only one helmet variation and thus 0 should work. 
    },
    airPatrol = {
        primaryWeapons = {
            { name = 'weapon_pistol', weight = 3 },
            { name = 'weapon_combatpistol', weight = 1 },
        },
        secondaryWeapons = {
            { name = 'weapon_smg', weight = 1 },
        },
        secondaryChance = 0.15,
        armorChance = 0.5,
        armorValue = 40,
        armorModel = 'prop_bodyarmour_03',
        helmetChance = 0.0,
        helmetModel = 0,
    },
}


--known locations
--these are locations pulled from other qb files to make a list of kown places and a setting a wanted level

Config.locations = {
    [1] = { vector3(-47.24, -1757.65, 29.53), type = 'Registers', wanted = 1},
    [2] = { vector3(-48.58, -1759.21, 29.59), type = 'Registers', wanted = 1 },
    [3] = { vector3(-1486.26, -378.0, 40.16), type = 'Registers', wanted = 1 },
    [4] = { vector3(-1222.03, -908.32, 12.32), type = 'Registers', wanted = 1 },
    [5] = { vector3(-706.08, -915.42, 19.21), type = 'Registers', wanted = 1 },
    [6] = { vector3(-706.16, -913.5, 19.21), type = 'Registers', wanted = 1 },
    [7] = { vector3(24.47, -1344.99, 29.49), type = 'Registers', wanted = 1 },
    [8] = { vector3(24.45, -1347.37, 29.49), type = 'Registers', wanted = 1 },
    [9] = { vector3(1134.15, -982.53, 46.41), type = 'Registers', wanted = 1 },
    [10] = { vector3(1165.05, -324.49, 69.2), type = 'Registers', wanted = 1 },
    [11] = { vector3(1164.7, -322.58, 69.2), type = 'Registers', wanted = 1 },
    [12] = { vector3(373.14, 328.62, 103.56), type = 'Registers', wanted = 1 },
    [13] = { vector3(372.57, 326.42, 103.56), type = 'Registers', wanted = 1 },
    [14] = { vector3(-1818.9, 792.9, 138.08), type = 'Registers', wanted = 1 },
    [15] = { vector3(-1820.17, 794.28, 138.08), type = 'Registers', wanted = 1 },
    [16] = { vector3(-2966.46, 390.89, 15.04), type = 'Registers', wanted = 1 },
    [17] = { vector3(-3041.14, 583.87, 7.9), type = 'Registers', wanted = 1 },
    [18] = { vector3(-3038.92, 584.5, 7.9), type = 'Registers', wanted = 1 },
    [19] = { vector3(-3244.56, 1000.14, 12.83), type = 'Registers', wanted = 1 },
    [20] = { vector3(-3242.24, 999.98, 12.83), type = 'Registers', wanted = 1 },
    [21] = { vector3(549.42, 2669.06, 42.15), type = 'Registers', wanted = 1 },
    [22] = { vector3(549.05, 2671.39, 42.15), type = 'Registers', wanted = 1 },
    [23] = { vector3(1165.9, 2710.81, 38.15), type = 'Registers', wanted = 1 },
    [24] = { vector3(2676.02, 3280.52, 55.24), type = 'Registers', wanted = 1 },
    [25] = { vector3(2678.07, 3279.39, 55.24), type = 'Registers', wanted = 1 },
    [26] = { vector3(1958.96, 3741.98, 32.34), type = 'Registers', wanted = 1 },
    [27] = { vector3(1960.13, 3740.0, 32.34), type = 'Registers', wanted = 1 },
    [28] = { vector3(1728.86, 6417.26, 35.03), type = 'Registers', wanted = 1 },
    [29] = { vector3(1727.85, 6415.14, 35.03), type = 'Registers', wanted = 1 },
    [30] = { vector3(-161.07, 6321.23, 31.5), type = 'Registers', wanted = 1 },
    [31] = { vector3(160.52, 6641.74, 31.6), type = 'Registers', wanted = 1 },
    [32] = { vector3(162.16, 6643.22, 31.6), type = 'Registers', wanted = 1 },
    [33] = { vector3(-43.43, -1748.3, 29.42), type = 'Safes', wanted = 1 },
    [34] = { vector3(-1478.94, -375.5, 39.16), type = 'Safes', wanted = 1 },
    [35] = { vector3(-1220.85, -916.05, 11.32), type = 'Safes', wanted = 1 },
    [36] = { vector3(-709.74, -904.15, 19.21), type = 'Safes', wanted = 1 },
    [37] = { vector3(28.21, -1339.14, 29.49), type = 'Safes', wanted = 1 },
    [38] = { vector3(1126.77, -980.1, 45.41), type = 'Safes', wanted = 1 },
    [39] = { vector3(1159.46, -314.05, 69.2), type = 'Safes', wanted = 1 },
    [40] = { vector3(378.17, 333.44, 103.56), type = 'Safes', wanted = 1 },
    [41] = { vector3(-1829.27, 798.76, 138.19), type = 'Safes', wanted = 1 },
    [42] = { vector3(-2959.64, 387.08, 14.04), type = 'Safes', wanted = 1 },
    [43] = { vector3(-3047.88, 585.61, 7.9), type = 'Safes', wanted = 1 },
    [44] = { vector3(-3250.02, 1004.43, 12.83), type = 'Safes', wanted = 1 },
    [45] = { vector3(546.41, 2662.8, 42.15), type = 'Safes', wanted = 1 },
    [46] = { vector3(1169.31, 2717.79, 37.15), type = 'Safes', wanted = 1 },
    [47] = { vector3(2672.69, 3286.63, 55.24), type = 'Safes', wanted = 1 },
    [48] = { vector3(1959.26, 3748.92, 32.34), type = 'Safes', wanted = 1 },
    [49] = { vector3(1734.78, 6420.84, 35.03), type = 'Safes', wanted = 1 },
    [50] = { vector3(-168.40, 6318.80, 30.58), type = 'Safes', wanted = 1 },
    [51] = { vector3(168.95, 6644.74, 31.70), type = 'Safes', wanted = 1 },
    [52] = { vector3(-630.5, -237.13, 38.08),type = 'jewelery', wanted = 3},
    [53] = { vector3(-149.98,6416.07,31.92), type = 'house', wanted = 2},
    [54] = { vector3(-159.84,6432.65,31.93), type = 'house', wanted = 2},
    [55] = { vector3(25.1,6601.76,32.47), type = 'house', wanted = 2},
    [56] = { vector3(-9.59,6654.23,31.7), type = 'house', wanted = 2},
    [57] = { vector3(-245.99,6414.45,31.46), type = 'house', wanted = 2},
    [58] = { vector3(-447.87,6260.25,30.05), type = 'house', wanted = 2},
    [59] = { vector3(-366.57,6214.12,31.84), type = 'house', wanted = 2},
    [60] = { vector3(-360.24,6260.61,31.9), type = 'house', wanted = 2},
    [61] = { vector3(1664.04,4739.68,42.01), type = 'house', wanted = 2},
    [62] = { vector3(1662.07,4776.19,42.07), type = 'house', wanted = 2},
    [63] = { vector3(-869.07,-1105.48,2.49), type = 'house', wanted = 2},
    [64] = { vector3(-869.53,-1103.41,6.45), type = 'house', wanted = 2},
    [65] = { vector3(-1063.57,-1160.35,2.75), type = 'house', wanted = 2},
    [66] = { vector3(-1074.13,-1152.73,2.16), type = 'house', wanted = 2},
    [67] = { vector3(-1024.42,-1140,2.75), type = 'house', wanted = 2},
    [68] = { vector3(-985.89,-1121.74,4.55), type = 'house', wanted = 2},
    [69] = { vector3(-1054.07,-1000.2,6.41), type = 'house', wanted = 2},
    [70] = { vector3(-1063.77,-1054.99,2.15), type = 'house', wanted = 2},
    [71] = { vector3(-1064.64,-1057.42,6.41), type = 'house', wanted = 2},
    [72] = { vector3(-1076.33,-1026.96,4.54), type = 'house', wanted = 2},
    [73] = { vector3(114.25,-1961.19,21.33), type = 'house', wanted = 2},
    [74] = { vector3(126.73,-1930.12,21.38), type = 'house', wanted = 2},
    [75] = { vector3(101.03,-1912.16,21.41), type = 'house', wanted = 2},
    [76] = { vector3(76.36,-1948.1,21.17), type = 'house', wanted = 2},
    [77] = { vector3(130.6,-1853.22,25.23), type = 'house', wanted = 2},
    [78] = { vector3(128.24,-1897.02,23.67), type = 'house', wanted = 2},
    [79] = { vector3(171.52,-1871.53,24.4), type = 'house', wanted = 2},
    [80] = { vector3(192.29,-1883.23,25.06), type = 'house', wanted = 2},
    [81] = { vector3(320.27,-1854.06,27.51), type = 'house', wanted = 2},
    [82] = { vector3(329.42,-1845.8,27.75), type = 'house', wanted = 2},
    [83] = { vector3(348.77,-1820.95,28.89), type = 'house', wanted = 2},
    [84] = { vector3(427.21,-1842.09,28.46), type = 'house', wanted = 2},
    [85] = { vector3(412.47,-1856.38,27.32), type = 'house', wanted = 2},
    [86] = { vector3(385.18,-1881.78,26.03), type = 'house', wanted = 2},
    [87] = { vector3(-110.05,501.83,143.38), type = 'house', wanted = 2},
    [88] = { vector3(57.56,449.68,147.03), type = 'house', wanted = 2},
    [89] = { vector3(80.09,486.26,148.2), type = 'house', wanted = 2},
    [90] = { vector3(-867.34,785,191.93), type = 'house', wanted = 2},
    [91] = { vector3(-962.7,814.09,177.57), type = 'house', wanted = 2},
    [92] = { vector3(-1065.02,772.17,170.06), type = 'house', wanted = 2},
    [93] = { vector3(-1117.77,761.48,164.29), type = 'house', wanted = 2},
    [94] = { vector3(-1130.87,784.44,163.89), type = 'house', wanted = 2},
    [95] = { vector3(-1056.34,761.34,167.32), type = 'house', wanted = 2},
    [96] = { vector3(-951.28,682.65,153.58), type = 'house', wanted = 2},
    [97] = { vector3(-908.66,693.67,151.44), type = 'house', wanted = 2},
    [98] = { vector3(-355.93,469.76,112.65), type = 'house', wanted = 2},
    [99] = { vector3(-348.73,514.95,120.65), type = 'house', wanted = 2},
    [100] = { vector3(-411.06,529.18,122.18), type = 'house', wanted = 2},
    [101] = { vector3(-418.09,568.99,125.06), type = 'house', wanted = 2},
    [102] = { vector3(-500.82,551.92,120.6), type = 'house', wanted = 2},
    [103] = { vector3(-554.48,541.26,110.71), type = 'house', wanted = 2},
    [104] = { vector3(-526.64,516.97,112.94), type = 'house', wanted = 2},
    [105] = { vector3(-536.67,477.36,103.19), type = 'house', wanted = 2},
    [106] = { vector3(-595.55,530.28,107.75), type = 'house', wanted = 2},
    [107] = { vector3(-622.84,488.88,108.88), type = 'house', wanted = 2},
    [108] = { vector3(-640.92,520.61,109.88), type = 'house', wanted = 2},
    [109] = { vector3(-678.01,512.13,113.53), type = 'house', wanted = 2},
    [110] = { vector3(-762.21,430.96,100.2), type = 'house', wanted = 2},
    [111] = { vector3(-784.72,459.77,100.39), type = 'house', wanted = 2},
    [112] = { vector3(311.15, -284.49, 54.16), type = 'small_bank', wanted = 4},
    [113] = { vector3(146.92, -1046.11, 29.36), type = 'small_bank', wanted = 4},
    [114] = { vector3(-353.82, -55.37, 49.03), type = 'small_bank', wanted = 4},
    [115] = { vector3(-1210.77, -336.57, 37.78), type = 'small_bank', wanted = 4},
    [116] = { vector3(-2956.55, 481.74, 15.69), type = 'small_bank', wanted = 4},
    [117] = { vector3(1175.96, 2712.87, 38.09), type = 'small_bank', wanted = 4},
    [118] = { vector3(-105.61, 6472.03, 31.62), type = 'big_bank', wanted = 5},
    [119] = { vector3(261.95, 223.11, 106.28), type = 'big_bank', wanted = 5},
    [120] = { vector3(253.25, 228.44, 101.68), type = 'big_bank', wanted = 5},
}


------------------------