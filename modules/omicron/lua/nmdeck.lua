-----------------------------------
require("modules/module_utils")
require("scripts/zones/Escha_RuAun/Zone")
-----------------------------------
local m = Module:new("???_Ports")
m:setEnabled(true)

m:addOverride("xi.zones.Escha_RuAun.Zone.onInitialize", function(zone)
    -------------------------
	-- Port to GOD Balcony --
	-------------------------
       super(zone)

    local suzport = zone:insertDynamicEntity({

        objtype = xi.objType.NPC,
        name = "Suzaku Portal",
		look = 2492,
        x = -359.060,
        y = -40.105,
        z = -255.183,
        rotation = 28,
        widescan = 1,

        onTrigger = function(player, npc)
		    player:injectActionPacket(6, 600, 0, 0, 0)
		      
			player:timer(2000, function(playerArg)
       			player:setPos(-454.702, -71.552, -308.579)
			end)

		    player:timer(2750, function(playerArg)
    		    player:injectActionPacket(6, 602, 0, 0, 0)
			end)
		end,
    })

    local byaport = zone:insertDynamicEntity({

        objtype = xi.objType.NPC,
        name = "Byakko Portal",
		look = 2492,
        x = -353.819,
        y = -40.105,
        z = 262.473,
        rotation = 28,

        onTrigger = function(player, npc)
	        player:injectActionPacket(6, 600, 0, 0, 0)

			player:timer(2000, function(playerArg)
			    player:setPos(-443.993, -71.552, 336.419)
			end)	
			
		    player:timer(2750, function(playerArg)
    		    player:injectActionPacket(6, 602, 0, 0, 0)
			end)
		end,
    })

    local genport = zone:insertDynamicEntity({

        objtype = xi.objType.NPC,
        name = "Genbu Portal",
		look = 2492,
        x = 140.386,
        y = -40.147,
        z = 417.497,
        rotation = 28,

        onTrigger = function(player, npc)
	        player:injectActionPacket(6, 600, 0, 0, 0)

			player:timer(2000, function(playerArg)
			    player:setPos(186.160, -71.552, 515.480)
			end)
			
		    player:timer(2750, function(playerArg)
    		    player:injectActionPacket(6, 602, 0, 0, 0)
			end)
		end,
    })

    local syrport = zone:insertDynamicEntity({

        objtype = xi.objType.NPC,
        name = "Seiyru Portal",
		look = 2492,
        x = 440.573,
        y = -40.106,
        z = -4.610,
        rotation = 28,

        onTrigger = function(player, npc)
	        player:injectActionPacket(6, 600, 0, 0, 0)
			
			player:timer(2000, function(playerArg)
			    player:setPos(548.250, -71.552, -17.000)
			end)
			
		    player:timer(2750, function(playerArg)
    		    player:injectActionPacket(6, 602, 0, 0, 0)
			end)
		end,
    })
	
	-----------------------
	-- NPC's to pop NM's --
	-----------------------
    local suzport = zone:insertDynamicEntity({

        objtype = xi.objType.NPC,
        name = "Fire Beacon",
		look = 2824,
        x = -492.100,
        y = -70.020,
        z = -253.984,
        rotation = 0,

        onTrigger = function(player, npc)
        if player:getGMLevel() > 0 and player:checkNameFlags(0x04000000) or
		   player:hasKeyItem(xi.keyItem.SUZAKUS_BENEFACTION) then
		   player:delKeyItem(xi.keyItem.SUZAKUS_BENEFACTION) 
		   SetServerVariable("[Eschan]Suzaku_Time", os.time())
		   SetServerVariable("[Eschan]Suzaku", 1)

        end
	end,
    })

    local byaport = zone:insertDynamicEntity({

        objtype = xi.objType.NPC,
        name = "Light Beacon",
		look = 2824,
        x = -393.230,
        y = -70.020,
        z = 390.329,
        rotation = 0,

        onTrigger = function(player, npc)
        if player:getGMLevel() > 0 and player:checkNameFlags(0x04000000) or
		   player:hasKeyItem(xi.keyItem.BYAKKOS_PRIDE) then
		   player:delKeyItem(xi.keyItem.BYAKKOS_PRIDE)
		   SetServerVariable("[Eschan]Byakko_Time", os.time())
		   SetServerVariable("[Eschan]Byakko", 1)
        end
	end,
    })

    local genport = zone:insertDynamicEntity({

        objtype = xi.objType.NPC,
        name = "Water Beacon",
		look = 2824,
        x = 251.169,
        y = -70.020,
        z = 494.367,
        rotation = 0,

        onTrigger = function(player, npc)
        if player:getGMLevel() > 0 and player:checkNameFlags(0x04000000) or
		   player:hasKeyItem(xi.keyItem.GENBUS_HONOR) then
		   SetServerVariable("[Eschan]Genbu_Time", os.time())
		   SetServerVariable("[Eschan]Genbu", 1)
		   player:delKeyItem(xi.keyItem.GENBUS_HONOR)
        end
	end,
    })

    local syrpop = zone:insertDynamicEntity({

        objtype = xi.objType.NPC,
        name = "Wind Beacon",
		look = 2824,
        x = 548.096,
        y = -70.020,
        z = -85.344,
        rotation = 0,

        onTrigger = function(player, npc)
        if player:getGMLevel() > 0 and player:checkNameFlags(0x04000000) or
		   player:hasKeyItem(xi.keyItem.SEIRYUS_NOBILITY) then
		   SetServerVariable("[Eschan]Seiryu_Time", os.time())
		   SetServerVariable("[Eschan]Seiryu", 1)
		   player:delKeyItem(xi.keyItem.SEIRYUS_NOBILITY)
        end
	end,
	})
	
	local kirpop = zone:insertDynamicEntity({

        objtype = xi.objType.NPC,
        name = "Avatar Beacon",
		look = 2827,
        x = -1.216,
        y = -55.240,
        z = -632.844,
        rotation = 0,

        onTrigger = function(player, npc)
        if player:getGMLevel() > 0 and player:checkNameFlags(0x04000000) or
		   player:hasKeyItem(xi.keyItem.KIRINS_FERVOR) then
		   SetServerVariable("[Eschan]Kirin_Time", os.time())
		   SetServerVariable("[Eschan]Kirin", 1)
		   player:delKeyItem(xi.keyItem.KIRINS_FERVOR)
        end
	end,
	})
	
end)

return m
