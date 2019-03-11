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
	use_array = {}
	exists = {}
	use_array[#use_array + 1] = "chien de compagnie"
	exists["chien de compagnie"] = 1
	
	if not haveTag(seq, "#use") then
		return use_array
	end
	
	for idx, pos in ipairs(seq["#use"]) do
		local start, finish = pos[1], pos[2]
		local res = {}
		for i = start, finish do 
			if seq[i].token == "chiens" then
				res[#res + 1] = "chien"
			else
				if i == finish and string.sub(seq[i].token, -1) == "s" then
					res[#res + 1] = seq[i].token:sub(1, -2)
				else
					res[#res + 1] = seq[i].token
				end
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

function getUseArray(seq)
	use_array = {}
	exists = {}
	use_array[#use_array + 1] = "chien de compagnie"
	exists["chien de compagnie"] = 1
	
	if not haveTag(seq, "#use") then
		return use_array
	end
	
	for idx, pos in ipairs(seq["#use"]) do
		local start, finish = pos[1], pos[2]
		local res = {}
		for i = start, finish do 
			if seq[i].token == "chiens" then
				res[#res + 1] = "chien"
			else
				if i == finish and string.sub(seq[i].token, -1) == "s" then
					res[#res + 1] = seq[i].token:sub(1, -2)
				else
					res[#res + 1] = seq[i].token
				end
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

function concatArrays(one, two)
	for _, v1 in pairs(two) do
		exists = false
		for _, v2 in pairs(one) do
			if v1 == v2 then
				exists = true
				break
			end
		end
		if not exists then
			table.insert(one, v1)
		end
	end
	
	return one
end

function initializeArray() 
	use_array = {}
	use_array[#use_array + 1] = "chien de compagnie"
	return use_array
end

function checkSection(section, line) 
	for idx, val in pairs(section) do
		if(line == val) then
			return true
		end
	end
	return false
end

function getWeight(seq) 
	local weight = 0
	for idx, pos in pairs(seq["#weight"]) do
		val = tonumber(seq[pos[1]].token)
		if(val > weight) then
			weight = val
		end
	end
	
	if(weight == 0) then
		return 0
	else 
		return weight
	end
end

function getHeight(seq) 
	local height = 0
	for idx, pos in pairs(seq["#measure"]) do
		val = tonumber(seq[pos[1]].token)
		if(val > height) then
			height = val
		end
	end
	
	if(height == 0) then
		return 0
	else 
		return height
	end
end

function structuredInformation(db, line, seq)
	local tmp = {}

	if haveTag(seq, "#key") then
		local category = tagStringInLink(seq, "#key", "#key")
		if haveTag(seq, "#weightunit") then			
			for w in string.gmatch(line, "%d+") do
    			tmp[#tmp + 1] = w
  			end
  			db.weight = tmp 		
		elseif haveTag(seq, "#value") then					
			db[category] = tagStringInLink(seq, "#value", "#value")	
		end					
	end

	return db
end


function structuredUnit(seq, tag)
	local low, high = 0, 0
	
	if haveTag(seq, tag) then
		for idx, pos in pairs(seq["#d"]) do
			w = tonumber(seq[pos[1]].token)
			if(w < low or low == 0) then
				low = w
			end	if w > high then
				high = w
			end
		end
	end
	
	return low, high
end

function compareWeight(db, si) 
	local total, found, successes, found_in_structured = 0, 0, 0, 0
	for k, v in pairs(db) do
		local w = v.weight
		if(w ~= 0) then
			found = found + 1
			
			if(si[k].weight ~= NIL) then
				local high, low = si[k].weight.high, si[k].weight.low
				if(low <= w and w <= high) then
					successes = successes + 1
				end
			else
				successes = successes + 1
			end
		else 
			if(si[k].weight ~= NIL) then
				found_in_structured = found_in_structured + 1
			end
		end
		
		total = total + 1
	end
	
	local statistics = {}
	statistics.weight = {}
	statistics.weight.found = math.floor((found/total)*100) .. "% on " .. total .. " dogs"
	statistics.weight.successes = math.floor(successes *100 / found) .. "% accuracy (comparing non-structured weights with structured weights)"
	statistics.weight.structured = "found " .. found_in_structured .. " new weights in structured data"

	return statistics
end

function compareHeight(db, si, statistics) 
	local total, found, successes, found_in_structured = 0, 0, 0, 0
	for k, v in pairs(db) do
		local w = v.measure
		if(w ~= 0) then
			found = found + 1
			
			if(si[k].height ~= NIL) then
				local high, low = si[k].height.high, si[k].height.low
				if(low <= w and w <= high) then
					successes = successes + 1
				end
			else
				successes = successes + 1
			end
		else 
			if(si[k].height ~= NIL) then
				found_in_structured = found_in_structured + 1
			end
		end
		
		total = total + 1
	end
	
	statistics.height = {}
	statistics.height.found = math.floor((found/total)*100) .. "% on " .. total .. " dogs"
	statistics.height.successes = math.floor(successes *100 / found) .. "% accuracy (comparing non-structured heights with structured heights)"
	statistics.height.structured = "found " .. found_in_structured .. " new heights in structured data"

	return statistics
end

function addedStatistics(db, statistics)
	found = 0
	total = 0
	
	use_avg = 0
	dogs_with_one_use = 0
	
	for race, _ in pairs(db) do
		if db[race].origin ~= NIL then
			found = found + 1
		end
		if #db[race].use == 1 then
			dogs_with_one_use = dogs_with_one_use + 1
		end
		use_avg = use_avg + #db[race].use
		total = total + 1
	end
	
	statistics.origin = {}
	statistics.origin.found = math.floor((found/total)*100) .. "% on " .. total .. " dogs"
	statistics.use = {}
	statistics.use.average = math.floor(use_avg / total) .. " uses per dog"
	statistics.use.pet_dogs = dogs_with_one_use .. " dogs with only use : pet"
	return statistics
end

function fillingMissingValues(db, si)
	for race, _ in pairs(db) do
		if db[race].origin == NIL then
			db[race].origin = "inconnue"
		end
		
		if db[race].height == NIL then
			db[race].height = "de taille inconnue"
		end
		
		if(db[race].weight == 0) then
			if(si[race].weight ~= NIL) then
				db[race].weight = si[race].weight.high
			end
		end
		
		if(db[race].measure == 0) then
			if(si[race].height ~= NIL) then
				db[race].measure = si[race].height.high
			end
		end
	end
end
