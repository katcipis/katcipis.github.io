---
published: false
title: Good Design
layout: post
---

# Good design  ?

Software is very abstract. From the outside you cannot see software duct tape.
Nor can you see a an over-engineered monstrosity that is equivalent to a car
with 5 tires, one door and craft glue.

With enough effort, even the most awfully designed software can be made to run
- even reliably, so working or not working is not a good measure either.

For me it is extremely hard to define what is good software, but at the same
time the simple answer of "it depends" just annoys me as hell.

I started to revisit the issue with new eyes when I read
[Hackers and Painters](https://www.amazon.com/Hackers-Painters-Big-Ideas-Computer/dp/1449389554).
The book is a collection of essays, and it is just awesome. More specifically,
I'm talking about the [Taste for makers](http://www.paulgraham.com/taste.html)
essay. The thing that I really liked was the idea that there is good and bad
design, it is not subjective (even when comparing language design):

```
After dinning into you that taste is merely a matter of personal preference,
they take you to the museum and tell you that you should pay attention because
Leonardo is a great artist.

What goes through the kid's head at this point? What does he think
"great artist" means? After having been told for years that everyone just
likes to do things their own way, he is unlikely to head straight for the
conclusion that a great artist is someone whose work is better than the others'.
A far more likely theory, in his Ptolemaic model of the universe,
is that a great artist is something that's good for you, like broccoli,
because someone said so in a book.

Saying that taste is just personal preference is a good way to
prevent disputes. The trouble is, it's not true.
You feel this when you start to design things.
```

This marked me, because there was nothing that I considered more subjective
than art, and yet, even on arts there is masters and geniuses. If art is
subjective, what is the difference between a five year old drawing and
a Leonardo masterpiece ?

There must be a difference, what is really hard is that sometimes we
have a really hard time telling why it feels good or right, but it
is a fact that some things just feel right and others not and being
hard to define it should not be an excuse to drop the subject altogether
(more on this can be found on
[How Art Can Be Good](http://www.paulgraham.com/goodart.html) )

So, what could help me on my quest for establishing good parameters for design ?


## Form ever follows function

This concept comes from architecture (not software architecture).
A quotation from [Louis Sullivan](https://en.wikipedia.org/wiki/Louis_Sullivan)'s
[De architectura](https://en.wikipedia.org/wiki/De_architectura):

```
Whether it be the sweeping eagle in his flight, or the open apple-blossom,
the toiling work-horse, the blithe swan, the branching oak,
the winding stream at its base, the drifting clouds, over all the coursing sun,
form ever follows function, and this is the law.

Where function does not change, form does not change. The granite rocks,
the ever-brooding hills, remain for ages; the lightning lives,
comes into shape, and dies, in a twinkling.

It is the pervading law of all things organic and inorganic,
of all things physical and metaphysical, of all things human and all
things superhuman, of all true manifestations of the head, of the heart,
of the soul, that the life is recognizable in its expression,
that form ever follows function. This is the law
```

Well, can't argue too much with this kind of logic, it is beautiful.
What does work better than nature ? It may not be perfect but well, it
is the best example of a working, sustainable, scalable system that
we have to observe.

The lesson to be take from this to software is that software developers
usually are so concerned on applying a lot of "cool" design patterns
and a lot of other stuff they read about that they forget to understand
the problem properly and to accommodate the design to serve the purpose,
not otherwise.

I say this with property because besides watching this on
other people, I myself have done this a lot of times, probably will still
do. It is very easy to be carried away by your ego and just write code
for yourself, just as there is a lot of famous architects that build stuff
for themselves and their own egos, not for people that are going to use.

This is specially dangerous, you can even seem like a great developer and
still be doing this kind of mistake, because just as it happens with a building,
software aesthetics can trick a lot of people on thinking that you have done
a great job, specially people that just observe it from some distance.
Who are the people that are going to really judge if the building is any good ?  Only people that uses it on their daily basis,
people that are directly affected by it.

On software there is two main classes of people that fits this criteria, it is
clients and maintainers. It is the feedback of these two classes that can
provide good guidance if the form of your software is following function.

From [Designing has nothing to do with art](https://qz.com/823204/graphic-design-legend-milton-glaser-dispels-a-universal-misunderstanding-of-design-and-art/):

```
It’s good to understand that design has a purpose and art
has another purpose,” said Glaser. Art’s power is mysterious and cannot be
quantified, he explained, while design’s efficacy is measured by how well it
delivers on a clients’ goal. “
As you get older you get clearer about that distinction about design and art.
```

This makes it cristal clear how to measure design quality, but nothing is never
as simple as we would like with software :-). It is easy to analyse just the
features and the interface with the client, we would be analysing a important
part of the software design, the user experience. Altought fundamental, at
least for me it is not the hardest part of the problem (as a programmer,
I'm biased), we are surrounded by software that just started great and went
straight to hell after time.

This happens because of the "soft" nature of software (duh, that is why it is
"soft"ware :-) ). Comparing software with architecture is useful but
the metaphor breaks on the pace of change, it reminds much more biologic
evolution on this case, and not the evolution we are used on nature,
more like X-Men evolution, rampaging crazily, that sadly creates more
useless atrocities than awesome super heroes :-).

There is a whole lot of problems that you can get by not managing what you
want the software to do, but I will focus from now on how the code accommodate
the changes, assuming that you choose the new features perfectly, things
can still be horribly wrong as you try to do more, and everyone wants to do
more with computers.


## Change

I can't think on any other good metric to evaluate than the pace of
change of the system. It is single handed the bigger problem that I always
see people in software dealing with, not only on companies, open source
projects too.

It is not the only function to avaliate the form, on computing early days,
on MIT IA lab, hackers where really excited with doing more and more stuff
with extremely limited resources. In that context, being able to use
less memory and instructions on a debugger was a great design choice since
now they would be able to debug bigger programs.

Today the context is considerably different, I still think efficiency is
very important, since you literally pay for resources, but it is not on the
same scale of being unable to debug something because the debugger used too
much resources and you end up without the hability to debug it. Even on embedded
systems this is more and more rare. Efficiency is something that should also
be considered on good design, but to be honest keeping the pace of changes
still triumphs that.

Well, but not is never that simple with software. Since software development
is a inherently social activity, the pace of change should also take that into
account when being evaluated.

You can have a mess of a code that is maintained just by one person. To that
one person that code makes totally sense, but to other people it will be
nearly impossible to understand it. This is a real problem since lone ranger
development is really rare these days.

The same fenomemon can happen to an entire team, it is usually to a team to
be synchronized, but if everyone is very synchronized on the same bad ideas
there is a good chance that terrible design will emerge and people will be
able to cope with it and make changes considerably fast.

These bad designs that are moving fast could only be considered good
in a context where project owners and developers never changes. If this is
you case you are welcomed to judge it as good design.

But, there is another dimension to analyze, that even when people is
going considerably fast, bad design gets bigger and bigger like a snowball,
and even the writers of the code will stop making sense of it. The dimension
to analyze is time. It is much easier to develop software thinking on only now,
it is orders of magnitude harder to develop it on a way that can resist time.


// CONCLUSION
Good design is universally understandable (check out art can be good essay)

Dijkstra also talks about this as the concept of "intelectually manageable"

http://www.cs.utexas.edu/users/EWD/transcriptions/EWD03xx/EWD340.html

It is about communication and human cognition, realizing how small our
skulls actually are :-).

// TODO: IMPLICATIONS OF DESIGN DECISIONS AND SPEED OF CHANGE AND FEELINGS
// WITH THE "WHAT I WANT IS NOT WHAT I NEED" PROBLEM.
// https://www.youtube.com/watch?v=N9c7_8Gp7gI


# Catalysing Change

# SOLID

# Four rules of simple design

# Isolate hard design decisions

# Symmetric

# Uniform

# Orthogonal

# Make it seem simple
