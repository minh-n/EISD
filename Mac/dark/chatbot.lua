
dark = require("dark")


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
require("dogs")



-- lexique
pipe = dark.pipeline()
pipe:basic()
pipe:lexicon("#vocab", "lexiqueChatbot1.txt")
pipe:lexicon("#questStarcraft", {"protoss", "zerg", "terran"})
pipe:lexicon("#race", {"beagle", "golden retriever"})
pipe:lexicon("#size", {"taille", "mesure", "hauteur", "cm", "m"})
pipe:lexicon("#use", {"utilisé", "utilité", "utilisation", "use", "emploi"})
pipe:lexicon("#origin", {"origine", "vient", "où", "where", "pays", "région"})
pipe:lexicon("#weight", {"poids", "peser", "pèse", "pèsent", "kg", "kilo", "kilogrammes"})


--TODO
-- quand on fait enter ça crash !
-- démajusculer tous les input



--read the user's input
function userInput()
	--print("-Debug: userInput()\n")
	print("Bot : Bonjour je suis un chatbot :) Je peux parler du Beagle ou du Golden retriever.\n")

	while 1 do
		line = io.read()
		hasAnswered = false
		line = string.lower(line)
		if line == "quitter" or line == "quit" or line == "q" then
		break;
		end

		--putting spaces around punctuation signs
		line = line:gsub("%p", " %0 ") --on met des espaces sur la ponctuation
		line = dark.sequence(line)
		
		pipe(line)

      	--print(dark.pipeline(line))
      	--print(line)

      	-- gestion du contexte



      	if (#line["#race"]) ~= 0 then
       		contextRace = true
      		stringRace = line:tag2str("#race")[1]
      		
      	end


      	if (#line["#use"]) ~= 0 then
       		contextUse = true

      	 	contextSize = false
      	 	contextOrigin = false
       	 	contextWeight = false
      	end

      	if (#line["#size"]) ~= 0 then
      		contextSize = true

       	 	contextWeight = false
      	 	contextOrigin = false
      	 	contextUse = false
      	end

      	if (#line["#weight"]) ~= 0 then
      		contextWeight = true

      	 	contextSize = false
      	 	contextOrigin = false
      	 	contextUse = false
      	end

      	if (#line["#origin"]) ~= 0 then
      		contextOrigin = true

       		contextWeight = false
      	 	contextSize = false
      	 	contextUse = false
       	end








       	-- génération du dialogue

      	if (contextSize and (contextRace))then
      	 	
      	 	print("\nInfochien : la taille du " .. stringRace .. " est " .. db[stringRace].height .. ".")
      	 	hasAnswered = true

      	elseif (contextUse and (contextRace))then
      	 	
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

		elseif (contextWeight and (contextRace))then
      	 	
      	 	print("\nInfochien : le poids du " .. stringRace .. " est de " .. db[stringRace].weight .. ".")
      	 	hasAnswered = true

		elseif (contextOrigin and (contextRace))then
      	 	
      	 	print("\nInfochien : l'origine du " .. stringRace .. " est : " .. db[stringRace].origin .. ".")
      	 	hasAnswered = true

      	elseif (contextRace) then

      		print("\nInfochien : Nous parlons bien du ".. stringRace .. " là, n'est-ce pas ?\n")

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

--print("-Debug: Main\n")

userInput()