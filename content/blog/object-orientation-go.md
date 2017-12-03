+++
author = "Tiago Katcipis"
categories = ["Go"]
date = "2017-12-03"
description = "What is Object Orientation anyway ?"
featured = "gophermessages.jpg"
featuredalt = "Gophers sending messages"
featuredpath = "img"
linktitle = "Object Orientation in Go"
title = "Object Orientation in Go"
type = "post"

+++

Walk with me through my journey on how Go approaches
object orientation and how in the end it seems much
more object oriented than most "traditional" object
oriented languages.

What do I mean with "more object oriented than most traditional
object oriented languages" ? I promise that I will try to back up my conclusions
with more support than "I just think this is what objects
should be about", so bear with me while I try to explain this long this post.

On a [previous post](https://katcipis.github.io/blog/exploring-go-objects/)
I explored the idea of expressing everything just with functions, and that
Go objects are actually just a safe way to express a 
set of functions that always go together with the same closure
and may operate on same state.

Safely expressing sets of functions that operates on same state is pretty
useful, but how to actually create abstractions that can have multiple
different implementations ?

Objects alone do not support that, each type has its own set of functions
attached to it (what we call methods) and that is it.
This is referred as polymorphism, but as I walk away from the traditional
notion of object orientation being about the objects and its form (type)
I find that thinking about protocols instead of polymorphism is more aligned
with what should be the focus when you are designing software
(more on that later).

# How to define a protocol ?

First lets define what would be a protocol, for me a protocol
is **a set of operations required to achieve a desired outcome**.

If this seems confusing let me give an example with the easier
to understand abstraction that I know, I/O.

Lets say you want to read a file, the protocol will be:

* Open file
* Read its contents
* Close it

To achieve your single purpose of reading all the contents of a file you
need these 3 operations, so these operations are what forms your
"reading file" protocol.

Now lets get this example and work with it through the rest of the post.

If functions are first class citizens in a language, structuring
functions would not differ from structuring data.

We have a way to compose data (structs), we could compose the functions the
same way, like this:

```go
type Reader func(data []byte) (int, error)
type Closer func() error

type ReadCloser struct {
    Read Reader
    Close Closer
}

type Opener func() (*ReadCloser, error)

func useFileProtocol(open Opener) {
        f, _ := open()
        data := make([]byte, 50)
        f.Read(data)
        f.Close()
}

func main() {
        useFileProtocol(func() (*ReadCloser, error) {
                return &ReadCloser{}, nil
        })
}
```

Which is very hard (if not impossible) to be a compile time
safe way to express a protocol. To make a point this example
causes a segmentation fault.

Another problem is that the code implementing the protocol
needs to known the protocol it is implementing explicitly
in order to initialize the struct properly
(just as how it happens with inheritance), or delegate
the struct initialization to other part of the system
which would spread around the code the knowledge on how
to initialize the struct properly.
When you think about the same set of functions implementing multiple
protocols this gets even worse.

The object that needs some third party protocol needs a way to:

* Express clearly what is the protocol it needs
* Be sure that when it starts interacting with an implementation no function is missing

The object that implements the service needs to:

* Be able to safely express that it has the required functions to satisfy the protocol
* Be able to satisfy a protocol even without knowing it explicitly

There is no need for two objects to interact to achieve a common goal
to have a specific type, all that matters is if the protocol between
them matches.

This is where Go interfaces comes in.
It provides us with a compile time safe way to express protocols eliminating
all the boilerplate of initializing structs with the proper functions.
It will initialize the structs for us, and even optimize to
initialize the struct just once, what is called in Go the **iface**,
which is comparable to C++ **vtable**.

It will also allow the code to be more decoupled since you don't have
to known the package where the interface is defined to implement it.
This is fundamental to how Go allows more flexibility with the same
compile time safety as languages like Java/C++.

Lets revisit the previous file protocol with interfaces:

```go
package main

type Reader interface {
    Read(data []byte) (int, error)
}

type Closer interface {
    Close() error
}

type ReadCloser interface {
    Reader
    Closer
}

type Opener func() (ReadCloser, error)

type File struct {}

func (f *File) Read(data []byte) (int, error) {
        return 0, nil
}

func (f *File) Close() error {
        return nil
}

func useFileProtocol(open Opener) {
        f, _ := open()
        data := make([]byte, 50)
        f.Read(data)
        f.Close()
}

func main() {
        useFileProtocol(func() (ReadCloser, error) {
                return &File{}, nil
        })
}
```

One key difference is that with interfaces this code is now
safe. The **useFileProtocol** do not have to worry with calling
functions that are actually nil, the Go compiler will do the work
of creating a struct that holds a pointer with a **iface** descriptor
that has all the functions required to satisfy the protocol.
It does this per match of type <-> interface, as it is used (initializes
on first usage). 

You still can cause a segmentation fault if you do something like this:

```go
useFileProtocol(func() (ReadCloser, error) {
        var a ReadCloser
        return a, nil
})
```

But there is still the bonus that every time you initialize the variable
properly, like this :

```go
useFileProtocol(func() (ReadCloser, error) {
        var a ReadCloser = &Whatever{}
        return a, nil
})
```

If it compiles you can be sure it is safe to call all functions of the interface.
Also with the Go's interface mechanism an object can implement multiple different
protocols without even knowing these protocols.

How useful can be implementing protocols that you do not even know it exists ?
This is very useful if you want your code to be truly extensible. Allow me
to provide a real world example from [nash](https://github.com/NeowayLabs/nash).

# Extending code beyond its original purpose

The first time I understood how powerful Go interfaces can be was
when I was trying to code the tests for the built-in function **exit**
on nash. The main problem was that it seemed like we would have to
implement different tests for each platform because the exit status
code was handled differently on some platforms. I don't remember all
the details right now but on plan9 the exit status is an string instead
of an integer.

Basically on an error I wanted the status code, not just the error like
it is provided on [Cmd.run](https://golang.org/pkg/os/exec/#Cmd.Run).

There is the [ExitError](https://golang.org/pkg/os/exec/#ExitError) type,
so I could do something like this:

```go
if exiterr, ok := err.(*exec.ExitError); ok {
}
```

To at least know that this is some error generated by an error
status on the process I just executed, but I was still out of luck
on finding the actual status code.

So I went on a stroll inside Go's code base to checkout how
I could get the error status code from ExitError.

My clue was the ProcessState that is composed inside the ExitError struct,
the **Sys** method seemed promissing:

```go
// Sys returns system-dependent exit information about
// the process. Convert it to the appropriate underlying
// type, such as syscall.WaitStatus on Unix, to access its contents.
func (p *ProcessState) Sys() interface{} {
	return p.sys()
}
```

Well, interface{} kinda says nothing, but following its threads I found
this posix implementation:

```go
func (p *ProcessState) sys() interface{} {
	return p.status
}
```

And what would be **p.status**, on posix:

```go
type WaitStatus uint32
```

With the very interesting method:

```go
func (w WaitStatus) ExitStatus() int {
	if !w.Exited() {
		return -1
	}
	return int(w>>shift) & 0xFF
}
```

But this is for posix, what about other platforms ?
Using this advanced inspection technique:

```
syscall % grep -R ExitStatus .
./syscall_nacl.go:func (w WaitStatus) ExitStatus() int    { return 0 }
./syscall_bsd.go:func (w WaitStatus) ExitStatus() int {
./syscall_solaris.go:func (w WaitStatus) ExitStatus() int {
./syscall_linux.go:func (w WaitStatus) ExitStatus() int {
./syscall_windows.go:func (w WaitStatus) ExitStatus() int { return int(w.ExitCode) }
./syscall_plan9.go:func (w Waitmsg) ExitStatus() int { 
```

Looks like common protocol being implemented by a
good enough amount of platforms, it was good enough for me at least
(windows + linux + plan9 would be enough). Now that we have a common protocol
for all desired platforms we can do something like this:

```go
	// exitResult is a common interface implemented by
	// all platforms.
	type exitResult interface {
		ExitStatus() int
	}

        if exiterr, ok := err.(*exec.ExitError); ok {
                if status, ok := exiterr.Sys().(exitResult); ok {
                        got := status.ExitStatus()
                        if desc.result != got {
                                t.Fatalf("expected[%d] got[%d]", desc.result, got)
                        }
                } else {
                        t.Fatal("exit result does not have a  ExitStatus method")
                }
        }
```

The whole code can be found
[here](https://github.com/NeowayLabs/nash/blob/c0cdacd3633ce7a21714c9c6e1ee76bceecd3f6e/internal/sh/builtin/exit_test.go)

If the Sys() method returned an abstraction more precise than just interface{}
it would be easier to come up with a new interface that is a subset of its
interface and we would have compile time safety, instead of just runtime
safety that is provided by the checked runtime cast.

But even an easy way to define a new interface and perform a safe runtime
cast without changing the original code that implements the interface is
pretty neat. In languages like Java or C++ I can't come up with a solution
that involves the same amount of code/complexity, specially because of
the brittleness of hierarchy based polymorphism. Casting is only allowed
if the original code knows the interface you are trying to cast and explicitly
inherits from it. To solve my problem I would have to change the core Go code
to know my interface, with Go interfaces this is not required (yay hierarchies).

This is extremely important because it allows developers to come up
with simple objects since they don't have to predict every single way
that the object may be used on the future,
like coming up with which interfaces may be useful.

As long as the protocol of your object is clear and useful it may be
reused on several ways that you never thought to be possible. You don't
even need to express interfaces explicitly for them to be defined and
used later.

# What is object orientation anyway ?

This is the part where I will try to make a point for Go as an awesome
object oriented language. All the early contact that I had with programming
was with languages like:

* Java
* C++
* Python

And learned about inheritance, multiple inheritance, diamond inheritance, etc.
There was a great focus on what are the types and inheritance trees,
an exercise on taxonomy. Like creating a good taxonomy would be the definition
of a good object oriented design.

As I progressed I started to talk with people who said that object orientation
was not about that (although all mainstream object oriented languages were)
and that way of designing was not flexible. I did not understand
that at the time but it got me curious. The best chance of understanding something
is going the closest to its core as possible, so I went for Alan Kay which is
the one who coined the term object orientation.

There is much more awesome stuff that can be learned from him,
but on the subject of object orientation there is the presentation
[The computer revolution has not happened yet](https://www.youtube.com/watch?v=oKg1hTOQXoY)
at OOPSLA where he talks a little about the origin of object orientation
(among other things).

He says that object orientation was supposed to focus on what is
between the objects, not the objects itself. He even says that a more process
oriented name would be better, because the focus on objects seems to have
generated a focus on types and taxonomy instead of this thing that actually
exists between the objects, which for me it is the protocols.

The important part of thinking about objects is the encapsulation
(again, not types). He gives a good example which are cells, they have membranes
that are explicit on what they allow to go out and what they allow to go in.

Every cell that interacts with each other knows nothing about each other
inner workings, they don't need to know the other cell type, they just have
to implement the same protocol, exchange the same proteins, etc
(I'm not that good with biology =)). The focus is on the chemical reactions
(processes) not the cells types.

So we end up with encapsulation and clear protocols as what object orientation
should be about, and with a great metaphor on how to develop systems that imitate
organisms instead of mechanisms, since organic life scales orders of magnitude
better.

Another great metaphor can be extracted from
[The Future of Programming](https://vimeo.com/71278954) presentation.
When talking about the beginning of the ARPANET and the "Intergalactic
Computer Network" one of the metaphors used to express how a system
could REALLY scale is how software would integrate with other software
that is completely alien (literally from other planet).

The metaphor is great because it shows the need for good protocols
and good forms to do content/protocol negotiation, which is what happens
on nature all the time, and probably what would happen if we met
alien life someday (hoping that we don't stupidly fight to death).

This metaphor even makes some point for dynamic languages, but to
be honest I don't have an understanding of this that is good enough
to propose something right now (I find hard to think on something
really adaptative without being dynamic, even in Go you need some
glue code to integrate the objects through manually created protocols).

The most important take right now of this metaphor is not what
would be best to represent this kind of system but to have the
right mindset to find possible answers, quoting from the presentation:

```
The most dangerous thought that you can have as a creative person is to
think that you know what you are doing
```

Even though I try to keep an open mind I can't find space for
inheritance when I think about programming
using the metaphors above. Alien life would never integrate since
they need a common ancestor that may simply not exist.

# Conclusion

The example that I gave above in Go already shows a glimpse on how you can
do more without having to change any pre existent code using the concept
of protocols (Go's interfaces) instead of types.
It seems to be easier to develop according
to the [open closed](https://en.wikipedia.org/wiki/Open/closed_principle)
principle since I can easily extend other code to do things that it was not
initially intended to without having to change it.

It may seem misleading that Go and Java have
interfaces since the only thing they have in common is their name.
In Java interfaces create a **is a** relationship, in Go it does not,
it simply defines a protocol to integrate an object with multiple others
that may implement that protocol and this is more object oriented than
anything that I know and extremely powerful.

# Acknowledgments

Special thanks to:

* [i4k](https://github.com/tiago4orion)
* [kamilash](https://github.com/kamilash)

For taking time reviewing and pointing out a lot
of stupid mistakes.
