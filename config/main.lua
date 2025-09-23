--? For support, join our Discord server: https://discord.gg/jAnEnyGBef

-- Check if a value exists in a table
local function contains(tbl, val)
    for _, v in pairs(tbl) do
        if v == val then
            return true
        end
    end
    return false
end

-- Filter items by category
local function filterByCategory(category)
    local result = {}
    for _, item in pairs(exports.ox_inventory:Items()) do
        if item.category ~= nill and contains(item.category, category) then
            local shopItem = {}
            shopItem.name = item.name
            shopItem.label = item.label
            shopItem.category = item.category
            shopItem.price = item.price
            table.insert(result, shopItem)
        end
    end
    local json = require("json") -- ou cjson / dkjson selon ce que tu as

    local function dumpJSON(tbl)
        return json.encode(tbl)
    end

    print(dumpJSON(result))
    return result
end


return {
	Framework = "auto", -- Options: "esx", "qbox", "qbcore", "custom", or "auto" (auto-detects avaible options)
	Locale = "en", -- Options: "en", "de"
	DebugMode = "dev", -- Options: "prod" (minimal logs), "dev" (detailed logs), false (disable logs)

	EnableSounds = true, -- Plays sounds when interacting with the shop interface
	ImagePath = "nui://ox_inventory/web/images/", -- Path to the item images --? Local folder: "item_images/"
	WeaponAsItem = true, -- Treat weapons as items

	Shops = {
		["247"] = {
			PointRadius = 25.0, -- The radius within which markers, peds, and other game elements related to the shop are displayed

			Locations = {
                vector4(378.01, 329.20, 103.55, 161.57), -- Clinton Ave

				vector4(2555.5110, 380.7313, 108.6229, 0.9597), -- Palomino Ave
				vector4(-3040.5376, 583.9359, 7.9089, 17.7445), -- Inseno Road
				vector4(-3243.9229, 1000.0519, 12.8307, 0.7583), -- Barbareno Rd
				vector4(-2193.4412, 4290.1064, 49.1743, 63.6331), -- Great Ocean Hwy
				vector4(1959.1536, 3741.4165, 32.3437, 298.7749), -- Niland Ave
				vector4(2676.5083, 3280.1863, 55.2411, 335.5104), -- Senora Fwy
				vector4(1728.5699, 6416.7671, 35.0372, 243.3380), -- Senora Fwy 2
				vector4(1134.2589, -983.0569, 46.4158, 278.9547), -- El Rancho Blvd
				vector4(-1221.4543, -908.0496, 12.3263, 36.5340), -- San Andreas Ave
				vector4(-1486.7350, -377.5593, 40.1634, 132.9464), -- Prosperity St
				vector4(-2966.3162, 391.5883, 15.0433, 86.4455), -- Great Ocean Hwy
				vector4(24.5062, -1345.5989, 29.4970, 263.3659), -- Inoccence Blvd
				vector4(-561.7218, 286.8480, 82.1765, 266.4413), -- Milton Rd
				vector4(-47.2886, -1758.5280, 29.4210, 45.3676), -- Davis Ave
				vector4(1165.0068, -323.6485, 69.2051, 101.2836), -- West Mirrow Drive
				vector4(-706.0665, -914.6005, 19.2156, 82.3892), -- Palomino Ave
				vector4(-1819.4907, 793.5951, 138.0846, 132.5959), -- Banham Canyon Dr
				vector4(549.2471, 2669.6699, 42.1565, 96.9846), -- Route 68
				vector4(1392.0671, 3606.1155, 34.9809, 203.5101), -- Algonquin Blvd
				vector4(1984.2482, 3054.3589, 47.2151, 240.0611), -- Panorama Dr
			},

			--? For icons, use Iconify: https://icon-sets.iconify.design
            Categories = {
                { name = "Boutique", type = "all", icon = "twemoji:shopping-bags" }, --! Required for all shops
                { name = "Nouriture", type = "food", icon = "twemoji:sandwich" },
                { name = "Repas", type = "meal", icon = "twemoji:fork-and-knife-with-plate" },
                { name = "Snacks", type = "snacks", icon = "twemoji:chocolate-bar" },
                { name = "Bonbons", type = "gums", icon = "twemoji:candy" },
                { name = "Boissons", type = "drinks", icon = "twemoji:tropical-drink" },
                { name = "Softs", type = "soft", icon = "twemoji:beverage-box" },
                { name = "Alcools", type = "alcool", icon = "twemoji:bottle-with-popping-cork" },
                { name = "Cigarettes", type = "smoking", icon = "fxemoji:smokingsymbol" },
            },
            Items = filterByCategory("smoking"),

			Requirement = {
				Job = {
					required = false, -- Whether a job is required to access the shop
				},
				License = {
					required = false, -- Whether a license is required to access the shop
				},
			},

			Locales = { --? More locales including the currency symbol, button text and more can be found in "locales/"
				MainHeader = {
					title = "Boutique",
					tag = "24/7",
					description = "Bienvenue dans votre marché local, où nous sommes toujours là pour vous, de jour comme de nuit !\nDécouvrez une sélection soignée de produits de qualité, conçus pour répondre à tous vos besoins.",
				},
				CartHeader = {
					title = "Pannier",
					tag = "24/7",
					description = "Vérifiez vos articles sélectionnés et passez à un paiement simple et sécurisé, avec plusieurs options de règlement.",
				},
			},

			Blip = {
				enabled = false, -- If true, displays a map blip for the shop locations
				name = "Shop [24/7]", -- Name displayed on the map
				sprite = 59, -- Blip icon type --? Reference: https://docs.fivem.net/docs/game-references/blips
				color = 0, -- Blip color --? Reference: https://docs.fivem.net/docs/game-references/blips/#blip-colors
				scale = 0.7, -- Size of the blip
			},

			Indicator = {
				Ped = {
					enabled = true, -- If true, spawns a ped (NPC) at the locations
					model = `mp_m_shopkeep_01`, -- Ped model type --? Reference: https://docs.fivem.net/docs/game-references/ped-models
					scenario = "WORLD_HUMAN_AA_SMOKE", -- Animation scenario for the ped --? Reference: https://github.com/DioneB/gtav-scenarios
				},
				Marker = {
					enabled = false, -- If true, displays a marker at the shop locations
					type = 20, -- Marker type --? Reference: https://docs.fivem.net/docs/game-references/markers
					size = vec3(0.7, 0.7, 0.7), -- Size of the marker
					color = { 65, 133, 235, 120 }, -- RGBA color of the marker
					bobUpAndDown = false, -- If true, marker moves up and down
					faceCamera = false, -- If true, marker faces the player's camera
					rotate = true, -- If true, marker rotates
				},
			},

			Interaction = {
				OpenKey = 38, -- Default: 38 (E key) --? Reference: https://docs.fivem.net/docs/game-references/controls

				HelpText = {
					enabled = false, -- If true, displays floating help text near the interaction point
					distance = 2.5, -- Distance within which help text appears and is interactable
				},
				FloatingText = {
					enabled = false, -- If true, displays floating text above the shop NPC
					distance = 2.5, -- Distance within which floating text is visible and interactable
				},
				Target = { -- Uses ox_target by default --? (modifiable in config/functions.lua)
					enabled = true, -- If true, enables targeting system
					boxZoneSize = vec3(4, 4, 4), -- Size of the target zone
					drawSprite = true, -- If true, displays a sprite for the target zone
					distance = 2.5, -- Interaction distance
				},
			},
		},

		["weapon_shop"] = {
			PointRadius = 25.0,

			Locations = {
				vector4(22.6509, -1105.4863, 29.7970, 161.7508), -- Elgin Ave
				vector4(-662.2554, -933.3735, 21.8292, 183.0097), -- Palomino Ave
				vector4(842.3751, -1035.5238, 28.1948, 356.2464), -- Olympic Fwy
				vector4(254.0491, -50.7247, 69.9410, 76.7617), -- Spanish Ave
				vector4(2567.8792, 292.3385, 108.7348, 3.7121), -- Palomino Fwy
				vector4(1692.0569, 3761.0879, 34.7053, 227.8851), -- Algonquin Blvd
				vector4(-331.7583, 6085.2231, 31.4548, 220.9601), -- Great Ocean Hwy
				vector4(-1119.0983, 2699.9138, 18.5541, 223.6154), -- Route 68
				vector4(-1303.8849, -394.7360, 36.6958, 76.3115), -- Morningwood Blvd
				vector4(810.1567, -2159.2566, 29.6190, 1.3184), -- Popular St
				vector4(-3173.7952, 1088.4893, 20.8387, 250.4138), -- Barbareno Rd
			},

			Categories = {
				{ name = "All Products", type = "all", icon = "ic:round-clear-all" },
				{ name = "Weapons", type = "weapons", icon = "mdi:pistol" },
				{ name = "Ammo", type = "ammo", icon = "mdi:ammunition" },
				{ name = "Attachments", type = "attachments", icon = "game-icons:machine-gun-magazine" },
				{ name = "Armour", type = "armour", icon = "game-icons:kevlar-vest" },
			},

			Items = {
				-- Pistols
				{ name = "WEAPON_GADGETPISTOL", label = "Gadgetpistol", category = "weapons", price = 250 },
				{ name = "WEAPON_SNSPISTOL", label = "SNS Pistol", category = "weapons", price = 350 },
				{ name = "WEAPON_CERAMICPISTOL", label = "Ceramicpistol", category = "weapons", price = 450 },
				{ name = "WEAPON_PISTOL", label = "Pistol", category = "weapons", price = 550 },
				{ name = "WEAPON_PISTOLXM3", label = "WM 29 Pistol", category = "weapons", price = 750 },

				-- Melee
				{ name = "WEAPON_KNUCKLE", label = "Knuckle", category = "weapons", price = 150 },
				{ name = "WEAPON_KNIFE", label = "Knife", category = "weapons", price = 200 },
				{ name = "WEAPON_SWITCHBLADE", label = "Switchblade", category = "weapons", price = 250 },
				{ name = "WEAPON_DAGGER", label = "Dagger", category = "weapons", price = 300 },
				{ name = "WEAPON_MACHETE", label = "Machete", category = "weapons", price = 350 },
				{ name = "WEAPON_HATCHET", label = "Hatchet", category = "weapons", price = 400 },
				{ name = "WEAPON_BATTLEAXE", label = "Battleaxe", category = "weapons", price = 450 },
				{ name = "WEAPON_STONE_HATCHET", label = "Stone Hatchet", category = "weapons", price = 500 },
				{ name = "WEAPON_BOTTLE", label = "Broken Bottle", category = "weapons", price = 100 },
				{ name = "WEAPON_BAT", label = "Bat", category = "weapons", price = 200 },
				{ name = "WEAPON_CROWBAR", label = "Crowbar", category = "weapons", price = 250 },
				{ name = "WEAPON_GOLFCLUB", label = "Golfclub", category = "weapons", price = 300 },
				{ name = "WEAPON_HAMMER", label = "Hammer", category = "weapons", price = 250 },
				{ name = "WEAPON_POOLCUE", label = "Poolcue", category = "weapons", price = 150 },
				{ name = "WEAPON_WRENCH", label = "Wrench", category = "weapons", price = 200 },

				-- Ammo
				{ name = "ammo-9", label = "9mm Ammo", category = "ammo", price = 100 },
				{ name = "ammo-22", label = ".22 LR Ammo", category = "ammo", price = 120 },
				{ name = "ammo-38", label = ".38 LC Ammo", category = "ammo", price = 140 },
				{ name = "ammo-44", label = ".44 Magnum Ammo", category = "ammo", price = 160 },
				{ name = "ammo-45", label = ".45 ACP Ammo", category = "ammo", price = 180 },
				{ name = "ammo-rifle", label = "5.56x45 Ammo", category = "ammo", price = 200 },
				{ name = "ammo-rifle2", label = "7.62x39 Ammo", category = "ammo", price = 220 },
				{ name = "ammo-shotgun", label = "12 Gauge Ammo", category = "ammo", price = 150 },
				{ name = "ammo-sniper", label = "7.62x51 Ammo", category = "ammo", price = 250 },
				{ name = "ammo-heavysniper", label = ".50 BMG Ammo", category = "ammo", price = 300 },
				{ name = "ammo-musket", label = ".50 Ball Ammo", category = "ammo", price = 350 },
				{ name = "ammo-flare", label = "Flare Ammo", category = "ammo", price = 120 },

				-- Armor
				{ name = "small_armour", label = "Small Armour", category = "armour", price = 150 },
				{ name = "medium_armour", label = "Medium Armour", category = "armour", price = 200 },
				{ name = "heavy_armour", label = "Heavy Armour", category = "armour", price = 250 },

				-- Attachments
				{ name = "at_suppressor", label = "Suppressor", category = "attachments", price = 200 },
				{ name = "at_grip", label = "Grip", category = "attachments", price = 150 },
				{ name = "at_flashlight", label = "Flashlight", category = "attachments", price = 180 },
				{ name = "at_barrel", label = "Barrel", category = "attachments", price = 220 },

				-- Magazines
				{ name = "at_clip_extended", label = "Extended Light Magazine", category = "attachments", price = 200 },
				{ name = "at_clip_extended2", label = "Extended Heavy Magazine", category = "attachments", price = 225 },
				{ name = "at_clip_drum", label = "Drum Magazine", category = "attachments", price = 250 },

				-- Scopes
				{ name = "at_scope_macro", label = "Macro Scope", category = "attachments", price = 300 },
				{ name = "at_scope_small", label = "Small Scope", category = "attachments", price = 250 },
				{ name = "at_scope_medium", label = "Medium Scope", category = "attachments", price = 270 },
				{ name = "at_scope_large", label = "Large Scope", category = "attachments", price = 300 },
				{ name = "at_scope_advanced", label = "Advanced Scope", category = "attachments", price = 350 },
				{ name = "at_scope_nv", label = "NV-Scope", category = "attachments", price = 400 },
				{ name = "at_scope_thermal", label = "Thermal Scope", category = "attachments", price = 450 },
				{ name = "at_scope_holo", label = "Holo Scope", category = "attachments", price = 500 },

				-- Muzzles
				{ name = "at_muzzle_flat", label = "Flat Muzzle", category = "attachments", price = 150 },
				{ name = "at_muzzle_tactical", label = "Tactical Muzzle", category = "attachments", price = 180 },
				{ name = "at_muzzle_fat", label = "Fat Muzzle", category = "attachments", price = 200 },
				{ name = "at_muzzle_heavy", label = "Heavy Muzzle", category = "attachments", price = 250 },
				{ name = "at_muzzle_slanted", label = "Slanted Muzzle", category = "attachments", price = 180 },
				{ name = "at_muzzle_split", label = "Split Muzzle", category = "attachments", price = 200 },
				{ name = "at_muzzle_squared", label = "Squared Muzzle", category = "attachments", price = 220 },
				{ name = "at_muzzle_bell", label = "Bell Muzzle", category = "attachments", price = 250 },
			},

			Requirement = {
				Job = {
					required = false,
					jobs = {
						{
							label = "Police",
							name = "police",
							grade = 0,
						},
						{
							label = "Sheriff",
							name = "sheriff",
							grade = 0,
						},
					},
				},
				License = {
					required = true,
					buyDialog = true,
					label = "Weapon License",
					type = "weapon",
					price = 1000,
				},
			},

			Locales = {
				MainHeader = {
					title = "Weapon Shop",
					tag = "24/7",
					description = "Welcome to your local weapon shop, where we're always here for you, day or night!\nExplore a curated selection of premium goods, tailored to meet your every need.",
				},
				CartHeader = {
					title = "Shopping",
					tag = "Cart",
					description = "Review your chosen items and proceed to secure, easy\ncheckout with multiple payment options.",
				},
			},

			Blip = {
				enabled = true,
				name = "Weapon Shop [24/7]",
				sprite = 110,
				color = 0,
				scale = 0.7,
			},

			Indicator = {
				Ped = {
					enabled = true,
					model = `mp_m_weapexp_01`,
					scenario = "WORLD_HUMAN_GUARD_STAND",
				},
				Marker = {
					enabled = false,
					type = 20,
					size = vec3(0.7, 0.7, 0.7),
					color = { 65, 133, 235, 120 },
					bobUpAndDown = false,
					faceCamera = false,
					rotate = true,
				},
			},

			Interaction = {
				OpenKey = 38,

				HelpText = {
					enabled = false,
					distance = 2.5,
				},
				FloatingText = {
					enabled = true,
					distance = 2.5,
				},
				Target = {
					enabled = false,
					boxZoneSize = vec3(4, 4, 4),
					drawSprite = true,
					distance = 2.5,
				},
			},
		},
	},
}
