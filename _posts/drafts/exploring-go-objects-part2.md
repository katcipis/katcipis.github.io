# Data structure

Basic introduction to the obvious advantages
of structuring data.

TODO

# How to structure functions ?

If functions are first class citizens in a language, structuring
functions would not differ from structuring data.

We have a way to compose data (structs), how to compose functions ?
how to express a protocol.

Talk about the idea of implementing interfaces like this:

```go
type SomeProtocol interface {
    Do(a string) error
    DoOther(a int) (int, error)
}

func useSomeProtocol(s SomeProtocol) {
        s.Do("hi")
        s.DoOther(5)
}

func main() {
        useSomeProtocol(SomeProtocol{
            Do: func(a string) error {
                    return nil
            },
            DoOther: func(a int) (int, error) {
                    return 0, nil
            },
        })
}
```

The negative point of this is that there is no easy way to verify at
compile time that all the functions of the interface instance
have been initialized with a proper function.

Using the objects notation you can guarantee that at compile time
since implementing a method is done by adding a function to a type
and checking for all functions attached to a type is pretty easy
to do statically.

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

## Conclusion

TODO: Go seems to me to be more object oriented
than most "classical" object oriented languages.
