import colorize from require "ansikit.style"

-- functions
recompile = (node, parent="root", ptint="white") ->
  switch node.tag
    when "id", "symbol"
      return node[1]
    when "string"
      return "\"#{node[1]}\""
    when "null"
      return "NULL"
    when "neg"
      return "!" .. recompile node[1], "neg"
    when "list"
      return "["..(table.concat [recompile nd, "list" for nd in *node], ",").."]"
    when "directive"
      return "==>#{node.id[1]}#{if node.string then " \"#{recompile node.string}\";" else ";"}"
    when "import"
      return "import #{recompile node.library, "import"} #{recompile node.id, "import"};"
    when "define"
      return "define #{recompile node.id, "define"} :#{recompile node.value, "define"};"
    when "bifur"
      return "bifurcate #{recompile node.id, "bifur"}#{recompile node.list, "bifur"};"
    when "die"
      return "#{recompile node.type, "die"}:DIE();"
    when "loop"
      return colorize.noReset "~ATH(#{recompile node.expr, "loop"}%{#{ptint}}) {#{recompile node.block, "loop", node.tint}%{#{ptint}}} EXECUTE(#{recompile node.execute, "loop", node.tint});"
    when "label"
      return colorize.noReset "%{#{string.lower recompile node.id, "label"}}#{recompile node.labeled, "label", node.tint}%{#{ptint}}"
    when "run"
      return "RUN#{recompile node.list, "label"};"
    when "scope"
      return "{#{recompile node.block, "scope"}}"
    when "chunk"
      cnode = [recompile s, "chunk" for s in *node]
      return table.concat cnode, "; "
    else
      return "???"

{
  :recompile
}