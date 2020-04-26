-- tildeath
-- My own dialect of ~ATH
-- By daelvn
re = require "re"

shorthand = (s) ->
  s = s\gsub "$(%w+)", [[{:tag: "" -> "%1" :}]]
  s = s\gsub "&(%w+)", [[{:%1: %1 :}]]
  s = s\gsub ";(%w+)", [[{:id: %1 :}]]
  return s

grammar = re.compile shorthand [[
  -- program
  program     <- chunk

  -- chunks and blocks
  block       <- ws "{" ws chunk ws "}" 
  chunk       <- ws {| $chunk (statement ";" ws)* |}
  marker      <- "->" id

  -- statements
  statement   <- import / define / bifurcate / execute / die / slabel / loop / directive / run
  label       <- blabel / mlabel / llabel
  slabel      <- llabel / blabel
  llabel      <- {| $label "#" &id {:labeled: loop :} |}
  blabel      <- {| $label "#" &id {:labeled: block :} |}
  mlabel      <- {| $label "#" &id {:labeled: marker :} |}
  loop        <- "~ATH(" ws {| $loop &expr ws ")" ws &block ws &execute |}
  die         <- {| $die &type ":DIE()" |}
  execute     <- "EXECUTE(" ws {| $execute (&type / &statement) |} ws ")"
  bifurcate   <- "bifurcate" rs {| $bifur ;cid ws &list |}
  import      <- "import" rs {| $import {:library:cid:} rs ;cid |}
  define      <- "define" rs {| $define ;cid rs {| $value symbol / string / list |} |}
  directive   <- "==>" ws {| $directive &id (rs &string)? |}
  run         <- "RUN" {| $run &list |}
  scope       <- "->" {| $scope &block |}

  -- recombine syntax
  list        <- ws "[" ws {| $list tlist |} ws "]"
  tlist       <- (type / string) ("," ws (type / string))*

  -- types
  expr        <- null / {| $neg "!" id |} / id / list / mlabel
  type        <- null / id / list / mlabel

  -- primitives
  string      <- {| $string '"' {[^"]*} '"' / "'" {[^']*} "'" |}
  symbol      <- {| $symbol ":" id |}
  null        <- {| $null "NULL" |}
  cid         <- id / mlabel
  id          <- {| $id {%w valid*} |}
  valid       <- [%w'!/@$%^&*<>_~-%.]
  rs          <- (%s / "//" [^%nl]*)+
  ws          <- (%s / "//" [^%nl]*)*
]]

reduce = (t, tint="white") ->
  switch t.tag
    when "execute"
      t = t.type or t.statement
    when "symbol"
      t[1] = t[1][1]
    when "label"
      tint = string.lower t.id[1]
  -- tint
  t.tint = tint
  -- iterate
  if "table" == type t
    for k, v in pairs t
      continue if k == "tint"
      if "table" == type v
        t[k] = reduce v, tint
  --
  return t

parse = (s) ->
  ast = grammar\match s
  error "Failed to parse: #{s}" unless ast
  return reduce ast

collect = (ast, t={}) ->
  for i, stat in ipairs ast
    if stat.tag == "define"
      -- FIXME make it work for strings and lists (tables)
      print "Collected -> #{stat.id[1]} = #{stat.symbol[1]}"
      t[stat.id[1]] = stat.symbol[1]
  t

{
  :NULL
  :grammar
  :parse, :reduce
  :collect
}