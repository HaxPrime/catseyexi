-----------------------------------
-- Area: Ru'Aun Gardens
--   NM: Seiryu
-----------------------------------
local ID = require("scripts/zones/Escha_RuAun/IDs")
mixins = {require("scripts/mixins/job_special")}
require("scripts/globals/mobs")
require("scripts/globals/status")
-----------------------------------
local entity = {}

entity.onMobSpawn = function(mob ,target)
end

entity.onMobInitialize = function(mob)
    mob:setMobMod(xi.mobMod.ADD_EFFECT, 1)
end

entity.onMobMagicPrepare = function(mob, target, spellId)
    if not mob:hasStatusEffect(xi.effect.HUNDRED_FISTS, 0) then
        local rnd = math.random()
        if rnd < 0.5 then
            return 186 -- aeroga 3
        elseif rnd < 0.7 then
            return 157 -- aero 4
        elseif rnd < 0.9 then
            return 208 -- tornado
        else
            return 237 -- choke
        end
    end
    return 0 -- Still need a return, so use 0 when not casting
end

entity.onAdditionalEffect = function(mob, target, damage)
end

entity.onMobDeath = function(mob, player, isKiller)
end

entity.onMobDespawn = function(mob)
end

return entity
