---
published: false
title: Hacking Go's type system
layout: post
---

Are you in the mood for a stroll inside Go's type system ?
If you are already familiarized with it, this post can be funny
for you, or just plain stupid.

If you have no idea how types and interfaces are implemented on Go,
you may learn something, I sure did :-)

<!-- more -->

Since I worked with handwritten type systems in C,
like the one found in [glib GObjects](https://developer.gnome.org/gobject/stable/),
I'm always curious on how languages implement the
concept of type safety on a machine that actually only
has numbers. This curiosity has extended to how I could
bend Go's type system to my own will.

Go's instances do not carry type information on them,
so my only chance will involve using an interface{}. All type systems
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

Is (roughly) this:

```
	0x002a 00042 (cast.go:7)	LEAQ	type.int(SB), AX
	0x0031 00049 (cast.go:8)	CMPQ	AX, AX
	0x0034 00052 (cast.go:8)	JNE	$0, 162
	0x0036 00054 (cast.go:9)	MOVQ	$0, ""..autotmp_3+56(SP)
	0x003f 00063 (cast.go:9)	MOVQ	$0, ""..autotmp_2+64(SP)
	0x0048 00072 (cast.go:9)	MOVQ	$0, ""..autotmp_2+72(SP)
	0x0051 00081 (cast.go:9)	MOVQ	AX, (SP)
	0x0055 00085 (cast.go:9)	LEAQ	""..autotmp_3+56(SP), AX
	0x005a 00090 (cast.go:9)	MOVQ	AX, 8(SP)
	0x005f 00095 (cast.go:9)	PCDATA	$0, $1
	0x005f 00095 (cast.go:9)	CALL	runtime.convT2E(SB)
```

The **runtime.convT2E** call caught my attention, it was not hard to
find it on the [iface.go](https://github.com/golang/go/blob/master/src/runtime/iface.go)
file on the golang source code.

It's code (on the time of writing, Go 1.8.1):

```
// The conv and assert functions below do very similar things.
// The convXXX functions are guaranteed by the compiler to succeed.
// The assertXXX functions may fail (either panicking or returning false,
// depending on whether they are 1-result or 2-result).
// The convXXX functions succeed on a nil input, whereas the assertXXX
// functions fail on a nil input.

func convT2E(t *_type, elem unsafe.Pointer) (e eface) {
	if raceenabled {
		raceReadObjectPC(t, elem, getcallerpc(unsafe.Pointer(&t)), funcPC(convT2E))
	}
	if msanenabled {
		msanread(elem, t.size)
	}
	if isDirectIface(t) {
		// This case is implemented directly by the compiler.
		throw("direct convT2E")
	}
	x := newobject(t)
	// TODO: We allocate a zeroed object only to overwrite it with
	// actual data. Figure out how to avoid zeroing. Also below in convT2I.
	typedmemmove(t, x, elem)
	e._type = t
	e.data = x
	return
}
```

There is the eface type, that has a **_type** field. Checking out what
would be a **eface** I found this:

```go
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
[Russ Cox post about interfaces](https://research.swtch.com/interfaces)
I would guess that the **iface** is used when you are using
interfaces that have actually methods on it. That is why it has
an itab, the interface table, which is roughly equivalent to
a C++ vtable.

I will ignore the iface (althought it is interesting) since it does not
seem to be what I need to hack Go's type system, there is more potential
on **eface**, which covers the special case of empty interfaces
(the equivalent of a void pointer in C).

On the post Russ Cox says that the empty interface is a special case that holds
only the type information + the data, there is no itable, since it makes
no sense at all (a interface{} has no methods).

The interface{} is just a way to transport runtime type information + data
on a generic way through your code and it seems to be the more promissing
way to hack types.

The **type** is:

```go
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

Lots of promissing fields to hack with, but actual type check is just
a direct pointer comparison:

```
	if e._type != t {
		panic(&TypeAssertionError{"", e._type.string(), t.string(), ""})
	}
```

It seems easier to just find a way to get the eface struct and overwrite its
**type** pointer with the one I desire. This smells like a job to the
[unsafe](https://golang.org/pkg/unsafe/) package.

I still don't have a good idea on how to get the **\_type**, or how to manipulate
the eface type. My guess would be to just cast it as a pointer and do some
old school pointer manipulation, but I'm not sure yet.

One function that is a good candidate to give some directions
on how to do it is **reflect.TypeOf**:

```
func TypeOf(i interface{}) Type {
	eface := *(*emptyInterface)(unsafe.Pointer(&i))
	return toType(eface.typ)
}
```

Yeah, just cast the pointer to a eface pointer:

```
// emptyInterface is the header for an interface{} value.
type emptyInterface struct {
	typ  *rtype
	word unsafe.Pointer
}
```

It seems that although the eface was private on the **runtime**
package it is copied here on the **reflect** package. Well, if the
reflect package can do it, so can I :-) (a little duplication is
better than a big dependency, right ?).

Before going on, I was curious about where the types are initialized.
It seems that there is just one unique pointer with all the type
information for each type. Thanks to [vim-go](https://github.com/fatih/vim-go)
and [go guru](https://godoc.org/golang.org/x/tools/cmd/guru)
for the invaluable help on analysing code and allowing me to
check all the referers to a type it has been
pretty easy to find this on [runtime/symtab.go](https://github.com/golang/go/blob/master/src/runtime/symtab.go):

```go
// moduledata records information about the layout of the executable
// image. It is written by the linker. Any changes here must be
// matched changes to the code in cmd/internal/ld/symtab.go:symtab.
// moduledata is stored in read-only memory; none of the pointers here
// are visible to the garbage collector.
type moduledata struct {
	pclntable    []byte
	ftab         []functab
	filetab      []uint32
	findfunctab  uintptr
	minpc, maxpc uintptr

	text, etext           uintptr
	noptrdata, enoptrdata uintptr
	data, edata           uintptr
	bss, ebss             uintptr
	noptrbss, enoptrbss   uintptr
	end, gcdata, gcbss    uintptr
	types, etypes         uintptr

	textsectmap []textsect
	typelinks   []int32 // offsets from types
	itablinks   []*itab

	ptab []ptabEntry

	pluginpath string
	pkghashes  []modulehash

	modulename   string
	modulehashes []modulehash

	gcdatamask, gcbssmask bitvector

	typemap map[typeOff]*_type // offset to *_rtype in previous module

	next *moduledata
}
```

A good candidate is the **typemap** field, checking out how
it is used I found this on runtime/type.go:

```go
// typelinksinit scans the types from extra modules and builds the
// moduledata typemap used to de-duplicate type pointers.
func typelinksinit() {
	if firstmoduledata.next == nil {
		return
	}
	typehash := make(map[uint32][]*_type, len(firstmoduledata.typelinks))

	modules := activeModules()
	prev := modules[0]
	for _, md := range modules[1:] {
		// Collect types from the previous module into typehash.
	collect:
		for _, tl := range prev.typelinks {
			var t *_type
			if prev.typemap == nil {
				t = (*_type)(unsafe.Pointer(prev.types + uintptr(tl)))
			} else {
				t = prev.typemap[typeOff(tl)]
			}
			// Add to typehash if not seen before.
			tlist := typehash[t.hash]
			for _, tcur := range tlist {
				if tcur == t {
					continue collect
				}
			}
			typehash[t.hash] = append(tlist, t)
		}

		if md.typemap == nil {
			// If any of this module's typelinks match a type from a
			// prior module, prefer that prior type by adding the offset
			// to this module's typemap.
			tm := make(map[typeOff]*_type, len(md.typelinks))
			pinnedTypemaps = append(pinnedTypemaps, tm)
			md.typemap = tm
			for _, tl := range md.typelinks {
				t := (*_type)(unsafe.Pointer(md.types + uintptr(tl)))
				for _, candidate := range typehash[t.hash] {
					if typesEqual(t, candidate) {
						t = candidate
						break
					}
				}
				md.typemap[typeOff(tl)] = t
			}
		}

		prev = md
	}
}
```

It seems that the typemap is initialized on the startup of the
process, with help of information collected by the linker, on
build time.

The typelinksinit function is used on the schedinit function
(from [runtime/proc.go](https://github.com/golang/go/blob/master/src/runtime/proc.go)):

```go
// The bootstrap sequence is:
//
//	call osinit
//	call schedinit
//	make & queue new G
//	call runtime·mstart
//
// The new G calls runtime·main.
func schedinit() {
	// raceinit must be the first call to race detector.
	// In particular, it must be done before mallocinit below calls racemapshadow.
	_g_ := getg()
	if raceenabled {
		_g_.racectx, raceprocctx0 = raceinit()
	}

	sched.maxmcount = 10000

	tracebackinit()
	moduledataverify()
	stackinit()
	mallocinit()
	mcommoninit(_g_.m)
	alginit()       // maps must not be used before this call
	modulesinit()   // provides activeModules
	typelinksinit() // uses maps, activeModules
	itabsinit()     // uses activeModules

	msigsave(_g_.m)
	initSigmask = _g_.m.sigmask

	goargs()
	goenvs()
	parsedebugvars()
	gcinit()

	sched.lastpoll = uint64(nanotime())
	procs := ncpu
	if n, ok := atoi32(gogetenv("GOMAXPROCS")); ok && n > 0 {
		procs = n
	}
	if procs > _MaxGomaxprocs {
		procs = _MaxGomaxprocs
	}
	if procresize(procs) != nil {
		throw("unknown runnable goroutine during bootstrap")
	}

	if buildVersion == "" {
		// Condition should never trigger. This code just serves
		// to ensure runtime·buildVersion is kept in the resulting binary.
		buildVersion = "unknown"
	}
}
```


And schedinit, at least according to go guru, is not called anywhere.
The output of -gcflags -S also has no reference to this initialization.

Searching inside the **runtime** package:

```
(runtime)λ> grep -R schedinit .
./asm_amd64.s: CALL    runtime·schedinit(SB)
./asm_mips64x.s:       JAL     runtime·schedinit(SB)
./asm_arm.s:   BL      runtime·schedinit(SB)
./proc.go://   call schedinit
./proc.go:func schedinit() {
./asm_s390x.s: BL      runtime·schedinit(SB)
./traceback.go:        // schedinit calls this function so that the variables are
./asm_ppc64x.s:        BL      runtime·schedinit(SB)
./asm_arm64.s: BL      runtime·schedinit(SB)
./asm_386.s:   CALL    runtime·schedinit(SB)
./asm_mipsx.s: JAL     runtime·schedinit(SB)
./asm_amd64p32.s:      CALL    runtime·schedinit(SB)
```

It seems like the bootstraping code for each supported platform is ASM code.
Lets take a look at the **amd64** implementation:

```
	CLD				// convention is D is always left cleared
	CALL	runtime·check(SB)

	MOVL	16(SP), AX		// copy argc
	MOVL	AX, 0(SP)
	MOVQ	24(SP), AX		// copy argv
	MOVQ	AX, 8(SP)
	CALL	runtime·args(SB)
	CALL	runtime·osinit(SB)
	CALL	runtime·schedinit(SB)

	// create a new goroutine to start program
	MOVQ	$runtime·mainPC(SB), AX		// entry
	PUSHQ	AX
	PUSHQ	$0			// arg size
	CALL	runtime·newproc(SB)
	POPQ	AX
	POPQ	AX
```

The whole thing has more than 2000 lines, so I just copied the
part that confirms that schedinit is called before running
the actual code, and on schedinit the typelinksinit will be
called, that will initialize the types map.

Sorry, got pretty far from the objective, lets go back to the type system
hacking fun. Lets start the copying fun, just like the reflect package does,
to inspect details on different types:

```go
package main

import (
	"fmt"
	"unsafe"
)

// tflag values must be kept in sync with copies in:
//	cmd/compile/internal/gc/reflect.go
//	cmd/link/internal/ld/decodesym.go
//	runtime/type.go
type tflag uint8

type typeAlg struct {
	// function for hashing objects of this type
	// (ptr to object, seed) -> hash
	hash func(unsafe.Pointer, uintptr) uintptr
	// function for comparing objects of this type
	// (ptr to object A, ptr to object B) -> ==?
	equal func(unsafe.Pointer, unsafe.Pointer) bool
}

type nameOff int32 // offset to a name
type typeOff int32 // offset to an *rtype

type rtype struct {
	size       uintptr
	ptrdata    uintptr
	hash       uint32   // hash of type; avoids computation in hash tables
	tflag      tflag    // extra type information flags
	align      uint8    // alignment of variable with this type
	fieldAlign uint8    // alignment of struct field with this type
	kind       uint8    // enumeration for C
	alg        *typeAlg // algorithm table
	gcdata     *byte    // garbage collection data
	str        nameOff  // string form
	ptrToThis  typeOff  // type for pointer to this type, may be zero
}

type eface struct {
	typ  *rtype
	word unsafe.Pointer
}

func (e eface) String() string {
	return fmt.Sprintf("type: %#v\n\ndataptr: %v", *e.typ, e.word)
}

func getEface(i interface{}) eface {
	return *(*eface)(unsafe.Pointer(&i))
}

func main() {
	var a int
	var b int
	var c string
	var d float32
	var e float64
	var f rtype
	var g eface

	fmt.Printf("a int:\n%s\n\n", getEface(a))
	fmt.Printf("b int:\n%s\n\n", getEface(b))
	fmt.Printf("c string:\n%s\n\n", getEface(c))
	fmt.Printf("d float32:\n%s\n\n", getEface(d))
	fmt.Printf("e float64:\n%s\n\n", getEface(e))
	fmt.Printf("f rtype:\n%s\n\n", getEface(f))
	fmt.Printf("g eface:\n%s\n\n", getEface(g))
}
```

The output of running the code:

```
(typehack(git master))λ> go run inspectype.go
a int:
type: main.rtype{size:0x8, ptrdata:0x0, hash:0xf75371fa, tflag:0x7, align:0x8, fieldAlign:0x8, kind:0x82, alg:(*main.typeAlg)(0x4fb3d0), gcdata:(*uint8)(0x4b0eb8), str:843, ptrToThis:35392}

dataptr: 0xc42000a2f0

b int:
type: main.rtype{size:0x8, ptrdata:0x0, hash:0xf75371fa, tflag:0x7, align:0x8, fieldAlign:0x8, kind:0x82, alg:(*main.typeAlg)(0x4fb3d0), gcdata:(*uint8)(0x4b0eb8), str:843, ptrToThis:35392}

dataptr: 0xc42000a390

c string:
type: main.rtype{size:0x10, ptrdata:0x8, hash:0xe0ff5cb4, tflag:0x7, align:0x8, fieldAlign:0x8, kind:0x18, alg:(*main.typeAlg)(0x4fb3f0), gcdata:(*uint8)(0x4b0eb8), str:5274, ptrToThis:44480}

dataptr: 0xc42000a400

d float32:
type: main.rtype{size:0x4, ptrdata:0x0, hash:0xb0c23ed3, tflag:0x7, align:0x4, fieldAlign:0x4, kind:0x8d, alg:(*main.typeAlg)(0x4fb420), gcdata:(*uint8)(0x4b0eb8), str:6791, ptrToThis:34880}

dataptr: 0xc42000a478

e float64:
type: main.rtype{size:0x8, ptrdata:0x0, hash:0x2ea27ffb, tflag:0x7, align:0x8, fieldAlign:0x8, kind:0x8e, alg:(*main.typeAlg)(0x4fb430), gcdata:(*uint8)(0x4b0eb8), str:6802, ptrToThis:34944}

dataptr: 0xc42000a4e8

f rtype:
type: main.rtype{size:0x30, ptrdata:0x28, hash:0x622c3ba0, tflag:0x7, align:0x8, fieldAlign:0x8, kind:0x19, alg:(*main.typeAlg)(0x482ca0), gcdata:(*uint8)(0x4b0ec9), str:11620, ptrToThis:35904}

dataptr: 0xc420014270

g eface:
type: main.rtype{size:0x10, ptrdata:0x10, hash:0x4358c73f, tflag:0x7, align:0x8, fieldAlign:0x8, kind:0x19, alg:(*main.typeAlg)(0x4fb3e0), gcdata:(*uint8)(0x4b0eba), str:11606, ptrToThis:74272}

dataptr: 0xc42000a5c0
```

Since this is already getting pretty extensive I won't dive in every single
detail of the outputs. But we can observe some interesting things.

The hack seems to have worked perfectly, since the size of all types
makes sense. Alignment information also makes sense too.
And also there is the **kind** information. Like I said on the start,
type systems usually just use a number to differentiate on the types.

But comparing two different structs shows an interesting characteristic
from Go. Although **rtype** and **eface** are two different types, and
casting between the two types won't work, they are of the same kind **0x19**.

On the reflect package there is the [Kind](https://golang.org/pkg/reflect/#Kind)
type, which is a enumeration of all Go's base types. There is some information
about that [here](https://golang.org/ref/spec#Types). Every named/unnamed type
you define in Go will always have an underlying type, which will be one
of the types on the kind enumeration (that shows up on our type struct).

So in Go you can't create types in the same sense of the native types that
comes with the language, you can't create new kinds, at least AFAIK.
This is considerably confusing, because kind is a synonim of type :-),
but it is one of the two hardest challenges on programming, giving names
to things (the other ones is implementing caches :-)).

But the types you create work well enough, the compiler will help you, and
reflection will also work properly. Even with the same kind, different
types will have different **rtype** pointers associated with them, even different
size in the struct case, but it is an interesting detail that I tought it was
worth mentioning.

Well, now we can go back to hacking the type system.

There is a lot of ways to manipulate this type information, but the
more naive way that I can think of is to define a function that gets
an interface{} variable representing the value that will be casted
and another interface{} variable that will carry the type information
from where you want to cast to. The return is a new interface{}
that can be casted to the desired target type. Something like this:

```go
func Morph(value interface{}, desiredtype interface{}) interface{}
```

Well, in this case the lack of generics on Go obligates me
to use an interface{} and push the cast to the client, or develop
a function for every basic type, but types defined by the client
would require the client writing its own functions.

Let's just let the client do some heavy lifting on this
case, [Jersey's style](https://www.jwz.org/doc/worse-is-better.html)
(not that "The right thing" also does not have it's place).

The final implementation can be found on [morfus](https://github.com/katcipis/morfos),
the most small and stupid Go library ever :-).

I say this because the final hack on the type system is so simple
that it makes me want to cry, Go is indeed terribly simple, nothing
to feed my ego here :-(. The whole magic:

```go
package morfos

import "unsafe"

type eface struct {
	Type unsafe.Pointer
	Word unsafe.Pointer
}

func geteface(i *interface{}) *eface {
	return (*eface)(unsafe.Pointer(i))
}

// Morph will coerce the given value to the type stored on desiredtype
// without copying or changing any data on value. The result will
// be a merge of the data stored on value with the type stored on
// desiredtype, basically a frankstein :-).
//
// The result value should be castable to the type of desiredtype.
func Morph(value interface{}, desiredtype interface{}) interface{} {
	valueeface := geteface(&value)
	typeeface := geteface(&desiredtype)
	valueeface.Type = typeeface.Type
	return value
}
```

My very first passing test:

```go
package morfos_test

import (
	"testing"

	"github.com/katcipis/morfos"
)

func TestStructsSameSize(t *testing.T) {
	type original struct {
		x int
		y int
	}
	type notoriginal struct {
		z int
		w int
	}

	orig := original{x: 100, y: 200}
	_, ok := interface{}(orig).(notoriginal)
	if ok {
		t.Fatal("casting should be invalid")
	}

	morphed := morfos.Morph(orig, notoriginal{})
	morphedNotOriginal, ok := morphed.(notoriginal)

	if !ok {
		t.Fatal("casting should be valid now")
	}

	if orig.x != morphedNotOriginal.z {
		t.Fatalf("expected x[%d] == z[%d]", orig.x, morphedNotOriginal.z)
	}

	if orig.y != morphedNotOriginal.w {
		t.Fatalf("expected y[%d] == w[%d]", orig.y, morphedNotOriginal.w)
	}
}
```

This test is "safe" because both structs have the same size,
C programmers must be feeling butterflies on their bellies :-).

Although the hack is small, there is a lot of fun we can have
with it, but before we go on there is one single line of unsafeness
that is usually unknow to Go newcomers:

```go
func geteface(i *interface{}) *eface {
	return (*eface)(unsafe.Pointer(i))
}
```

My feeling the first time I saw this was:

![Go or C](img/hack-go-types/fly.jpg)

With this kind of casting, my hack could be written as:

```go
package main

import (
 	"fmt"
	"unsafe"
)

type a struct {
	a int
}

type b struct {
	b int
}

func main() {
	x := a{a:100}
	y := *(*b)(unsafe.Pointer(&x))
	
	fmt.Printf("x %v\n", x)
	fmt.Printf("y %v\n", y)
}
```

And get this:

```
x {100}
y {100}
```

It works, as can be read [here](https://golang.org/pkg/unsafe/#Pointer)
the unsafe.Pointer has special properties that allows it to be
cast just like you do in C:

```
A Pointer can be converted to a pointer value of any type.
```

You may be thinking, what was the point of all this then ?
Well, the objective was to hack the type system, which is to
make the runtime casting facility behave as I want,
my interest was to break this:

```go
        a, ok := b.(someType)
```

Make the "safe" cast behave unsafely, based on sheer curiosity on
how this can actually be safe (take a look under the hood).
And this has been achieved.

So lets forget that there is a **VERY** simpler way to force casts in Go
and have some fun with my useless hack (we should at least have some
fun, right ?).

In Go strings are immutable, or are they ?

```go
func TestMutatingString(t *testing.T) {

	type stringStruct struct {
		str unsafe.Pointer
		len int
	}

	var rawstr [5]byte
	rawstr[0] = 'h'
	rawstr[1] = 'e'
	rawstr[2] = 'l'
	rawstr[3] = 'l'
	rawstr[4] = 'o'

	hi := stringStruct{
		str: unsafe.Pointer(&rawstr),
		len: len(rawstr),
	}

	somestr := ""

	morphed := morfos.Morph(hi, somestr)
	mutableStr := morphed.(string)

	if mutableStr != "hello" {
		t.Fatalf("expected hello, got: %s", mutableStr)
	}

	rawstr[0] = 'h'
	rawstr[1] = 'a'
	rawstr[2] = 'c'
	rawstr[3] = 'k'
	rawstr[4] = 'd'

	if mutableStr != "hackd" {
		t.Fatalf("expected hackd, got: %s", mutableStr)
	}
}
```

To do this I exploited the fact that Go's strings are just structs
with a pointer to the actual byte array and a len, the string does not
need to be null terminated, thanks to the len field.

As expected this test pass. Without reassigning the **mutableStr**
variable at any moment I was able to make it represent a different
string, by changing its internal byte array.

Besides being fun, this hack is another example on how using the
**unsafe** package will trully make your program unsafe. Seeing this
on the code:

```go
        y := *(*b)(unsafe.Pointer(&x))
```

Will make all kind of alarms bell on your head, but this:

```go
        val, ok := b.(someType)
```

Well, if **ok** is true it is safe to use **val**, or is it ? :-)
