readfile = (file) ->
  with fs.safeOpen file, "r"
    if .error
      error "could not read file #{file}"
    content = \read "*a"
    \close!
    return content

tasks:
  athw: (file) =>
    require "moonscript"
    import parse              from require "tildeath.parser"
    import interactiveASTWalk from require "tildeath.astw"
    interactiveASTWalk parse readfile file
