-----------------------------------
-- Predatory Glare
-- Description: Stuns with a gaze.
-- Type: Gaze
-- Utsusemi/Blink absorb: Ignores shadows
-----------------------------------
require("scripts/globals/mobskills")
require("scripts/globals/settings")
require("scripts/globals/status")
require("scripts/globals/msg")
-----------------------------------
local mobskill_object = {}

mobskill_object.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskill_object.onMobWeaponSkill = function(target, mob, skill)
    local typeEffect = xi.effect.STUN
    skill:setMsg(xi.mobskills.mobGazeMove(mob, target, typeEffect, 1, 0, 15))

    return typeEffect
end

return mobskill_object
