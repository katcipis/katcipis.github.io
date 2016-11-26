# Go object model

---

Go object model gets easier to understand when you accept
that there is no objects at all, there is just functions and
contracts, that are basically sets of functions.

<!-- more -->

Ok, now that I got your attention and you must be thinking
"shut up, of course there are objects in Go", well, you are
right. But it is a object model that is very different from
the classical ones (like Java, C++, Python, the ones I know
at least).

Since I had my share of C programming, and also other cool
languages like Lua, it is not very hard to me to think
about closures and functions, but as I see other people
developing in Go I sense some struggling to understand how
Go works with objects.

A vivid example is not seeing that a function that accepts
a function as a parameter can also be called passing a method,
So the idea is to de construct the object model to just functions
and build it back to how Go works.

It will probably be a lousy de construction since I'm not an
expert in Go, but yet I feel compelled to try :-).
