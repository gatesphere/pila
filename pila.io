#!/usr/bin/env io

// pila programming language
// 20120711
// Jacob Peck

// control variables
DEBUG_OUTPUT := false
VERSION := "20120712"

// Override Io's behavior a bit
List asString := method("[" .. self join(", ") .. "]<=")
List peek := method(self last)
List oldPush := List getSlot("push")
List push := method(x, if(x != nil, self oldPush(x)))
Sequence asBool := method(if(self asLowercase == "true", true, false))
nil asString := ""
true xor := method(x, if(x, false, true))
false xor := method(x, if(x, true, false))

// internals
stack := list()
builtins := Map clone
macros := Map clone
running := true
rl := ReadLine

// helper methods
is_num := method(x, n := x asNumber; n isNan not and n asString == x)
is_bool := method(x, x asLowercase == "true" or x asLowercase == "false")
is_macro := method(x,x beginsWithSeq("##"))
is_anonmacro := method(x, x beginsWithSeq("#(") and x endsWithSeq(")"))
is_string := method(x, x beginsWithSeq("\"") and x endsWithSeq("\""))
unquote := method(x, x exSlice(1, x size - 1))
unmacro := method(x, x exSlice(2))
unanonmacro := method(x, x exSlice(2, x size - 1))
load_history := method(try(rl loadHistory(".pila_history")))
save_history := method(try(rl saveHistory(".pila_history")))

// set up builtins
initialize := method(
  // printing
  builtins atPut(".", block(writeln(stack peek)))
  builtins atPut("...", block(writeln(stack)))
  
  // stack manip
  builtins atPut("dup", block(stack push(stack peek)))
  builtins atPut("cls", block(stack = list()))
  builtins atPut("pop", block(stack pop))
  builtins atPut("swap", block(a := stack pop; b := stack pop; stack push(a); stack push(b)))
  builtins atPut("rot", block(a := stack pop; b := stack pop; c := stack pop; stack push(b); stack push(a); stack push(c)))
  builtins atPut("-rot", block(run_input("rot rot")))
  builtins atPut("over", block(stack push(stack at(stack size - 2))))
  builtins atPut("nip", block(run_input("swap pop")))
  builtins atPut("tuck", block(run_input("swap over")))
  builtins atPut("2dup", block(run_input("over over")))
  builtins atPut("2pop", block(run_input("pop pop")))
  builtins atPut("2swap", block(
    a := stack pop; b := stack pop; c := stack pop; d := stack pop
    stack push(b); stack push(a); stack push(d); stack push(c)
  ))
  builtins atPut("2rot", block(
    a := stack pop; b := stack pop; c := stack pop; d := stack pop; e := stack pop; f := stack pop
    stack push(d); stack push(c); stack push(b); stack push(a); stack push(f); stack push(e)
  ))
  builtins atPut("2-rot", block(run_input("2rot 2rot")))
  builtins atPut("2over", block(2 repeat(stack push(stack at(stack size - 4)))))
  builtins atPut("2nip", block(run_input("2swap 2pop")))
  builtins atPut("2tuck", block(run_input("2swap 2over"))) 
  
  // arithmetic (and string manipulation)
  builtins atPut("+", block(
    b := stack pop
    a := stack pop
    if(a isKindOf(Sequence) or b isKindOf(Sequence),
      a = a asString
      b = b asString
      if(is_string(a), a = unquote(a))
      if(is_string(b), b = unquote(b))
      stack push("\"" .. a .. b .. "\"")
      ,
      stack push(a + b)
    )
  ))
  builtins atPut("-", block(stack push(-(stack pop - stack pop))))
  builtins atPut("/", block(stack push(1/(stack pop / stack pop))))
  builtins atPut("*", block(
    a := stack pop
    b := stack pop
    if((a isKindOf(Sequence) xor(b isKindOf(Sequence))) and
       (a isKindOf(Number) xor(b isKindOf(Number))),
       if(a isKindOf(Number), x := a; a = b; b = x)
       x := ""
       b repeat(x = x .. unquote(a))
       stack push("\"" .. x .. "\"")
       ,
       stack push(a * b)
    )
  ))
  builtins atPut("%", block(a := stack pop; b := stack pop; stack push(b % a)))
  builtins atPut("<<", block(a := stack pop; b := stack pop; stack push(b << a)))
  builtins atPut(">>", block(a := stack pop; b := stack pop; stack push(b >> a)))
  
  // boolean logic
  builtins atPut("=", block(stack push(stack pop == stack pop)))
  builtins atPut("<", block(stack push(stack pop > stack pop)))
  builtins atPut(">", block(stack push(stack pop < stack pop)))
  builtins atPut("<=", block(stack push(stack pop >= stack pop)))
  builtins atPut(">=", block(stack push(stack pop <= stack pop)))
  builtins atPut("not", block(stack push(stack pop not)))
  builtins atPut("and", block(a := stack pop; b := stack pop; stack push(a and b)))
  builtins atPut("or", block(a := stack pop; b := stack pop; stack push(a or b)))
  
  // flow control
  builtins atPut("if", block(
    then := stack pop
    else := stack pop
    if(DEBUG_OUTPUT, writeln("  DEBUG: if > then = #{then}" interpolate))
    if(DEBUG_OUTPUT, writeln("  DEBUG: if > else = #{else}" interpolate))
    if(stack pop,
      if(DEBUG_OUTPUT, writeln("  DEBUG: if > taking then branch"))
      run_input(then)
      ,
      if(DEBUG_OUTPUT, writeln("  DEBUG: if > taking else branch")) 
      run_input(else)
    )
  ))
  
  // direct calls
  builtins atPut("nop", block())
  builtins atPut("call", block(run_input(stack pop))) 
  
  // meta 
  builtins atPut("$bye", block(writeln("goodbye"); running = false))
  builtins atPut("$macros", block(
    writeln("registered macros:")
    macros keys foreach(key,
      writeln("#{key} := #{macros at(key)}" interpolate)
    )
  ))
)

// prompt and read input
get_input := method(
  rl prompt = "[#{stack size}]> " interpolate
  l := rl readLine(rl prompt)
  rl addHistory(l)
  l
)


run := method(word,
  if(DEBUG_OUTPUT, writeln("    DEBUG: running word #{word} > stack = #{stack}" interpolate))
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
  if(DEBUG_OUTPUT, writeln("  DEBUG: stack = #{stack}" interpolate))
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
  
  if(DEBUG_OUTPUT, writeln("  DEBUG: ilist (anonmacro phase) = #{ilist}" interpolate))
  
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
  
  if(DEBUG_OUTPUT, writeln("  DEBUG: ilist (string phase) = #{ilist}" interpolate))
  
  // run each word
  ilist foreach(word,
    run(word)
  )
)

start := method(
  writeln("pila #{VERSION}" interpolate)
  initialize
  load_history
  while(running,
    run_input(get_input)
  )
  save_history
  System exit
)

start