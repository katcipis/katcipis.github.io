---
published: false
title: Having fun with nil and interfaces
layout: post
---

Learning and programming in Go has been delightful 99% of the time,
This makes even more remarkable when the language bites you in the ass :-).
Actually it is a mix of my own ignorance + some other detailsm but for everyone
that I presented this situation it did not seem like something obvious and intuitive.

A few weeks ago I have watched the [Understanding Nil](https://www.youtube.com/watch?v=ynoY2xz-F8s)
presentation, it is great way to really understand what nil is in Go, and I had no idea
nil could behave as explained on the presentation. I'm still kinda torn about this in Go,
it still seems like a great lack of uniformity/symmetry the way nil behaves.

It reminds me all my pain with channels, where there a full combinatorial explosion of
different behaviours if you are reading/writing closed/nil/ok channels.
For the channels I understood the reasons and the tradeoffs, it seems fair enough and I
still can't come up with better solutions (although I still have some problems remembering
the correct behaviour depending on the combination).

With nil I still dont get the benefit quite clearly. For example, a nil map behaves like
an empty map:

```go
package main

import (
	"fmt"
)

func main() {
	var a map[string]string
	b,ok := a["whatever"]
	fmt.Println(b,ok)
}
```

Hmm, it seems like a way to initialize a empty map, ok. But it is a read only map,
if you try to add any data on it a panic will occur:

```go
package main

import (
	"fmt"
)

func main() {
	var a map[string]string
	b,ok := a["whatever"]
	fmt.Println(b,ok)
	
	a["hi"] = "a"
}
```

Which makes me consider its usefulness, I used this on a lot of my tests, since I knew the
map would be read only. But I'm still not sure if it is a good choice, there is no way to communicate
that a map is read only, and the minimal change on the behaviour of the code can cause
a panic.

But that is not even why I started to write this, I had an interesting experience
playing around with error aggregation + nil behaviour + interfaces + testify, and I hope this
experience may be useful to someone else.

Just wanted to start with some warm up on nil behaviour, if you didnt know that nil maps
behave like that in Go, watch the presentation, it will be enlightening and will give some
base to understand the rest of the post.

In the end the problem is more about interface initialization than nil behaviour,
but I wanted to use this opportunity to bring this up, since it is a common source
of problem for newcomers.


# The problem


There was I writing some new service in Go when I was presented with this situation where
I had to perform two operations, if the first one failed I was also required to execute
the second one, but if any of them failed I had to report the error, and if both failed I
was also required to report it and coalesce the errors.

So the caller should receive a nil error if everything went ok, and an error if any of
the operations failed, or both.

This is a very interesting situation (and not a very common one for me) because it is
where Go's simple errors as values decisions shines. Doing this kind of thing with exceptions
would be pretty clumsy, at least with my knowledge of exceptions, with Go it seemed that
code would be pretty clean, and in the end it was, and I believe that more experienced
developers can even come with better solutions than mine. But before a definitive 
solution has been found some thorns where on the way.


# The first solution, an array of errors as an error


My first solution was to define an array of errors that behaves as one error,
and I was feeling pretty hacker about it :-), with the exception that it exploded on my
face. Here is an example of the idea, with some code omitted for brevity sake:

```go
type errorsAggregate []error

func (errors errorsAggregate) Error() string {
	if errors == nil {
		return "errors is nil"
	}
	return "concatenate all error messages inside the slice here"
}
```

The idea was to use my errorsAggregate as any slice to append multiple errors.
If no error at all has been appended on it, it would be nil, and I would be happy.

I tested the code, using testify assert package, and it was working like a charm.
If any error happened, assert.NotNil caught it. If no error happened, assert.Nil
passed ok. Development continued on, and things started when I started to do some
integration testing, stuff started to break down and I was very confusing.

My function that was returning the errors array was always returning a non-nil value
(or something that was not passing on a err == nil check anyway), and I was
very confused, specially with my previous tests still working.

I had to isolate the problem since it was extremely bizarre, when I did this I came up
with something like this:

```go
package main

import (
	"fmt"
)


type errorsAggregate []error

func (errors errorsAggregate) Error() string {
	if errors == nil {
		return "errors is nil"
	}
	return "concatenate all error messages"
}

func returnsErrors() error {
	var errs errorsAggregate
	fmt.Println(errs == nil)
	return errs
}

func main() {
	err := returnsErrors()
	fmt.Println(err)
	fmt.Println(err == nil)
}
```

If you run it on the Go playground you will get this:

```
true
errors is nil
false
```

What the actual fuck ? Inside the function my errs variable is nil, when I try
to print the error with Error() it evaluates as nil, just as expected, but when
I do the traditional Go checking, if != nil, the error is actually not nil ?

And on top of that, assert.Nil was working, how ? (it is not nil !!!)
Here is the answer:

```go
func isNil(object interface{}) bool {
	if object == nil {
		return true
	}

	value := reflect.ValueOf(object)
	kind := value.Kind()
	if kind >= reflect.Chan && kind <= reflect.Slice && value.IsNil() {
		return true
	}

	return false
}
```

Why the hell are they doing that check on a range of kinds and chaining with a value.IsNil() ?
The answer is on how interfaces behaves with nil. A pretty good source on that is this
[Russ Cox post about interfaces](http://research.swtch.com/interfaces), I'm going to
try to explain at least what was happening with me based on what I learned there.


# What is a nil interface ?


Well, a nil interface would be this:

```go
package main

import (
	"fmt"
)

func main() {
	var a interface{}
	fmt.Println(a == nil)
}
```

This is not:

```go
package main

import (
	"fmt"
)

func main() {
	var b *string
	var a interface{} = b
	fmt.Println(a == nil)
}
```

Why ? It seems to me that it happens because how interfaces are implemented:

![interface{}](http://research.swtch.com/gointer3.png)

When you assign the string to the interface{} variable, the interface{} is initialized
with the string type, and a nil string pointer as data.
So it is not actually nil, it has type information.

When an explicit assignment is made, and you are aware of how interfaces are initialized, this starts
to seem intuitive. The problem is that on a function return this is more subtle:

```go
func returnsErrors() error {
	var errs errorsAggregate
	fmt.Println(errs == nil)
	return errs
}
```

The error interface is being initialized with the errorsAggregate type information and its nil data pointer.
Since error is not an empty interface it would be pointing to a itable matching errorsAggregate Error method 
with the error interface Error, and a nil data pointer. But the error is not nil. This subtle detail +
testity.assert behaviour created a very bizarre scenario for me.

Although testify assert behaviour makes perfectly sense, since the function accepts a empty interface,
this kind of code would pass as non nil:

```go
package main

import (
	"fmt"
)

func assertNil(a interface{}) {
	fmt.Println(a == nil)
}

func main() {
	var b *string
	fmt.Println(b == nil)
	assertNil(b)
}
```

It explains why it uses reflection on the interface{} and checks if the value of interface{}
is actually nil, which on this case will be the string pointer.

This makes me wonder if it is a good idea to use a generic assertion module or just roll out
my own that would check for a nil string pointer directly on the test case.

Also, if I used a simple err != nil on the test, I would have caught the problem right away
,it would not be nil. It seems like another instance of generic programming (the interface{})
just making life harder.

As I develop more code on Go, the more I like the idea of just using the core language,
but that would be a topic for a entire other post.


# The final solution

The final solution is basically the aggregator with a method that actually returns a nil error
if it is empty:

```go
package main

import (
	"fmt"
	"errors"
)


type errorsAggregate []error

func (errs errorsAggregate) err() error {
	if errs == nil {
		return nil
	}
	return errors.New("aggregate errors here")
}

func returnsErrors() error {
	var errs errorsAggregate
	//some code here
	return errs.err()
}

func main() {
	err := returnsErrors()
	fmt.Println(err)
	fmt.Println(err == nil)
}
```

I have this feeling that this is not the better solution out there, but it is doing
its job properly right now.


I have a long way to go on understand how interfaces in Go work, but this experience already
taught me a lot and I hope it helps you to avoid this kind of problem on the future.
