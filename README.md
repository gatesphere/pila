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

Documentation
-------------
TBD.

License
-------
BSD.  See [license/license.txt](https://raw.github.com/gatesphere/pila/master/license/license.txt) for details.

To do
-----
  * Add ReadLine support.
  * Clean it all up.
  * Documentation
  * File I/O?
