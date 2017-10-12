---
published: false
title: True object orientation with Go interfaces
layout: post
---

Walk with me through my journey on how Go approaches
object orientation and how in the end is seems much
more object oriented than most "traditional" object
oriented languages.

<!-- more -->

OK, true object orientation seems like a stretch,
specially because who the hell am I to talk about
what is really object orientation ?

I promise that I will try to back up my conclusions
with more support than "I just think this is what objects
should be about".

On a [previous post](https://katcipis.github.io/2017/03/28/exploring-go-objects.html)
I explored the idea of expressing everything just with functions, and that
Go objects are actually just a safe way to express a 
set of functions that always go together and may operate on same state.

Safely expressing sets of functions that operates on same state is pretty
useful, but how to actually create abstractions that can have multiple
different implementations ?

Objects alone do not support that, each type has its own set of functions
attached to it and that is it. Before I was referring to this need as
polymorphism, but as I walk away from the traditional notion of object
orientation being about the objects and its form I find that thinking about
protocols instead of polymorphism is more aligned with what should be the
focus when you are designing software (more on that later).

# How to define a protocol ?

First lets define what would be a protocol, for me a protocol
is **a set of operations required to achieve a desired outcome**.

If this seems confusing, let me give an example with the more
easy to understand abstraction that I know, I/O.

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

Which is a very hard (if not impossible) to be a compile time
safe way to express a protocol. This example for example causes
a segmentation fault, on purpose.

Another problem is that the code implementing the protocol
needs to known the protocol it is implementing explicitly
in order to initialize the struct properly, or delegate
the struct initialization to other part of the system
which would spread around the code the knowledge on how
to initialize the struct.  When you think about the same set
of functions implementing multiple
protocols this gets even worse.

This is where Go interfaces comes in,
it provides us with a safe way to express protocols eliminating
all the boilerplate of initializing structs with the proper functions,
it will initialize the structs for us (and even optimize to
initialize the struct just once).

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

You still can cause a segmentation fault if you do something like this:

```go
func() (ReadCloser, error) {
        var a ReadCloser
        return a, nil
}
```

But there is still the bonus that every time you initialize the variable
properly, like this :

```go
func() (ReadCloser, error) {
        var a ReadCloser = &Whatever{}
        return a, nil
}
```

If it compiles you can be sure it is safe to call all functions of the interface.
Also with the Go's interface mechanism an object can implement multiple different
protocols without even knowing these protocols.

How useful can be implementing protocols that you do not even known exists ?
This is very useful if you want your code to be truly extensible, allow me
to provide a real world example from [nash](https://github.com/NeowayLabs/nash).

## Extending code beyond its original purpose

The first time I understood how powerful Go interfaces can be was
when I was trying to code the tests for the built-in function **exit**
on nash.

The whole code can be found
[here](https://github.com/NeowayLabs/nash/blob/c0cdacd3633ce7a21714c9c6e1ee76bceecd3f6e/internal/sh/builtin/exit_test.go)

This is extremely important because it allows developers to come
with simple objects since they dont have to predict every single way
that the object may be used on the future. As long as the protocol
of your object is clear and useful it may be reused on several ways
that you never thought to be possible.

## What is object orientation anyway ?

TODO, source:

Alan Kay [The computer revolution has not happened yet](https://www.youtube.com/watch?v=oKg1hTOQXoY)

Object orientation was supposed to model and focus on what is between the objects, not
the objects itself.

Japanese word "ma", english word "interstitial"

Importance of encapsulation comparing to cells.

Cells membrane exists to avoid stuff from getting out and also
avoiding things to get in, clear protocol is implemented on
the membrane to express that.

### To inherit or not to inherit ?

Inheritance as a means of creating taxonomy (C++ / Java).

Inheritance as a means of lazy functions composition (Python mixins)

### Duck Typing

Fuck the duck, focus on protocols not form.

## Conclusion

TODO: Go seems to me to be more object oriented
than most "classical" object oriented languages.
