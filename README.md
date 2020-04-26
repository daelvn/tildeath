# ~ATH (tildeath)

This is my own implementation of [~ATH](https://mspaintadventures.fandom.com/wiki/~ATH) in MoonScript, trying to imitate the "original" one as much as possible.

## Conventions

### Filetype

There's really no MIME filetype for this, although it would be rad. I'm using the standard, Homestuck-official `.~ATH` filetype. At one point `.~ath` is used too, but you won't be able to load libraries with that extension.

### Lifetime

A lifetime of 0 means that the object will loop forever. Any other lifetime is in seconds. If the object or the lifetime of the object could not be found, it will loop 413 times (one per second).

### Errors

- If a logic error is found, the computer will be explosionated (or shut down).
- If you try to kill an imported object, the computer will be blow up'ed (or shut down).
- If you try to import a library that does not exist, it will instead make it an object with the lifespan of [\[S\] Collide](https://www.youtube.com/watch?v=Y5wYN6rB_Rg) in seconds (1801s).
- If there is a syntax error, the file will be deleted. Nobody wants invalid files! (~~you're not a file Tavros you can stay.~~)
- See more below!

## Installing

### LuaRocks

(Not availiable yet.)

### Building from source

First, you will need to install the several dependencies:
```sh
$ luarocks install lpeg       # For parsing (re)
$ luarocks install socket     # For the sleep function 
$ luarocks install filekit    # For checking whether a file exists
$ luarocks install ansikit    # For colored output
$ luarocks install inspect    # For pretty-printing tables
$ luarocks install moonscript # For building the source
```

Now, clone the source: `$ hub clone daelvn/tildeath`

With MoonScript installed, run `moon tildeath/astw.moon file.~ATH` (file loading not implemented yet).

## AST Walker / parse REPL

astw.moon (built as `athw`) is a code walker for this implementation. It will parse a file, let you inspect the AST in several ways (including color!), and even run it.

### Commands

```
          help, h          - displays this message
          quit, exit, q, e - exits the AST walker
          statements, s    - shows all statements in chunk
          pick, p          - pretty prints a node
          inspect, i       - inspects the structure of a node
          into, n          - goes into a node
          back, b          - backsteps from a node
          list, l          - list subnodes
          run, r           - run program
```

## Complete syntax

Behold ye! The complete syntax of Dael's ~ATH in re/BNF!

```
  -- program
  program     <- chunk

  -- chunks and blocks
  block       <- ws "{" ws chunk ws "}" 
  chunk       <- ws {| $chunk (statement ";" ws)* |}
  marker      <- "->" id

  -- statements
  statement   <- import / define / bifurcate / execute / die / slabel / loop / directive
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
  define      <- "define" rs {| $define ;cid rs &symbol|}
  directive   <- "==>" ws {| $directive &id (rs &string)? |}

  -- recombine syntax
  list        <- ws "[" ws {| $list tlist |} ws "]"
  tlist       <- type ("," ws type)*

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
```

### Syntax shortcuts

I'm using a couple shortcuts in the re syntax, just as simple replacements, they go as such:

- `$...` is `{:tag: "" -> "..." :}`
- `&...` is `{:...: ... :}`
- `;...` is `{:id: ... :}`

## On the topic of IO

### Proof

I don't know if I'm going to be contradicting myself here, but I kept reading on Homestuck, and in [page 4443](https://www.homestuck.com/story/4443) there's a file named `SBURB CLIENT.~ATH`. Next page, when you open it, you get:

![homestuck page 4444](https://www.homestuck.com/images/storyfiles/hs2/04441.gif)

And I thought that ~ATH had no standard IO! Well, turns out it does, and it can print ASCII art, and wait for key inputs! This opens up for so many new possibilites! Our problem now is implementing them.

### Implementation

Remember that ~ATH is not known to have functions, so we're going to have to implement IO as keywords. Now, how do you wait for input, in a language that only waits for lifespans? ... wait until the creation of...

## On the topic of bifurcation and tints

These sort of serve as diaries for myself so I can keep up with the mind-boggling intricacies of this language. This one will be on the topic of bifurcation and tints/labels/colors.

### Bifurcate

The `bifurcate` keyword will divide an object into two branches canonically, although this implementation has no limit in the amount of bifurcations you can make out of a single object. As in the original, you can make branches of branches, but I'm talking 3+ branches of a *same* object. The real question is: what does this actually mean? Let's see the canonical uses:

Oh no, it's the [Mobius Double Reacharound Virus](https://mspaintadventures.fandom.com/wiki/Mobius_Double_Reacharound_Virus). I wrote that article/entry (the one right below) before writing this one, so I'm not writing on it again. If you want to learn about that first, I recommend doing so now, for now, we're only going to talk about what bifurcate does here.

![original code](https://vignette.wikia.nocookie.net/mspaintadventures/images/d/de/Virus.gif/revision/latest?cb=20100625045237)

`bifurcate` splits the object representing the current running program (`THIS`) into its red and blue variants. Other implementations make it either do something I don't understand (drocta ~ATH) or not implement it at all (tilde-ath). The [CodeGolf specification](https://codegolf.stackexchange.com/questions/64486/write-a-ath-interpreter) says that for `bifurcate x[y,z];`, it copies `x` to `y` and `z` and deletes `x`, but keep in mind that the implementation is meant to be an over-engineered brainfuck that keeps no resemblance to the original.

### Tints and labels

So the big question is, what does it actually do? Let's start by answering another question: does splitting `THIS` into tints change the behavior of tinted loops and blocks? If so, how? The MDRV (Mobius Double Reacharound Virus) seems to give it some significance.

- You could argue that the color of the loop must be the same color than the expression inside it, but the virus itself would contradict this.
- (See **On the Mobius Double Reacharound Virus**) Perhaps this significance is only symbolic, again, and I could use it as an excuse to ignore it as well.

As for the significance I could give it myself, well:

- I could make it so imports create variables in the coloured THIS, but that would give us some really freaky paths. If I do `define lifetime :0;` and I import it tinted such as `import object #YELLOW->O;`, it will be saved to `env.THIS.YELLOW.O` instead of `env.O`. Now imagine tinting the import itself so we get a double tint. `#GREEN{ import object #YELLOW->O; };`, that'd store it in `env.THIS.GREEN.THIS.YELLOW.O`. Yucky, because now add what we were looking for, the bifurcated `THIS`:
  ```js
  bifurcate THIS[#RED->THIS,#BLUE->THIS];
  #RED~ATH(U) {
    #GREEN{ import object #YELLOW->O; };
  } EXECUTE(NULL);
  // The final path would be env.THIS.RED.THIS.GREEN.THIS.YELLOW.O
  ```
  *Shudders*. Truly cursed.
- I could make it only symbolic, in which case the virus *would still work*, but then, why would you want to write any colored role?
- Multithreading! Well, coroutines rather. I could make each tinted loop run in a different coroutine. I have to say, this would make coroutine usage ridiculously easier. Let's see some examples:
  ```js
  // Download.lua is a file that downloads an arbitrary file over HTTP.
  // Arguments are passed by the "RUN" statement.

  // Bifurcation of THIS creates new threads
  bifurcate THIS[#RED->THIS,#BLUE->THIS];

  // This runs on the RED thread
  #RED~ATH(NULL){}EXECUTE(RUN[Download.lua, "https://example.com/a.txt"]);
  // This runs on the BLUE thread
  #BLUE~ATH(NULL){}EXECUTE(RUN[Download.lua, "https://example.com/b.txt"]);
  ```
  I think this would be in line with what bifurcation means in Homestuck. But we forgot something, and that is killing the threads. The big funny thing here is that we can only stop both threads simultaneously, by reconstructing the original object. `THIS == [RED/THIS,BLUE/THIS]`. But that would be pretty much it!

### More on Multithreading

We will be using the [raisin](https://github.com/hugeblank/raisin) library to run our threads and manage them into groups.

So, let's try to implement the concept of multithreading:

- There's a "main group" of threads, which would be the white group.
- All statements can be understood as a transformer funuction that affects the environment.
- Some statements (`import`) can run "off-thread". They will be executed as they are interpreted, without turning into a thread.

But then I thought... what about `:DIE()`? 

- We can't put it in several groups (i mean, we can, but ew).
- If we put it on the white group, it will run before the loops get a chance to finish.
- If we run it off-thread, the tinted groups won't even exist.

This is my proposed solution: we run everything off-thread, until we find tinted loops. We collect all tinted loops in scope\*, run them, and only resume off-thread execution when these loops are done running. `:DIE()` then would become `<group>.remove()` in Raisin terms. So, let's look at the execution order of this previous program.

```js
1. bifurcate THIS[#RED->THIS,#BLUE->THIS];

2. #RED~ATH(NULL)  {} EXECUTE(RUN[Download.lua, "https://example.com/a.txt"]);
2. #BLUE~ATH(NULL) {} EXECUTE(RUN[Download.lua, "https://example.com/b.txt"]);

3. [#RED->THIS,#BLUE->THIS]:DIE();
```

1. The bifurcation is created, and so are the groups. The loops are registered as threads and attached to each group.
2. They do their own thing.
3. After they are done running, or deadened (killed, lol) from inside, the third-running statement will remove them from memory.

If you don't remove all of the bifurcated objects at the same time, it will explode your computer. If you don't remove them at all, the program will simply attempt to loop forever.

> \*By scope, that means the current block. The main program is a block itself, but you can use a labeled block `#name {...}` to create a new scope. ~~Will I ever implement unnamed blocks? Who knows!~~ I ended up implementing unnamed blocks like, 2 minutes after writing this? Just do `-> {...}` to create an unnamed scope.

## On the Mobius Double Reacharound Virus

This [Mobius Double Reacharound Virus](https://mspaintadventures.fandom.com/wiki/Mobius_Double_Reacharound_Virus) is quite difficult to understand, and has a fair amount of significance *in the comic*. Read that page for more info. Here, I will discuss the significance of the code, and the design choices and assumptions I had to make so it would work.

### The original code

This is the original code for the virus. At first sight, we notice quite a few weird things.

![original code](https://vignette.wikia.nocookie.net/mspaintadventures/images/d/de/Virus.gif/revision/latest?cb=20100625045237)

For one, it seems to be color-sensitive, which is already pretty unseen in programming languages, the only one I can think of is [Piet](https://esolangs.org/wiki/Piet), but it does not use it in the same way at all. I'm going to showcase the new syntax to accomodate this:

```js
bifurcate THIS[#RED->THIS,#BLUE->THIS];
import #RED->universe #RED->U1;
import #BLUE->universe #BLUE->U2;

#RED~ATH(U1) {
  #BLUE~ATH(!U2) {
} EXECUTE(~ATH(#BLUE->THIS){}EXECUTE(NULL));
  } EXECUTE(~ATH(#RED->THIS){}EXECUTE(NULL));

[#RED->THIS,#BLUE->THIS]:DIE();
```

I'm not going to go into details, since when this README is finished, there will be full documentation on my implementation. Just notice `#LABEL->id` (markers) for individual references, and `#LABEL~ATH` (loops) for labeled loops. This makes the program we wrote and the one above equivalent... or does it? More on that later.

Second, we see the loops are *interlocked*, it looks unparseable, but the purpose of it is, well, because the trolls' universe and our universe are, in fact, interlocked. If you want to see the common interpretation of the code, just visit the [MSPA wiki page](https://mspaintadventures.fandom.com/wiki/Mobius_Double_Reacharound_Virus) or the [Esolangs.org page](https://esolangs.org/wiki/~ATH), but I'm here to propose a wildly new interpretation.

### The twist

We all assumed that ~ATH is whitespace-sensitive but... is it really? The good thing of not having an official implementation is that things like this are up to the programmer. For parsing and sanity purposes, we will say this dialect is NOT whitespace-sensitive. Let's re-indent our code based on this:

```js
bifurcate THIS[#RED->THIS,#BLUE->THIS];
import #RED->tildeath/std/universe #RED->U1;
import #BLUE->tildeath/std/universe #BLUE->U2;

#RED~ATH(U1) {
  #BLUE~ATH(!U2) {
  } EXECUTE(~ATH(#BLUE->THIS){}EXECUTE(NULL));
} EXECUTE(~ATH(#RED->THIS){}EXECUTE(NULL));

[#RED->THIS,#BLUE->THIS]:DIE();
```

Very interesting, see what happened? If whitespace is ignored, the blue loop is inside the red one now, and it becomes something that we can actually understand. But, of course, then what's the whole point? Symbolism. I propose that the code was indented like that because of the
interlocking symbolism, but Sollux, knowing this, knew it would not affect the outcome of the program. Now it has a very simple reading:

> Split this program into red and blue. Import the kids' universe as U1 and the trolls' universe as U2. Til death of the kids' universe, run a loop til *creation* (death of the nonexistence) of the trolls' universe. After this loop, wait til death of the blue program. When the blue program dies, wait til death of the red program. Then, kill the program.

### The error

Well, perhaps that wasn't a very simple reading, but there is a problem here! You might have noticed that the blue program does not actually get killed until all loops end, nor does the red one. This will make an *infinitely running loop* (like the universes, which are also defined as infinite. How else are you supposed to define it? ~~The length in seconds of the existence of each universe in the most popular YouTube let's read.~~ Ehem.). Of course, we can kill the program from inside (unlike the universe, because then I could just import and kill the universe so rules are that imported objects cannot be killed.), but it's not what's happening in this program. Oh no! How do we run this! ...except we don't! Let's throw it back to what this virus actually does: blow up the computer ~~and place a curse on the user, the people they know, and the people they will ever meet~~.

Another assumption we need to make: Does the computer blow up because it was commanded to, or because of a logic error in the program? There's no actual importing of the computer, nor anything that commands to blow it up. It seems that the *illogicality* of this program is what makes it blow up. Quite ironic, considering we're talking about Homestuck!

But... what is the error? Well, I can see several, actually:

- The trolls universe already exists, yet it waits for its creation (`!U2`).
- Pretending that universes die, making them "not infinite" loops (although they are defined as so), there is still two infinite loops (the bifurcated programs). Heresy!
- Because of this, the bifurcations are actually never killed, and they will never be, which is nothing less but unacceptable!

Let's pretend we can blow up computers for a moment, and that an error will cause this. Now all that this is about is identifying which error would be easiest to detect either at compile time or runtime. I think I will go with the first, making up one simple rule: "If it is in the library, then it's already created". Therefore, since I am importing something that exists, that specific instance cannot be created again, and it would have to be another. This makes for a very easy way of blowing up a computer:

```js
import universe U;
~ATH(!U){}EXECUTE(NULL);
```

Therefore, any loop that awaits for the creation of something already created, will cause the whole program to error, and the computer to blow up. Literally, just having `!U2` in it will blow it up.

### Conclusion

No, this does not make the virus a *successfully running and valid* ~ATH program, BUT! It actually does what it was meant to do! Explode! We did it!

And these are the mental gymnastics I had to go on about just to implement this virus...

## See also

- [tilde-ath](https://github.com/PaulkaToast/tilde-ath), another ~ATH implementation. I find it far from the original, but still fun!
- [drocta's ~ATH](https://github.com/drocta/TILDE-ATH), yet another ~ATH implementation. Closer to the original although still stay. Has things like IO. Doesn't seem to like indentation, either? Just non-standard as well.
- [CodeGolf's ~ATH](https://codegolf.stackexchange.com/questions/64486/write-a-ath-interpreter). Codegolf StackExchange came up with a very weird ~ATH looking brainfuck. Not sure how much it's related to this, but it is called ~ATH anyway.

## License

```
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <http://unlicense.org/>
```

Hell yeah public domain.