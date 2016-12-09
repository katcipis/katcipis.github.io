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
about closures and functions, but as I see other people
developing in Go I sense some struggling to understand how
Go works with objects.

A vivid example is not seeing that a function that accepts
a function as a parameter can also be called passing a method,
So the idea is to de construct the object model to just functions
and build it back to how Go works, showing that the first class
concept in Go is actually functions not objects.

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
yet it worked.  In any other object oriented language that I know (not much,
C++, Python and Java basically) this would never work, but in
Go it worked, why ?

Well because in Go, there is no methods at all, there is no method type,
methods are actually syntactic sugar for calling functions passing the
struct as the first parameter (as people are used to do in C).

Not convinced ? Lets elaborate our example:

```go
	fmt.Printf("ObjectAdder.Add: %T\n", (*ObjectAdder).Add)
	fmt.Printf("ObjectAdder.Add: %d + %d = %d\n", 1, 1, (*ObjectAdder).Add(nil, 1, 1))
```

Result:

```
ObjectAdder.Add: func(*main.ObjectAdder, int, int) int
ObjectAdder.Add: 1 + 1 = 2
```

As you can see, what Go actually does is to append a function on the type
**\*ObjectAdder** that accepts a **\*ObjectAdder** as the first
parameter. There is not method at all, it is just a function.

What we see as an object in Go is actually a collection of functions appended
to a type and syntactic sugar to pass the first argument for you.

The implementation of object orientation usually is something like that,
but in Go this is explicit (as almost everything in Go, there is great
value on being explicit about stuff).

This makes a lot of things more simple and uniform, the examples
showed that, passing a function or a method as a argument has no
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
parameters should be stateless (or even idempotent) may be useful,
but it is dangerous to trust that in Go.


# Functions and state

TODO

- Talk about closures
- Create an "object" just with closures


# What is an object anyway ?


Until now it seems like an object is just a set of functions
that operates on the same data structure. In all languages it
is actually just that, with the exception that this is not
just as explicit as it is in Go.

There is just one thing missing, that is the hallmark of traditional
object oriented languages (although it was not the original purpose),
safe polymorphism achieved through inheritance.

This is actually what differentiate objects on "modern" languages
from sets of functions operating on the same data structure in Go
(and in C, which is even more explicit on this subject).

So how does Go approach the safe polymorphism problem ? Here enters
one of the coolest features of Go, interfaces.

Since this post is already very long, the evolution of the ideas to interfaces
will be made on a subsequent post.

Happy Go hacking ;-).
