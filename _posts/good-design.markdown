---
published: false
title: Good Design
layout: post
---

# SOLID

# Four rules of simple design

# Other interesting characteristics

## Symmetic

## Uniform

## Orthogonal


# Drivers for good design

Why the hell design must be good ? Just for the sake of it ? So the developer can
feel good about himself ? For now I can see clearly two main motivators,
one is economic and is the one managers like more, the other one is the one
developers usually like more and have to do with learning and ego.


## Reducing waste

The more I thought about good design it always looked like embracing change,
being ready to adapt to it. It is a common subject on extreme programing and
on cool ideas like the pragmatic programmer bend or break.

Almost all practice and idea listed here seems to improve your chances of
changing the software with success, with its a necessity to almost all
software since business are evolving faster and faster.

But one idea that sinked on my mind when I was reading Kent Beck's Extreme Programming
Explained book is the idea of removing waste. Removing waste is the only true way to go faster.

Of course it is a tradeoff. Good design is hard, that is why it is so rare :-). If it is hard,
it takes more time. Since it takes more time, instead of delivering a feature
this week you are actually wasting time, on the present good design is the waste.

But you are doing it to avoid unnecessary waste on the future, next time
you or someone else has to change the code to add new stuff. This even helps you to
think how much upfront design you are going to make. There is always upfront design, I never
saw a decent piece of software that people did not thought at least a little about what they are doing.

The problem with **big** upfront design is that it was trying to mitigate the future waste of years
with months of more waste, and in the end you end up with a huge pile of crap accumulated.

The nice spot is always wasting less time now than the time you would waste handling the code on the
future. This is directly tied to not trying to see too much in the future, just design to make
the intention of what you want now be clear and easy to change, and perhaps a few months upfront
(sometimes this is a good idea, but I prefer small windows of seeing in the future).

Here is where experience brings a great advantage, I can't even explain how code can handle only what it needs
right now but be flexible to future change, it seems that to be future proof it will need a lot of unnecessary stuff,
but the hallmark of great design is not having a lot of unnecessary stuff but when future hits it
the changes are minimal and things just fit. This is **VERY** hard and in my opinion only happens with years
of deliberate practice and a lot of mistakes.

In conclusion to the waste motivator, good design is when the sum of the time you spent on it and
the time that you gain when you have to change and extend it is less than it would be with
a bad design. Lets say we have two designs:

* GoodDesign, cost = 10
* BadDesign, cost = 5

Then happens the future, this will generate the tuples:

* (GoodDesign,Future), cost=10
* (BadDesign,Future), cost=20

Total cost now is:

* GoodDesign, cost=20
* BadDesign, cost=25

The good design payed off. Of course it is not that simple, this is oversimplified, but it helps
me to see the tradeoffs and even seeing the important paper that the future has on your code.
The more convinced you are that a lot of change will take place on your code, the more concerned
you have to be on how it will accommodate this change. If you are sure that no one is never going
to change the code or even see it, design does not matter at all (although I don't think such
software exists :-), prototypes would be an instance of this when people don't decide to
toss then on production later).

Another thing to bear in mind is that on each cycle of change your software suffers the impact
of bad design is cumulative, this is what some people refers as entropy. If no real thought is
given to a piece of software that is changed every week chances are that you are going to end
up with software that can't be changed at all.

