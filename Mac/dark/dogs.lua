dark = require("dark")

-- Ensemble de données
local line = "Le golden retriever ou simplement golden  Le terre-neuve ( ou )  Le retriever du Labrador, plus communément appelé labrador retriever  est une race de chien d'origine britannique. Sélectionné comme chien de rapport, le golden retriever est une race très populaire depuis les années 1990. Il s'agit d'un chien de taille moyenne possédant une robe à poil long, de couleur crème à doré foncé. "

-- Création d'une pipeline pour stocker les filtres
local pipeline = dark.pipeline()

-- FUNCTIONS
function haveTag(seq, tag)
	return #seq[tag] ~= 0
end

function tagString(seq, tag, b_gin, e_nd)
	-- Valeurs par défaut
	b_gin, e_nd = b_gin or 1, e_nd or #seq
	
	if not haveTag(seq, tag) then
		return
	end
	
	for idx, pos in ipairs(seq[tag]) do
		local start, finish = pos[1], pos[2]
		if start >= b_gin and finish <= e_nd then
			local res = {}
	
			-- Concaténer les tokens avec des espaces entre
			for i = start, finish do 
				res[#res + 1] = seq[i].token
			end
			
			return table.concat(res, " ")
		end
	end
end

function tagStringInLink(seq, link, tag)
	if not haveTag(seq, link) then
		return
	end
	
	local pos = seq[link][1]
	local start, finish = pos[1], pos[2]
	
	return tagString(seq, tag, start, finish)
end

-- Annotateurs classique (donne des tags aux tokens)
pipeline:basic()						
--pipeline:lexicon("#unit", "units.txt")

-- PATTERNS
pipeline:pattern([[	("Le" | "appelé") [#race (#w | #w #w)] (( "ou" | "est") | /\(/ ) ]])
pipeline:pattern([[ de [#height taille #w] ]])

-- Création d'une séquence
local seq = dark.sequence(line)

-- Application des patterns et lexiques grace à notre pipeline
pipeline(seq)

-- Tags et couleurs pour l'affichage de la séquence
local tags = {
			--["#unit"] = "red",
			--["#d"] = "yellow",
			["#race"] = "cyan",
			["#height"] = "magenta"
		}
		
-- Base de données
db = {
	["golden retriever"] = {
		height = "100 cm",
		weight = " BIG DOG kg/m^3",
		origin = "Système Solaire",
		use = {
			[1] = "chien de police",
			[2] = "chien de compagnie",
			[3] = "chien de bail",
			[4] = "chien de montagne",
			[5] = "chien de campagne"
		}
	},
	["beagle"] = {
		height = "19 cm",
		weight = "15 kg",
		origin = "US of A",
		use = {
			[1] = "chien de traineau",
			[2] = "chien d'aveugle"
		}
	}
}	

if haveTag(seq, "#race") then
			local race = tagStringInLink(seq, "#race", "#race")
			local height = tagStringInLink(seq, "#height", "#height")

			db[race] = db[race] or {}
			db[race].height = height
end
		
print("###\n")
print(seq:tostring(tags))
print("\n###")


print(serialize(db))
