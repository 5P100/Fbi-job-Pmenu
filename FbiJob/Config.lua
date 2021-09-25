Config = {}

Config.DrawDistance               = 18.0
Config.MarkerType                 = {Cloakrooms = 1, Ordinateur = 1, Accueil = 1, Armories = 1, Vehicles = 1, Deleter = 1, Helicopters = 1, BossActions = 1, ElevatorDown = 1, ElevatorTop = 1, ElevatorPark = 1, ElevatorBas = 1}
Config.MarkerSize                 = {x = 1.1, y = 1.1, z = 1.45}
Config.MarkerColor                = {r = 51, g = 153, b = 255}

Config.EnablePlayerManagement     = true 
Config.EnableSocietyOwnedVehicles = false
Config.EnableArmoryManagement     = true
Config.EnableESXIdentity          = true 
Config.EnableLicenses             = false 

Config.EnableHandcuffTimer        = false 
Config.HandcuffTimer              = 10 * 60000 -- 10 minutes.

Config.EnableJobBlip              = false
Config.EnablePoliceFine           = true

Config.EnableESXService           = false
Config.MaxInService               = -1 -- How much people can be in service at once?

Config.Locale                     = 'fr'

Config.FBIStations = {
    FBI = {
        Blip = {
            Coords  = vector3(112.1, -749.3, 45.7),
            Sprite  = 88,
            Display = 4,
            Scale   = 0.8,
            Colour  = 63,
        },

        Accueil = {
            vector3(115.31, -748.15, 44.75)
        },

        Cloakrooms = {
            vector3(152.0, -736.1, 241.1)
        },

        Ordinateur = {
            vector3(118.39, -764.19, 241.2)
        },

        Armories = {
            vector3(143.6, -764.3, 241.1)
        },

        Vehicles = {
            {
                Spawner = vector3(64.29, -744.34, 30.68)
            }
        },

        Deleter = {
            vector3(113.63, -716.33, 32.13)
        },

        Helicopters = {
            {
                Spawner = vector3(129.65, -730.22, 262.86),
                InsideShop = vector3(121.2, -744.3, 262.85),
                SpawnPoints = {
                    {coords = vector3(121.2, -744.3, 262.85), heading = 340.8, radius = 6.0}
                }
            }
        },

        BossActions = {
            vector3(149.26, -758.47, 241.1)
        },

        ElevatorTop = {
            {coords = vector3(136.09, -761.8, 241.1)}
        },

        ElevatorDown = {
            {coords = vector3(136.09, -761.5, 44.7)}
        },

        ElevatorPark = {
            {coords = vector3(65.4, -749.6, 30.6)}
        },

        ElevatorBas = {
            {coords = vector3(65.7, -749.72, 30.63)}
        }
    }
}

Config.Weapons = {
    "weapon_nightstick",
    "weapon_combatpistol",
    "weapon_pumpshotgun",
    "weapon_flashlight",
    "weapon_carbinerifle_mk2",
}


Config.AuthorizedVehicles = {
    helicopter = {
        agent = {
            {model = 'buzzard2', price = 35000}
        },
        special = {
            {model = 'havok', price = 10000},
            {model = 'buzzard2', price = 35000}
        },
        supervisor = {
            {model = 'buzzard', price = 50000},
            {model = 'buzzard2', price = 35000}
        },
        assistant = {
            {model = 'swift2', price = 60000},
            {model = 'buzzard', price = 50000},
            {model = 'buzzard2', price = 35000}
        },
        boss = {
            {model = 'volatus', price = 70000},
            {model = 'buzzard', price = 50000},
            {model = 'buzzard2', price = 35000}
        }
    }
}

Config.Uniforms = {
    Agent = {
        male = {
            tshirt_1 = 32,      tshirt_2 = 0,
            torso_1 = 4,        torso_2 = 0,
            decals_1 = 0,       decals_2 = 0,
            arms = 4,           arms_2 = 0,
            pants_1 = 28,       pants_2 = 0,
            shoes_1 = 10,       shoes_2 = 0,
            helmet_1 = -1,      helmet_2 = 0,
            chain_1 = 128,      chain_2 = 0,
            ears_1 = 2,         ears_2 = 0,
            glasses_1 = 8,      glasses_2 = 0,
            mask_1 = 0,         mask_2 = 0
        },
        female = {
            tshirt_1 = 38,      tshirt_2 = 0,
            torso_1 = 7,        torso_2 = 0,
            decals_1 = 0,       decals_2 = 0,
            arms = 3,           arms_2 = 0,
            pants_1 = 37,       pants_2 = 0,
            shoes_1 = 0,        shoes_2 = 0,
            helmet_1 = -1,      helmet_2 = 0,
            chain_1 = 87,       chain_2 = 4,
            ears_1 = -1,        ears_2 = 0,
            mask_1 = 0,         mask_2 = 0
        }
    },
    bullet_wear = {
        male = {
            bproof_1 = 11,  bproof_2 = 1
        },
        female = {
            bproof_1 = 13,  bproof_2 = 1
        }
    }
}

Config.Webhook = "https://discord.com/api/webhooks/857655567840313354/YxC_SSlc9ZMGfw-RqqnwBrfH3bkm_gM7JPB9kdNNhaMoZndH1I9PAmFejkC37PSajWEG"