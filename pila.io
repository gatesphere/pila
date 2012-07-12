#!/usr/bin/env io

// pila programming language
// 20120711
// Jacob Peck

List asString := method("bottom [" .. self join(", ") .. "] top")
List peek := method(self last)
Sequence asBool := method(if(self asLowercase == "true", true, false))

stack := list()
builtins := Map clone
macros := Map clone

is_num := method(x, x asNumber isNan not)
is_bool := method(x, x asLowercase == "true" or x asLowercase == "false")
is_macro := method(x,x beginsWithSeq("##"))
is_anonmacro := method(x, x beginsWithSeq("#(") and x endsWithSeq(")"))
is_string := method(x, x beginsWithSeq("\"") and x endsWithSeq("\""))

unquote := method(x, x exSlice(1, x size - 1))
unmacro := method(x, x exSlice(2))
unanonmacro := method(x, x exSlice(2, x size - 1))

initialize := method(
  builtins atPut(".", block(writeln(stack peek)))
  builtins atPut("...", block(writeln(stack)))
  builtins atPut("dup", block(stack push(stack peek)))
  builtins atPut("cls", block(stack = list()))
  builtins atPut("pop", block(stack pop))
  builtins atPut("swap", block(a := stack pop; b := stack pop; stack push(a); stack push(b)))
  builtins atPut("+", block(stack push(stack pop + stack pop)))
  builtins atPut("-", block(stack push(-(stack pop - stack pop))))
  builtins atPut("/", block(stack push(1/(stack pop / stack pop))))
  builtins atPut("*", block(stack push(stack pop * stack pop)))
  builtins atPut("%", block(a := stack pop; b := stack pop; stack push(b % a)))
  builtins atPut("<<", block(a := stack pop; b := stack pop; stack push(b << a)))
  builtins atPut(">>", block(a := stack pop; b := stack pop; stack push(b >> a)))
  builtins atPut("=", block(stack push(stack pop == stack pop)))
  builtins atPut("<", block(stack push(stack pop > stack pop)))
  builtins atPut(">", block(stack push(stack pop < stack pop)))
  builtins atPut("<=", block(stack push(stack pop >= stack pop)))
  builtins atPut(">=", block(stack push(stack pop <= stack pop)))
  builtins atPut("!", block(stack push(stack pop not)))
  builtins atPut("&", block(a := stack pop; b := stack pop; stack push(a and b)))
  builtins atPut("|", block(a := stack pop; b := stack pop; stack push(a or b)))
  builtins atPut("if", block(
    then := stack pop
    else := stack pop
    if(stack pop, 
      run_input(then)
      , 
      run_input(else)
    )
  ))
  builtins atPut("nop", block())
  builtins atPut("call", block(run_input(stack pop)))  
  builtins atPut("bye", block(writeln("goodbye"); System exit))
)


get_input := method(
  write("[#{stack size}]> " interpolate)
  File standardInput readLine
)

run := method(word,
  // check for builtin
  if(builtins keys contains(word asLowercase),
    builtins at(word) call
    ,
    if(macros keys contains(word asLowercase),
      run_input(macros at(word))
      ,
      if(is_num(word),
        stack push(word asNumber)
        ,
        if(is_bool(word),
          stack push(word asBool)
          ,
          if(is_macro(word),
            stack push(unmacro(word))
            ,
            if(is_anonmacro(word),
              stack push(unanonmacro(word))
              ,
              if(is_string(word),
                stack push(word)
                ,
                writeln("  >> ERROR: Unknown word, ignoring: #{word}" interpolate)
              )
            )
          )
        )
      )
    )
  )
)

run_input := method(input,
  //writeln("  DEBUG: stack = #{stack}" interpolate)
  // check for macro
  if(input beginsWithSeq(":"),
    a := input exSlice(1) splitNoEmpties
    macros atPut(a at(0), a rest join(" "))
    return
  )
    
  
  // selectively split (preserve anonmacros and strings)
  // ugly and broken
  ilist := list()
  gather := list()
  anonmacro := false
  macrodepth := 0
  input split(" ") foreach(token,
    if(token beginsWithSeq("#("), anonmacro = true; macrodepth = macrodepth + 1)
    if(anonmacro, gather append(token), ilist append(token))
    if(token endsWithSeq(")"), macrodepth = macrodepth - 1)
    if(macrodepth == 0 and anonmacro,
      anonmacro = false
      ilist append(gather join(" "))
      gather = list()
    )
  )
  if(anonmacro,
    writeln("  >> ERROR: Unterminated anonymous macro.  Ignoring all input")
    return
  )
  
  //writeln("  DEBUG: ilist = #{ilist}" interpolate)
  
  input = ilist
  ilist = list()
  gather = list()
  quote := false
  input foreach(token,
    if(token beginsWithSeq("\""), quote = true)
    if(quote, gather append(token), ilist append(token))
    if(token endsWithSeq("\""), 
      quote = false
      ilist append(gather join(" "))
      gather = list()
    )
  )
  if(quote,
    writeln("  >> ERROR: Unterminated string literal.  Ignoring all input")
    return
  )
  
  //writeln("  DEBUG: ilist = #{ilist}" interpolate)
  
  // run each word
  ilist foreach(word,
    run(word)
  )
)

start := method(
  writeln("pila 20120711")
  initialize
  loop(
    run_input(get_input)
  )
)

start