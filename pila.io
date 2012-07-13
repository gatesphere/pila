#!/usr/bin/env io

// pila programming language
// 20120711
// Jacob Peck

// control variables
DEBUG_OUTPUT := false
VERSION := "20120713"

// Override Io's behavior a bit
List asString := method("[" .. self join(", ") .. "]<=")
List peek := method(self last)
List oldPush := List getSlot("push")
List push := method(x, if(x != nil, self oldPush(x), self))
Sequence asBool := method(if(self asLowercase == "true", true, false))
nil asString := ""
true xor := method(x, if(x, false, true))
false xor := method(x, if(x, true, false))
Object select := method( 
  for(couple, 0, call argCount - 2, 2, 
    if(call evalArgAt(couple), return call relayStopStatus(call evalArgAt(couple + 1)))
  )
)

// internals
stack := list()
builtins := Map clone
macros := Map clone
running := true
rl := ReadLine

// helper methods
is_num := method(x, n := x asNumber; n isNan not and x at(x size - 1) - 48 <= 9)
is_bool := method(x, x asLowercase == "true" or x asLowercase == "false")
is_anonmacro := method(x, x beginsWithSeq("#(") and x endsWithSeq(")"))
is_string := method(x, x beginsWithSeq("\"") and x endsWithSeq("\""))
unquote := method(x, x exSlice(1, x size - 1))
unanonmacro := method(x, x exSlice(2, x size - 1))
load_history := method(try(rl loadHistory(".pila_history")))
save_history := method(try(rl saveHistory(".pila_history")))

// set up builtins
initialize := method(
  // printing
  builtins atPut(".", block(writeln(stack peek)))
  builtins atPut("...", block(writeln(stack)))
  
  // stack manip
  builtins atPut("dup", block(if(stack size > 0, stack push(stack peek))))
  builtins atPut("cls", block(stack = list()))
  builtins atPut("pop", block(if(stack size > 0, stack pop)))
  builtins atPut("swap", block(if(stack size > 1,a := stack pop; b := stack pop; stack push(a) push(b))))
  builtins atPut("rot", block(if(stack size > 2, a := stack pop; b := stack pop; c := stack pop; stack push(b) push(a) push(c))))
  builtins atPut("-rot", block(run_input("rot rot")))
  builtins atPut("over", block(if(stack size > 1, a := stack pop; b := stack pop; stack push(b) push(a) push(b))))
  builtins atPut("nip", block(run_input("swap pop")))
  builtins atPut("tuck", block(run_input("swap over")))
  builtins atPut("2dup", block(run_input("over over")))
  builtins atPut("2pop", block(run_input("pop pop")))
  builtins atPut("2swap", block(if(stack size > 3,
    a := stack pop; b := stack pop; c := stack pop; d := stack pop
    stack push(b) push(a) push(d) push(c)
  )))
  builtins atPut("2rot", block(if(stack size > 5,
    a := stack pop; b := stack pop; c := stack pop; d := stack pop; e := stack pop; f := stack pop
    stack push(d) push(c)push(b) push(a) push(f) push(e)
  )))
  builtins atPut("2-rot", block(run_input("2rot 2rot")))
  builtins atPut("2over", block(if(stack size > 3,
    a := stack pop; b := stack pop; c := stack pop; d := stack pop
    stack push(d) push(c) push(b) push(a) push(d) push(c)
  )))
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
      if(macros at(key) != true, writeln("#{key} := #{macros at(key)}" interpolate))
    )
  ))
  builtins atPut("$import", block(
    filename := unquote(stack pop)
    e := try(
      f := File with(filename) openForReading
      f foreachLine (l, run_input(l))
      f close
    )
    e catch(
      writeln("  >> ERROR: Could not open file: #{filename}" interpolate)
    )
  ))
  
  // add reference to macros for faster lookup
  builtins keys foreach(key, macros atPut(key, true))
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
  select(
    macros keys contains(word),
      if(macros at(word) == true, builtins at(word) call, run_input(macros at(word))),
    is_num(word),
      stack push(word asNumber),
    is_bool(word),
      stack push(word asBool),
    is_anonmacro(word),
      stack push(unanonmacro(word)),
    is_string(word),
      stack push(word),
    word,
      writeln("  >> ERROR: Unknown word, ignoring: #{word}" interpolate)
  )
)

run_input := method(input,
  if(input == nil, return)
  input = input asString
  
  if(DEBUG_OUTPUT, writeln("  DEBUG: stack = #{stack}" interpolate))
  // check for macro
  if(input beginsWithSeq(":"),
    a := input exSlice(1) splitNoEmpties
    if(builtins keys contains(a at(0)),
      writeln("  >> ERROR: Cannot redefine builtin: #{a at(0)}" interpolate)
      return
    )
    if(macros keys contains(a at(0)), 
      writeln("  >> WARNING: Redefining macro: #{a at(0)}" interpolate)
    )
    macros atPut(a at(0), a rest join(" "))
    return
  )
  
  // discard comments
  input = input split("//") at(0)
  if(input == nil, return)
  
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
    writeln("  >> ERROR: Unterminated anonymous macro.  Ignoring all input.")
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
    writeln("  >> ERROR: Unterminated string literal.  Ignoring all input.")
    return
  )
  
  if(DEBUG_OUTPUT, writeln("  DEBUG: ilist (string phase) = #{ilist}" interpolate))
  
  // run each word
  cachestack := stack clone
  ilist foreach(word, 
    e := try(
      run(word)
    )
    e catch(
      writeln("  >> ERROR: Something went wrong.  Reverting stack to previous state.")
      if(DEBUG_OUTPUT, writeln("  DEBUG: exception caught: #{e}" interpolate))
      stack = cachestack
      break
    )
  )
)

start := method(
  writeln("pila #{VERSION}" interpolate)
  initialize
  if(System args at(1) != nil,
    run_input("\"" .. System args at(1) .. "\" $import")
    
    ,
    load_history
    while(running,
      run_input(get_input)
    )
    save_history
  )
  System exit
)

start