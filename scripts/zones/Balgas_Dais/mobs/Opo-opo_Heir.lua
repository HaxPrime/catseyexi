-----------------------------------
-- Area: Balga's Dais
--  Mob: Opo-opo Heir
-- BCNM: Royal Succession
-----------------------------------
require("scripts/globals/status")
-----------------------------------
local entity = {}

entity.onMobSpawn = function(mob)
    mob:SetAutoAttackEnabled(false)
    mob:SetMobAbilityEnabled(false)
end

entity.onMobFight = function(mob, target)
    local partner = (mob:getID() - 1)
    if (GetMobByID(partner):isDead() and mob:getLocalVar("buffed") == 0) then
        mob:setLocalVar("buffed", 1)
        mob:SetAutoAttackEnabled(true)
        mob:SetMobAbilityEnabled(true)
        mob:addHP(mob:getMaxHP()/2)
        mob:addMod(xi.mod.ATT, 500)
        if(math.random(2)==2) then
            mob:addMod(xi.mod.UDMGPHYS, -10000)
            mob:addMod(xi.mod.UDMGRANGE, -10000)
        else
            mob:setMod(xi.mod.UDMGMAGIC, -10000)
        end
    end
end

entity.onMobDeath = function(mob, player, optParams)
end

return entity
