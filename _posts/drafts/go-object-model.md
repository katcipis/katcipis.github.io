---
published: false
title: Exploring Go's object model
layout: post
---

Go object model gets easier to understand when you accept
that there is no objects at all, there is just sets of functions
that can operate on common state, with
some sugar sprinkled on top.

<!-- more -->

Perhaps you are thinking
"shut up, of course there are objects in Go" or
"sets of functions that operates on common state is the definition
of an object", well, you are probably right.

I can't see a difference between a set of related functions
operating on the same state and an object, at least thinking
on the objects that I'm used to.
And there is more to Go object model than syntactic sugar.

But it is an object model very different from
the classical ones, like Java, C++ and Python
(these are the ones I know at least).

When struggling to get a sense of how Go objects works
it helped me a lot to just let go of my traditional object
notion and think only in terms of functions.

What I'm going to try is to de-construct the object model
to just functions and build it back to how Go works,
showing that Go is much more prone to functions with objects
as an aid to make some idiom's
easier than an object oriented language where everything
is an object.

It will probably be a lousy de-construction since I'm not an
expert in Go, but yet I feel compelled to try,
since it looks like fun :-).

# In the beginning there was the functions

Well I'm trying to make a point around thinking first about
functions, so here goes a stupid example of what can be done with functions.

Lets define a type that is actually a function:

```go
type Adder func(int, int) int
```

You can think about it as an interface (but it is not the same thing).
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

This really recalls the kind of thing you can do with interfaces.
**abstractedAdd** does not know how to add, and it will accept any
implementation of an Adder that respects the same protocol.

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

With this example in mind we have the opportunity to start exploring
Go's objects. Can a method satisfy the **Adder** type ? Depending
on your background this may sound counter intuitive (something like,
one is a method, but you need a function, etc)
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
match any kind of method name, you just pass the method as a parameter, since
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
the object method ? No ? It's because there is none. That is why passing
it as the parameter worked. This also explains another thing going on
in this code that sometimes makes newcomers (like me) to Go confused.

There is no fully initialized ObjectAdder on our example. I used a pointer
by purpose, as you can see the pointer is not initialized at all (it is nil),
yet it worked.  In any other object oriented language that I know this would
never work, but in Go it worked, why ?

Well because in Go, there is no methods at all, there is no method type,
methods are actually syntactic sugar for calling functions passing
an instance of the type as the first parameter (as people are used to do in C).
In Go this first parameter is usually called the method receiver, but there
is nothing special about it, it is just a parameter being
passed to a function.

Lets elaborate our example:

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

It will add a function on the type **\*ObjectAdder**.
This function is accessible and can be used as any other value on the
language (being called, passed as a parameter, etc).

If you are thinking "hey, but the type is ObjectAdder not \*ObjectAdder",
well in Go the pointer counter part of a type is actually another type
and has even a different set of functions appended to it.
To which of the types the function will be added is decided by the
type of the method receiver, on this case it is a (\*ObjectAdder).

This related to the [method sets](https://github.com/golang/go/wiki/MethodSets)
concept introduces on Go.

Anyway, going on, the result:

```
ObjectAdder.Add: func(*main.ObjectAdder, int, int) int
ObjectAdder.Add: 1 + 1 = 2
```

There is no method at all, it is just a function. What we see as an object in
Go is actually a collection of functions associated
to a type and syntactic sugar to pass the first argument for you.

Which to be honest is like almost all object oriented languages
is actually implemented.
The good thing is that in Go this is 100% explicit, no magic, just some
syntactic sugar. Go is really serious about being explicit.

This makes a lot of things more simple and uniform, the examples
showed that. Passing a function or a method as an argument has no
difference at all (I can't think on a reason to exist a difference).

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

This example is completely stateless. Objects usually have state and
side effects,can Go functions have state and side effects too ?

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

This is a mind bender if you are used to only use objects as a mean to
managing state (actually it is odd to most C programmers too,
since functions are a static construction in C).

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
ass pointer arithmetic using the unsafe package.

This is fun, since languages like Lisp have closures since ever and
this provides the absolute maximum level of encapsulation you can imagine.
There is no way to access the state directly except through the function.

Lets take a look on how this would look like using a Go object:

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

If you are feeling fancy, you can do this in Go without an struct at all:

```
package main

import "fmt"

type iterator int

func (i *iterator) iter() int {
	*i++
	return int(*i)
}

func main() {
	var i iterator

	fmt.Printf("iter 1: %d\n", i.iter())
	fmt.Printf("iter 2: %d\n", i.iter())
	fmt.Printf("iter 3: %d\n", i.iter())
}
```

The function version did the same thing, on a different way. And
it was able to manage state just as an object would, with
lexical scoping to guarantee state isolation, just the function
is able to change the state.

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
to give name and meaning to a composition of other types.

The same applies to functions, just having a lot of loose
functions would be a mess on a lot of cases (just as is with data).

Since Go does have functions as first class citizens,
a struct could have some fields that holds functions,
emulating the behaviour of methods, and representing a set of
functions that operates on common state. But that
would be clumsy and error prone, like the possibility of a non
initialized field/method being called (anyone that have programmed in C
will understand this problem very well, and its consequences).

A working calculator:

```
package main

import "fmt"

type Calculator struct {
	Add func(int,int) int
	Sub func(int,int) int
}

func newCalculator() Calculator {
	return Calculator{
		Add: func(a int, b int) int {
			return a + b
		},
		Sub: func(a int, b int) int {
			return a - b
		},
	}
}

func main() {
	calc := newCalculator()
	fmt.Println(calc.Add(3, 2))
	fmt.Println(calc.Sub(3, 2))
}
```

Well, you could argue about the clumsiness, depending on your
background this may seem better than the way Go expresses methods.
But you can't argue about the space this gives to error's.

For example, this:

```
package main

import "fmt"

type Calculator struct {
	Add func(int,int) int
	Sub func(int,int) int
}

func newCalculator() Calculator {
	return Calculator{
		Add: func(a int, b int) int {
			return a + b
		},
		Sub: func(a int, b int) int {
			return a - b
		},
	}
}

func main() {
	var calc Calculator
	fmt.Println(calc.Add(3, 2))
	fmt.Println(calc.Sub(3, 2))
}
```

Will result in:

```
panic: runtime error: invalid memory address or nil pointer dereference
[signal SIGSEGV: segmentation violation code=0xffffffff addr=0x0 pc=0xc64e8]

goroutine 1 [running]:
main.main()
	/tmp/sandbox772959961/main.go:23 +0x28
```

Even tough this is also possible to happen with methods, the feature of adding
functions to a type gives a compile time safe way to represent a set of
functions that operate on the same type. At least the call to the method is
always safe (although you may have a invalid method receiver that will
crash your program).

Besides clumsiness and error proneness there is also the problem
of how to express abstractions that are more complex than a single
function.

# Abstracting

All our abstractions until now consisted of something that could
be expressed with just one function, but what can you do
when the abstraction requires more than one function ?

If there is no way to express this you would always have to conflate
your abstractions in one function, that would look just horrible
(think about a read/write abstraction modeled on just one function).

The calculator example above provided a way to simulate methods to
a level that someone looking at how the Calculator is used would
be unable to tell that it's methods are not methods at all.

But there is a very important concept missing, a concept where Go's
methods are fundamental, how you express that you require a set
of functions without defining who will implement them and how
it will be implemented ?

To complete it, given a function X, that requires a set of functions Y,
how would you syntactically express that a type Z
implements the required set of functions Y, hence being a viable choice
to integrate with the function X ?

One way to solve this is with **safe** polymorphism. I want to be able to have
multiple different implementations of the same set of functions that
can interoperate seamlessly. There is emphasis on the **safe** part
of polymorphism. I had my share of C polymorphism, it is
possible and works very well, but it is definitely not safe.
You could argue that no implementation is completely safe, but safer
than C would be the basic, and it is what most languages like Java and
Python delivered on the time they where developed.

Safe is important because the calculator example could be used to implement
a form of this. We could do this:

```go
type Calculator struct {
	Add func(int,int) int
	Sub func(int,int) int
}

func codeThatDependsOnCalculator(c Calculator) {
        // etc
}
```

This would allow for N different implementations of a **Calculator**
to integrate with the code that depends on it, but it would not
be safe. It is very easy to provide just half the implementation and
get away with it. All functions that accept a **Calculator**
would need to check if **Add** and **Sub** are not nil.

This is awfully a lot alike how this is usually implemented in C,
and is clearly job that a compiler can do for you (in C you
can use some macros).

The answer Go have for this is interfaces, which is in
my opinion the most awesome feature of Go.

Since this post is already very long, the evolution of the ideas
to interfaces will be made on a subsequent post.

Happy Go hacking ;-).

# Acknowledgments

Special thanks to [i4k](https://github.com/tiago4orion) and
[vitorarins](https://github.com/vitorarins) for taking
time reviewing and pointing out a lot of stupid mistakes.
