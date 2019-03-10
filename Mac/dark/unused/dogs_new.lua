dark = require("dark")

-- Ensemble de données
local line = "Le dalmatien est une race de chiens originaire de la Dalmatie (région de la Croatie). Race apparentée au chien courant, le dalmatien est de taille moyenne, musclé, actif, harmonieux dans ses lignes doté d'un trot remarquable. Il est selon la FCI d'un caractère calme, assez têtu mais très intelligent et câlin. Sa robe a pour couleur de base le blanc pur et comporte des taches rondes et bien dessinées, pouvant être soit noires, soit foie. Le dalmatien est un chien sportif et gai qui a besoin de se dépenser. C'est une race qui s'illustre par la pratique de sports comme l'agility, le cani-cross ainsi que l'obé rythmée."
line = line:gsub("%.", " %0 ")
line = line:gsub("%,", " %0 ")
line = line:gsub("%;", " %0 ")

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

-- PATTERNS
pipeline:lexicon("#unit", "units.txt")
pipeline:lexicon("#heightvoc", "height_voc.txt")
pipeline:pattern([[	("Le" | "appelé") [#race (#w | #w #w)] (( "ou" | "est") | /\(/ ) ]])
pipeline:pattern([[    [#measure (#d "à")? #d #unit] ]])

--go checker si des fois height_voc est utilisé sans qu'on parle de taille
pipeline:pattern([[    [#height #w taille? #heightvoc taille?] ]])


-- Création d'une séquence
local seq = dark.sequence(line)

-- Application des patterns et lexiques grace à notre pipeline
pipeline(seq)

-- Tags et couleurs pour l'affichage de la séquence
local tags = {
			["#measure"] = "red",
			--["#d"] = "yellow",
			["#race"] = "cyan",
			["#height"] = "magenta"
		}
		
-- Base de données
local db = {
	["golden retriever"] = {
		height = "taille moyenne"
	},
	["pug"] = {
		height = "petite taille"
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
