---
published: false
title: Having fun with nil and interfaces
layout: post
---

Learning and programming in Go has been delightful 99% of the time,
and is an experience that I hadn't experienced for some time.
This makes even more remarkable when the language bites you in the ass :-).

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

```
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

```
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
a panic. But that is not even why I started to write this, I had an interesting experience
playing around with error aggregation + nil behaviour + interfaces + testify, and I hope this
experience may be useful to someone else.


# First example

https://play.golang.org/p/ZShTB22Stp


# Aggregating errors and testify

https://github.com/stretchr/testify/blob/master/assert/assertions.go#L321
