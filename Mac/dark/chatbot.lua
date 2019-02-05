
dark = require("dark")


-- random sentences
math.randomseed(os.time())

otherAnswer={
		"Voulez-vous en savoir plus ?",
		"Voulez-vous d'autres informations sur les chiens ?",
		"Quelque chose d'autre ?",
		"D'autres questions sur les chiens ?",
		"D'autres questions ?",
		"Quoi d'autre ?",
		"Ouaf.",
		"Je sais tout sur les chiens !",
		"Demandez-moi quelque chose d'autre si vous le souhaitez.",
}




-- database
require("dogs")



-- lexique
pipe = dark.pipeline()
pipe:basic()
pipe:lexicon("#vocab", "lexiqueChatbot1.txt")
pipe:lexicon("#questStarcraft", {"protoss", "zerg", "terran"})
pipe:lexicon("#race", {"beagle", "golden retriever"})
pipe:lexicon("#size", {"taille", "mesure", "hauteur", "cm", "m"})
pipe:lexicon("#use", {"utilisé", "utilité", "utilisation", "use", "emploi"})
pipe:lexicon("#origin", {"origine", "vient", "où", "where"})
pipe:lexicon("#weight", {"poids", "peser", "pèse", "pèsent"})


--TODO
-- quand on fait enter ça crash !
-- démajusculer tous les input



--read the user's input
function userInput()
	print("-Debug: userInput()\n")
	print("Bot : Bonjour je suis un chatbot :) Je peux parler du Beagle ou du Golden retriever.\n")

	while 1 do
		line = io.read()
		hasAnswered = false
		if line == "Quitter" or line == "quitter" or line == "quit" or line == "q" or line == "Q" then
		break;
		end

      	line = line:gsub("%.", " %0 ") --on met des espaces sur la ponctuation
      	line = line:gsub("%,", " %0 ") --on met des espaces sur la ponctuation
      	line = line:gsub("%'", " %0 ") --on met des espaces sur la ponctuation
      	line = line:gsub("%;", " %0 ") --on met des espaces sur la ponctuation
      	line = line:gsub("%:", " %0 ") --on met des espaces sur la ponctuation
      	line = line:gsub("%-", " %0 ") --on met des espaces sur la ponctuation
      	line = line:gsub("%'", " %0 ") --on met des espaces sur la ponctuation

		line = dark.sequence(line)
		
		pipe(line)

      	--print(dark.pipeline(line))
      	--print(line)
      	if (#line["#vocab"]) ~= 0 then

      		print("\nBot (Debug) : ceci est une ligne de test.\n")
			hasAnswered = true
      	elseif (#line["#questStarcraft"]) ~= 0 then

      	 	print("\nBot (StarCraft) : Yes AlphaStar go full win.\n")
			hasAnswered = true

      	elseif ((#line["#size"] ~= 0) and (#line["#race"] ~= 0))then
      	 	
      	 	print("\nInfochien : la taille du " .. line:tag2str("#race")[1] .. " est " .. db[line:tag2str("#race")[1]].height .. ".")
      	 	hasAnswered = true

      	elseif ((#line["#use"] ~= 0) and (#line["#race"] ~= 0))then
      	 	
      	 	io.write("\nInfochien : l'utilisation du " .. line:tag2str("#race")[1] .. " est ")
      	 
      	 	-- For every item in the list, including correct use of comma
			for useCount = 1, #db[line:tag2str("#race")[1]].use do
			  
				if(useCount == #db[line:tag2str("#race")[1]].use) then
					io.write("et " .. db[line:tag2str("#race")[1]].use[useCount] .. ".")

				elseif (useCount == #db[line:tag2str("#race")[1]].use-1) then

			  		io.write(db[line:tag2str("#race")[1]].use[useCount] .. " ")
			  	else 
			  		io.write(db[line:tag2str("#race")[1]].use[useCount] .. ", ")
			  	end
			end
			io.write("\n")
			hasAnswered = true

		elseif ((#line["#weight"] ~= 0) and (#line["#race"] ~= 0))then
      	 	
      	 	print("\nInfochien : le poids du " .. line:tag2str("#race")[1] .. " est de " .. db[line:tag2str("#race")[1]].weight .. ".")
      	 	hasAnswered = true

		elseif ((#line["#origin"] ~= 0) and (#line["#race"] ~= 0))then
      	 	
      	 	print("\nInfochien : l'origine du " .. line:tag2str("#race")[1] .. " est : " .. db[line:tag2str("#race")[1]].origin .. ".")
      	 	hasAnswered = true


		else
			print("\nJe n'ai pas compris la question. Pouvez-vous reformuler s'il-vous-plait ? Ouaf.\n")
      	end



      	if (hasAnswered == true) then

      		io.write("Infochien : " .. otherAnswer[math.random(#otherAnswer)] .. "\n\n")
      		hasAnswered = false
      	end
   end
end



-- Main

print("-Debug: Main\n")

userInput()