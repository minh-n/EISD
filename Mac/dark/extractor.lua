dark = require("dark")
require("functions")

-- Création d'une pipeline pour stocker les filtres
local pre_proc = dark.pipeline()
local pipe_race = dark.pipeline()
local dog_use = dark.pipeline()
local dog_origin = dark.pipeline()
local dog_height = dark.pipeline()
local dog_weight = dark.pipeline()
local dog_structured = dark.pipeline()

-- Annotateurs classique (donne des tags aux tokens)					
dog_use:lexicon("#use", "lexicons/dog_use.txt")
dog_height:lexicon("#unit", "lexicons/height_units.txt")
dog_height:lexicon("#heightvoc", "lexicons/height_voc.txt")
dog_weight:lexicon("#weightunit", "lexicons/weight_units.txt")


-- Patterns
pre_proc:basic()
pre_proc:pattern([[ [#detle (la | le | l "'" | les)] ]])
pre_proc:pattern([[ [#detde de #detle? | du | des | d "'"] ]])
pipe_race:pattern([[ [#race (#w "-" #w | #w{1,4})] ]])
dog_origin:pattern([[ 
	(((originaire | originaires) #detde) | (#detde origine) | #detde origine "," #detle)
	[#origin #w{1,6} "-" #w | #w{1,6} ] 
	(("," | ".") | "(" | "et" ) 
]])
dog_height:pattern([[   [#measure (#d "à")? #d #unit] ]])
dog_height:pattern([[   [#height #w (#heightvoc taille | "forte" "taille" | #w "variétés" "de" "taille")] ]])
dog_height:pattern([[   [#height #w taille #heightvoc ("à" #heightvoc)?] ]])
dog_weight:pattern([[ 	[#weight #d] #weightunit] ]])
dog_structured:pattern([[ [#measure #d] #unit ]])

-- Bases de données (non structurées et structurées)
db = {}		
local si = {}

-- Sections
local section_structured = { "informations structurées" }

-- Debug
local tags = { ["#origin"] = "red",
				["#detde"] = "cyan"
}

os.chdir("text_files")
for filename in os.dir(".") do
	local race = NIL
	local structured = false
	
	--filename = "EpagneulBreton.txt"

	for line in io.lines(filename) do	
		line = line:gsub("\r", "")
		line = line:gsub("%’", "'")			
		line = line:gsub("%p", " %0 "):lower()

		local seq = dark.sequence(line)
		pre_proc(seq)
		pipe_race(seq) -- Parsing dog race
		dog_use(seq) -- Parsing dog use
		dog_origin(seq) -- Parsing dog origin
		dog_height(seq) -- Parsing dog_height
		dog_weight(seq) -- Parsing dog weight
		dog_structured(seq)
		
		if structured then -- STRUCTURED
			-- Structured weight
			if haveTag(seq, "#weight") and si[race].weight == NIL then		
				low, high = structuredUnit(seq, "#weight")
				si[race].weight = {}
				si[race].weight.low = low
				si[race].weight.high = high
			end	
			
			-- Structured height
			if haveTag(seq, "#measure") and si[race].height == NIL then		
				low, high = structuredUnit(seq, "#measure")
				si[race].height = {}
				si[race].height.low = low
				si[race].height.high = high
			end				
		else
			-- RACE
			if haveTag(seq, "#race") and race == NIL then
				race = tagStringInLink(seq, "#race", "#race")
				db[race] = {} or db[race]
				db[race].use = initializeArray() -- Initialize use
				db[race].weight = 0
				db[race].measure = 0
				si[race] = {}
			end
			
			if(race ~= NIL) then
				-- USE
				use_array = getUseArray(seq)
				db[race].use = concatArrays(db[race].use, use_array)
				
				-- ORIGIN
				local origin = tagStringInLink(seq, "#origin", "#origin")
				if origin ~= NIL and db[race].origin == NIL then
					db[race].origin = origin
				end
				
				-- HEIGHT
				if haveTag(seq, "#height") and db[race].height == NIL then
					db[race].height = seq:tag2str("#height")[1]
				end
				
				measure = getHeight(seq)
				if db[race].measure < measure then
					db[race].measure = measure
				end
					
				-- WEIGHT
				weight = getWeight(seq)
				if db[race].weight < weight then
					db[race].weight = weight
				end
			end
		end
		
		-- Check if we are reading structured data
		if checkSection(section_structured, line) then structured = true end
	end	
	
	--fillingMissingValues(race, db, si)
end

local statistics = compareWeight(db, si)
statistics = compareHeight(db, si, statistics)
statistics = addedStatistics(db, statistics)
print(serialize(statistics))

fillingMissingValues(db, si)

for u,v in pairs(db) do
	i = string.find(u, " %- ")
	if(i ~= NIL) then
		name = u:gsub(" %- ", "-")
		db[name] = db[u]
		db[u] = NIL
	end
	
end	


for k,v in pairs(db) do

	i = string.find(k, "é")
	if(i ~= NIL) then
		name = k:gsub("é", "e")
		db[name] = db[k]
		db[k] = NIL
	end
end




--db["terre-neuve"] = db["terre - neuve"]
--db["terre - neuve"] = NIL

print(serialize(db))
--print("\n#############\n")
--print(serialize(si))
