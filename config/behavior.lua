-- config/behavior.lua

local BehaviorConfig = {}

BehaviorConfig.Levels = {
    [1] = function(officer)
        SetPedCombatAttributes(officer, 46, false) -- Don't shoot from vehicle
        SetPedCombatAttributes(officer, 2, false)  -- No drive-by
        SetPedCombatAttributes(officer, 3, false)  -- Allow to flee
        SetPedFleeAttributes(officer, 0, 0)        -- Don't flee from anything
        SetPedSeeingRange(officer, 100.0)
        SetPedHearingRange(officer, 100.0)
        SetPedAlertness(officer, 3)
    end,

    [2] = function(officer)
        -- Escalated behavior
        SetPedCombatAttributes(officer, 46, false)
        SetPedCombatAttributes(officer, 2, true)
        SetPedCombatAttributes(officer, 3, false)
        SetPedFleeAttributes(officer, 0, 0)
        SetPedSeeingRange(officer, 120.0)
        SetPedHearingRange(officer, 120.0)
        SetPedAlertness(officer, 3)
        SetPedAccuracy(officer, 25)
    end,

    [3] = function(officer)
        -- More aggressive
        SetPedCombatAttributes(officer, 46, true)
        SetPedCombatAttributes(officer, 2, true)
        SetPedCombatAttributes(officer, 3, false)
        SetPedFleeAttributes(officer, 0, 0)
        SetPedSeeingRange(officer, 150.0)
        SetPedHearingRange(officer, 150.0)
        SetPedAlertness(officer, 3)
        SetPedAccuracy(officer, 40)
    end
}

return BehaviorConfig
