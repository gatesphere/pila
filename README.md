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
pila is easy to run, but it requires [Io](http://iolanguage.com/).  To begin a pila session, simply do:

    ./pila.io
    
To run a script file, do:

    ./pila.io somescript.pila

**Builtins**
The following words are built in as a part of pila, and cannot be redefined:

Word    | Description
--------|------------
.       | Print the top of the stack.
...     | Print the whole stack.
dup     | Duplicate the top of the stack.
cls     | Empty the stack completely.
pop     | Discard the top of the stack.
swap    | Exchange the first two items of the stack.
rot     | Move the third item in the stack to the top of the stack.
-rot    | Move the top of the stack into the third position.
over    | Push a copy of the second item in the stack to the top of the stack.
nip     | Remove the second item in the stack.
tuck    | Copy the top element of the stack to the third position.
2dup    | Same as dup, but copies the top two elements.
2pop    | Same as pop, but pops the top two elements.
2swap   | Same as swap, but operates on pairs of elements.
2rot    | Same as rot, but operates on pairs of elements.
2-rot   | Same as -rot, but operates on pairs of elements.
2over   | Same as over, but operates on pairs of elements.
2nip    | Same as nip, but operates on pairs of elements.
2tuck   | Same as tuck, but operates on pairs of elements.
+       | Pops the top two items and pushes their sum onto the stack.  If at least one of the elements is a string, + performs concatenation.
-       | Pops the top two items and pushes their difference onto the stack.
*       | Pops the top two items and pushes their product onto the stack.  If one of the elements is a string, * performs string multiplication.
/       | Pops the top two items and pushes their quotient onto the stack.
%       | Pops the top two items and pushes their modulo onto the stack.
<<      | Pops the top two items (m, n) from the stack and pushes (m << n) to the stack.
>>      | Pops the top two items (m, n) from the stack and pushes (m >> n) to the stack.
=       | Pops the top two items from the stack and pushes true if they're equal, false otherwise.
>       | Pops the top two items (m, n) from the stack and pushes true if m > n, false otherwise.
<       | Pops the top two items (m, n) from the stack and pushes true if m < n, false otherwise.
>=      | Pops the top two items (m, n) from the stack and pushes true if m >= n, false otherwise.
<=      | Pops the top two items (m, n) from the stack and pushes true if m <= n, false otherwise.
and     | Pops the top two items (m, n) from the stack and pushes true if (m && n) == true, false otherwise.
or      | Pops the top two items (m, n) from the stack and pushes true if (m && n) == true, false otherwise.
not     | Pops the top item (n) from the stack and pushes true if n == false, false otherwise.
nop     | Does absolutely nothing (no operation).
call    | Pops the top item from the stack and attempts to evaluates it as code.
if      | Pops the top three items from the stack (c, t, e), and if c == true, evaluates t, otherwise evaluates e.
$bye    | Exits the program.
$macros | Lists defined macros.
$import | Pops the top item (n) from the stack and reads in the script file whose name is n.

**Predefined macros (Standard Library)**
TBD.

**Defining macros**
TBD.

**Redefining macros**
TBD.

**Anonymous macros**
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
