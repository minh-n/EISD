
dark = require("dark")


-- lexique
pipe = dark.pipeline()
pipe:basic()
pipe:lexicon("#vocab", "lexiqueChatbot1.txt")
pipe:lexicon("#questStarcraft", {"protoss", "zerg", "terran"})


--read the user's input
function userInput()
	print("-Debug: userInput()\n")
	print("Bot : Bonjour je suis un chatbot :) Je peux parler de Starcaft\n")



	while 1 do
		line = io.read()
		if line == "Quitter" or line == "quitter" or line == "quit" or line == "q" or line == "Q" then
		break;
		end
      	line = line:gsub("%p", " %0 ") --on met des espaces sur la ponctuation

		line = dark.sequence(line)
		
		pipe(line)
      	--print(dark.pipeline(line))
      	local lex = dark.lexicon("#vocab", "lexiqueChatbot1.txt")

      	if (#line["#vocab"]) ~= 0 then

      		print("\nBot : ceci est une ligne de test.\n")
      	 elseif (#line["#questStarcraft"]) ~= 0 then
      	 	print("\nBot : Yes AlphaStar go full win.\n")

      	end

   end
end



-- Main

print("-Debug: Main\n")

userInput()