
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
qualificatifList = {"grand", "petit", "grande", "petite"}
useList = {"utilisé", "utilité", "utilisation", "use", "emploi"}
originList = {"origine", "vient", "où", "where", "pays", "région"}
weightList = {"poids", "peser", "pèse", "pèsent", "kilo", "kg", "kilogrammes", "plus lourd"}
compareList = {"entre le", "entre les", "lequel est", "comparer", "comparaison", "compare", "quel est le plus", "quel chien est le plus", "le plus", "la plus" }

pipe:lexicon("#race", raceList)
pipe:lexicon("#size", sizeList)
pipe:lexicon("#use", useList)
pipe:lexicon("#origin", originList)
pipe:lexicon("#weight", weightList)
pipe:lexicon("#compare", compareList)
pipe:lexicon("#qualif", qualificatifList)



--replaces correct words in the user input string 
function lev(line)
	words = {}
	for m in line:gmatch("%w+") do table.insert(words, m) end --separating the user input into words

	levCoef = 1

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



function getUserAnswer()

	ans = io.read()

	ans = string.lower(ans) --démajusculer

	--putting spaces around punctuation signs
	ans = ans:gsub("%p", " %0 ") --on met des espaces sur la ponctuation

	return ans

end




--read the user's input
function userInput()
	--print("-Debug: userInput()\n")
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

		-- TODO : gestion du contexte en mieux
				-- stocker le chien précédent : OK !
				-- les accents : hmm...
				-- je ne sais pas, je ne comprend pas, ou je fais avec les infos disponibles : pas ouf en vrai
				-- recherche approximative (mal orthographié), distance (de Levenshtein par ex, à retrouver sur le web en LUA) : OK !
				-- donner une info complémentaire : pas ouf ?

		--todo : reset le contexte quand on mentionne une race 

		-- Trouver les tags des questions avec des moyens conventionnels
		if (#line["#race"]) ~= 0 then
					contextTable["race"].value = true
					if(stringRace == nil) then
						if((#line["#race"]) == 2) then
							previousRace = line:tag2str("#race")[1]
							stringRace = line:tag2str("#race")[2]
						else
							stringRace = line:tag2str("#race")[1]
						end

					else
						previousRace = stringRace
						stringRace = line:tag2str("#race")[1]
					end	

					--labrador
					if (stringRace == "labrador") then
						stringRace = "labrador retriever"
					elseif (previousRace == "labrador") then
						previousRace = "labrador retriever"
					end
					currentAnswerHasMeaning = true
		end
		if (#line["#use"]) ~= 0 then
					contextTable["use"].value = true

					contextTable["size"].value = false
					contextTable["origin"].value = false
					contextTable["weight"].value = false
					currentAnswerHasMeaning = true
		end
		if (#line["#size"]) ~= 0 then
					contextTable["size"].value = true

					contextTable["weight"].value = false
					contextTable["origin"].value = false
					contextTable["use"].value = false
					currentAnswerHasMeaning = true
		end
		if (#line["#weight"]) ~= 0 then
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

					print("\nInfochien : voulez-vous comparer deux chiens, ou faire une comparaison absolue?")
					answer = getUserAnswer()
					-------------------
					if(answer == "ouaf") then --comparaison entre deux chiens
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
															print("Infochien : le poids du " .. stringRace .. " est " .. db[stringRace].weight .. "kg.")
															print("Infochien : le poids du " .. previousRace .. " est " .. db[previousRace].weight .. "kg.")
															print("\nInfochien : Todo : comparer ces deux tailles.")
															hasAnswered = true
								elseif (contextTable["origin"].value and contextTable["race"].value) then					
															print("\nInfochien : l'origine du " .. stringRace .. " est : " .. db[stringRace].origin .. ".")
															hasAnswered = true
								elseif (contextTable["race"].value) then
										print("\nInfochien : Comparons le ".. stringRace .. " et le " .. previousRace .. ".\n")
								else
														for k,context in pairs(contextTable) do
															if (context.value) then
																print("\nInfochien : De quel chien voulez-vous savoir " .. context.label .. " ?\n")
															end	
														end
								end

						else
							print("\nDebug : pas de contexte go mettre context svp")
							--il attend une réponse après, c'est pas normal
							hasAnswered = true
						end
					-------------------
					elseif (answer == "ouaf ouaf") then --comparaison absolue
						
						if ((#line["#qualif"]) ~= 0)then

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
					elseif (contextTable["origin"].value and contextTable["race"].value) then					
							print("\nInfochien : l'origine du " .. stringRace .. " est : " .. db[stringRace].origin .. ".")
							hasAnswered = true
					elseif (contextTable["race"].value) then
							print("\nInfochien : Parlons du ".. stringRace .. ".\n")
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

userInput()
