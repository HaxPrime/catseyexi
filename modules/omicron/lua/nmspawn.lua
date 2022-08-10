-----------------------------------

-----------------------------------
require("modules/module_utils")
require("scripts/mixins/rage")
require("scripts/globals/mobs")
require("scripts/globals/status")
require("scripts/zones/Escha_RuAun/Zone")
mixins = {require("scripts/mixins/job_special")}
-----------------------------------
local m = Module:new("Escha_NM")

m:addOverride("xi.zones.GM_Home.Zone.onInitialize", function(zone)
    super(zone)

    -- cleanup variables
    if GetServerVariable("Avatar1") > 1 then
       SetServerVariable("Avatar1", 0)
    end
    if GetServerVariable("Avatar2") > 1 then
       SetServerVariable("Avatar2", 0)
    end
    if GetServerVariable("Avatar3") > 1 then
       SetServerVariable("Avatar3", 0)
    end
    if GetServerVariable("Avatar4") > 1 then
       SetServerVariable("Avatar4", 0)
    end
    
end)

m:addOverride("xi.zones.Escha_RuAun.Zone.onZoneTick", function(zone, mob)
    super(zone)
                            ------------------
                            -- Byakko Spawn --
                            ------------------
    if
        GetServerVariable("[Eschan]Byakko") == 1 and                -- Correct NM
        (os.time() - GetServerVariable("[Eschan]Byakko_Time")) > 5  -- NM Cooldown
    then
        local mob = zone:insertDynamicEntity({
                objtype = xi.objType.MOB,
                name = "Escha Byakko",
                x = -417.141,
                y = -70.298,
                z = 409.665,
                rotation = 50,
                groupId = 78,
                groupZoneId = 289,

            onMobSpawn = function(mob)
            SetServerVariable("[Eschan]Byakko", 0)   
			
			xi.mix.jobSpecial.config(mob, {
                specials =
                {
                    {
                        id = xi.jsa.PERFECT_DODGE,
                        hpp = 50,
                        begCode = function(mob)
                            mob:messageText(mob, ID.text.HOW_CAN_YOU_EXPECT_TO_KILL_ME)
                        end,
                        endCode = function(mob)
                            mob:messageText(mob, ID.text.WHEN_YOU_CANT_EVEN_HIT_ME)
                        end,
                    },
                },
            })
			
            end,
			
            onMobDeath = function(mob, player, isKiller, noKiller)
                player:setCharVar("[Eschan]Byakko",1)
            end,
            releaseIdOnDeath = true,
        })
        mob:setDropID(3990)
        mob:setSpawn(-417.141, -70.298, 409.665, 50)
        mob:spawn()
        mob:setMobMod(xi.mobMod.CHECK_AS_NM, 1)
        mob:setMobLevel(95)
        mob:setMobMod(xi.mobMod.DRAW_IN, 2)	
        mob:setMobMod(xi.mobMod.SKILL_LIST, 279)
        mob:setMobMod(xi.mobMod.SPELL_LIST, 26)	
        mob:addMod(xi.mod.STR, 30)
        mob:addMod(xi.mod.VIT, 30)
        mob:addMod(xi.mod.INT, 30)
        mob:addMod(xi.mod.MND, 30)
        mob:addMod(xi.mod.CHR, 30)
        mob:addMod(xi.mod.AGI, 30)
        mob:addMod(xi.mod.DEX, 30)
        mob:addMod(xi.mod.DEFP, 30)
        mob:addMod(xi.mod.RATTP, 30)
        mob:addMod(xi.mod.ACC, 100)
        mob:setMod(xi.mod.CRITHITRATE, 20)
        mob:setMod(xi.mod.CRIT_DMG_INCREASE, 10)
        mob:addMod(xi.mod.MAIN_DMG_RATING, 50)		
        mob:setMod(xi.mod.SILENCERES, 10000)
        mob:setMod(xi.mod.STUNRES, 10000)
        mob:setMod(xi.mod.BINDRES, 10000)
        mob:setMod(xi.mod.GRAVITYRES, 10000)
        mob:setMod(xi.mod.SLEEPRES, 10000)
        mob:setMod(xi.mod.POISONRES, 10000)
        mob:setMod(xi.mod.PARALYZERES, 10000)
        mob:setMod(xi.mod.LULLABYRES, 10000)
        mob:setMod(xi.mod.DOUBLE_ATTACK, 20)
        mob:setMod(xi.mod.EARTH_MEVA, 150)
        mob:setMod(xi.mod.DARK_MEVA, 128)
        mob:setMod(xi.mod.LIGHT_MEVA, 200)
        mob:setMod(xi.mod.FIRE_MEVA, 150)
        mob:setMod(xi.mod.WATER_MEVA, 150)
        mob:setMod(xi.mod.THUNDER_MEVA, 150)
        mob:setMod(xi.mod.WIND_MEVA, 150)
        mob:setMod(xi.mod.ICE_MEVA, 150)
        mob:setMod(xi.mod.EARTH_SDT, 150)
        mob:setMod(xi.mod.LIGHT_SDT, 200)
        mob:setMod(xi.mod.FIRE_SDT, 150)
        mob:setMod(xi.mod.WATER_SDT, 150)
        mob:setMod(xi.mod.THUNDER_SDT, 150)
        mob:setMod(xi.mod.ICE_SDT, 150)
        mob:setMod(xi.mod.WIND_SDT, 150)	
        mob:setMod(xi.mod.LIGHT_ABSORB, 100)
        mob:setMod(xi.mod.FASTCAST, 20)
        mob:addStatusEffect(xi.effect.REGEN, 30, 3, 0)
        mob:addStatusEffect(xi.effect.REFRESH, 30, 3, 0)
		mob:addStatusEffect(xi.effect.REGAIN, 30, 3, 0)
    end
    
                            ------------------
                            -- Suzaku Spawn --
                            ------------------
    if
        GetServerVariable("[Eschan]Suzaku") == 1 and                -- Correct NM
        (os.time() - GetServerVariable("[Eschan]Suzaku_Time")) > 5  -- NM Cooldown
    then
        local mob = zone:insertDynamicEntity({
                objtype = xi.objType.MOB,
                name = "Escha Suzaku",
                x = -513.394,
                y = -70.020,
                z = -269.371,
                rotation = 50,
                groupId = 81,
                groupZoneId = 289,

            onMobSpawn = function(mob)
            SetServerVariable("[Eschan]Suzaku", 0)
            end,    
            
            onMobDeath = function(mob, player, isKiller, noKiller)
                player:setCharVar("[Eschan]Suzaku",1)
            end,
            releaseIdOnDeath = true,
        })
        mob:setDropID(3992)
        mob:setSpawn(-513.394, -70.020, -269.371, 50)
        mob:spawn()
        mob:setMobMod(xi.mobMod.CHECK_AS_NM, 1)
        mob:setMobLevel(95)
        mob:setMaxHP(30000)	
        mob:setMaxMP(15000)		
        mob:setMobMod(xi.mobMod.DRAW_IN, 2)	
        mob:setMobMod(xi.mobMod.SKILL_LIST, 280)
        mob:setMobMod(xi.mobMod.SPELL_LIST, 27)	
        mob:addMod(xi.mod.STR, 30)
        mob:addMod(xi.mod.VIT, 30)
        mob:addMod(xi.mod.INT, 30)
        mob:addMod(xi.mod.MND, 30)
        mob:addMod(xi.mod.CHR, 30)
        mob:addMod(xi.mod.AGI, 30)
        mob:addMod(xi.mod.DEX, 30)
        mob:addMod(xi.mod.DEFP, 30)
        mob:addMod(xi.mod.RATTP, 30)
        mob:addMod(xi.mod.ACC, 100)
        mob:setMod(xi.mod.CRITHITRATE, 20)
        mob:setMod(xi.mod.CRIT_DMG_INCREASE, 10)
        mob:addMod(xi.mod.MAIN_DMG_RATING, 50)		
        mob:setMod(xi.mod.SILENCERES, 10000)
        mob:setMod(xi.mod.STUNRES, 10000)
        mob:setMod(xi.mod.BINDRES, 10000)
        mob:setMod(xi.mod.GRAVITYRES, 10000)
        mob:setMod(xi.mod.SLEEPRES, 10000)
        mob:setMod(xi.mod.POISONRES, 10000)
        mob:setMod(xi.mod.PARALYZERES, 10000)
        mob:setMod(xi.mod.LULLABYRES, 10000)
        mob:setMod(xi.mod.DOUBLE_ATTACK, 20)
        mob:setMod(xi.mod.EARTH_MEVA, 150)
        mob:setMod(xi.mod.DARK_MEVA, 150)
        mob:setMod(xi.mod.LIGHT_MEVA, 200)
        mob:setMod(xi.mod.FIRE_MEVA, 150)
        mob:setMod(xi.mod.WATER_MEVA, 150)
        mob:setMod(xi.mod.THUNDER_MEVA, 150)
        mob:setMod(xi.mod.WIND_MEVA, 150)
        mob:setMod(xi.mod.ICE_MEVA, 150)
        mob:setMod(xi.mod.EARTH_SDT, 150)
        mob:setMod(xi.mod.LIGHT_SDT, 200)
        mob:setMod(xi.mod.FIRE_SDT, 200)
        mob:setMod(xi.mod.WATER_SDT, 128)
        mob:setMod(xi.mod.THUNDER_SDT, 150)
        mob:setMod(xi.mod.ICE_SDT, 150)
        mob:setMod(xi.mod.WIND_SDT, 150)	
        mob:setMod(xi.mod.LIGHT_ABSORB, 100)
        mob:setMod(xi.mod.FASTCAST, 20)
        mob:addStatusEffect(xi.effect.REGEN, 30, 3, 0)
        mob:addStatusEffect(xi.effect.REFRESH, 30, 3, 0)
		mob:addStatusEffect(xi.effect.REGAIN, 30, 3, 0)
    end
    
                         ------------------
                         -- Genbu Spawn --
                         ------------------
    if
        GetServerVariable("[Eschan]Genbu") == 1 and               -- Correct NM
        (os.time() - GetServerVariable("[Eschan]Genbu_Time")) > 5 -- NM Cooldown
    then
        local mob = zone:insertDynamicEntity({
                objtype = xi.objType.MOB,
                name = "Escha Genbu",
                x = 260.208,
                y = -70.298,
                z = 523.173,
                rotation = 50,
                groupId = 79,
                groupZoneId = 289,

            onMobSpawn = function(mob)
            SetServerVariable("[Eschan]Genbu", 0)
            end,    
            
            onMobDeath = function(mob, player, isKiller, noKiller)
                player:setCharVar("[Eschan]Genbu",1)
            end,
            releaseIdOnDeath = true,
        })
        mob:setDropID(3991)
        mob:setSpawn(260.208, -70.298, 523.173, 50)
        mob:spawn()
        mob:setMobMod(xi.mobMod.CHECK_AS_NM, 1)
        mob:setMobLevel(95)
        mob:setMaxHP(30000)	
        mob:setMaxMP(15000)		
        mob:setMobMod(xi.mobMod.DRAW_IN, 2)	
        mob:setMobMod(xi.mobMod.SKILL_LIST, 277)
        mob:setMobMod(xi.mobMod.SPELL_LIST, 24)	
        mob:addMod(xi.mod.STR, 30)
        mob:addMod(xi.mod.VIT, 30)
        mob:addMod(xi.mod.INT, 30)
        mob:addMod(xi.mod.MND, 30)
        mob:addMod(xi.mod.CHR, 30)
        mob:addMod(xi.mod.AGI, 30)
        mob:addMod(xi.mod.DEX, 30)
        mob:addMod(xi.mod.DEFP, 30)
        mob:addMod(xi.mod.RATTP, 30)
        mob:addMod(xi.mod.ACC, 100)
        mob:setMod(xi.mod.CRITHITRATE, 20)
        mob:setMod(xi.mod.CRIT_DMG_INCREASE, 10)
        mob:addMod(xi.mod.MAIN_DMG_RATING, 50)		
        mob:setMod(xi.mod.SILENCERES, 10000)
        mob:setMod(xi.mod.STUNRES, 10000)
        mob:setMod(xi.mod.BINDRES, 10000)
        mob:setMod(xi.mod.GRAVITYRES, 10000)
        mob:setMod(xi.mod.SLEEPRES, 10000)
        mob:setMod(xi.mod.POISONRES, 10000)
        mob:setMod(xi.mod.PARALYZERES, 10000)
        mob:setMod(xi.mod.LULLABYRES, 10000)
        mob:setMod(xi.mod.DOUBLE_ATTACK, 20)
        mob:setMod(xi.mod.EARTH_MEVA, 150)
        mob:setMod(xi.mod.DARK_MEVA, 150)
        mob:setMod(xi.mod.LIGHT_MEVA, 200)
        mob:setMod(xi.mod.FIRE_MEVA, 150)
        mob:setMod(xi.mod.WATER_MEVA, 200)
        mob:setMod(xi.mod.THUNDER_MEVA, 150)
        mob:setMod(xi.mod.WIND_MEVA, 150)
        mob:setMod(xi.mod.ICE_MEVA, 150)
        mob:setMod(xi.mod.EARTH_SDT, 128)
        mob:setMod(xi.mod.LIGHT_SDT, 200)
        mob:setMod(xi.mod.FIRE_SDT, 150)
        mob:setMod(xi.mod.WATER_SDT, 150)
        mob:setMod(xi.mod.THUNDER_SDT, 150)
        mob:setMod(xi.mod.ICE_SDT, 150)
        mob:setMod(xi.mod.WIND_SDT, 150)	
        mob:setMod(xi.mod.LIGHT_ABSORB, 100)
        mob:setMod(xi.mod.FASTCAST, 20)
        mob:addStatusEffect(xi.effect.REGEN, 30, 3, 0)
        mob:addStatusEffect(xi.effect.REFRESH, 30, 3, 0)
		mob:addStatusEffect(xi.effect.REGAIN, 30, 3, 0)
    end
    
                            ------------------
                            -- Seiryu Spawn --
                            ------------------
    if
        GetServerVariable("[Eschan]Seiryu") == 1 and                -- Correct NM
        (os.time() - GetServerVariable("[Eschan]Seiryu_Time")) > 5  -- NM Cooldown
    then
        local mob = zone:insertDynamicEntity({
                objtype = xi.objType.MOB,
                name = "Escha Seiryu",
                x = -417.141,
                y = -70.298,
                z = 409.665,
                rotation = 50,
                groupId = 80,
                groupZoneId = 289,

            onMobSpawn = function(mob)
               SetServerVariable("[Eschan]Seiryu", 0)
            end,    
            
            onMobDeath = function(mob, player, isKiller, noKiller)
                player:setCharVar("[Eschan]Seiryu",1)
            end,
            releaseIdOnDeath = true,
        })
        mob:setDropID(3993)
        mob:setSpawn(581.474, -70.298, -86.974, 50)
        mob:spawn()
        mob:setMobMod(xi.mobMod.CHECK_AS_NM, 1)
        mob:setMobLevel(95)
        mob:setMaxHP(30000)	
        mob:setMaxMP(15000)		
        mob:setMobMod(xi.mobMod.DRAW_IN, 2)	
        mob:setMobMod(xi.mobMod.SKILL_LIST, 278)
        mob:setMobMod(xi.mobMod.SPELL_LIST, 25)	
        mob:addMod(xi.mod.STR, 30)
        mob:addMod(xi.mod.VIT, 30)
        mob:addMod(xi.mod.INT, 30)
        mob:addMod(xi.mod.MND, 30)
        mob:addMod(xi.mod.CHR, 30)
        mob:addMod(xi.mod.AGI, 30)
        mob:addMod(xi.mod.DEX, 30)
        mob:addMod(xi.mod.DEFP, 30)
        mob:addMod(xi.mod.RATTP, 30)
        mob:addMod(xi.mod.ACC, 100)
        mob:setMod(xi.mod.CRITHITRATE, 20)
        mob:setMod(xi.mod.CRIT_DMG_INCREASE, 10)
        mob:addMod(xi.mod.MAIN_DMG_RATING, 50)		
        mob:setMod(xi.mod.SILENCERES, 10000)
        mob:setMod(xi.mod.STUNRES, 10000)
        mob:setMod(xi.mod.BINDRES, 10000)
        mob:setMod(xi.mod.GRAVITYRES, 10000)
        mob:setMod(xi.mod.SLEEPRES, 10000)
        mob:setMod(xi.mod.POISONRES, 10000)
        mob:setMod(xi.mod.PARALYZERES, 10000)
        mob:setMod(xi.mod.LULLABYRES, 10000)
        mob:setMod(xi.mod.DOUBLE_ATTACK, 20)
        mob:setMod(xi.mod.EARTH_MEVA, 150)
        mob:setMod(xi.mod.DARK_MEVA, 128)
        mob:setMod(xi.mod.LIGHT_MEVA, 200)
        mob:setMod(xi.mod.FIRE_MEVA, 150)
        mob:setMod(xi.mod.WATER_MEVA, 150)
        mob:setMod(xi.mod.THUNDER_MEVA, 150)
        mob:setMod(xi.mod.WIND_MEVA, 150)
        mob:setMod(xi.mod.ICE_MEVA, 150)
        mob:setMod(xi.mod.EARTH_SDT, 150)
        mob:setMod(xi.mod.LIGHT_SDT, 200)
        mob:setMod(xi.mod.FIRE_SDT, 150)
        mob:setMod(xi.mod.WATER_SDT, 150)
        mob:setMod(xi.mod.THUNDER_SDT, 150)
        mob:setMod(xi.mod.ICE_SDT, 150)
        mob:setMod(xi.mod.WIND_SDT, 150)	
        mob:setMod(xi.mod.LIGHT_ABSORB, 100)
        mob:setMod(xi.mod.FASTCAST, 20)
        mob:addStatusEffect(xi.effect.REGEN, 30, 3, 0)
        mob:addStatusEffect(xi.effect.REFRESH, 30, 3, 0)
		mob:addStatusEffect(xi.effect.REGAIN, 30, 3, 0)
    end
                            -----------
                            -- Kirin --
                            -----------
     if
        GetServerVariable("[Eschan]Kirin") == 1 and                -- Correct NM
        (os.time() - GetServerVariable("[Eschan]Kirin_Time")) > 5  -- NM Cooldown
    then
            
        local mob = zone:insertDynamicEntity({
                objtype = xi.objType.MOB,
                name = "Escha Kirin",
                x = -1.582,
                y = -54.039,
                z = -597.508,
                rotation = 50,
                groupId = 64,
        groupZoneId = 288,

        onMobSpawn = function(mob)
            SetServerVariable("[Eschan]Kirin", 0)
        mob:setMobMod(xi.mobMod.CHECK_AS_NM, 1)
            mob:setMod(xi.mod.DEF, 550)
            mob:setMod(xi.mod.MEVA, 475)
            mob:setMod(xi.mod.MDEF, 682)
            -- Make sure model is reset back to start
            mob:setModelId(403)
            mob:setMobMod(xi.mobMod.SKILL_LIST, 281)
            mob:setMobMod(xi.mobMod.SPELL_LIST, 23)
            -- Prevent death and hide HP until final phase
            mob:hideHP(true)
        end,
        onMobFight = function(mob, target)

            local lifePercent = mob:getHPP()
            if lifePercent < 70 then
                mob:setModelId(407) -- Genbu
                mob:setMobMod(xi.mobMod.SKILL_LIST, 277)
                mob:setMobMod(xi.mobMod.SPELL_LIST, 24)
                mob:setMod(xi.mod.DEF, 1000)
                mob:setMod(xi.mod.MEVA, 1000)
                mob:setMod(xi.mod.STR, 50)
                mob:setMod(xi.mod.VIT, 20)
                mob:setMod(xi.mod.INT, 50)
                mob:setMod(xi.mod.MND, 20)
                mob:setMod(xi.mod.CHR, 20)
                mob:setMod(xi.mod.AGI, 20)
                mob:setMod(xi.mod.DEX, 40)
                mob:setMod(xi.mod.DEFP, 0)
                mob:setMod(xi.mod.RATTP, 0)
                mob:setMod(xi.mod.DEFP, 475)
                mob:setMod(xi.mod.RATTP, 475)
                mob:setMod(xi.mod.ACC, 100)
                mob:setMod(xi.mod.DOUBLE_ATTACK, 5)
                mob:setMod(xi.mod.EARTH_MEVA, 170)
                mob:setMod(xi.mod.DARK_MEVA, 250)
                mob:setMod(xi.mod.LIGHT_MEVA, 128)
                mob:setMod(xi.mod.FIRE_MEVA, 170)
                mob:setMod(xi.mod.WATER_MEVA, 170)
                mob:setMod(xi.mod.THUNDER_MEVA, 170)
                mob:setMod(xi.mod.ICE_MEVA, 200)
                mob:setMod(xi.mod.WIND_MEVA, 170)
                mob:setMod(xi.mod.SILENCERES, 100)
                mob:setMod(xi.mod.FIRE_ABSORB, 100)
                mob:setMod(xi.mod.STUNRES, 50)
                mob:setMod(xi.mod.BINDRES, 100)
                mob:setMod(xi.mod.GRAVITYRES, 100)
                mob:setMod(xi.mod.SLEEPRES, 100)
                mob:setMod(xi.mod.PARALYZERES, 100)
                mob:setMod(xi.mod.LULLABYRES, 100)
                mob:setMod(xi.mod.FASTCAST, 100)
                mob:addStatusEffect(xi.effect.REGEN, 50, 3, 0)
                mob:addStatusEffect(xi.effect.REFRESH, 50, 3, 0)
            end
            if lifePercent < 60 then
                mob:setModelId(399) -- Seiryu
                mob:setMobMod(xi.mobMod.SKILL_LIST, 278)
                mob:setMobMod(xi.mobMod.SPELL_LIST, 25)
                mob:setMod(xi.mod.DEF, 550)
                mob:setMod(xi.mod.MEVA, 475)
                mob:setMod(xi.mod.MDEF, 682)
                mob:setMod(xi.mod.STR, 40)
                mob:setMod(xi.mod.VIT, 20)
                mob:setMod(xi.mod.INT, 50)
                mob:setMod(xi.mod.MND, 20)
                mob:setMod(xi.mod.CHR, 20)
                mob:setMod(xi.mod.AGI, 20)
                mob:setMod(xi.mod.DEX, 40)
                mob:setMod(xi.mod.DEFP, 0)
                mob:setMod(xi.mod.RATTP, 0)
                mob:setMod(xi.mod.DEFP, 475)
                mob:setMod(xi.mod.RATTP, 475)
                mob:setMod(xi.mod.ACC, 150)
                mob:setMod(xi.mod.EARTH_MEVA, 128)
                mob:setMod(xi.mod.DARK_MEVA, 250)
                mob:setMod(xi.mod.LIGHT_MEVA, 200)
                mob:setMod(xi.mod.ICE_MEVA, 200)
                mob:setMod(xi.mod.FIRE_MEVA, 200)
                mob:setMod(xi.mod.WATER_MEVA, 200)
                mob:setMod(xi.mod.THUNDER_MEVA, 200)
                mob:setMod(xi.mod.WIND_MEVA, 200)
                mob:setMod(xi.mod.SILENCERES, 100)
                mob:setMod(xi.mod.STUNRES, 50)
                mob:setMod(xi.mod.BINDRES, 100)
                mob:setMod(xi.mod.GRAVITYRES, 100)
                mob:setMod(xi.mod.SLEEPRES, 100)
                mob:setMod(xi.mod.POISONRES, 100)
                mob:setMod(xi.mod.PARALYZERES, 100)
                mob:setMod(xi.mod.LULLABYRES, 100)
                mob:setMod(xi.mod.FASTCAST, 10)
                mob:addStatusEffect(xi.effect.REGEN, 30, 3, 0)
                mob:addStatusEffect(xi.effect.REFRESH, 50, 3, 0)
            end
            if lifePercent < 50 then
                mob:setModelId(338) -- Suzaku
                mob:setMobMod(xi.mobMod.SKILL_LIST, 280)
                mob:setMobMod(xi.mobMod.SPELL_LIST, 27)
                mob:setMod(xi.mod.STR, 50)
                mob:setMod(xi.mod.VIT, 20)
                mob:setMod(xi.mod.INT, 50)
                mob:setMod(xi.mod.MND, 20)
                mob:setMod(xi.mod.CHR, 20)
                mob:setMod(xi.mod.AGI, 50)
                mob:setMod(xi.mod.DEX, 50)
                mob:setMod(xi.mod.DEFP, 0)
                mob:setMod(xi.mod.RATTP, 0)
                mob:setMod(xi.mod.DEFP, 450)
                mob:setMod(xi.mod.RATTP, 450)
                mob:setMod(xi.mod.ACC, 150)
                mob:setMod(xi.mod.EVA, 100)
                mob:setMod(xi.mod.TRIPLE_ATTACK, 5)
                mob:setMod(xi.mod.EARTH_MEVA, 170)
                mob:setMod(xi.mod.DARK_MEVA, 250)
                mob:setMod(xi.mod.LIGHT_MEVA, 128)
                mob:setMod(xi.mod.FIRE_MEVA, 128)
                mob:setMod(xi.mod.WATER_MEVA, 170)
                mob:setMod(xi.mod.THUNDER_MEVA, 170)
                mob:setMod(xi.mod.ICE_MEVA, 200)
                mob:setMod(xi.mod.WIND_MEVA, 170)
                mob:setMod(xi.mod.SILENCERES, 100)
                mob:setMod(xi.mod.STUNRES, 50)
                mob:setMod(xi.mod.BINDRES, 100)
                mob:setMod(xi.mod.GRAVITYRES, 100)
                mob:setMod(xi.mod.SLEEPRES, 100)
                mob:setMod(xi.mod.PARALYZERES, 100)
                mob:setMod(xi.mod.LULLABYRES, 100)
                mob:setMod(xi.mod.FASTCAST, 10)
                mob:addStatusEffect(xi.effect.REGEN, 30, 3, 0)
                mob:addStatusEffect(xi.effect.REFRESH, 50, 3, 0)
            end
            if lifePercent < 40 then
                mob:setModelId(309) -- Byakko
                mob:setMobMod(xi.mobMod.SKILL_LIST, 279)
                mob:setMobMod(xi.mobMod.SPELL_LIST, 26)
                mob:setMod(xi.mod.STR, 40)
                mob:setMod(xi.mod.VIT, 20)
                mob:setMod(xi.mod.INT, 65)
                mob:setMod(xi.mod.MND, 20)
                mob:setMod(xi.mod.CHR, 20)
                mob:setMod(xi.mod.AGI, 20)
                mob:setMod(xi.mod.DEX, 40)
                mob:setMod(xi.mod.DEFP, 0)
                mob:setMod(xi.mod.RATTP, 0)
                mob:setMod(xi.mod.DEFP, 525)
                mob:setMod(xi.mod.RATTP, 525)
                mob:setMod(xi.mod.ACC, 100)
                mob:setMod(xi.mod.EARTH_MEVA, 200)
                mob:setMod(xi.mod.DARK_MEVA, 250)
                mob:setMod(xi.mod.LIGHT_MEVA, 200)
                mob:setMod(xi.mod.FIRE_MEVA, 128)
                mob:setMod(xi.mod.WATER_MEVA, 200)
                mob:setMod(xi.mod.THUNDER_MEVA, 200)
                mob:setMod(xi.mod.WIND_MEVA, 200)
                mob:setMod(xi.mod.ICE_MEVA, 200)
                mob:setMod(xi.mod.SILENCERES, 100)
                mob:setMod(xi.mod.ICE_ABSORB, 100)
                mob:setMod(xi.mod.STUNRES, 50)
                mob:setMod(xi.mod.BINDRES, 100)
                mob:setMod(xi.mod.GRAVITYRES, 100)
                mob:setMod(xi.mod.SLEEPRES, 100)
                mob:setMod(xi.mod.POISONRES, 100)
                mob:setMod(xi.mod.PARALYZERES, 100)
                mob:setMod(xi.mod.LULLABYRES, 100)
                mob:setMod(xi.mod.FASTCAST, 10)
                mob:addStatusEffect(xi.effect.REGEN, 30, 3, 0)
                mob:addStatusEffect(xi.effect.REFRESH, 50, 3, 0)

            end
            if lifePercent < 30 then
                mob:setModelId(610) -- Kirin
                mob:setMobMod(xi.mobMod.SKILL_LIST, 259)
                mob:setMobMod(xi.mobMod.SPELL_LIST, 109)
                mob:setMod(xi.mod.STR, 40)
                mob:setMod(xi.mod.VIT, 20)
                mob:setMod(xi.mod.INT, 65)
                mob:setMod(xi.mod.MND, 20)
                mob:setMod(xi.mod.CHR, 20)
                mob:setMod(xi.mod.AGI, 20)
                mob:setMod(xi.mod.DEX, 40)
                mob:setMod(xi.mod.DEFP, 0)
                mob:setMod(xi.mod.RATTP, 0)
                mob:setMod(xi.mod.DEFP, 375)
                mob:setMod(xi.mod.RATTP, 375)
                mob:setMod(xi.mod.ACC, 100)
                mob:setMod(xi.mod.EARTH_MEVA, 170)
                mob:setMod(xi.mod.DARK_MEVA, 240)
                mob:setMod(xi.mod.LIGHT_MEVA, 170)
                mob:setMod(xi.mod.FIRE_MEVA, 128)
                mob:setMod(xi.mod.WATER_MEVA, 170)
                mob:setMod(xi.mod.THUNDER_MEVA, 170)
                mob:setMod(xi.mod.WIND_MEVA, 128)
                mob:setMod(xi.mod.ICE_MEVA, 200)
                mob:setMod(xi.mod.SILENCERES, 100)
                mob:setMod(xi.mod.STUNRES, 50)
                mob:setMod(xi.mod.BINDRES, 100)
                mob:setMod(xi.mod.GRAVITYRES, 100)
                mob:setMod(xi.mod.SLEEPRES, 100)
                mob:setMod(xi.mod.POISONRES, 100)
                mob:setMod(xi.mod.PARALYZERES, 100)
                mob:setMod(xi.mod.LULLABYRES, 100)
                mob:setMod(xi.mod.EARTH_ABSORB, 100)
                mob:setMod(xi.mod.LIGHT_ABSORB, 100)
                mob:addStatusEffect(xi.effect.REGEN, 30, 3, 0)
                mob:setMod(xi.effect.FAST_CAST, 25)
                mob:addStatusEffect(xi.effect.REFRESH, 50, 3, 0)
            end
        end,
            
        onMobDeath = function(mob, playerArg, isKiller)

        end,
            
            releaseIdOnDeath = true,
        })
        mob:setDropID(3989)
        mob:setSpawn(-1.52, -54.039, -597.508, 50)
        mob:spawn()

    end

end)

return m