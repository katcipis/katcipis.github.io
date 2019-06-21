+++
author = "Tiago Katcipis"
categories = ["Go"]
date = "2019-06-07"
description = "Multiplexing Channels in Go"
featured = "todo.png"
featuredalt = "Go Channel Multiplexer"
featuredpath = "img"
linktitle = "Multiplexing Channels in Go"
title = "Multiplexing Channels in Go"
type = "post"

+++

Here I will provide some context on how the
concept of multiplexing (or joining) channels
got into my life and present an implementation
of that idea.

I have a feeling that this may be something well know
by people who have experience with concurrent algorithms,
but since there is a chance that I'm not the
only person oblivious to this idea I'm going to try
and explain how I discovered it and then had some fun with
it and how I think it now helps me, in some cases
(it is not a silver bullet), to write simpler concurrent code.

The first time that I read about the idea of multiplexing channels
in Go was in Russ Cox blog post
[My Go Resolutions for 2017](https://research.swtch.com/go2017),
it was a very brief mention in the section regarding generics in Go
(no, there is no way I'm not going to touch that subject here =P):

```
Personally, I would like to be able to write general channel-processing functions like:

// Join makes all messages received on the input channels
// available for receiving from the returned channel.
func Join(inputs ...<-chan T) <-chan T

// Dup duplicates messages received on c to both c1 and c2.
func Dup(c <-chan T) (c1, c2 <-chan T)
```

The first thing that caught my attention is that generics is usually
exemplified with data structures, but in this case the example was a
generic algorithm, so it stayed in the back of my mind but I was
not able to come up with no apparent application to the idea
(to be honest I did not even tried too hard, I just kinda thought it
was a cool example of a possible generic algorithm).

So I moved on with my life, and while I was reading some papers from
the [Inferno](http://www.vitanuova.com/inferno/) operational system
I ended up stumbling on the language
[Limbo](http://www.vitanuova.com/inferno/limbo.html), not quite stumbled
because the language used to program on top of the operational system is
Limbo (it would be as C is to Linux, or even Plan9). There is no amount
of words to express how awesome the whole ecosystem of the Inferno
operational system is and I barely scratched the surface of the ideas,
but when I was reading about concurrency in Limbo and thinking on how
similar it is to Go I stumbled again with multiplexing (or joining).

From [The Limbo Programming Language](http://www.vitanuova.com/inferno/papers/limbo.html):

```
8.2.9 Channel communication

The operand of the communication operator <- has type chan of sometype.
The value of the expression is the first unread object previously sent
over that channel, and has the type associated with the channel.
If the channel is empty, the program delays until something is sent.

As a special case, the operand of <- may have type array of chan of
sometype. In this case, all of the channels in the array are tested;
one is fairly selected from those that have data.
The expression yields a tuple of type (int, sometype ); its first member
gives the index of the channel from which data was read,
and its second member is the value read from the channel.
If no member of the array has data ready, the expression delays.
```

Even the communication operator is the same, but then a crucial difference,
there is a special case to handle arrays of channels which does exactly the
joining/multiplexing of channels. This idea seemed important enough to be
supported by the language itself. I connected this with what I have
read previously about joining channels (duh) and started to get
strong feelings that this could be something useful when I needed
to add concurrency to Go code.

# Implementing a channel multiplexer

I went ahead and did the only thing that usually helps me understand
something, trying to build it, this is not always possible (sadly =(),
but in this case it seemed simple enough. I also wanted to give the idea of
implementing a generic algorithm in Go a spin.

You can checkout the code
[here](https://github.com/madlambda/spells/tree/master/muxer)
(it even has some [docs](https://godoc.org/github.com/madlambda/spells/muxer) ).
As can be seen on the code, most of the logic is related with the
hardships of trying to build safe generic algorithms in Go, it is
indeed not very fun (although in Go defense that was the only time
I needed this in like 4 years).

The logic is pretty simple but at the
same time I would not like to reimplement this for every different
type that I need, so in the end I felt considerably good with
the final result. It was not as good as with parametric polymorphism
and not as good as Limbo which provides syntactic/semantic support
to it directly in the language but it was good enough.

![its something](https://raw.githubusercontent.com/katcipis/memes/master/itssomething.png)

There is one caveat which is the reason why there is also
a [benchmark for the muxer](https://github.com/madlambda/spells/blob/master/muxer/muxer_bench_test.go),
the algorithms for selecting the channels fairly is quadratic in
time complexity (O(N^2)), so as the number of channels increases
you can have some severe performance penalties. But it scales to
a pretty useful amount of channels, results running it with
Go 1.12:

```
go test ./... -bench .
?       github.com/madlambda/spells/assert      [no test files]
goos: linux
goarch: amd64
pkg: github.com/madlambda/spells/muxer
BenchmarkMux10-4               1        1000363294 ns/op
BenchmarkMux100-4              1        1000754728 ns/op
BenchmarkMux1000-4             1        1004244489 ns/op
BenchmarkMux2500-4             1        2334183235 ns/op
BenchmarkMux5000-4             1        9755168646 ns/op
BenchmarkMux10000-4            1        40901490254 ns/op
PASS
ok      github.com/madlambda/spells/muxer       56.012s
PASS
ok      github.com/madlambda/spells/semaphore   0.817s
```

As you can see, things starts to go downhill pretty fast
with more than 1000 channels. I have not yet encountered
a problem that had required me to use more than 100 channels
so that limit never worried me (also there are alternatives
designs that don't use
[reflect.Select](https://golang.org/pkg/reflect/#Select)
which I have not experimented yet).

As luck would have it, just as I was toying around with this muxer
package I had a problem at work that seemed that could benefit
from the idea. Here I will try to express the underlying pattern
which is a simple fan-out/fan-in using multiple concurrent
workers to solve some problem.

# Fan Out / Fan in

The solution space for concurrent algorithms design is pretty vast,
but one way to solve some problem concurrently is to set a fixed set
of long lived goroutines, that will act as workers, and distribute tasks
to them. Usually in a scenario like that you have three concepts in play:

* Task generation
* Task execution
* Results aggregation

This is a way to model concurrency that reminds me a lot of
[Map Reduce](https://en.wikipedia.org/wiki/MapReduce), you can
design the tasks to be completely independent of each other but
in the end you need to aggregate the results before producing
a meaningful result (in my case at work it was some metrics
extracted from the results).

This would look at something like this:

TODO: Fan out / Fan in diagram

As I mentioned earlier, the design space is vast, you can even work with
a shared map and use some locking mechanism around it, but for the
sake of brevity I will focus on how to model this problem
using only channels and communication.

Enriching the diagram to use channels gives a hint that it is
a good idea to use channels and communication to solve
the problem, it fits very well:

TODO: Diagram now annotated with channels/Go specific stuff

The fan-out part is usually easy, specially if generating
a task is fast when compared to executing the task, in this
case (with me it usually is) you can have a single
task generator goroutine writing to a channel and multiple
workers reading from it, Go is designed to make it easier
to have a single writer and multiple readers, and it provides
a way embedded on channels to indicate that processing is over,
which makes signalling that there are no more tasks to
execute trivial.

To understand how easy is to model things when there is
a single writer on channels let me introduce the
sample code that we will be working from now on
(it is as simple/stupid as possible):

```go
package main

import (
	"fmt"
)

type Task int

type Result int

func startTaskGenerator(start int, end int) <-chan Task {
	tasks := make(chan Task)
	go func() {
		for i := start; i <= end; i++ {
			tasks <- Task(i)
		}
		close(tasks)
	}()
	return tasks
}

func startTaskExecutor(tasks <-chan Task) <-chan Result {
	results := make(chan Result)
	go func() {
		for task := range tasks {
			results <- Result(int(task) * int(task))
		}
		close(results)
	}()
	return results
}

func resultAggregator(results <-chan Result) {
	sumSquares := 0
	totalResults := 0
	for res := range results {
		fmt.Printf("received result %v\n", res)
		sumSquares += int(res)
		totalResults += 1
	}
	fmt.Printf("total os squares received: %d\n", totalResults)
	fmt.Printf("sum of squares: %d", sumSquares)
}

func main() {
	tasks := startTaskGenerator(1, 100)
	results := startTaskExecutor(tasks)
	resultAggregator(results)
}
```

Usually all of these steps, task generation, execution and
result aggregation, are more complex, so having as little
as complexity as possible from the concurrency control is a
big win. At least in my opinion it does not get much
simpler than that. Understanding the logic and how the computation
ends is pretty simple when we leverage the close function
and channel iteration.

When just 3 goroutines is enough
for your problem this is bliss, it forms a very simple pipeline.
The problem is that sometimes the task execution takes more time
than the other phases in this pipeline, which brings us back
to the fan-out.

I wanted to start with a simpler version
of the problem because the beauty of multiplexing channels
stems from keeping this same simplicity but for a more complex
problem, the fan-out.

Let's say that now we want 30 concurrent task executors.
With the previous design that is not quite possible because we would
have something like this:

```go
func main() {
	tasks := startTaskGenerator(1, 100)
	for i := 0; i < 30; i++ {
	        results := startTaskExecutor(tasks)
	        // how to handle N result channels ?
	}
	resultAggregator(results)
}
```

Which usually evolves to something like this:

```go
func main() {
	tasks := startTaskGenerator(1, 100)
	results := make(chan Result)
	for i := 0; i < 30; i++ {
	        startTaskExecutor(tasks, results)
	}
	resultAggregator(results)
}
```

Which has nothing essentially wrong with it, but will
not work without some further redesign on the
startTaskExecutor function and the overall concurrency control.

Why is that ?

# Sharing read channels is fun, sharing write channels is not

TODO: Talk a little about sharing read channels

The problem with sharing write channels is that
you have to be very careful when you close a channel
that has multiple go routines writing on it, you
will need to use some signalization mechanism to know
that all workers have finished and no more writes
will happen and then you can close it. Not implementing
this properly can result in very sad non-deterministic
panics.

Even if you try to avoid the closing the channel problem
you are left with the problem of knowing that all workers
finished and also now with the problem of signalling go routines
that are reading from that channel (closing it would be
the more idiomatic way to signal that no more data
will come from that channel).

# Enters multiplexing

TODO: Explain how multiplexing channels can help you
scale a one worker goroutine simple code to a very similar
code that can run N workers.

# Simplicity is complicated

TODO: the overall design and code is simple, but some complexity
is hidden inside the muxer. Make some comments using
[Simplicity is Complicated](https://www.youtube.com/watch?v=rFejpH_tAHM).
