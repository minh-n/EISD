dark = require("dark")

-- Ensemble de données
--local line = "Le golden retriever ou simplement golden  Le terre-neuve ( ou )  Le retriever du Labrador, plus communément appelé labrador retriever  est une race de chien d'origine britannique. Sélectionné comme chien de rapport, le golden retriever est une race très populaire depuis les années 1990. Il s'agit d'un chien de taille moyenne possédant une robe à poil long, de couleur crème à doré foncé. "

-- Création d'une pipeline pour stocker les filtres
local pipeline = dark.pipeline()
local pre_proc = dark.pipeline()
local pipe_race = dark.pipeline()
local dog_use = dark.pipeline()
local dog_origin = dark.pipeline()
local dog_height = dark.pipeline()

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

function createUseArray(seq)
	if not haveTag(seq, "#use") then
		return
	end
	
	use_array = {}
	exists = {}
	use_array[#use_array + 1] = "chien de compagnie"
	exists["chien de compagnie"] = 1
	
	for idx, pos in ipairs(seq["#use"]) do
		local start, finish = pos[1], pos[2]
		local res = {}
		for i = start, finish do 
			if seq[i].token == "chiens" then
				res[#res + 1] = "chien"
			else
				res[#res + 1] = seq[i].token
			end
		end
		temp = table.concat(res, " ")
		
		if not exists[temp] then
			use_array[#use_array + 1] = temp
			exists[temp] = true
		end
	end
	
	return use_array
end

-- Annotateurs classique (donne des tags aux tokens)
pipeline:basic()					
--pipeline:lexicon("#unit", "units.txt")
pre_proc:lexicon("#section-use", "section_use.txt")
pre_proc:lexicon("#section-history", "section_history.txt")
pre_proc:lexicon("#section-description", "section_description.txt")
pre_proc:lexicon("#section-behavior", "section_behavior.txt")
pre_proc:lexicon("#section-health", "section_health.txt")
dog_use:lexicon("#use", "dog_use.txt")
dog_height:lexicon("#unit", "units.txt")
dog_height:lexicon("#heightvoc", "height_voc.txt")


-- PATTERNS
--pipeline:pattern([[	("Le" | "appelé") [#race (#w | #w #w)] (( "ou" | "est") | /\(/ ) ]])
pipeline:pattern([[	[#measure #d #unit] ]])
pipeline:pattern([[ [#height ( "taille" | "mesure" ) .* #measure] ]])
pipeline:pattern([[	("Le" | "appelé" | "le") [#race (#w | #w #w | #w "-" #w)] (( "ou" | "est" | "fait") | /\(/ ) ]])
--pipeline:pattern([[ /L[ae]/ [#monument ("tour" | "pont") #W] ]])
--pipeline:pattern([[ [#height #monument .* #measure] ]])
pre_proc:pattern([[ [#detle (la | le | l "'" | les)] ]])
pre_proc:pattern([[ [#detde de #detle | du | des | d "'"] ]])
pipe_race:basic()
pipe_race:pattern([[ [#race (#w "-" #w | #w{1,4})] ]])
dog_origin:basic()
dog_origin:pattern([[ 
	((originaire #detde) | (#detde origine) | #detde origine "," #detle) 
	[#origin #w{1,6} "-" #w | #w{1,6} ] 
	(("," | ".") | "(" ) 
]])
dog_height:pattern([[    [#measure (#d "à")? #d #unit] ]])
dog_height:pattern([[    [#height (#w taille? #heightvoc taille? | "forte" "taille")] ]])

-- Base de données
db = {}		

-- DEBUG
local tags = { ["#use"] = "cyan" }

os.chdir("text_files")
for filename in os.dir(".") do
	local race = NIL
	local section = "RACE"
	
	--filename = "Labrador.txt"

	for line in io.lines(filename) do	
		line = line:gsub("%’", "'")			
		line = line:gsub("%p", " %0 "):lower()

		local seq = dark.sequence(line)
		pre_proc(seq)

		if haveTag(seq, "#section-use") then section = "USE"
		--elseif haveTag(seq, "#section-history") then section = "HISTORY"
		--elseif haveTag(seq, "#section-description") then section = "DESCRIPTION"
		--elseif haveTag(seq, "#section-behavior") then section = "BEHAVIOR"
		--elseif haveTag(seq, "#section-health") then section = "HEALTH"
		end
		
		if section == "USE" then
			dog_use(seq) -- Pipeline dog_use
			
			use_array = createUseArray(seq)
			if use_array ~= NIL then
				db[race].use = use_array
				section = "NOTHING"
			end
		elseif section == "RACE" then
			pipe_race(seq) -- Pipeline race
			
			if haveTag(seq, "#race") then
				race = tagStringInLink(seq, "#race", "#race")
				db[race] = {} or db[race]
			end
			section = "INTRODUCTION"
		elseif section == "INTRODUCTION" then
			dog_origin(seq) -- Pipeline dog_origin

			local origin = tagStringInLink(seq, "#origin", "#origin")
			if origin ~= NIL then
				db[race].origin = origin
			end		
			
			dog_height(seq)
			
			if(haveTag(seq, "#height")) then
				db[race].height = seq:tag2str("#height")[1]
			end
			
			-- If we found the right line (not empty)
			if(line ~= "") then
				section = "NOTHING"
			end 	
		elseif section == "HISTORY" then
		elseif section == "DESCRIPTION" then
			--pipeline(seq)
			--db[race] = {} or db[race]
			--if haveTag(seq, "#height") then
			--	local height = tagStringInLink(seq, "#height", "#height")
			--	db[race].height = height	
			--end
		elseif section == "BEHAVIOR" then
		elseif section == "HEALTH" then
		end
	end	
end


--print("\n#############\n")
--print(serialize(db))
