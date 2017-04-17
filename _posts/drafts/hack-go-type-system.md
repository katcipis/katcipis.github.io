# Hacking Go's type system

Since I worked with handwritten type systems in C,
like the one found in [glib GObjects](TODO), I'm
always curious on how languages implement the
concept of type safety on a machine that actually only
has numbers. This curiosity has extended to how I could
bend Go's type system to my own will.

Go's instances do not carry type information on the instances,
so my only chance will involve using a interface{}. All type systems
that I'm aware off usually implement types as some sort of integer code,
which is used to check if the type corresponds to the one you are casting.

To begin the exploration I wanted to find how type assertions are
made, so I wrote this ridiculous code:

```
package main

import "fmt"

func main() {
	var a int
	var b interface{} = a
	c := b.(int)
	fmt.Println(c)
}
```

Compiled it outputing it's assembly:

```
go build -gcflags -S cast.go
```

Found that the assembly code corresponding to this:

```
	c := b.(int)
```

Is this:

```
	0x0075 00117 (cast.go:8)	MOVQ	CX, 8(SP)
	0x007a 00122 (cast.go:8)	MOVQ	AX, 16(SP)
	0x007f 00127 (cast.go:8)	LEAQ	"".autotmp_1+64(SP), AX
	0x0084 00132 (cast.go:8)	MOVQ	AX, 24(SP)
	0x0089 00137 (cast.go:8)	PCDATA	$0, $0
	0x0089 00137 (cast.go:8)	CALL	runtime.assertE2T(SB)
```

The **runtime.assertE2T** call caught my attention, it was not hard to
find it on the [iface.go](TODO) file on the golang source code.

It's code (on the time of writing, Go 1.8):

```
func assertE2T(t *_type, e eface, r unsafe.Pointer) {
	if e._type == nil {
		panic(&TypeAssertionError{"", "", t.string(), ""})
	}
	if e._type != t {
		panic(&TypeAssertionError{"", e._type.string(), t.string(), ""})
	}
	if r != nil {
		if isDirectIface(t) {
			writebarrierptr((*uintptr)(r), uintptr(e.data))
		} else {
			typedmemmove(t, r, e.data)
		}
	}
}
```

There is the eface type, that has a **_type** field. Checking out what
would be a **eface** I found this:

```
type iface struct {
	tab  *itab
	data unsafe.Pointer
}

type eface struct {
	_type *_type
	data  unsafe.Pointer
}
```

From what I read before on
[Russ Cox post about interfaces](TODO)
I would guess that the **iface** is used when you are using
interfaces that have actually methods on it (that is why it has
a itab, the interface table, which is roughly equivalent to
C++ vtable).

I will ignore the iface (althought it is interesting) since it does not
seem to be what I need to hack Go's type system, there is more potential
on **eface**, which covers the special case of empty interfaces. On the
post Russ Cox says that the empty interface is a special case that holds
only the type information + the data, there is no itable, since it makes
no sense at all.

The interface{} is just a way to transport runtime type information + data
on a generic way through your code and it seems to be the more promissing
way to hack types.

The **type** is:

```
type _type struct {
	size       uintptr
	ptrdata    uintptr // size of memory prefix holding all pointers
	hash       uint32
	tflag      tflag
	align      uint8
	fieldalign uint8
	kind       uint8
	alg        *typeAlg
	// gcdata stores the GC type data for the garbage collector.
	// If the KindGCProg bit is set in kind, gcdata is a GC program.
	// Otherwise it is a ptrmask bitmap. See mbitmap.go for details.
	gcdata    *byte
	str       nameOff
	ptrToThis typeOff
}
```

Lots of promissing fields to hack with, but since the comparison is just
a direct pointer comparison:

```
	if e._type != t {
		panic(&TypeAssertionError{"", e._type.string(), t.string(), ""})
	}
```

It seems easier to just find a way to get the eface struct and overwrite its
**type** with the one I desire. This smells like a job to the [unsafe](TODO)
package. But before that I needed more information on how a interface{}
is initialized. Going back to the assembly code.

This line:

```
	var b interface{} = a
```

Becomes this:

```
	0x0021 00033 (cast.go:7)	MOVQ	$0, "".autotmp_0+72(SP)
	0x002a 00042 (cast.go:7)	MOVQ	$0, "".autotmp_3+48(SP)
	0x0033 00051 (cast.go:7)	LEAQ	type.int(SB), AX
	0x003a 00058 (cast.go:7)	MOVQ	AX, (SP)
	0x003e 00062 (cast.go:7)	LEAQ	"".autotmp_0+72(SP), CX
	0x0043 00067 (cast.go:7)	MOVQ	CX, 8(SP)
	0x0048 00072 (cast.go:7)	LEAQ	"".autotmp_3+48(SP), CX
	0x004d 00077 (cast.go:7)	MOVQ	CX, 16(SP)
	0x0052 00082 (cast.go:7)	PCDATA	$0, $0
	0x0052 00082 (cast.go:7)	CALL	runtime.convT2E(SB)
	0x0057 00087 (cast.go:7)	MOVQ	32(SP), AX
	0x005c 00092 (cast.go:7)	MOVQ	24(SP), CX
```

My first move is on **runtime.convT2E(SB)**:

```	
func convT2E(t *_type, elem unsafe.Pointer, x unsafe.Pointer) (e eface) {
	if raceenabled {
		raceReadObjectPC(t, elem, getcallerpc(unsafe.Pointer(&t)), funcPC(convT2E))
	}
	if msanenabled {
		msanread(elem, t.size)
	}
	if isDirectIface(t) {
		throw("direct convT2E")
	}
	if x == nil {
		x = newobject(t)
		// TODO: We allocate a zeroed object only to overwrite it with
		// actual data. Figure out how to avoid zeroing. Also below in convT2I.
	}
	typedmemmove(t, x, elem)
	e._type = t
	e.data = x
	return
}
```

Yeah, definitely seems to be initializing the eface and returning it.
Now I just have to figure a way to get my hands on the **_type** pointer.

Since this is all internal to Go from now on there will be a lot
of unsafe fun and this will probably not be portable code (as most
fun stuff).
