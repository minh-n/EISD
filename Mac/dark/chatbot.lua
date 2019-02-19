
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

raceList = {"beagle", "terre - neuve", "labrador"}
sizeList = {"taille", "mesure", "hauteur", "cm", "m"}
useList = {"utilisé", "utilité", "utilisation", "use", "emploi"}
originList = {"origine", "vient", "où", "where", "pays", "région"}
weightList = {"poids", "peser", "pèse", "pèsent", "kilo", "kg", "kilogrammes", "plus lourd"}
compareList = {"entre le", "entre les", "lequel est", "comparer", "comparaison", "compare", "quel est le plus", "comparons", "quel chien est le plus", "le plus", "la plus" }


qualifTaille = {"grand", "petit", "grande", "petite", "gros", "grosse"}
qualifPoids = {"léger", "lourd"}

pipe:lexicon("#race", raceList)
pipe:lexicon("#size", sizeList)
pipe:lexicon("#use", useList)
pipe:lexicon("#origin", originList)
pipe:lexicon("#weight", weightList)
pipe:lexicon("#compare", compareList)
pipe:lexicon("#qualifTaille", qualifTaille)
pipe:lexicon("#qualifPoids", qualifPoids)


--TODO : ne pas vérifier chaque mot
--replaces correct words in the user input string 
function lev(line)
	words = {}

	for m in line:gmatch("%w+") do
		table.insert(words, m) 
		--print("Debug words :" .. m .. "\n")

	end --separating the user input into words

	levCoef = 1

	for _,word in pairs(words) do 
		--print("\nDebug : len" .. string.len(word))

		if (string.len(word) < 4) then
			goto endOfNestedFor
		end

		--replace wrong words for the race etc
		for _,correctWord in pairs(raceList) do
				--print("Debug : go into correct race\n")

				if(lev_iter(word, correctWord) <= levCoef) then
					--print("Debug : corrige\n")
					line = line:gsub(word, correctWord) --remplacer le mot avec une typo
					goto endOfNestedFor -- double break to avoid checking a word twice
				end
		end
		for _,correctWord in pairs(sizeList) do
				--print("Debug : go into correct size\n")


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


function convertWordIntoSize(line)

	size = 0
	line = line:gsub("kg", "")
	patternNumbers = "[0-9]+"

	if string.match(line, patternNumbers) then
	    size = line:tostring()
	end 

	if((string.find(line, "grand") ~= nil) or string.find(line, "fort") ~= nil)then
		size = 50
	elseif(string.find(line, "moyen") ~= nil) then
		size = 30
	else --petit
		size = 10
	end	

	return size
end


--TODO ? Utile ou pas ?
function convertWordIntoWeight(line)

	size = 0
	line = line:gsub("kg", "")
	patternNumbers = "[0-9]+"

	if string.match(line, patternNumbers) then
	    size = line:tostring()
	end 

	if((string.find(line, "grand") ~= nil) or string.find(line, "fort") ~= nil)then
		size = 50
	elseif(string.find(line, "moyen") ~= nil) then
		size = 30
	else --petit
		size = 10
	end	

	return size
end

--Comparaison
function getBiggestDog()
	biggestDog = ""
	biggestHeight = 0

	for k,v in pairs(db) do
		currentHeight = convertWordIntoSize(v.height)
		if(currentHeight > biggestHeight) then
			biggestDog = k
			biggestHeight =  currentHeight
		end
	end

	return biggestDog
end

--TODO : Comparaison
function getHeaviestDog()
	biggestDog = ""
	biggestHeight = 0

	for k,v in pairs(db) do
		currentHeight = convertWordIntoSize(v.height)
		if(currentHeight > biggestHeight) then
			biggestDog = k
			biggestHeight =  currentHeight
		end
	end

	return biggestDog
end


function getUserAnswer()

	ans = io.read()
	ans = string.lower(ans) --démajusculer
	--putting spaces around punctuation signs
	ans = ans:gsub("%p", " %0 ") --on met des espaces sur la ponctuation

	return ans

end


function parseUserAnswer() --with levenshtein distance

	line = io.read()
	line = string.lower(line) --démajusculer
	line = line:gsub("%p", " %0 ") --putting spaces around punctuation signs
	line = lev(line)
	return line

end


--TODO
--Moins de contexte
--Optimiser levenshtein
--Quel autre chien a la même origine ?
--combien de chien de la même taille ?
--je ne sais pas, je ne comprend pas, je n'ai pas l'info

--site de la prof
--des infos utiles sur le LUA

--revenir aux statuts
-- que les adhérents qui peuvent voter
-- à huis clos
-- fuck


--read the user's input and answers accordingly
function chatbotMain()
	--print("-Debug: chatbotMain()\n")
	print("Infochien : Bonjour je suis un chienbot ! Je peux parler du Beagle, du Labrador Retriever ou du Terre-Neuve.\n")

	local contextTable = { 
		["race"] = {
				value = false,
				label = "la race"
		},
		["use"] = {
				value = false,
				label = "l'utilité"
		},
		["size"] = {
				value = false,
				label = "la taille"
		},
		["weight"] = {
				value = false,
				label = "le poids"
		},
		["origin"] = {
				value = false,
				label = "l'origine"
		}
	}


	while 1 do


		line = parseUserAnswer()

		hasAnswered = false
		currentAnswerHasMeaning = false

		if line == "quitter" or line == "quit" or line == "q" then
			break;
		end

		line = dark.sequence(line)
		pipe(line)
		
		if(line ~= nil) then
			previousLine = line
		else
			previousLine = ""
			previousLine = dark.sequence(previousLine)
			pipe(previousLine)
		end

		--print(dark.pipeline(line))
		--print(line)

		-- TODO : gestion du contexte en mieux
				-- stocker le chien précédent : OK !
				-- les accents : hmm...
				-- je ne sais pas, je ne comprend pas, ou je fais avec les infos disponibles : pas ouf en vrai
				-- recherche approximative (mal orthographié), distance (de Levenshtein par ex, à retrouver sur le web en LUA) : OK !
				-- donner une info complémentaire : pas ouf ?

		--todo : reset le contexte quand on mentionne une race 

		-- Trouver les tags des questions avec des moyens conventionnels
		if (#line["#race"]) ~= 0 then
			if (#line["#race"]) ~= 0 then
				contextTable["race"].value = true
				if((#line["#race"]) == 2) then
					--print("\nDEBUG first : 2 chiens")
					stringRace = line:tag2str("#race")[1]
					if(line:tag2str("#race")[1] ~= line:tag2str("#race")[2]) then
						previousRace = line:tag2str("#race")[2]
					end
				
				else --if((#line["#race"]) == 1) then
					if(stringRace ~= line:tag2str("#race")[1]) then
						previousRace = stringRace
						stringRace = line:tag2str("#race")[1]
					end
					--if(previousRace ~= nil) then
						--print("\nDEBUG first : 1 chien previousRace= ".. previousRace )
					--end
				end	

					--labrador
				if (stringRace == "labrador") then
					stringRace = "labrador retriever"
				elseif (previousRace == "labrador") then
					previousRace = "labrador retriever"
				end
				currentAnswerHasMeaning = true
			end
		end
		if (#line["#use"]) ~= 0 then
			contextTable["use"].value = true

			contextTable["size"].value = false
			contextTable["origin"].value = false
			contextTable["weight"].value = false
			currentAnswerHasMeaning = true
		end
		if (((#line["#size"]) ~= 0) or (#line["#qualifTaille"] ~= 0)) then
			contextTable["size"].value = true

			contextTable["weight"].value = false
			contextTable["origin"].value = false
			contextTable["use"].value = false
			currentAnswerHasMeaning = true
		end
		if (((#line["#weight"]) ~= 0) or (#line["#qualifPoids"] ~= 0)) then
			contextTable["weight"].value = true

			contextTable["size"].value = false
			contextTable["origin"].value = false
			contextTable["use"].value = false
			currentAnswerHasMeaning = true
		end
		if (#line["#origin"]) ~= 0 then
			contextTable["origin"].value = true

			contextTable["weight"].value = false
			contextTable["size"].value = false
			contextTable["use"].value = false
			currentAnswerHasMeaning = true
		end
		if (#line["#compare"]) ~= 0 then
					
			currentAnswerHasMeaning = true
		end

		--Trouver les tags avec la distance de Levenshtein




		-- génération du dialogue

		--
		-- HAS MEANING
		--

		if(currentAnswerHasMeaning) then
				---------------------------------
				--is comparison
				if((#line["#compare"]) ~= 0 ) then

					--((#previousLine["#race"]) >= 1 or (#line["#race"]) >= 1)
					if(   (contextTable["race"].value) and   stringRace ~= nil and previousRace ~= nil ) then

						print("\nInfochien : Comparons le ".. stringRace .. " et le " .. previousRace .. ".")

						print("\nDebug : contextSize = " )
						print(contextTable["size"].value )

						if(contextTable["size"].value == false and ~contextTable["weight"].value == false) then
							print("\nInfochien : Quelle information voulez-vous comparer (taille ou poids) ?\n")

							--user input, telling what info to compare----------------
							line = parseUserAnswer()
							line = dark.sequence(line)
							pipe(line)

							if (((#line["#size"]) ~= 0) or (#line["#qualifTaille"] ~= 0)) then
									contextTable["size"].value = true
									contextTable["weight"].value = false
									contextTable["origin"].value = false
									contextTable["use"].value = false
									currentAnswerHasMeaning = true

									
							end
							if (((#line["#weight"]) ~= 0) or (#line["#qualifPoids"] ~= 0)) then
									contextTable["weight"].value = true
									contextTable["size"].value = false
									contextTable["origin"].value = false
									contextTable["use"].value = false
									currentAnswerHasMeaning = true

							end
						end
						answer = "ouaf"
					else
						print("\nInfochien : voulez-vous comparer deux chiens (dites 'ouaf'), ou faire une comparaison absolue (dites 'ouaf ouaf') ? ")
						answer = getUserAnswer()

					end
					
					
					-------------------
					
					if(answer == "ouaf") then --comparaison entre deux chiens
						
						print("\n Debug strragce le ".. stringRace .. " et le " .. previousRace .. ".")

						if(stringRace == "" or previousRace == "") then
							print("\nInfochien : Quels chiens voulez-vous comparer ?\n")

							line = parseUserAnswer()
							line = dark.sequence(line)
							pipe(line)

							if (#line["#race"]) ~= 0 then
							contextTable["race"].value = true
							if((#line["#race"]) == 2) then
								--print("\nDEBUG first : 2 chiens")
								stringRace = line:tag2str("#race")[1]
								if(line:tag2str("#race")[1] ~= line:tag2str("#race")[2]) then
									previousRace = line:tag2str("#race")[2]
								end
							
							else --if((#line["#race"]) == 1) then
								if(stringRace ~= line:tag2str("#race")[1]) then
									previousRace = stringRace
									stringRace = line:tag2str("#race")[1]
								end
								--if(previousRace ~= nil) then
									--print("\nDEBUG first : 1 chien previousRace= ".. previousRace )
								--end
							end	

								--labrador
							if (stringRace == "labrador") then
								stringRace = "labrador retriever"
							elseif (previousRace == "labrador") then
								previousRace = "labrador retriever"
							end
							currentAnswerHasMeaning = true
						end

						end


						::hasContextAndRace::

						if(previousRace ~= nil) then
							if (contextTable["size"].value and contextTable["race"].value)then

									dogSize = convertWordIntoSize(db[stringRace].height)
									previousSize = convertWordIntoSize(db[previousRace].height)

									if(dogSize > previousSize) then
										print("\nInfochien : le " .. stringRace .. " (" .. db[stringRace].height .. ") est plus grand que le " .. previousRace .. " (" .. db[previousRace].height ..").\n")
									else
										print("\nInfochien : le " .. previousRace .. " (" .. db[previousRace].height .. ") est plus grand que le " .. stringRace .. " (" .. db[stringRace].height ..").\n")
									end

									hasAnswered = true
							
							elseif (contextTable["weight"].value and contextTable["race"].value) then

									print("Infochien : le poids du " .. stringRace .. " est " .. db[stringRace].weight .. "kg.")
									print("Infochien : le poids du " .. previousRace .. " est " .. db[previousRace].weight .. "kg.")
									print("\nInfochien : Todo : comparer ces deux tailles.")
									hasAnswered = true

							elseif (contextTable["origin"].value and contextTable["race"].value) then			

									print("\nInfochien : l'origine du " .. stringRace .. " est : " .. db[stringRace].origin .. ".")
									hasAnswered = true

							--elseif (contextTable["race"].value) then
									
							--		print("Go jamais ici\n")



								-----
								---
								---

							else
									--for k,context in pairs(contextTable) do
									--	if (context.value) then
									--		print("\nInfochien : De quel chien voulez-vous savoir " .. context.label .. " ?\n")
									--	end	
									--end

									print("\nInfochien : Comparons le ".. stringRace .. " et le " .. previousRace .. ".")
									print("\nInfochien : Quelle information voulez-vous savoir ?\n")

									--user input, telling what info to compare----------------
									line = parseUserAnswer()
									line = dark.sequence(line)
									pipe(line)

									if (((#line["#size"]) ~= 0) or (#line["#qualifTaille"] ~= 0)) then
											contextTable["size"].value = true
											contextTable["weight"].value = false
											contextTable["origin"].value = false
											contextTable["use"].value = false
											currentAnswerHasMeaning = true
											goto hasContextAndRace
									end
									if (((#line["#weight"]) ~= 0) or (#line["#qualifPoids"] ~= 0)) then
											contextTable["weight"].value = true
											contextTable["size"].value = false
											contextTable["origin"].value = false
											contextTable["use"].value = false
											currentAnswerHasMeaning = true
											goto hasContextAndRace

									end
							end

						else
							print("\nDebug : pas de race go mettre context svp")
							--TODO il attend une réponse après, c'est pas normal ???
							--line = "labrador retriever"
							--goto hasRaceContext


							hasAnswered = true
						end
					-------------------
					elseif (answer == "ouaf ouaf") then --comparaison absolue
						
						if ((#line["#qualifTaille"]) ~= 0)then

							biggestDog = getBiggestDog()
							--if(line:tag2str("#size")[1] == "grand") then
								print("\nInfochien : le chien le plus grand de la BD est le " .. biggestDog .. ".\n")
							
							--end

								hasAnswered = true
						end

					end
				


				---------------------------------
				--is not comparison
				else
					if (contextTable["size"].value and contextTable["race"].value)then
									
							print("\nInfochien : le " .. stringRace .. " est un chien " .. db[stringRace].height .. ".")
							hasAnswered = true
					elseif (contextTable["use"].value and contextTable["race"].value)then
									
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
					elseif (contextTable["weight"].value and contextTable["race"].value) then
							print("\nInfochien : le poids du " .. stringRace .. " est " .. db[stringRace].weight .. "kg.")
							hasAnswered = true
							--set context weight to false here
					elseif (contextTable["origin"].value and contextTable["race"].value) then					
							print("\nInfochien : l'origine du " .. stringRace .. " est : " .. db[stringRace].origin .. ".")
							hasAnswered = true
					elseif (contextTable["race"].value) then
						if(previousRace ~= nil) then
							print("\nInfochien : Parlons du " .. stringRace .. " et du " .. previousRace .. ".\n")
						else
							print("\nInfochien : Parlons du " .. stringRace .. ".\n")
						end
					else
						for k,context in pairs(contextTable) do
							if (context.value) then
								print("\nInfochien : De quel chien voulez-vous savoir " .. context.label .. " ?\n")
							end	
						end
					end
				end

		--
		-- Else: HAS NO MEANING
		--
		else
				print("Infochien : Je n'ai pas compris la question. Pouvez-vous reformuler s'il-vous-plait ?\n")
				hasAnswered = false
		end


	 end
end


if (hasAnswered == true) then

				io.write("Infochien : " .. otherAnswer[math.random(#otherAnswer)] .. "\n\n")
				hasAnswered = false
		end

-- Main

--print("-Debug: Main\n")

chatbotMain()
