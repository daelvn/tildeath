-- tildeath.astw
-- AST Walker for ~ATH
-- By daelvn
import colorize  from require "ansikit.style"
import recompile from require "tildeath.util"
inspect             = require "inspect"
io.stdout\setvbuf "no"

get = (path, t) ->
  for idx in *path
    t = t[idx]
  return t

-- prompt
prompt = ->
  io.write ">>> "
  return io.read "*l"

tn = (n) -> if nn = tonumber n then nn else n

interactiveASTWalk = (ast) ->
  print colorize "%{blue}Welcome to the ~ATH AST walker!"
  path = {}
  while true do
    -- path
    node = get path, ast
    -- prompt
    tcmd  = prompt!
    parts = [part for part in tcmd\gmatch "%S+"]
    cmd   = parts[1]
    cmd2  = parts[2]
    switch cmd
      when "help", "h"
        print [[
          help, h          - displays this message
          quit, exit, q, e - exits the AST walker
          statements, s    - shows all statements in chunk
          pick, p          - pretty prints a node
          inspect, i       - inspects the structure of a node
          into, n          - goes into a node
          back, b          - backsteps from a node
          list, l          - list subnodes
          run, r           - run program
        ]]
      when "quit", "exit", "q", "e"
        return true
      when "statements", "s"
        for n, statement in ipairs node do print "#{n}. #{recompile statement}"
      when "pick", "p"
        if cmd2
          print style "%{red}Statement does not exist!" unless node[tn cmd2]
          print "#{cmd2}. #{recompile node[tn cmd2]}" if node[tn cmd2]
        else
          print recompile node
      when "inspect", "i"
        if cmd2
          print style "%{red}Statement does not exist!" unless node[tn cmd2]
          print "#{cmd2}. #{inspect node[tn cmd2]}" if node[tn cmd2]
        else
          print inspect node
      when "into", "n"
        print style "%{red}Statement does not exist!" unless node[tn cmd2]
        table.insert path, tn cmd2
        print "Current path: #{table.concat path, "."}" if node[tn cmd2]
      when "back", "b"
        table.remove path, #path
        print "Current path: #{table.concat path, "."}"
      when "list", "l"
        if cmd2
          for k, _ in pairs node[tn cmd2]
            print "    #{k}"
        else
          for k, _ in pairs node
            print "    #{k}"
      when "run", "r"
        import run from require "tildeath.runtime"
        run {}, node

{
  :interactiveASTWalk
}