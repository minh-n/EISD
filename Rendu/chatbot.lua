
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
--require("extractor") --(pour lancer avec l'extraction d'information)
--require("db/db_demo") -- (pour lancer avec la base de donnée de la présentation)
require("db/db_full") -- (pour lancer avec la base de donnée complète de 27 chiens)


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
end


helloLexicon = {"bonjour", "salut", "henlo", "yo"}
sizeLexicon = {"taille", "mesure", "hauteur", "cm", "m"}
useLexicon = {"utilise", "utilite", "utilisation", "use", "emploi"}
originLexicon = {"origine", "vient", "where", "pays", "région", "vient-il"}
weightLexicon = {"poids", "peser", "pèse", "pèsent", "kilo", "kg", "kilogrammes"}
compareLexicon = {"entre le", "entre les", "lequel est", "comparer", "comparaison", "compare", "quel est le plus", "comparons", "quel chien est le plus", "le plus", "la plus" }
listLexicon = {"liste", "lister"}

qualifTaille = {"grand", "petit", "grande", "petite"}
qualifPoids = {"leger", "lourd", "gros", "grosse"}

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

	end --separating the user input into words


	for _,word in pairs(words) do 


		if (string.len(word) < 4) then
			goto endOfNestedFor
		end

		levCoef = (string.len(word)/3)-((string.len(word)/3)%1) --proportional to the word's length

		--replace wrong words for the race etc
		for _,correctWord in pairs(raceList) do
				if(lev_iter(word, correctWord) <= levCoef) then
					line = line:gsub(word, correctWord) --remplacer le mot avec une typo
					goto endOfNestedFor -- double break to avoid checking a word twice
				end
		end
		for _,correctWord in pairs(sizeLexicon) do
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
		for _,correctWord in pairs(weightLexicon) do

				if(lev_iter(word, correctWord) <= levCoef) then
					line = line:gsub(word, correctWord) --remplacer le mot avec une typo
					goto endOfNestedFor -- double break to avoid checking a word twice
				end
		end
		--for _,correctWord in pairs(placeList) do

		--		if(lev_iter(word, correctWord) <= levCoef) then
		--			line = line:gsub(word, correctWord) --remplacer le mot avec une typo
		--			goto endOfNestedFor -- double break to avoid checking a word twice
		--		end
		--	end

		::endOfNestedFor:: 
	end
	return line
end

--Non utilisé
function convertWordIntoSize(line) 

	size = 0
	line = line:gsub("cm", "")
	patternNumbers = "[0-9]+"

	if string.match(line, patternNumbers) then
	    size = line:tostring()
	end 

	if((string.find(line, "grand") ~= nil) or string.find(line, "fort") ~= nil) then
		size = 40
	elseif(string.find(line, "moyen") ~= nil) then
		size = 20
	else --petit
		size = 5
	end	

	return size
end


--Non utilisé
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

--Comparaison taille : le plus grand
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


--Comparaison taille : le plus petit
function getSmallestDog()
	smallestDog = ""
	smallestHeight = 100

	for k,v in pairs(db) do

		currentHeight = v.measure

		if ( (currentHeight < smallestHeight) and (currentHeight ~=0) )then
			smallestDog = k --print("smallestDog = "..k)
			smallestHeight = currentHeight
		end
	end

	return smallestDog
end

--Comparaison poids : le plus lourd
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

--Comparaison poids : le plus léger
function getLightestDog()
	lightestDog = ""
	lightestWeight = 100

	for k,v in pairs(db) do
		if(v.weight < lightestWeight and (v.weight ~=0) ) then

			lightestDog = k
			lightestWeight = v.weight
		end
	end

	return lightestDog
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
	line = line:gsub("é", "e") 
	line = line:gsub("%p", " %0 ") --putting spaces around punctuation signs
	line = line:gsub(" %- ", "-")

	--Trouver les tags avec la distance de Levenshtein
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

--return a list of dogs corresponding to a specific location (example : 'Allemagne')
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

--read the user's input and answers accordingly
function chatbotMain()
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
		}
	}


	while 1 do

		line = parseUserAnswer()

		hasAnswered = false
		currentAnswerHasMeaning = false

		if line == "quitter" or line == "quit" or line == "q" then
			print("Infochien : Au revoir ! Ouaf !\n")
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
				
				if(k == "race") then
					previousRace = nil
					currentRace = nil
				end
			else
				contextTable[k].count = contextTable[k].count + 1
			end
		end

		
		-- Trouver les tags des questions avec des moyens conventionnels
		if (#line["#race"]) ~= 0 then
			if (#line["#race"]) ~= 0 then
				contextTable["race"].value = true
				contextTable["race"].count = 0

				if((#line["#race"]) == 2) then
					currentRace = line:tag2str("#race")[1]
					if(line:tag2str("#race")[1] ~= line:tag2str("#race")[2]) then
						previousRace = line:tag2str("#race")[2]
					end
				
				else 
					if(currentRace ~= line:tag2str("#race")[1]) then
						previousRace = currentRace
						currentRace = line:tag2str("#race")[1]
					end

				end	

				currentAnswerHasMeaning = true
			end
		end

		------------------------------------------------------------
		-- 
		-- Replissage
		-- du 
		-- contexte
		--
		------------------------------------------------------------

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

		------------------------------------------------------------
		-- 
		-- Génération
		-- du 
		-- dialogue
		--
		------------------------------------------------------------
		--
		-- HAS MEANING
		if(currentAnswerHasMeaning) then

				---------------------------------
				--is comparison
				if((#line["#compare"]) ~= 0 ) then
					if(   (contextTable["race"].value) and currentRace ~= nil and previousRace ~= nil ) then

						print("Infochien : Comparons le ".. currentRace .. " et le " .. previousRace .. ".")

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
					elseif (currentRace == nil and previousRace == nil) then
						answer = "ouafouaf" --forcer la comparaison absolue
					else
						print("Infochien : Voulez-vous comparer deux chiens (dites 'ouaf'), ou faire une comparaison absolue (dites 'ouaf ouaf') ?\n")
						answer = getUserAnswer()
						answer = answer:gsub(" ", "")
						print("")

					end
					
					-------------------		
					if(answer == "ouaf") then --comparaison entre deux chiens
					
						--GET RACE
						if(currentRace == nil or previousRace == nil) then
							print("\nInfochien : Quel autre chien voulez-vous comparer ?\n")

							line = parseUserAnswer()
							line = dark.sequence(line)
							pipe(line)

							print("")
							if (#line["#race"]) ~= 0 then
								contextTable["race"].value = true
								if((#line["#race"]) == 2) then
									--print("\nDEBUG first : 2 chiens")
									currentRace = line:tag2str("#race")[1]
									if(line:tag2str("#race")[1] ~= line:tag2str("#race")[2]) then
										previousRace = line:tag2str("#race")[2]
									end
								
								else --if((#line["#race"]) == 1) then
									if(currentRace ~= line:tag2str("#race")[1]) then
										previousRace = currentRace
										currentRace = line:tag2str("#race")[1]
									end
									--if(previousRace ~= nil) then
										--print("\nDEBUG first : 1 chien previousRace= ".. previousRace )
									--end
								end	

								--labrador
							--if (currentRace == "labrador") then
							--	currentRace = "labrador retriever"
							--elseif (previousRace == "labrador") then
							--	previousRace = "labrador retriever"
							--end
							currentAnswerHasMeaning = true
						end

						end


						::hasContextAndRace::

						if(previousRace ~= nil) then
							if (contextTable["size"].value and contextTable["race"].value)then

									dogSize = db[currentRace].measure
									previousSize = db[previousRace].measure

									if(db[currentRace].measure > db[previousRace].measure) then
										print("Infochien : Le " .. currentRace .. " (" .. db[currentRace].height .. ") est plus grand que le " .. previousRace .. " (" .. db[previousRace].height ..").")
									else
										print("Infochien : Le " .. previousRace .. " (" .. db[previousRace].height .. ") est plus grand que le " .. currentRace .. " (" .. db[currentRace].height ..").")
									end

									hasAnswered = true
							
							elseif (contextTable["weight"].value and contextTable["race"].value) then

									dogWeight = db[currentRace].weight
									previousWeight = db[previousRace].weight

									if(dogWeight == 0 or previousWeight == 0) then
										print("Infochien : Je n'ai pas cette information.")
									elseif(dogWeight > previousWeight) then
										print("Infochien : Le " .. currentRace .. " (" .. dogWeight .. " kg) est plus lourd que le " .. previousRace .. " (" .. previousWeight .." kg).")
									else
										print("Infochien : Le " .. previousRace .. " (" .. previousWeight .. " kg) est plus lourd que le " .. currentRace .. " (" .. dogWeight .." kg).")
									end

									hasAnswered = true

							elseif (contextTable["origin"].value and contextTable["race"].value) then			

									origin = formatOrigin(db[currentRace].origin)
									print("\nInfochien : L'origine du " .. currentRace .. " est : " .. origin .. ".")
									hasAnswered = true

							else
									
									--DEBUG : cette partie n'est jamais atteinte
									print("\nInfochien : Comparons le ".. currentRace .. " et le " .. previousRace .. ".")
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
								
										currentRace = line:tag2str("#race")[1]
										if(line:tag2str("#race")[1] ~= line:tag2str("#race")[2]) then
											previousRace = line:tag2str("#race")[2]
										end
									
									else 
										if(currentRace ~= line:tag2str("#race")[1]) then
											previousRace = currentRace
											currentRace = line:tag2str("#race")[1]
										end
									end	

								
								currentAnswerHasMeaning = true
							end
							

							hasAnswered = true
						end
					-------------------
					elseif (answer == "ouafouaf") then --comparaison absolue. On ne peut comparer que la taille et le poids
						
						if ((#line["#qualifTaille"]) ~= 0)then

							if(line:tag2str("#qualifTaille")[1] == "grand") then							
								biggestDog = getBiggestDog()
								print("Infochien : Le chien le plus grand de la BD est le " .. biggestDog .. ".")
							
							else
								smallestDog = getSmallestDog()
								print("Infochien : Le plus petit chien de la BD est le " .. smallestDog .. ".")

							end

							hasAnswered = true

						else
							if(line:tag2str("#qualifPoids")[1] == "gros" or line:tag2str("#qualifPoids")[1] == "lourd") then
								heaviestDog = getHeaviestDog()
								print("Infochien : Le chien le plus lourd de la BD est le " .. heaviestDog .. ".")
							else
								lightestDog = getLightestDog()
								print("Infochien : Le chien le plus léger de la BD est le " .. lightestDog .. ".")
							end
							hasAnswered = true
						
						end

					else
						print("Infochien : Désolé, je n'ai pas compris.")
					end

				---------------------------------
				--is not comparison
				else
					if (#line["#race"] == 2) then

						print("Infochien : Parlons du " .. currentRace .. " et du " .. previousRace .. ".")
						hasAnswered = true

					--tell size
					elseif (contextTable["size"].value and contextTable["race"].value)then
							if (db[currentRace].height ~= "de taille inconnue") then
								print("Infochien : Le " .. currentRace .. " est un chien " .. db[currentRace].height .. " (" .. db[currentRace].measure .. " cm).")
							else
								if(db[currentRace].measure == 0 ) then
									print("Infochien : Désolé, mais je n'ai pas cette information.")
								else
									print("Infochien : Le " .. currentRace .. " est un chien de " .. db[currentRace].measure .. " cm.")
								end
							end
							hasAnswered = true

					--tell use
					elseif (contextTable["use"].value and contextTable["race"].value)then
									
							io.write("Infochien : L'utilisation du " .. currentRace .. " est ")
								 
							-- For every item in the list, including correct use of comma
							for useCount = 1, #db[currentRace].use do
									
									displayUse = db[currentRace].use[useCount]
									displayUse = displayUse:gsub(" \' ", "\'")

									if (#db[currentRace].use > 1) then
										if(useCount == #db[currentRace].use) then
												io.write("et " .. displayUse .. ".")

										elseif (useCount == #db[currentRace].use-1) then

												io.write(displayUse .. " ")
										else 
												io.write(displayUse .. ", ")
										end
									else
										io.write(displayUse .. ".")
									end
							end

							io.write("\n")
							hasAnswered = true
					elseif (contextTable["weight"].value and contextTable["race"].value) then

						if(db[currentRace].weight == 0 ) then
							print("Infochien : Désolé, mais je n'ai pas cette information.")
						else
							print("Infochien : Le poids du " .. currentRace .. " est " .. db[currentRace].weight .. "kg.")
						end	
						hasAnswered = true

					elseif (#line["#place"] ~= 0) then
							print("Infochien : " .. getDogFromLocation(line:tag2str("#place")[1]) .. "" )
							hasAnswered = true

					elseif (contextTable["origin"].value and contextTable["race"].value) then	

							origin = formatOrigin(db[currentRace].origin)				
							print("Infochien : L'origine du " .. currentRace .. " est : " .. origin .. ".")
							hasAnswered = true

					elseif (contextTable["race"].value) then
						if(previousRace ~= nil) then
							print("Infochien : Parlons du " .. currentRace .. " et du " .. previousRace .. ".")
						else
							print("Infochien : Parlons du " .. currentRace .. ".")
						end

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
chatbotMain()
