-----------------------------------
-- Area: Grand Palace of Hu'Xzoi
--  Mob: Eo'zdei
-- Animation Sub 0 Pot Form
-- Animation Sub 1 Pot Form (reverse eye position)
-- Animation Sub 2 Bar Form
-- Animation Sub 3 Ring Form
-----------------------------------
local ID = require("scripts/zones/Grand_Palace_of_HuXzoi/IDs")
require("scripts/globals/status")
-----------------------------------
local entity = {}

entity.onMobSpawn = function(mob)
    -- Set AnimationSub to 0, put it in pot form
    mob:setAnimationSub(0)
    entity.onPath(mob)
end

entity.onPath = function(mob)
    local spawnPos = mob:getSpawnPos()
    mob:pathThrough({ spawnPos.x, spawnPos.y, spawnPos.z })
    local pos = mob:getPos()
    if (spawnPos.x == pos.x and spawnPos.z == pos.z) then
        mob:setPos(spawnPos.x, spawnPos.y, spawnPos.z, mob:getRotPos() + 16)
    end
end

entity.onMobFight = function(mob)

    local randomTime = math.random(15, 45)
    local changeTime = mob:getLocalVar("changeTime")

    if (mob:getAnimationSub() == 0 and mob:getBattleTime() - changeTime > randomTime) then
        mob:setAnimationSub(math.random(2, 3))
        mob:setLocalVar("changeTime", mob:getBattleTime())
    elseif (mob:getAnimationSub() == 1 and mob:getBattleTime() - changeTime > randomTime) then
        mob:setAnimationSub(math.random(2, 3))
        mob:setLocalVar("changeTime", mob:getBattleTime())
    elseif (mob:getAnimationSub() == 2 and mob:getBattleTime() - changeTime > randomTime) then
        local aniChance = math.random(0, 1)
        if (aniChance == 0) then
            mob:setAnimationSub(0)
            mob:setLocalVar("changeTime", mob:getBattleTime())
        else
            mob:setAnimationSub(3)
            mob:setLocalVar("changeTime", mob:getBattleTime())
        end
    elseif (mob:getAnimationSub() == 3 and mob:getBattleTime() - changeTime > randomTime) then
        mob:setAnimationSub(math.random(0, 2))
        mob:setLocalVar("changeTime", mob:getBattleTime())
    end

end

entity.onMobDeath = function(mob, player, optParams)
    if optParams.isKiller then
        local mobId = mob:getID()
        local nm    = GetMobByID(ID.mob.JAILER_OF_TEMPERANCE)
        local ph    = nm:getLocalVar("ph")

        if (ph == mobId and os.time() > nm:getLocalVar("pop")) then
            local pos = mob:getSpawnPos()
            nm:setSpawn(pos.x, pos.y, pos.z)
            SpawnMob(ID.mob.JAILER_OF_TEMPERANCE):updateClaim(player)
            nm:setLocalVar("ph", ph)
            DisallowRespawn(mobId, true)
        end
    end
end

return entity
