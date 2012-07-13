pila
====

A small, stack based language.

Overview
--------
pila is different.

Here's a factorial macro:

    :fac dup 0 = #(dup 1 - fac *) #(pop 1) if
    
Here's how you use it:

    [0]> 6 fac .
    720
    
Here's a Fibonacci calculator:

    :fib dup 1 <= #(1 - dup fib swap 1 - fib +) #(pop 1) if
    
And an example:
    
    [0]> 6 fib .
    13

String manipulation can be neat too:
  
    $ ./pila.io
    pila 20120712
    [0]> "foo" "bar" + .
    "foobar"
    [1]> "baz" 3 * ...
    ["foobar", "bazbazbaz"]<=
    [2]> + .
    "foobarbazbazbaz"
    [1]> $bye
    goodbye  

Anonymous macros open up the possibilities for meta-programming.  Here's a particularly
*bad* example:

    :a #(:b a) call b

About the name
--------------
"Pila" means "stack" or "pile" in Italian.  Unfortunately it's also Portuguese 
slang for male anatomy.  I learned of this fact after I had already grown attached
to the name, so I'm keeping it as "pila".  However, someone in #io suggested I 
make the mascot an overly sexual rooster, and I might just have to do this.

Ah well, learn from my mistakes.  Do more than a cursory Google search before
you name a project.  Or not, the results could be hilarious.

Documentation
-------------
**Concepts**
pila is a stack based language, meaning that all operations in pila are operations
to manipulate the stack.  Unlike languages such as FORTH, there is a single monolithic
stack to manipulate, and no concept of anything such as a variable.  There are however
macros and anonymous macros to make your life easier.

**Words**
Stack based languages operate on the concept of words, which can be seen as unary
functions--with an implicit argument being the stack.  For example, the word `3`
is a function which pushes the `3` onto the stack.  The word `...` prints the
stack in text form.  And the word `-` pops the top two elements from the stack
and subtracts the first popped element from the second.  There's a more in-depth
look at words below.

**Macros**
Macros are placeholders for a collection of words.  Using macros in clever ways,
you can significantly reduce the cognitive burden on yourself when writing programs.

**Data types**
pila recognizes and works with 3 distinct data types, which is really all you need.
pila will work with numbers (integers and floating point, autoconverted on the fly),
character strings (surrounded with `"` characters), and boolean values (`true` and
`false`).

pila is also smart when it comes to types: `+` and `*` change their behavior when
appropriate to work on numbers and strings! 

**Running pila**
TBD.

**Builtins**
TBD.

**Predefined macros**
TBD.

**Defining macros**
TBD.

**Redefining macros**
TBD.

**Anonymous macros**
TBD.

**Quoting a macro**
TBD.

**Recursion**
TBD.

**ReadLine support**
TBD.

**Script file support**
You can run a file of valid pila words by placing it's relative path as a string
on the stack, and then running the `$import` word.  Thanks to the ReadLine support,
typing file names and paths are tab-completed on some systems.

**Comments**
Comments are delimited by `//`.  Anything to the right of `//` to the end of a line
is discarded and ignored by the parser.  This works both in the REPL and in script
files.  You can use this as a way to add documentation to macros that will be 
visible in the repl when using the `$macros` word, just be sure to keep your comments
on the same line when doing this!

License
-------
BSD.  See [license/license.txt](https://raw.github.com/gatesphere/pila/master/license/license.txt) for details.

To do
-----
  * Standard library
  * Add hex, octal, binary support for numbers
  * Fix string parsing code
  * Clean it all up.
  * Documentation
  * File I/O?
