---
published: false
title: Fun with Go's object model
layout: post
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
about closures and first class functions, but as I see
other people developing in Go I sense some struggling
to understand how Go works with objects.

A vivid example is not seeing that a function that accepts
a function as a parameter can also be called passing a method,
So the idea is to de-construct the object model to just functions
and build it back to how Go works, showing that Go is much more
prone to functions with objects as an aid to make some idiom's
easier than a object oriented language where objects domain
with the traditional "everything is an object" idea.

It will probably be a lousy de construction since I'm not an
expert in Go, but yet I feel compelled to try :-).


# In the beginning there was the functions


Well I'm trying to make a point around thinking first about
functions, so here goes an lousy example of what can be done with functions.

Lets define a type that is actually a function:

```go
type Adder func(int, int) int
```

You can think about it as a interface (but it is not the same thing).
Any function that matches the signature will be acceptable as being of
the type **Adder**:

```go
// Same type as Adder
func add(a int, b int) int {
	return a + b
}
```

An abstract adder that does not know how to add:

```go
func abstractedAdd(a Adder, b int, c int) int {
	return a(b, c)
}
```

This reminds a lot the kind of thing you can do with interfaces.
**abstractedAdd** does not know how to add, and it will accept any
implementation of an Adder that respects the same signature.

Given this extremely useless and simple example,
here is the full working code:

```go
package main

import "fmt"

type Adder func(int, int) int

// Same type as Adder
func add(a int, b int) int {
	return a + b
}

func abstractedAdd(a Adder, b int, c int) int {
	return a(b, c)
}

func main() {
	var a Adder
	fmt.Printf("Adder: %v\n", a)
	a = add
	fmt.Printf("Adder initialized: %v\n", a)
	fmt.Printf("%d + %d = %d\n", 1, 1, abstractedAdd(a, 1, 1))
	fmt.Printf("%d + %d = %d\n", 1, 1, abstractedAdd(add, 1, 1))
}
```

As it can be seen, Go has first class functions, we can store
functions in variables, pass them as arguments to other functions,
and even pass a function directly as an argument too.

With this example in mind we have the opportunity to start exploring
Go's objects. Can a method satisfy the **Adder** type ? Depending
on your background this may sound counter intuitive,
lets take a look at an adder object:

```go
type ObjectAdder struct{}

func (o *ObjectAdder) Add(a int, b int) int {
	return a + b
}
```

Sound about right, adding it on our example:

```go
package main

import "fmt"

type Adder func(int, int) int

// Same type as Adder
func add(a int, b int) int {
	return a + b
}

func abstractedAdd(a Adder, b int, c int) int {
	return a(b, c)
}

type ObjectAdder struct{}

func (o *ObjectAdder) Add(a int, b int) int {
	return a + b
}

func main() {
	var a Adder
	fmt.Printf("Adder: %v\n", a)
	a = add
	fmt.Printf("Adder initialized: %v\n", a)
	fmt.Printf("func: %d + %d = %d\n", 1, 1, abstractedAdd(a, 1, 1))
	fmt.Printf("func: %d + %d = %d\n", 1, 1, abstractedAdd(add, 1, 1))

	var o *ObjectAdder
	fmt.Printf("object: %d + %d = %d\n", 1, 1, abstractedAdd(o.Add, 1, 1))
}
```

Result:

```
Adder: <nil>
Adder initialized: 0x401000
func: 1 + 1 = 2
func: 1 + 1 = 2
object: 1 + 1 = 2
```

Yep, it worked. Differently from interfaces, the function signature will not
match any kind of method name, you just pass the method as a parameters, since
the method is actually just a function, it could be something like:

```go
	var o *ObjectAdder
	fmt.Printf("object: %d + %d = %d\n", 1, 1, abstractedAdd(o.Whatever, 1, 1))
```

Should work just fine. Not convinced that the method is just a function ?
Let's add this:

```go
	fmt.Printf("func add: %T\n", add)
	fmt.Printf("object.Add: %T\n", o.Add)
```

Result:

```
func add: func(int, int) int
object.Add: func(int, int) int
```

Do you see any difference on the type of the free function and
the object method ? No...because there is none. That is why passing
it as the parameter worked. This also explains another thing going on
on our code that sometimes makes newcomers to Go confused.

There is no fully initialized ObjectAdder on our example. I used a pointer
by purpose, as you can see the pointer is not initialized at all (it is nil),
yet it worked.  In any other object oriented language that I know this would
never work, but in Go it worked, why ?

Well because in Go, there is no methods at all, there is no method type,
methods are actually syntactic sugar for calling functions passing the
struct ("object") as the first parameter (as people are used to do in C).

Not convinced ? Lets elaborate our example:

```go
	fmt.Printf("ObjectAdder.Add: %T\n", (*ObjectAdder).Add)
	fmt.Printf("ObjectAdder.Add: %d + %d = %d\n", 1, 1, (*ObjectAdder).Add(nil, 1, 1))
```

What I'm doing here ? Just making it explicit what Go actually does when you
declare something like:

```go
type ObjectAdder struct{}

func (o *ObjectAdder) Add(a int, b int) int {
}
```

It will append a function on the type **\*ObjectAdder**.
This function is accessible and can be used as any other value on the
language (being called, passed as a parameter, etc).

If you are thinking "hey, but the type is ObjectAdder not \*ObjectAdder",
well in Go the pointer counter part of a type is actually another type
and has even a different set of functions appended to it.

This is one of the more hard to understand parts of Go that I stumbled
and I'm not going to be able to explain here right now, but it relates
to [this](https://github.com/golang/go/wiki/MethodSets) and some other
stuff that I assume are just implementation details.

Anyway, going on, the result:

```
ObjectAdder.Add: func(*main.ObjectAdder, int, int) int
ObjectAdder.Add: 1 + 1 = 2
```

As you can see, what Go actually does is to append a function on the type
**\*ObjectAdder** that accepts a **\*ObjectAdder** as the first
parameter. There is not method at all, it is just a function.

What we see as an object in Go is actually a collection of functions appended
to a type and syntactic sugar to pass the first argument for you.
Which to be honest is like almost all object oriented languages implementation.
The good thing is that in Go this is 100% explicit, not magic, just some
syntactic sugar. Go is really serious about being explicit and simple :-).

This makes a lot of things more simple and uniform, the examples
showed that. Passing a function or a method as a argument has no
difference at all.

Here is the full code of the final example:

```go
package main

import "fmt"

type Adder func(int, int) int

// Same type as Adder
func add(a int, b int) int {
	return a + b
}

func abstractedAdd(a Adder, b int, c int) int {
	return a(b, c)
}

type ObjectAdder struct{}

func (o *ObjectAdder) Add(a int, b int) int {
	return a + b
}

func main() {
	var a Adder
	fmt.Printf("Adder: %v\n", a)
	a = add
	fmt.Printf("Adder initialized: %v\n", a)
	fmt.Printf("func: %d + %d = %d\n", 1, 1, abstractedAdd(a, 1, 1))
	fmt.Printf("func: %d + %d = %d\n", 1, 1, abstractedAdd(add, 1, 1))

	var o *ObjectAdder
	fmt.Printf("func add: %T\n", add)
	fmt.Printf("object.Add: %T\n", o.Add)
	fmt.Printf("object: %d + %d = %d\n", 1, 1, abstractedAdd(o.Add, 1, 1))

	fmt.Printf("ObjectAdder.Add: %T\n", (*ObjectAdder).Add)
	fmt.Printf("ObjectAdder.Add: %d + %d = %d\n", 1, 1, (*ObjectAdder).Add(nil, 1, 1))
}
```

This example is completely stateless. Another argument that I read on some
discussions about Go is that functions should be used when there is no state
involved, and objects and interfaces should be used when there is
state involved.

This question comes up specially when your Interface has just one method,
why not a function ? I'm not very sure about using the state as an argument
on this discussion, because as we have seen there is no difference between
methods and functions, there is just functions, and functions can have
state too.

In a specific domain defining a guideline that all functions passed as
parameters should be stateless may be useful, but it is dangerous to
trust that in Go and it don't seem to be a general purpose guideline
to choose between a function as parameter or a interface.


# Functions and state

To make the gap between functions and objects even smaller lets
work with the oldest/simplest example, an iterator:

```go
package main

import "fmt"

func iterator() func() int {
	a := 0
	return func() int {
		a++
		return a
	}
}

func main() {

	iter := iterator()

	fmt.Printf("iter 1: %d\n", iter())
	fmt.Printf("iter 2: %d\n", iter())
	fmt.Printf("iter 3: %d\n", iter())
}
```

If you run this you will see that it is a valid iterator.
What we have here exactly ? We have a **iterator** function
that acts as a constructor for another function, that will
be returned, that is why the return type of **iterator** is:

```go
func() int
```

What is usually referred as closure is this lexical construction:

```go
	a := 0
	return func() int {
		a++
		return a
	}
```

The function that we are instantiating access a variable that exists
on the outer scope, this will associate the **a** variable to the
newly created function, it has a reference to **a** and can manipulate it.

This is a mind bender if you are just used to objects as a mean to
managing state, and also the only thing that can be instantiated
(actually it is odd to C programmers too, since functions are a static
construction in C).

In Go, functions are instantiated all the time, here goes another version
of this example that makes it explicit that we are actually instantiating
functions:

```go
package main

import "fmt"

func iterator() func() int {
	a := 0
	return func() int {
		a++
		return a
	}
}

func main() {
	itera := iterator()
	iterb := iterator()

	fmt.Printf("itera 1: %d\n", itera())
	fmt.Printf("itera 2: %d\n", itera())
	fmt.Printf("itera 3: %d\n", itera())

	fmt.Printf("iterb 1: %d\n", iterb())
	fmt.Printf("iterb 2: %d\n", iterb())
	fmt.Printf("iterb 3: %d\n", iterb())
}
```

We get:

```
itera 1: 1
itera 2: 2
itera 3: 3
iterb 1: 1
iterb 2: 2
iterb 3: 3
```

So each iterator is completely isolated from each other and there is
no way for one function to access state from the other, unless it is
explicitly allowed lexically on the code, or you do some really bad
ass pointer arithmetic.

This is fun, since languages like Lisp have closures since ever and
this provides the absolutely maximum level of encapsulation you can imagine.
There is no way to access the state directly except through the function.

So no, encapsulation has not been invented by object oriented programming.
Lets take a look on how this would like using a Go object:

```go
package main

import "fmt"

type iterator struct {
	a int
}

func (i *iterator) iter() int {
	i.a++
	return i.a
}

func newIter() *iterator {
	return &iterator{
		a: 0,
	}
}

func main() {
	i := newIter()

	fmt.Printf("iter 1: %d\n", i.iter())
	fmt.Printf("iter 2: %d\n", i.iter())
	fmt.Printf("iter 3: %d\n", i.iter())
}
```

As you can see, for something very simple the object way seems
a little more clumsy, at least it looks like it to me.
I even gave the same lousy name **a** to the integer, that is
actually the state.

Here you create a struct to hold the state, add a function to the type,
and use that function to manipulate the state.

The function version did the same thing, on a different way. And
it was able to manage state just as an object would, with automatic
lexical scoping to guarantee state isolation, just the function
is able to change state.

To finish this argument, lets develop a set of functions that
operates on shared state (that is pretty much the work an object does):

```go
package main

import "fmt"

type stateChanger func() int

func new() (stateChanger, stateChanger) {
	a := 0
	return func() int {
			a++
			return a
		},
		func() int {
			a--
			return a
		}
}

func main() {
	inc, dec := new()

	fmt.Printf("inc 1: %d\n", inc())
	fmt.Printf("inc 2: %d\n", inc())
	fmt.Printf("inc 3: %d\n", inc())

	fmt.Printf("dec 1: %d\n", dec())
	fmt.Printf("dec 2: %d\n", dec())
	fmt.Printf("dec 3: %d\n", dec())
}
```

The output:

```go
inc 1: 1
inc 2: 2
inc 3: 3
dec 1: 2
dec 2: 1
dec 3: 0
```

As can be seen clearly, both functions share the same common
state and can manipulate it, just as you would do with an
object with two methods.

Of course I'm not advocating that you should just play around
with a bunch of variables holding functions, structs exist exactly
to give one shape to composition of other types. The same applies to
functions, just having a lot of loose functions would be a mess
on a lot of cases.

Since Go does have first class functions, a struct could have some fields
that holds functions, emulating the behaviour of methods. But that
would be clumsy and error prone, like the possibility of a non
initialized field being called (anyone that have programmed in C
will understand this problem very well, and its consequences).

The feature of adding methods to a type gives a compile time safe
way to represent a set of functions that operate on the same type.


# What is an object anyway ?


Until now it seems like an object is just a set of functions
that operates on the same data structure. In all languages it
is actually just that, with the exception that this is not
just as explicit as it is in Go.

There is just one thing missing, that is the hallmark of traditional
object oriented languages (although it was not the original purpose),
safe polymorphism, usually achieved through inheritance.

This is actually what differentiate objects on "modern" languages
from sets of functions operating on the same data structure in Go
(and in C, which is even more explicit on this subject).

So how does Go approach the safe polymorphism problem without inheritance ?
Here enters one of the coolest features of Go, interfaces.

Since this post is already very long, the evolution of the ideas to interfaces
will be made on a subsequent post.

Happy Go hacking ;-).
