AMA = {}
AMA.Players = {}

-- Fonction de logging
function AMA.Log(level, message)
    if not Config.Logs.EnableConsole then return end
    
    local prefix = "[AMA Framework]"
    local levelColors = {
        DEBUG = "^7",
        INFO = "^5",
        WARN = "^3",
        ERROR = "^1"
    }
    
    local color = levelColors[level] or "^7"
    print(string.format("%s %s[%s]^7 %s", prefix, color, level, message))
end

-- Fonction pour arrondir les coordonnées
function AMA.Round(num, decimals)
    local mult = 10^(decimals or 2)
    return math.floor(num * mult + 0.5) / mult
end

-- Fonction pour calculer la distance entre deux points
function AMA.GetDistance(coords1, coords2)
    local dx = coords1.x - coords2.x
    local dy = coords1.y - coords2.y
    local dz = coords1.z - coords2.z
    return math.sqrt(dx*dx + dy*dy + dz*dz)
end

-- Fonction pour formatter les coordonnées
function AMA.FormatCoords(coords)
    return {
        x = AMA.Round(coords.x, 2),
        y = AMA.Round(coords.y, 2),
        z = AMA.Round(coords.z, 2)
    }
end