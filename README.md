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
TBD.

License
-------
BSD.  See [license/license.txt](https://raw.github.com/gatesphere/pila/master/license/license.txt) for details.

To do
-----
  * Catch exceptions/nil values
  * Add script file support. (std lib?)
  * Add hex, octal, binary support for numbers
  * Fix string parsing code
  * Clean it all up.
  * Documentation
  * File I/O?
