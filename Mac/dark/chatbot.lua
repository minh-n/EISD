
dark = require("dark")
local lev_iter = (require 'levenshtein').lev_iter

-- random sentences
math.randomseed(os.time())

otherAnswer={
		"voulez-vous en savoir plus ?",
		"voulez-vous d'autres informations sur les chiens ?",
		"quelque chose d'autre ?",
		"d'autres questions sur les chiens ?",
		"d'autres questions ?",
		"quoi d'autre ?",
		"ouaf.",
		"je sais tout sur les chiens !",
		"demandez-moi quelque chose d'autre si vous le souhaitez.",
}




-- database
require("extractor")

-- lexique
pipe = dark.pipeline()
pipe:basic()
--pipe:lexicon("#vocab", "lexiqueChatbot1.txt")
--pipe:lexicon("#questStarcraft", {"protoss", "zerg", "terran"})

raceList = {"beagle", "terre - neuve", "labrador"}
sizeList = {"taille", "mesure", "hauteur", "cm", "m"}
useList = {"utilisé", "utilité", "utilisation", "use", "emploi"}
originList = {"origine", "vient", "où", "where", "pays", "région"}
weightList = {"poids", "peser", "pèse", "pèsent", "kilo", "kg", "kilogrammes"}

pipe:lexicon("#race", raceList)
pipe:lexicon("#size", sizeList)
pipe:lexicon("#use", useList)
pipe:lexicon("#origin", originList)
pipe:lexicon("#weight", weightList)



--replaces correct words in the user input string 
function lev(line)
	words = {}
	for m in line:gmatch("%w+") do table.insert(words, m) end --separating the user input into words

	levCoef = 2

	for _,word in pairs(words) do 

		if (#word < 3) then
			break
		end

		--replace wrong words for the race etc
		for _,correctWord in pairs(raceList) do

				if(lev_iter(word, correctWord) <= levCoef) then
					line = line:gsub(word, correctWord) --remplacer le mot avec une typo
					goto endOfNestedFor -- double break to avoid checking a word twice
				end
		end
		for _,correctWord in pairs(sizeList) do

				if(lev_iter(word, correctWord) <= levCoef) then
					line = line:gsub(word, correctWord) --remplacer le mot avec une typo
					goto endOfNestedFor -- double break to avoid checking a word twice
				end
		end
		for _,correctWord in pairs(useList) do

				if(lev_iter(word, correctWord) <= levCoef) then
					line = line:gsub(word, correctWord) --remplacer le mot avec une typo
					goto endOfNestedFor -- double break to avoid checking a word twice
				end
		end
		for _,correctWord in pairs(originList) do

				if(lev_iter(word, correctWord) <= levCoef) then
					line = line:gsub(word, correctWord) --remplacer le mot avec une typo
					goto endOfNestedFor -- double break to avoid checking a word twice
				end
		end
		for _,correctWord in pairs(weightList) do

				if(lev_iter(word, correctWord) <= levCoef) then
					line = line:gsub(word, correctWord) --remplacer le mot avec une typo
					goto endOfNestedFor -- double break to avoid checking a word twice
				end
		end

		::endOfNestedFor:: 
	end

	return line
end

--read the user's input
function userInput()
	--print("-Debug: userInput()\n")
	print("Infochien : Bonjour je suis un chienbot ! Je peux parler du Beagle, du Labrador Retriever ou du Terre-Neuve.\n")

	while 1 do
		line = io.read()
		hasAnswered = false
		currentAnswerHasMeaning = false
		line = string.lower(line) --démajusculer
		if line == "quitter" or line == "quit" or line == "q" then
			break;
		end


		--putting spaces around punctuation signs
		line = line:gsub("%p", " %0 ") --on met des espaces sur la ponctuation
		line = lev(line)

		line = dark.sequence(line)
		
		pipe(line)
		
				--print(dark.pipeline(line))
				--print(line)

				-- TODO : gestion du contexte mieux
				-- stocker le chien précédent ?

				-- je ne sais pas, je ne comprend pas, ou je fais avec les infos disponibles
				-- recherche approximative (mal orthographié), distance (de Levenshtein par ex, à retrouver sur le web en LUA)
				-- donner une info complémentaire


		-- Trouver les tags des questions avec des moyens conventionnels
		if (#line["#race"]) ~= 0 then
					contextRace = true
					stringRace = line:tag2str("#race")[1]
					if stringRace == "labrador" then
						stringRace = "labrador retriever"
					end
					currentAnswerHasMeaning = true
		end
		if (#line["#use"]) ~= 0 then
					contextUse = true

					contextSize = false
					contextOrigin = false
					contextWeight = false
					currentAnswerHasMeaning = true
		end
		if (#line["#size"]) ~= 0 then
					contextSize = true

					contextWeight = false
					contextOrigin = false
					contextUse = false
					currentAnswerHasMeaning = true
		end
		if (#line["#weight"]) ~= 0 then
					contextWeight = true

					contextSize = false
					contextOrigin = false
					contextUse = false
					currentAnswerHasMeaning = true
		end
		if (#line["#origin"]) ~= 0 then
					contextOrigin = true

					contextWeight = false
					contextSize = false
					contextUse = false
					currentAnswerHasMeaning = true
		end


		--Trouver les tags avec la distance de Levenshtein




		-- génération du dialogue
		if(currentAnswerHasMeaning) then
					--
					--HAS MEANING
					--
		if (contextSize and contextRace)then
						
				print("\nInfochien : le " .. stringRace .. " est un chien " .. db[stringRace].height .. ".")
				hasAnswered = true
		elseif (contextUse and contextRace)then
						
				io.write("\nInfochien : l'utilisation du " .. stringRace .. " est ")
					 
				-- For every item in the list, including correct use of comma
				for useCount = 1, #db[stringRace].use do
							
						if(useCount == #db[stringRace].use) then
								io.write("et " .. db[stringRace].use[useCount] .. ".")

						elseif (useCount == #db[stringRace].use-1) then

								io.write(db[stringRace].use[useCount] .. " ")
						else 
								io.write(db[stringRace].use[useCount] .. ", ")
						end
				end

				io.write("\n")
				hasAnswered = true
		elseif (contextWeight and contextRace) then
								
								print("\nInfochien : le poids du " .. stringRace .. " est de " .. db[stringRace].weight .. ".")
								hasAnswered = true
		elseif (contextOrigin and contextRace) then					
				print("\nInfochien : l'origine du " .. stringRace .. " est : " .. db[stringRace].origin .. ".")
				hasAnswered = true
		elseif (contextRace) then
				print("\nInfochien : Parlons du ".. stringRace .. ".\n")
		elseif (contextOrigin) then
				print("\nInfochien : De quel chien voulez-vous savoir l'origine ?\n")
		elseif (contextUse) then
				print("\nInfochien : De quel chien voulez-vous savoir l'utilité ?\n")
		elseif (contextWeight) then
				print("\nInfochien : De quel chien voulez-vous savoir le poids ?\n")
		elseif (contextSize) then
				print("\nInfochien : De quel chien voulez-vous savoir la taille ?\n")
		end

		if (hasAnswered == true) then

				io.write("Infochien : " .. otherAnswer[math.random(#otherAnswer)] .. "\n\n")
				hasAnswered = false
		end

				--
				-- HAS NO MEANING
				--
		else
				print("\nJe n'ai pas compris la question. Pouvez-vous reformuler s'il-vous-plait ?\n")
				hasAnswered = false
		end


				
	 end
end



-- Main

--print("-Debug: Main\n")

userInput()
