# The RESTless struggle for RESTfullness

This post will be about my history trying to understand
REST and RESTfullness (whatever that is, spoiler alert, I'm
not going to define what it is), what worked for me and
what sidetracked me.

As I evolve my ideas over time do not confuse that with
me being sure of anything, I'm still not sure of shit
until now, the only thing I'm sure is that going back
is not a good idea, but where would be forward is another
history.

I decided to write this because I think it is a very important
topic (duh, obviously or I would be an idiot for wasting time no ? =P).
Not REST of RESTfull, but defining good API's on a distributed system.
Having good abstractions and a good environment are essencial to
build a truly scalable distributed system. Not only scalable on
the sense of supporting millions of users, but cognitively scalable,
a system that very limited humans beings can understand. An example
of this idea can be found on
[Dijkstra's The Humble Programmer](https://www.cs.utexas.edu/~EWD/transcriptions/EWD03xx/EWD340.html)
where he uses the term "intellectual manageability".

For me this is one of the holy grails of computing,
a great deal of our pain is caused by our feeble brains
and it difficulty on handling details. And to help ourselves
people that are usually attracted to computing do not have a
lot of skills with human psychology and cognition,
they like computers and math (nothing wrong with that),
but the problem is related to human cognition, that is the bottleneck
on most systems not the computers (of course sometimes it is the computers,
but on the industry the bottleneck is people by far).

Why talk about cognition before talking about REST ? Well it is another
spoiler alert, but REST is an architecture for a system with massive scalability
(the internet), almost all companies that you will work will not work on that
scale, the closes you would get would be Google. So there is a great deal
of chance that when you are contemplating REST you are not thinking about
scaling to billions of requests but thinking on how to make your
system easy to understand, to make intentions clear.

But enough with spoilers and start with ancient history.

# On the beginning there was REST

OK it is not that ancient, the year is 2008 and I had the
opportunity to take an internship on an awesome company.
Since I don't seem to run out of luck in life, I had the opportunity
to work with a lot of new projects, developing from scratch, defining
protocols, etc. Of course I was not doing it alone, I was just the curious
talkative intern, there where much wiser people guiding me.

Some of the projects where restricted to internal proprietary protocols,
others where using RTMP (thank God that is over), but we faced some opportunity
to do what all the other cool kids where doing, shiny new REST API's.
At that time it as so well established that WS-\* stuff and SOAP where pure
evil that I didn't even bother to look that up too much and delve directly
on REST and its blazing glory.

When you have no idea what you are doing because something is new
to you the first instinct is too come up with a set of rules to
avoid stupid mistakes and to avoid handling with context that
you can't understand yet, this fits with the
[Dreyfus Model Of Skill Acquisition](https://en.wikipedia.org/wiki/Dreyfus_model_of_skill_acquisition).

Searching for guidance on this aspect we found several guidelines
that helped us build our own. At this stage there was just
some web searching. The guidelines where sound, that usual stuff
of handling collections of stuff and individual stuff on a
hierarchical way using URL's, the traditional dogs example:

Getting all dogs:

```
GET
/myapi/dogs
```

Getting individual dog:

```
GET
/myapi/dogs/someid
```

Using verbs on URL names mean you got everything wrong and was a bad bad
developer, you where not thinking on the RESTFull way and should feel
bad about yourself. There was a **LOT** of focus on the CRUD thing too,
on how the HTTP methods should be used correctly. Not that these are
bad ideas, it is a good idea to have a uniform system where the intentions
are clear. No one wants to use the **DELETE** method to get some data, etc.
But I started to get frustrated on how almost all material that I was reading
focused way too much on URL's naming and HTTP verbs.

They always explain the collection of resources thing, and them how to related
resources, like the dog has an owner, how to express that ? Again, not that it
is a bad idea to think on how to properly handle this kind of relationship, but to
be honest it was not one of my biggest problems at the time. Actually if
you squint you will see that discussing this is the same as discussing how
to organize data on a database.

Since URL's are hierarchical you will have similar problems to when you
represent sets of information (or resources) that have relationships between
them using a document oriented database (hierarchical). You will need to think
if you always send the resource with its related resources embedded, or return
links, there will be tradeoff's with each approach, etc. There is a good space
for discussion on this area, and it is good discussion, depending on the
kind of system you are developing different sets of tradeoff's must be made.

But even though this is an interesting space of discussion I was growing
frustrated. Why ? Well because I was not developing a database with a REST API.
It was not just a set of static data, or static data with relationships between
it. I was still all alone on how to model processes.

Now things get interesting. At least for me, you must be already dozing off =P.

# Who ate my process ?

On the land of substantives and resources there seems to have little
space for processes, they tend to be verbs since they do stuff with
your data to produce some other data, or just change the state
of a system (OMG state ? but isn't REST stateless ? it took me some
time to understand that, but it is basically because I'm stupid, and
very little material makes this really clear too).

I felt stuck on discussions on how to use status codes and which
HTTP methods to use. Again, not that this is necessarily bad, but
it crossed the point of being useful and started to feel like
bike shedding, specially when compared with the tremendous difficulty
that I was feeling on how to actually solve a problem being "RESTFull".
I was very used to solve problems with data + algorithms and it seemed
that I was being presented only with the data part of the idea + the
bike shedding on how to properly use methods and status codes. It is
important to do CRUD stuff consistently, but to be honest it is boring
as hell discussing CRUD stuff.

I remember something like linkedin using 9XX status codes, twitter using
only POST and GET and no other methods and some sacred quest for the
true RESTFull way to do stuff (create your own status codes ?
use all methods ?).

One example that I remember vaguely (bad memory + 8 years) is how to
model on a REST API transferring a call on a PBX API. I do not even
remember how we solved, I just remember that I was frustrated, specially
because all that talk about methods and substantives was not helping me
at all on how to design it properly.

In the midst of this suffering a friend of mine recommended the
[REST in Practice](http://www.amazon.com/gp/product/0596805829) which helped
me a lot to understand something that seemed much more interesting than
the CRUD stuff.

# State Machines Everywhere

TODO:

HATEOAS


# RESTing from REST

Perhaps, in the end, this is just the normal process of learning something.
Or I'm just stupid. But things started to go sideways for me when I stopped
to think on the problem that I was solving and started thinking on how
to be RESTFull. When the problem did not fitted my poor model of what is
RESTFull (whatever that actually is) I was kinda depressed, felt shame about
my API, lost a lot of time trying to make it RESTFull and even made it
worse for the sake of being RESTFull.
