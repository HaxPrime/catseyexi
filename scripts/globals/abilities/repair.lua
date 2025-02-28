-----------------------------------
-- Ability: Repair
-- Uses oil to restore pet's HP.
-- Obtained: Puppetmaster Level 15
-- Recast Time: 3:00
-- Duration: Instant
-----------------------------------
require("scripts/globals/settings")
require("scripts/globals/status")
require("scripts/globals/pets")
require("scripts/globals/msg")
-----------------------------------
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    if not player:getPet() then
        return xi.msg.basic.REQUIRES_A_PET, 0
    elseif not player:getPetID() or not (player:getPetID() >= 69 and player:getPetID() <= 72) then
        return xi.msg.basic.NO_EFFECT_ON_PET, 0
    else
        local id = player:getEquipID(xi.slot.AMMO)
        if (id >= 18731 and id <= 18733 or id == 19185) then
            return 0, 0
        else
            return xi.msg.basic.UNABLE_TO_USE_JA, 0
        end
    end
end

abilityObject.onUseAbility = function(player, target, ability)
    -- 1st need to get the pet food is equipped in the range slot.
    local rangeObj = player:getEquipID(xi.slot.AMMO)
    local totalHealing = 0
    local regenAmount = 0
    local regenTime = 0
    local pet = player:getPet()
    local petCurrentHP = pet:getHP()
    local petMaxHP = pet:getMaxHP()

    -- Need to start to calculate the HP to restore to the pet.
    -- Please note that I used this as base for the calculations:
    -- http://ffxiclopedia.wikia.com/wiki/Repair

    switch (rangeObj) : caseof {
        [18731] = function (x) -- Automaton Oil
            regenAmount = 10
            totalHealing = petMaxHP * 0.1
            regenTime = 30
            end,
        [18732] = function (x) -- Automaton Oil + 1
            regenAmount = 20
            totalHealing = petMaxHP * 0.2
            regenTime = 60
            end,
        [18733] = function (x) -- Automaton Oil + 2
            regenAmount = 30
            totalHealing = petMaxHP * 0.3
            regenTime = 90
            end,
        [19185] = function (x) -- Automaton Oil + 3
            regenAmount = 40
            totalHealing = petMaxHP * 0.4
            regenTime = 120
            end,
    }

    local function removeStatus()
        --if pet:delStatusEffect(xi.effect.DOOM) then return true end
        if pet:delStatusEffect(xi.effect.PETRIFICATION) then return true end
        if pet:delStatusEffect(xi.effect.SILENCE) then return true end
        if pet:delStatusEffect(xi.effect.BANE) then return true end
        if pet:delStatusEffect(xi.effect.CURSE_II) then return true end
        if pet:delStatusEffect(xi.effect.CURSE_I) then return true end
        if pet:delStatusEffect(xi.effect.PARALYSIS) then return true end
        if pet:delStatusEffect(xi.effect.PLAGUE) then return true end
        if pet:delStatusEffect(xi.effect.POISON) then return true end
        if pet:delStatusEffect(xi.effect.DISEASE) then return true end
        if pet:delStatusEffect(xi.effect.BLINDNESS) then return true end
        if pet:eraseStatusEffect() ~= 255 then return true end
        return false
    end

    local toremove = player:getMod(xi.mod.REPAIR_EFFECT)

    --[[if (feet == 28240) then -- This item isn't implemented so im leaving this here for reference
        toremove = 1
    end]]

    while toremove > 0 do
        if not removeStatus() then break end
        toremove = toremove - 1
    end

    local bonus = 1 + player:getMerit(xi.merit.REPAIR_EFFECT)/100

    totalHealing = totalHealing * bonus

    bonus = bonus + player:getMod(xi.mod.REPAIR_POTENCY)/100

    regenAmount = regenAmount * bonus

    local diff = petMaxHP - petCurrentHP

    if (diff < totalHealing) then
        totalHealing = diff
    end

    pet:addHP(totalHealing)
    pet:wakeUp()

    -- Apply regen xi.effect.

    pet:delStatusEffect(xi.effect.REGEN)
    pet:addStatusEffect(xi.effect.REGEN, regenAmount, 3, regenTime) -- 3 = tick, each 3 seconds.
    player:removeAmmo()

    return totalHealing
end

return abilityObject
