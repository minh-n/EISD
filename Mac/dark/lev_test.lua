-- Tests for levenshtein.lua
local lev_iter      = (require 'levenshtein').lev_iter
local lev_recursive = (require 'levenshtein').lev_recursive

local total, pass = 0, 0

local function dec(str, len)
  return #str < len
     and str .. (('.'):rep(len-#str))
      or str:sub(1,len)
end

local function run(message, f)
  total = total + 1
  local ok, err = pcall(f)
  if ok then pass = pass + 1 end
  local status = ok and 'PASSED' or 'FAILED'
  print(('%02d. %68s: %s'):format(total, dec(message,68), status))
end

run('Fails on running with no arg', function()
  print(not pcall(lev_iter))
  print(not pcall(lev_recursive))
end)

run('Fails if only one string is passed', function()
  print(not pcall(     lev_iter, 'astring'))
  print(not pcall(lev_recursive, 'astring'))
end)

run('Otherwise, returns the levenshtein distance', function()
  print(lev_iter('chien', 'iench'))
  print(lev_iter('labrador',  'labrador retriever'))
  print(lev_iter('golden',  'gloden'))
  print(lev_iter('salut',    'sluat'))
  print(lev_iter(    'mdr',     'mdr'))

  print("-------")
  print(lev_recursive('chien', 'iench'))
  print(lev_recursive('labrador',  'labrador retriever'))
  print(lev_recursive('golden',  'gloden'))
  print(lev_recursive('salut',    'sluat'))
  print(lev_recursive(    'mdr',     'mdr'))
end)

print(('-'):rep(80))
print(('Total : %02d: Pass: %02d - Failed : %02d - Success: %.2f %%')
  :format(total, pass, total-pass, (pass*100/total)))