-- tildeath.runtime
-- Runtime for my dialect of ~ATH
-- By daelvn
import sleep          from  require "socket"
import recompile      from  require "tildeath.util"
import parse, collect from  require "tildeath.parser"
import colorize       from  require "ansikit.style"
raisin                   = (require "raisin").manager (...) -> ...
fs                       =  require "filekit"
inspect                  =  require "inspect"

explodeComputer = ->
  os.execute "shutdown -s -t 01"
  os.execute "shutdown -h now"
  os.shutdown!

-- # Conventions
-- ## Timespans
--     0:  Runs til manual death
--     n:  Timespan in seconds
-- NOTE: only THIS and manually created variables can be deathened. Things like
--       universes cannot, and they will instead explode (or shut down) the computer.
-- If the expression in a loop refers to an unknown object, it will use a timespan of 413
-- seconds.

local *

setVar = (env, stat, v) ->
  switch stat.tag
    when "id"
      print "Setting env[#{stat[1]}] = #{inspect v}"
      env[stat[1]] = v
    when "label"
      print "Setting env.THIS[#{stat.id[1]}][#{stat.labeled[1]}] = #{library}"
      env.THIS[stat.id[1]]                  or= {}
      env.THIS[stat.id[1]][stat.labeled[1]]   = v

getVar = (env, stat) ->
  switch stat.tag
    when "id"
      print "Getting env[#{stat[1]}] = #{inspect env[stat[1]]}"
      return env[stat[1]]
    when "label"
      print "Getting env.THIS[#{stat.id[1]}][#{stat.labeled[1]}] = #{inspect env.THIS[stat.id[1]][stat.labeled[1]]}"
      return env.THIS[stat.id[1]][stat.labeled[1]]
  return false

bifurcate = (env, stat) ->

execute = (env, exec) ->
  switch exec.tag
    when "id"
      id = exec[1]
      if id\match "lua$"
        dofile id
    when "list"
      for elem in *exec
        execute elem
    when "label"
      --tint, id = stat.id[1], stat.labeled[1]
      error "Label not allowed in EXECUTE();"
    when "null"
      print "Executed nothing."
    else
      processStatement exec

runStat = (env, stat) ->
  runner = loadfile stat.list[1][1]
  args   = for elem in *stat.list[2,]
    switch elem.tag
      when "string" then elem[1]
      when "id"     then getVar env, elem
      when "list"   then error ""
  runner unpack args

runLoop = (env, stat) ->
  print colorize "Running loop: #{recompile stat}"
  til, inner, exec = stat.expr, stat.block, stat.execute
  print "  until -> #{til.tag}"
  switch til.tag
    when "neg"
      if getVar env, til[1]
        error "Cannot wait for the creation of something that already exists"
      else
        runLoop env, {expr: til.id, block: inner, execute: exec, tag: stat.tag, tint: stat.tint}
    when "id", "label"
      print "  (#{til[1]})"
      id   = til[1]
      ntil = if obj = getVar env, til then tonumber obj.lifetime else 413
      if ntil == 0
        while true do
          print "  he does another."
          run env, inner, true
          sleep 1
      else
        for i=1, ntil
          run env, inner, true
          print "  [#{i}]"
          sleep 1
  print "  execute -> #{recompile exec}"
  execute env, exec

runDirective = (env, stat) ->
  id = stat.id[1]
  print "Running directive: #{id}"
  switch id
    when "DUMP"
      print (require "inspect") env
    when "PRINT"
      print stat.string[1]

-- ## Importing
-- Labels are ignored when calling a library. The reference will save to the correct color.
importAth = (env, stat) ->
  library = if stat.library.tag == "id" then stat.library[1] else stat.library.labeled[1]
  to      = if stat.id.tag == "id"      then stat.id[1]      else stat.id.labeled[1]
  path    = if fs.exists "#{library}.~ATH"
    "#{library}.~ATH"
  elseif fs.exists "tildeath/std/#{library}.~ATH"
    "tildeath/std/#{library}.~ATH"
  else
    "uHHH.~ATH"
  print "Importing: #{path} as #{to}"
  
  if fs.exists path
    local content
    with io.open path, "r"
      content = \read "*a"
      \close!
    ast          = parse content
    lib          = collect ast
    lib.imported = true
    setVar env, stat.id, lib
  else
    print "Could not find #{path}"

processLabel = (env, stat) ->
  switch stat.labeled.tag
    when "chunk"
      run env, stat.labeled, true
    when "loop"
      runLoop env, stat.labeled

processStatement = (env, stat) ->
  -- define does not need to be included because they're all precollected
  switch stat.tag
    when "loop"      then runLoop env, stat
    when "import"    then importAth env, stat
    when "directive" then runDirective env, stat
    when "label"     then processLabel env, stat
    when "bifurcate" then bifurcate env, stat
    when "die"       then dieStat env, stat
    when "run"       then runStat env, stat
    when "scope"     then run env, stat.block, true

run = (env, ast, subproc=false) ->
  -- create a new environment
  env           or= {}
  env.THIS      or= {} -- ?
  env.THIS.PROC   = raisin
  env.THIS.GROUPS = {}
  -- all defines are read ahead of time
  collect ast, env unless subproc
  -- iterate statements
  for stat in *ast
    processStatement env, stat
  -- run manager
  raisin.run!
        
{
  :processStatement, :processLabel
  :runLoop
  :runDirective
  :importAth
  :execute
  :setVar, :getVar
  :run
}