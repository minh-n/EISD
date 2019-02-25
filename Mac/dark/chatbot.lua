
dark = require("dark")
local lev_iter = (require 'levenshtein').lev_iter

-- random sentences
math.randomseed(os.time())

otherAnswer={
		"Voulez-vous en savoir plus ?",
		"Voulez-vous des informations sur les chiens ?",
		"Quelque chose d'autre ?",
		"Des questions sur les chiens ?",
		"Des questions ?",
		"Quoi d'autre ?",
		"Ouaf.",
		"Je sais tout sur les chiens !",
		"Demandez-moi quelque chose d'autre si vous le souhaitez.",
}




-- database
require("extractor")

-- lexique
pipe = dark.pipeline()
pipe:basic()


raceList = {}
for k,v in pairs(db) do
	table.insert(raceList, k)
end

placeList = {}
for k,v in pairs(db) do
	table.insert(placeList, v.origin)
	--print(placeList[#placeList])
end


helloLexicon = {"bonjour", "salut", "henlo", "yo"}
sizeLexicon = {"taille", "mesure", "hauteur", "cm", "m"}
useLexicon = {"utilisé", "utilité", "utilisation", "use", "emploi"}
originLexicon = {"origine", "vient", "where", "pays", "région"}
weightLexicon = {"poids", "peser", "pèse", "pèsent", "kilo", "kg", "kilogrammes", "lourd"}
compareLexicon = {"entre le", "entre les", "lequel est", "comparer", "comparaison", "compare", "quel est le plus", "comparons", "quel chien est le plus", "le plus", "la plus" }
listLexicon = {"liste", "lister", "tous"}

qualifTaille = {"grand", "petit", "grande", "petite"}
qualifPoids = {"léger", "lourd", "gros", "grosse"}

pipe:lexicon("#hello", helloLexicon)
pipe:lexicon("#race", raceList)
pipe:lexicon("#size", sizeLexicon)
pipe:lexicon("#use", useLexicon)
pipe:lexicon("#origin", originLexicon)
pipe:lexicon("#weight", weightLexicon)
pipe:lexicon("#compare", compareLexicon)

pipe:lexicon("#qualifTaille", qualifTaille)
pipe:lexicon("#qualifPoids", qualifPoids)
pipe:lexicon("#place", placeList)
pipe:lexicon("#list", listLexicon)


--replaces correct words in the user input string 
function lev(line)
	words = {}

	for m in line:gmatch("%w+") do
		table.insert(words, m) 
		--print("Debug words :" .. m .. "\n")

	end --separating the user input into words

	levCoef = 2

	for _,word in pairs(words) do 
		--print("\nDebug : len" .. string.len(word))

		if (string.len(word) < 4) then
			goto endOfNestedFor
		end

		--replace wrong words for the race etc
		for _,correctWord in pairs(raceList) do
				--print("Debug : go into correct race\n")
				--print("Debug : " .. lev_iter(word, correctWord) .. ".\n")
				if(lev_iter(word, correctWord) <= levCoef) then
					line = line:gsub(word, correctWord) --remplacer le mot avec une typo
					goto endOfNestedFor -- double break to avoid checking a word twice
				end
		end
		for _,correctWord in pairs(sizeLexicon) do
				--print("Debug : go into correct size\n")


				if(lev_iter(word, correctWord) <= levCoef) then
					line = line:gsub(word, correctWord) --remplacer le mot avec une typo
					goto endOfNestedFor -- double break to avoid checking a word twice
				end
		end
		for _,correctWord in pairs(useLexicon) do

				if(lev_iter(word, correctWord) <= levCoef) then
					line = line:gsub(word, correctWord) --remplacer le mot avec une typo
					goto endOfNestedFor -- double break to avoid checking a word twice
				end
		end
--		for _,correctWord in pairs(originLexicon) do
--
--				if(lev_iter(word, correctWord) <= levCoef) then
--					line = line:gsub(word, correctWord) --remplacer le mot avec une typo
--					goto endOfNestedFor -- double break to avoid checking a word twice
--				end
--		end
		for _,correctWord in pairs(weightLexicon) do

				if(lev_iter(word, correctWord) <= levCoef) then
					line = line:gsub(word, correctWord) --remplacer le mot avec une typo
					goto endOfNestedFor -- double break to avoid checking a word twice
				end
		end
		for _,correctWord in pairs(placeList) do

				if(lev_iter(word, correctWord) <= levCoef) then
					line = line:gsub(word, correctWord) --remplacer le mot avec une typo
					goto endOfNestedFor -- double break to avoid checking a word twice
				end
		end

		::endOfNestedFor:: 
	end

	--TODO : ne pas vérifier chaque mot mais pattern de question ? Approche statistique

	return line
end


function lev2()

	print("Todo")

end


function convertWordIntoSize(line)

	size = 0
	line = line:gsub("kg", "")
	patternNumbers = "[0-9]+"

	if string.match(line, patternNumbers) then
	    size = line:tostring()
	end 

	if((string.find(line, "grand") ~= nil) or string.find(line, "fort") ~= nil)then
		size = 40
	elseif(string.find(line, "moyen") ~= nil) then
		size = 20
	else --petit
		size = 5
	end	

	return size
end


--Useless
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

--Comparaison taille
function getBiggestDog()
	biggestDog = ""
	biggestHeight = 0

	for k,v in pairs(db) do

		currentHeight = v.measure

		if(currentHeight > biggestHeight) then
			biggestDog = k
			biggestHeight = currentHeight
		end
	end

	return biggestDog
end

--Comparaison poids
function getHeaviestDog()
	heaviestDog = ""
	biggestWeight = 0

	for k,v in pairs(db) do
		if(v.weight > biggestWeight) then

			heaviestDog = k
			biggestWeight = v.weight
		end
	end

	return heaviestDog
end


function getUserAnswer()

	ans = io.read()
	ans = string.lower(ans) --démajusculer
	--putting spaces around punctuation signs

	ans = ans:gsub("é", "e") 
	ans = ans:gsub("%p", " %0 ") --on met des espaces sur la ponctuation

	return ans
end


function parseUserAnswer() --with levenshtein distance

	line = io.read()
	line = string.lower(line) --démajusculer
	line = line:gsub("%p", " %0 ") --putting spaces around punctuation signs
	line = line:gsub(" %- ", "-")
	line = lev(line)
	return line
end

-- removes spaces around "-", and replace the first letter with its uppercase version 
function formatOrigin(str)
	str = str:gsub(" %- ", "-")
    return (str:gsub("^%l", string.upper))
end

--return true if the first letter of str is a vowel
function isVoyelle(str)
	if((string.sub(str, 1, 1) == "a") or (string.sub(str, 1, 1) == "i") or (string.sub(str, 1, 1) == "u") or (string.sub(str, 1, 1) == "e") or (string.sub(str, 1, 1) == "o")) then
		return true
	else
		return false
	end
end

function getDogFromLocation(location)

	chiens = {}
	str = ""
	for k,v in pairs(db) do
		if(v.origin == location) then
			chiens[#chiens+1] = k	
		end
	end

	if(#chiens == 0) then
		print("Infochien : D'après notre base de données, aucun chien ne vient de cet endroit.")
	else
		if(#chiens > 1) then
			str = "Les " .. chiens[1]
			for k,v in pairs(chiens) do
				if (v ~= chiens[1]) then
					str = str..", les ".. chiens[k]
				end
			end
		
		else
			str = "Les " .. chiens[1]

		end

		if (isVoyelle(string.sub(location, 1, 1))) then
			location = location:gsub("^%l", string.upper)
			str = str.." viennent d'"..location .. "."
		else
			location = location:gsub("^%l", string.upper)
			str = str.." viennent de "..location .. "."

		end


	end

	return str
end



--TODO
--Moins de contexte
--Optimiser levenshtein
--Quel autre chien a la même origine ?
--combien de chien de la même taille ?
--je ne sais pas, je ne comprend pas, je n'ai pas l'info : ok
--BONJOUR : ok

--read the user's input and answers accordingly
function chatbotMain()
	--print("-Debug: chatbotMain()\n")
	print("Infochien : Bonjour je suis un chienbot ! Je peux parler de beaucoup de chiens.\n")

	local contextTable = { 
		["race"] = {
				value = false,
				label = "la race",
				count = 0
		},
		["use"] = {
				value = false,
				label = "l'utilité",
				count = 0
		},
		["size"] = {
				value = false,
				label = "la taille",
				count = 0
		},
		["weight"] = {
				value = false,
				label = "le poids",
				count = 0
		},
		["origin"] = {
				value = false,
				label = "l'origine",
				count = 0
		},
		["unknown"] = {
				value = false,
				label = "donnée inconnue",
				count = 0
		}
	}


	while 1 do

		line = parseUserAnswer()

		hasAnswered = false
		currentAnswerHasMeaning = false

		if line == "quitter" or line == "quit" or line == "q" then
			break
		end

		line = dark.sequence(line)
		pipe(line)
		print("") --saut de ligne entre la question de l'user et la reponse

		if(line ~= nil) then
			previousLine = line
		else
			previousLine = ""
			previousLine = dark.sequence(previousLine)
			pipe(previousLine)
		end

		if (#line["#hello"]) ~= 0 then
			print("Infochien : Bonjour !")
			hasAnswered = true
			currentAnswerHasMeaning = true
		end


		if (#line["#list"]) ~= 0 then
			print("Infochien : Voici la liste de tous les chiens de la base de donnée :")
			
			chiens = {}

			for k,v in pairs(db) do
				chiens[#chiens+1] = k	
			end

			str = "Le " .. chiens[1]
			for k,v in pairs(chiens) do
				if (v ~= chiens[1]) then
					str = str..", le ".. chiens[k]
				end
			end
			str = str .. " sont dans la base de donnée.\n"
			print(str)
			hasAnswered = true
		end

		--increment context : au bout de 3 questions, le context est reset

		for k, v in pairs(contextTable) do
			
			if(contextTable[k].count >= 3) then
				contextTable[k].count = 0
				contextTable[k].value = false
			else
				contextTable[k].count = contextTable[k].count + 1
			end
		end

		-- TODO : gestion du contexte en mieux
				-- stocker le chien précédent : OK !
				-- les accents : hmm...
				-- je ne sais pas, je ne comprend pas, ou je fais avec les infos disponibles : pas ouf en vrai
				-- recherche approximative (mal orthographié), distance (de Levenshtein par ex, à retrouver sur le web en LUA) : OK !
				-- donner une info complémentaire : pas ouf ?

		--todo : reset le contexte quand on mentionne une race = Non !

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
				--if (stringRace == "labrador") then
				--	stringRace = "labrador retriever"
				--elseif (previousRace == "labrador") then
				--	previousRace = "labrador retriever"
				--end

				currentAnswerHasMeaning = true
			end
		end
		if (#line["#use"]) ~= 0 then
			contextTable["use"].value = true
			contextTable["use"].count = 0

			contextTable["size"].value = false
			contextTable["origin"].value = false
			contextTable["weight"].value = false
			currentAnswerHasMeaning = true
		end
		if (((#line["#size"]) ~= 0) or (#line["#qualifTaille"] ~= 0)) then
			contextTable["size"].value = true
			contextTable["size"].count = 0

			contextTable["weight"].value = false
			contextTable["origin"].value = false
			contextTable["use"].value = false
			currentAnswerHasMeaning = true
		end
		if (((#line["#weight"]) ~= 0) or (#line["#qualifPoids"] ~= 0)) then
			contextTable["weight"].value = true
			contextTable["weight"].count = 0

			contextTable["size"].value = false
			contextTable["origin"].value = false
			contextTable["use"].value = false
			currentAnswerHasMeaning = true
		end
		if (#line["#origin"]) ~= 0 then
			contextTable["origin"].value = true
			contextTable["origin"].count = 0

			contextTable["weight"].value = false
			contextTable["size"].value = false
			contextTable["use"].value = false
			currentAnswerHasMeaning = true
		end
		if (#line["#compare"]) ~= 0 then		
			currentAnswerHasMeaning = true
		end
		if (#line["#place"]) ~= 0 then		
			currentAnswerHasMeaning = true
		end
		if (#line["#list"]) ~= 0 then		
			contextTable["origin"].value = false
			contextTable["weight"].value = false
			contextTable["size"].value = false
			contextTable["use"].value = false
			contextTable["race"].value = false
			currentAnswerHasMeaning = true
		end
		--Trouver les tags avec la distance de Levenshtein


		-- génération du dialogue

		--
		-- HAS MEANING
		if(currentAnswerHasMeaning) then

				---------------------------------
				--is comparison
				if((#line["#compare"]) ~= 0 ) then

					--((#previousLine["#race"]) >= 1 or (#line["#race"]) >= 1)
					if(   (contextTable["race"].value) and stringRace ~= nil and previousRace ~= nil ) then

						print("Infochien : Comparons le ".. stringRace .. " et le " .. previousRace .. ".")

						--print("Debug : contextSize = " )
						--print(contextTable["size"].value )

						if(contextTable["size"].value == false and contextTable["weight"].value == false) then
							print("Infochien : Quelle information voulez-vous comparer (taille ou poids) ?\n")

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
									--print("Debug: comparons la taille\n")
									
							end
							if (((#line["#weight"]) ~= 0) or (#line["#qualifPoids"] ~= 0)) then
									contextTable["weight"].value = true
									contextTable["size"].value = false
									contextTable["origin"].value = false
									contextTable["use"].value = false
									currentAnswerHasMeaning = true
									--print("Debug: comparons le poids\n")
							end
						end
						answer = "ouaf"
					else
						print("Infochien : Voulez-vous comparer deux chiens (dites 'ouaf'), ou faire une comparaison absolue (dites 'ouaf ouaf') ?\n")
						answer = getUserAnswer()
						answer = answer:gsub(" ", "")

					end
					
					-------------------		
					if(answer == "ouaf") then --comparaison entre deux chiens
						
					--print("\n Debug strragce le ".. stringRace .. " et le " .. previousRace .. ".")

						--GET RACE
						if(stringRace == nil or previousRace == nil) then
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
							--if (stringRace == "labrador") then
							--	stringRace = "labrador retriever"
							--elseif (previousRace == "labrador") then
							--	previousRace = "labrador retriever"
							--end
							currentAnswerHasMeaning = true
						end

						end


						::hasContextAndRace::

						if(previousRace ~= nil) then
							if (contextTable["size"].value and contextTable["race"].value)then

									dogSize = db[stringRace].measure
									previousSize = db[previousRace].measure

									if(db[stringRace].measure > db[previousRace].measure) then
										print("Infochien : Le " .. stringRace .. " (" .. db[stringRace].height .. ") est plus grand que le " .. previousRace .. " (" .. db[previousRace].height ..").")
									else
										print("Infochien : Le " .. previousRace .. " (" .. db[previousRace].height .. ") est plus grand que le " .. stringRace .. " (" .. db[stringRace].height ..").")
									end

									hasAnswered = true
							
							elseif (contextTable["weight"].value and contextTable["race"].value) then

									dogWeight = db[stringRace].weight
									previousWeight = db[previousRace].weight

									if(dogWeight == 0 or previousWeight == 0) then
										print("Infochien : Je n'ai pas cette information.")
									elseif(dogWeight > previousWeight) then
										print("Infochien : Le " .. stringRace .. " (" .. dogWeight .. " kg) est plus lourd que le " .. previousRace .. " (" .. previousWeight .." kg).")
									else
										print("Infochien : Le " .. previousRace .. " (" .. previousWeight .. " kg) est plus lourd que le " .. stringRace .. " (" .. dogWeight .." kg).")
									end

									hasAnswered = true

							elseif (contextTable["origin"].value and contextTable["race"].value) then			

									origin = formatOrigin(db[stringRace].origin)
									print("\nInfochien : L'origine du " .. stringRace .. " est : " .. origin .. ".")
									hasAnswered = true

							--elseif (contextTable["race"].value) then
									
							--		print("Go jamais ici\n")

							else
									--for k,context in pairs(contextTable) do
									--	if (context.value) then
									--		print("\nInfochien : De quel chien voulez-vous savoir " .. context.label .. " ?\n")
									--	end	
									--end
									--DEBUG : cette partie n'est jamais atteinte
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
							print("Infochien : Quels chiens voulez-vous comparer ?\n")

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
									end	

								
								currentAnswerHasMeaning = true
							end
							--goto hasRaceContext

							hasAnswered = true
						end
					-------------------
					elseif (answer == "ouafouaf") then --comparaison absolue
						
						if ((#line["#qualifTaille"]) ~= 0)then

							biggestDog = getBiggestDog()
							--if(line:tag2str("#size")[1] == "grand") then
							print("Infochien : Le chien le plus grand de la BD est le " .. biggestDog .. ".")
							hasAnswered = true
						elseif ((#line["#qualifPoids"]) ~= 0)then
							heaviestDog = getHeaviestDog()
							--if(line:tag2str("#size")[1] == "grand") then
							print("Infochien : Le chien le plus gros de la BD est le " .. heaviestDog .. ".")
							hasAnswered = true
						else
							print("Debug: Rien")
						end
					end

				---------------------------------
				--is not comparison
				else
					if (#line["#race"] == 2) then

						print("Infochien : Parlons du " .. stringRace .. " et du " .. previousRace .. ".")
						hasAnswered = true

					--tell size
					elseif (contextTable["size"].value and contextTable["race"].value)then
							if (db[stringRace].height ~= "de taille inconnue") then
								print("Infochien : Le " .. stringRace .. " est un chien " .. db[stringRace].height .. " (" .. db[stringRace].measure .. " cm).")
							else
								print("Infochien : Le " .. stringRace .. " est un chien de " .. db[stringRace].measure .. " cm.")
							end
							hasAnswered = true

					--tell use
					elseif (contextTable["use"].value and contextTable["race"].value)then
									
							io.write("Infochien : L'utilisation du " .. stringRace .. " est ")
								 
							-- For every item in the list, including correct use of comma
							for useCount = 1, #db[stringRace].use do
									
									displayUse = db[stringRace].use[useCount]
									displayUse = displayUse:gsub(" \' ", "\'")
									if(useCount == #db[stringRace].use) then
											io.write("et " .. displayUse .. ".")

									elseif (useCount == #db[stringRace].use-1) then

											io.write(displayUse .. " ")
									else 
											io.write(displayUse .. ", ")
									end
							end

							io.write("\n")
							hasAnswered = true
					elseif (contextTable["weight"].value and contextTable["race"].value) then

						if(db[stringRace].weight == 0 ) then
							print("Infochien : Désolé, mais je n'ai pas cette information.")
						else
							print("Infochien : Le poids du " .. stringRace .. " est " .. db[stringRace].weight .. "kg.")
						end	
						hasAnswered = true
							--set context weight to false here ? TODO ?

					elseif (#line["#place"] ~= 0) then
							print("Infochien : " .. getDogFromLocation(line:tag2str("#place")[1]) .. "" )
							hasAnswered = true

					elseif (contextTable["origin"].value and contextTable["race"].value) then	

							origin = formatOrigin(db[stringRace].origin)				
							print("Infochien : L'origine du " .. stringRace .. " est : " .. origin .. ".")
							hasAnswered = true

					elseif (contextTable["race"].value) then
						if(previousRace ~= nil) then
							print("Infochien : Parlons du " .. stringRace .. " et du " .. previousRace .. ".")
						else
							print("Infochien : Parlons du " .. stringRace .. ".")
						end

						--je l'ai pas mis pour une raison mais on va le laisser
						hasAnswered = true

					else
						for k,context in pairs(contextTable) do
							if (context.value) then
								print("Infochien : De quel chien voulez-vous savoir " .. context.label .. " ?\n")
							end	
						end
					end
				end

		--
		-- Else: HAS NO MEANING
		else
			print("Infochien : Je n'ai pas compris la question. Pouvez-vous reformuler s'il-vous-plait ?\n")
			hasAnswered = false
		end
		if (hasAnswered == true) then
			io.write("Infochien : " .. otherAnswer[math.random(#otherAnswer)] .. "\n\n")
			hasAnswered = false
		end
	end	
end


-- Main
--print("-Debug: Main\n")
chatbotMain()
