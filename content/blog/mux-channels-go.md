+++
author = "Tiago Katcipis"
categories = ["Go"]
date = "2019-06-07"
description = "Multiplexing channels in Go"
featured = "todo.png"
featuredalt = "Go Explorer"
featuredpath = "img"
linktitle = "Multiplexing channels in Go"
title = "Multiplexing channels in Go"
type = "post"

+++

Writing this post required a great deal of courage from me
because the more I think about the idea of multiplexing
channels and how it can simplify some nasty problems in
concurrent algorithms it seems that it is something that
I was supposed to already know for a long time and
never caught up because of sheer stupidity on my part, so
there is a great risk that this post will be a waste
of time for people that actually know what they are
doing =P. But since there is a chance that I'm not the
only person oblivious to this idea I'm going to try
and explain how I discovered it and then had some fun with
it and how I think it now helps me, in some cases
(it is not a silver bullet), to write simpler concurrent code.

The first time that I read about the idea of multiplexing channels
in Go was in Russ Cox blog post
[My Go Resolutions for 2017](https://research.swtch.com/go2017),
it was a very brief mention in the section regarding generics in Go
(no, there is no way I'm not going to touch that =P):

```
Personally, I would like to be able to write general channel-processing functions like:

// Join makes all messages received on the input channels
// available for receiving from the returned channel.
func Join(inputs ...<-chan T) <-chan T

// Dup duplicates messages received on c to both c1 and c2.
func Dup(c <-chan T) (c1, c2 <-chan T)
```

The first thing that caught my attention is that generics is usually
exemplified with data structures, but in this case the example were
generic algorithms, so it stayed in the back of my mind but I was
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
similar it is to Go channels I stumbled again with multiplexing (or
joining). From [The Limbo Programming Language](http://www.vitanuova.com/inferno/papers/limbo.html):

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

Even the communication operator is different, but then a crucial difference,
there is a special case to handle arrays of channels which does exactly the
joining/multiplexing of channels. And it seemed important enough to be
supported by the language itself. I connected this with what I have
read previously about joining channels (duh) and started to get
strong feelings that this could be something useful to concurrency.
