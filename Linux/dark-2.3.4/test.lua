dark = require("dark")

-- Ensemble de données
local line = "La tour Eiffel mesure 324 mètres ."

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

-- Annotateur classique (donne des tags aux tokens)
pipeline:basic()
								
-- Annotateur d'unité (repère les unités)
pipeline:lexicon("#unit", "units.txt")

-- PATTERNS
pipeline:pattern([[	[#measure #d #unit] ]])
pipeline:pattern([[ /L[ae]/ [#monument ("tour" | "pont") #W] ]])
pipeline:pattern([[ [#height #monument .* #measure] ]])

-- Création d'une séquence
local seq = dark.sequence(line)

-- Application des patterns et lexiques grace à notre pipeline
pipeline(seq)

-- Tags et couleurs pour l'affichage de la séquence
local tags = {
			--["#unit"] = "red",
			--["#d"] = "yellow",
			["#measure"] = "cyan",
			["#monument"] = "green",
			["#height"] = "magenta"
		}
		
-- Base de données
local db = {
	["tour Eiffel"] = {
		position = "Paris"
	},
	["Notre dame de Paris"] = {
		height = "57 mètres"
	}
}		

if haveTag(seq, "#height") then
			local monument = tagStringInLink(seq, "#height", "#monument")
			local measure = tagStringInLink(seq, "#height", "#measure")

			db[monument] = db[monument] or {}
			db[monument].height = measure
end
		
print("###\n")
print(seq:tostring(tags))
print("\n###")

print("\nLa ligne contient un monument : ", haveTag(seq, "#monument"))

print(serialize(db))
