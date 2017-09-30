# How to compose functions ?

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
