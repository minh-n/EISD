dark = require("dark")
dog = require("dogs")

function parse_file()

    file = io.open("../../text_files/Labrador.txt","r")

    if(file) then
        print("file read correctly !")
        for line in file:lines() do 
            print(line)
        end
        print("Parsing done")
        file:close()
    end
end

--Main

print("-Debug : Main\n")

parse_file()