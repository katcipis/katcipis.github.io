---
published: false
title: Drivers for good design
layout: post
---

# Why care ?

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

The good design payed off (that is the **only** reason we can say it is actually good).
Of course it is not that simple, this is wildly oversimplified, but it helps
me to see the tradeoffs and even seeing the important paper that the future has on your code.

The more convinced you are that a lot of change will take place on your code, the more concerned
you have to be on how it will accommodate this change. If you are sure that no one is never going
to change the code or even see it, design does not matter at all (although I don't think such
software exists :-), prototypes would be an instance of this when people don't decide to
toss then on production later).

Another thing to bear in mind is that on each cycle of change your software suffers the impact
of bad design is cumulative, this is what some people refers as software entropy. If no real thought is
given to a piece of software that is changed every week chances are that you are going to end
up with software that can't be changed at all.


## Learning and Ego

This is the reason as a developer that I relate more and this is the one that explains the
gigantic refactorings, the months without delivering features, excessive attention to hacking great
code while you completely forget about the client. Excessive attention to how the ride is cool
and forgetting where you where trying to go, just drive and feel the wind on the hair :-).

Not being aware of human nature or how someone achieves great performance may make this reason
as superfluous, like something that must be corrected, damn developers and their egos.
Reading the [Talent is overrated](https://www.amazon.com/Talent-Overrated-Separates-World-Class-Performers/dp/1591842948)
book helped me get some new insights about this and what motivates people do amazing stuff.

As the title makes clear, the book advocates deliberate practice to achieve high performance
instead of just being born with some innate talent, and it makes a pretty good case in favor
of this idea. Deliberate practice is very intense and hard, it usually involves you
giving up time for personal relationships, family, etc. The difficulty on achieving this
performance explains why it is so rare. But what would motivate someone to do that ?

There is no single reason, but the weakest one is money. When you achieve high performance, money will
follow, but that was never the point anyway. I'm not saying that there is no people driven by that,
but honestly the more amazing ones certainly are not. It's not that they don't care or don't like money,
it is just not the main driver for all the effort required to be great.

One of the main drivers usually is the sense of mastery, the desire to be really great and unique
on your field. To build a great mental model on the domain of your work and have great insights.
This starts as seeing other people exhibiting that. They just seem to see everything different.
When you talk to them, you learn a lot. When you read their code, you learn a lot.
They just does not seem to be like an average human, its awesome to be near them.

Most people when in contact with that, just thinks, "ehh they have some special innate ability", the
ones that start the journey to mastery are the ones that says "to hell with that, I want that too".
The book talks a lot about intrinsic and extrinsic motivations, there is also extrinsic motivators for
performance, but usually the great part is intrinsic and on software developers the most common
intrinsic motivator that I see is developing code that will teach something to other people.
The feeling of "I hacked the shit out of this hard problem".

They want to develop solutions that will leave people impressed on how simple it can be, on how
it elegantly solves a very complex problem. Actually this is another hallmark of great design,
it makes a very complex problem seem stupid, after someone seeing the solution it seems obvious,
but coming up with it is definitely not.

This mindset requires you forgetting sometimes about your client, you have to spend time with the
problem, think on it, try stuff, even absurd ideas.

Thinking about design only as a economic factor will hinder this, and since it is a strong
motivator for great performance, or people striving to get there, it is not wise to only
think about value and clients.

To support this there is the idea of allocating some time to let developers just work
on something they think it is interesting, this supports this idea that developers value
more this kind of freedom and ability to experiment and grow in knowledge than money or
even positive feedback from clients.

If you invest part of the time of your company on that you can only win. The worst case
scenario you are motivating people to be great and talk and try new ideas. On the best case
some new product may come out of it. The worst scenario possibility is what enables
creativity, there is no pressure, on that time you can only focus on experiment on something
new, no result required, just try to think different and see what comes from it.

This is the basis of deliberate practice. You need to try different stuff, that takes you
out of the comfort zone, and then have feedback if it improved your performance or not.
Doing this continually is what will lead someone to greatness, and sometimes design is just
about that, people trying to improve on what they already know, getting out from the comfort zone.

This does not means that great developers does not care if people are going to use their
software. The ones completely disconnected from people and reality usually do not produce
great stuff either. But the balance is more to the ego and hacking great programs than
necessarily a huge amount of clients and money.

This is why it is good to have on a team people with different mindsets to even things out.
