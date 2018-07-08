# The RESTless struggle for RESTfullness

This post will be about my history trying to understand
REST and RESTfullness (whatever that is, spoiler alert, I'm
not going to define what it is), what worked for me and
what sidetracked me.

As I evolve my ideas do not confuse that with
me being sure of anything, I'm still not sure of shit
until now, the only thing I'm sure is that repeating
the same mistakes is not a good idea,
but how to make new ones is another history.

I decided to write this because I think it is a very important
topic (duh, obviously or I would be an idiot for wasting time no ? =P).

Having good abstractions and a good environment are essential to
build a truly scalable distributed system. Not only scalable on
the sense of supporting millions of users, but cognitively scalable,
a system that very limited humans beings can understand. An example
of this idea can be found on
[Dijkstra's The Humble Programmer](https://www.cs.utexas.edu/~EWD/transcriptions/EWD03xx/EWD340.html)
where he uses the term "intellectual manageability".

For me this is one of the holy grails of computing,
a great deal of our pain is caused by our feeble brains
and its difficulty on handling details. And to make things worse,
people that are usually attracted to computing do not have a
lot of skills with human psychology and cognition.
They like computers and math (nothing wrong with that),
but the problem is related to human cognition, that is the bottleneck
on most systems, not the computers. Of course sometimes it is the computers,
but on the industry the bottleneck is people by far.

Why talk about cognition before talking about REST ? Well it is another
spoiler alert, but REST is an architecture for a system with massive scalability
(the internet). Almost every company out there will not work on that
scale. The closest you will find will be Google. So there is a great deal
of chance that when you are contemplating REST you are not thinking about
scaling to billions of requests but thinking on how to make your
system easy to understand, to make intentions clear.

But you don't have to believe me, here is a quote from
[Architectural Styles and the Design of Network-based Software Architectures](https://www.ics.uci.edu/%7Efielding/pubs/dissertation/top.htm):

```
A good architecture is not created in a vacuum. All design decisions at the
architectural level should be made within the context of the functional,
behavioral, and social requirements of the system being designed, which is a 
principle that applies equally to both software architecture and the traditional
field of building architecture.
```
Of course I could be wrong, but it seems that "social requirements" of the system
involves people that are going to use the system and the ones that are going to develop
it too, and since it is a social aspect it involves our cognition.

But enough with spoilers and start with ancient history.

# On the beginning there was REST

OK it is not that ancient, the year is 2008 and I had the
opportunity to take an internship on an awesome company.
Since I don't seem to run out of luck in life, I had the opportunity
to work with a lot of new projects, developing from scratch, defining
protocols, etc. Of course I was not doing it alone, I was just the curious
talkative intern, there were much wiser people guiding me.

Some of the projects were restricted to internal proprietary protocols,
others were using RTMP (thank God that is over), but we faced some opportunity
to do what all the other cool kids where doing, shiny new REST API's.
At that time it was so well established that WS-\* stuff and SOAP were pure
evil that I didn't even bother to look that up too much and delve directly
on REST and its blazing glory.

When you have no idea what you are doing because something is new
to you the first instinct is too come up with a set of rules to
avoid stupid mistakes and to avoid handling with context that
you can't understand yet, this fits with the
[Dreyfus Model Of Skill Acquisition](https://en.wikipedia.org/wiki/Dreyfus_model_of_skill_acquisition).

Searching for guidance on this aspect we found several guidelines
that helped us build our own. At this stage there was just
some web searching. The guidelines were sound, that usual stuff
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
developer, you where not thinking on the RESTful way and should feel
bad about yourself. There was a **LOT** of focus on the CRUD thing too,
on how the HTTP methods should be used correctly. Not that these are
bad ideas, it is a good idea to have a uniform system where the intentions
are clear. No one wants to use the **DELETE** method to get some data, etc.
But I started to get frustrated on how almost all material that I was reading
focused way too much on URL's naming and HTTP verbs.

They always explain the collection of resources thing, and them how to relate
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

A great article that helped me understand the solution space better is
[A Relational Model of Data for Large Shared Data Banks](https://www.seas.upenn.edu/~zives/03f/cis550/codd.pdf).

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
that I was feeling on how to actually solve a problem being "RESTful".

I was very used to solve problems with data + algorithms and it seemed
that I was being presented only with the data part of the idea + the
bike shedding on how to properly use methods and status codes. It is
important to do CRUD stuff consistently, but to be honest it is boring
as hell to discuss CRUD stuff.

I remember something like linkedin using 9XX status codes, twitter using
only POST and GET and no other methods and some sacred quest for the
true RESTful way to do stuff (create your own status codes ?
use all methods ?).

One example that I remember vaguely (bad memory + 8 years) is how to
model on a REST API the transfer of a call on a PBX API. I do not even
remember how we solved, I just remember that I was frustrated, specially
because all that talk about methods and substantives was not helping me
at all on how to design it properly.

In the midst of this suffering a friend of mine recommended the
[REST in Practice](http://www.amazon.com/gp/product/0596805829) which helped
me a lot to understand something that seemed much more interesting than
the CRUD stuff.

# State Machines Everywhere

As I read the book it explained much better the
[Richardson Maturity Model](https://martinfowler.com/articles/richardsonMaturityModel.html).
Specially because it did that with much more detail and explaining it
like a series of trade-offs instead of a quest for glory.

The Richardson Maturity Model already starts to give a hint on what is
wrong with most talks about REST, the maturity part will make you feel
immature when your problem do not fit the abstraction. RPC for example
is portraited as a swamp, perhaps it is if you use HTTP to transport it
and use XML, but when you are young it is pretty hard to understand
the difference and it is pretty easy to develop the notion that RPC is bad
(specially with some bad implementations of RPC and remote objects).

Perhaps the notion of maturity is intended to be used inside a REST API,
but most people that advocate RESTfulness takes it as a maturity of any API
(and no one wants to have an immature API).

When you start to grown up you start to see that there are no demons,
so RPC is not a demon and REST is not the glorious light that will
vanquish it, but more on that later, lets focus on the REST learning
(have I mentioned how I'm slow to learn ?).

Anyway, I was finally getting the idea behind [HATEOAS](https://en.wikipedia.org/wiki/HATEOAS)
(which is also known as the worse acronym ever created) and was excited
because for the first time there was something on all the REST talk
that was actually useful.

OK I'm exaggerating, it is not that the CRUD and status code talk does
not have some usefulness, but compared to the idea of designing cool
state machines that helps enforce decoupling of clients and servers is
so exciting that it got me frustrated how people talk so little about this.
Actually usually there is not talk at all about this aspect of REST.

An example of that was the tooling for writing docs ate the time (CIRCA 2010-2011),
they where pretty beautiful (like swagger) but they had 0 support to the
idea of designing a state machine with links driving the next possible states.
That frustrated the hell out of me (of course it may be that I'm lousy at looking stuff
on the internet,perhaps there was something, but I didn't found it).

The best that I found as inspiration was the
[JSON HAL](http://stateless.co/hal_specification.html) specification that I used
as a inspiration for an API that I was developing at the time.

Inspiration because I did not used it. It was simply too much for an API that
was going to be used internally by less than a hundred clients, a lot of it
seems focused on internet scale stuff and I was not building
internet scale stuff.

But the idea of expressing the state machine in-band on the protocol
of the API is applicable on any scale. The alternative would be to
document a series of URL templates (creates more coupling) and document
in which states some of the URL's would be available and when it was not.

Using the HATEOAS idea I was able to decouple clients from internal details
on how resources are organized on the service and also from details of
which states some interactions where possible or not, the protocol embedded
that on the answers. This does not solve all problems on earth, but it was
the first time that I was actually feeling good about this
REST stuff, life was good (who doesn't like opaque stuff ?
opaque URL's rlz !).

After some time I even started to feel stupid on how I did not get
the HATEOAS idea before. What is great about navigating in the internet
is the fact that you do not need to know anything about the site you
are visiting, only the initial entry point. After that you can understand
what you can do (the docs, on sites usually text intended to humans =P)
and have links that you can click to express your desire to change state
(or not if you just want to load a different resource). The name REST
has State Transfer on it, how can we give so little attention to that
and focus on representing collections of stuff ? The theory behind the
[bike shedding phenomenon](https://en.wiktionary.org/wiki/bikeshedding)
is that because it is easier and it is easy
to discuss easy stuff (easy does not mean unimportant, but it means
not spending almost all your time just on that).

But the eternal bike shedding on REST methods was not over yet.
And there was still the pain of ostracizing verbs, an URL is a
Uniform Resource Location, RESOURCE, so it can't be a verb...
fuck you and your API if it is a verb.

# What the hell is a resource ?

The path that took me to a better understanding (or less crappy, at
least for me) involves not just resources, but also the dispute
on HTTP methods. More exactly the PUT method (also the PATCH one).

For me trying to handle everything JUST with HTTP methods seemed
again like working just with databases, the API felt anemic, like
I have so little logic that just changing fields on JSON documents
is enough to solve all my problems.

One post that introduced me to some interesting ideas was the
[REST API Design - Resource Modeling](https://www.thoughtworks.com/insights/blog/rest-api-design-resource-modeling).
As far as I got it, it introduced the idea that everything that
can be turned on a resource if this makes sense to be done
on the domain of the problem that you are solving. It also
shared my view that thinking only on CRUD generate an anemic API,
if the API is anemic the client needs to get fattier:

```
Essentially, the low level CRUD oriented approach puts the business
logic in the client code creating tight coupling between the client
(API consumer) and services (API) it shouldn't care about,
and it loses the user intent by decomposing it in the client.

Anytime the business logic changes,
all your API consumers have to change the code and redeploy the system.
```

And it introduces an example of creating a resource to model something
that is actually a process (see the "Nouns versus Verbs" part).

This does seem at first as a way to introduce hacks instead of
good design (specially if you are feeling RESTy), but almost all
good ideas can be used as crappy hacks.
Also the anemic feeling on APIs start to dissipate when you
open yourself to this idea, so I embraced it.

Later I encountered the concept of [reification](https://en.wikipedia.org/wiki/Reification),
I was doing it for some time since it is what we do when we are programming,
but I didn't have a name for it and never stopped to think on it
as a valid design goal on a system.

For example, compilers use this idea to make it easier to be ported to
multiple platforms. What would be the reification ? The intermediary code.
It is treated and tested on the compiler as real code, it is a valid
testable product of the compilation process, but it does not exist, there
is no machine on the world that can run it, it is a pure design creation
made to make the system easier to port and test.

So it can be your passport to an horrible API or to wonderful abstractions
and a more testable API (I first heard about this for testing on this
[great podcast](http://www.se-radio.net/2010/09/episode-167-the-history-of-junit-and-the-future-of-testing-with-kent-beck/)
where Kent Beck talks about testing).

# But what about the methods ?

OK I got all excited with the state transfer thing and totally forgot
that not being uniform on how you use a set of operations (methods) can
be really hurtful to a distributed system.

On a system where there are IDL's (Interface Description Languages)
you usually don't have this problem
since each interface has its own set of operations that is documented,
there is less restrictions (also more space to inconsistencies in naming
and other things, trade-offs, no free lunch, etc).

So REST and its more known implementation on top of HTTP has a fixed
set of methods with a specific semantic for each one.

Before going deeper on the semantics of the methods, you must ask yourself,
why it is so important to use the correct semantic of each method ?

The first that always came to my mind is that consistency makes your API
easier to understand, you can use intuition to infer how to do stuff instead
of always reading docs. Being able to use intuition to do something on an API
is a sign of a great API to me. But when we are thinking about distributed
systems there are other important things to consider.

The most important one, that always bites us in the ass, is side effects.
Our inability to properly handle side effects is what makes functional
programming so attractive, we suck at it.

So how does HTTP specifies state changes ? Lets take a look on the
[spec](https://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html):

```
In particular, the convention has been established that the GET and HEAD
methods SHOULD NOT have the significance of taking an action
other than retrieval.

These methods ought to be considered "safe". This allows user agents
to represent other methods, such as POST, PUT and DELETE, in a special way,
so that the user is made aware of the fact that a possibly unsafe
action is being requested.

Naturally, it is not possible to ensure that the server does not
generate side-effects as a result of performing a GET request; in fact,
some dynamic resources consider that a feature. The important distinction
here is that the user did not request the side-effects,
so therefore cannot be held accountable for them.
```

The advantage of being explicit about state changes is a more obvious one.
If the system is built properly and some code is only performing GET's you
can be sure that it is not the culprit for some state change (it also has
applications on caching, which is pretty important to scale in some contexts).

There are more subtle ones, like idempotent methods:

```
Methods can also have the property of "idempotence" in that
(aside from error or expiration issues) the side-effects of
N > 0 identical requests is the same as for a single request.

The methods GET, HEAD, PUT and DELETE share this property.
Also, the methods OPTIONS and TRACE SHOULD NOT have side effects,
and so are inherently idempotent.

However, it is possible that a sequence of several requests
is non- idempotent, even if all of the methods executed in
that sequence are idempotent. (A sequence is idempotent if
a single execution of the entire sequence always yields a
result that is not changed by a reexecution of all,
or part, of that sequence.) For example,
a sequence is non-idempotent if its result depends on a
value that is later modified in the same sequence.

A sequence that never has side effects is idempotent,
by definition (provided that no concurrent operations
are being executed on the same set of resources).
```

If you never heard about idempotent methods this can be a little hard
to digest, and can also generate a feeling of "why should I care ?".

In a distributed system making idempotent operations explicit is
important for failure recovery. If an operation is idempotent
and its answer timeouts (perhaps a node went down, who knows ?)
you can safely retransmit it, if the previous one was actually
executed this will generate no problem's at all since the operation
is idempotent. If this does not seem that important to you yet
checkout this
[awesome post on cockroachdb passing the jepsen test](https://www.cockroachlabs.com/blog/cockroachdb-beta-passes-jepsen-testing/).

Quoting:

```
The sets test (described in section 2.7) revealed a bug
when it was refactored to use a single auto-committed INSERT
statement instead of a multi-statement BEGIN/INSERT/COMMIT transaction
(using a table with no primary key).

Single statements can be retried by the server after certain
errors (multi-statement transactions generally cannot,
because the results of previous statements have already been
returned to the client).

In this case, the statement was attempted once, timed
out due to a network failure, then retried,
and both attempts eventually succeeded
(this was possible because the table had an
auto-generated primary key, so the two insertion
attempts were not using the same PK values).
```

Distributed systems are hard, being sure of what can be retried and what
can't is essential. So right now we have 3 categories of operations:

* Side Effect Free
* Idempotent (with side effects)
* Non-Idempotent  (with side effects)

To give a more simple example, deleting a resource using the **DELETE**
method is safe for retransmission since deleting something twice
ends up on the same final state, that thing has been deleted.

It is important to not mix leaving the system at the same state
and giving the same answer. The first delete will return OK and the second
one will fail, the operation is still idempotent because the final state
of the system is the same (the resource has been deleted).

Another interesting property of operations is commutativity, since they
enable parallelization, but AFAIK there is nothing on REST about that.

We saw some examples of side effects free operations and idempotent ones,
this leaves us with the non-idempotent one, the beloved **POST** method.

What should be the semantics of **POST** ? This is one of the biggest
sources of bike shedding on RESTfulness because of the addiction
to creating resources, that does not map well with some sorts of processes
(yeah, REST can not map well to stuff,
it is real, it happens, more on that later).

An example from a RESTful guideline:

```
POST requests are idiomatically used to create
single resources on a collection resource endpoint,
```

Which leads to:

```
POST request should only be applied to collection resources,
and normally not on single resource, as this has an undefined semantic
```

Undefined semantic ? Creating resources ? OK lets take a look at the
[spec](https://tools.ietf.org/html/rfc2616#section-9), this time I will
copy the entire method specification, because this is important.

```
9.5 POST

   The POST method is used to request that the origin server accept the
   entity enclosed in the request as a new subordinate of the resource
   identified by the Request-URI in the Request-Line. POST is designed
   to allow a uniform method to cover the following functions:

      - Annotation of existing resources;

      - Posting a message to a bulletin board, newsgroup, mailing list,
        or similar group of articles;

      - Providing a block of data, such as the result of submitting a
        form, to a data-handling process;

      - Extending a database through an append operation.

   The actual function performed by the POST method is determined by the
   server and is usually dependent on the Request-URI. The posted entity
   is subordinate to that URI in the same way that a file is subordinate
   to a directory containing it, a news article is subordinate to a
   newsgroup to which it is posted, or a record is subordinate to a
   database.

   The action performed by the POST method might not result in a
   resource that can be identified by a URI. In this case, either 200
   (OK) or 204 (No Content) is the appropriate response status,
   depending on whether or not the response includes an entity that
   describes the result.

   If a resource has been created on the origin server, the response
   SHOULD be 201 (Created) and contain an entity which describes the
   status of the request and refers to the new resource, and a Location
   header (see section 14.30).

   Responses to this method are not cacheable, unless the response
   includes appropriate Cache-Control or Expires header fields. However,
   the 303 (See Other) response can be used to direct the user agent to
   retrieve a cacheable resource.

   POST requests MUST obey the message transmission requirements set out
   in section 8.2.

   See section 15.1.3 for security considerations.
```

Focus on:

```
   The actual function performed by the POST method is determined by the
   server and is usually dependent on the Request-URI.
```

And:

```
   If a resource has been created on the origin server, the response
   SHOULD be 201 (Created) and contain an entity which describes the
   status of the request and refers to the new resource, and a Location
   header (see section 14.30).
```

So no, there is nothing undefined and wrong with a *POST* method
that does not create a new resource, it MAY create resources but there
are a lot of examples on the spec itself where they simply do not.

The important thing to convey by using a *POST* method to a URL is that
side effects will be produced by the request and that is it. There is
nothing wrong, or hacky, on modelling a process as a resource and
using a POST method for it to do its job when the process will
result on state changes on the system but will produce no resources
at all.

On this case I got strong feelings of **guidelines considered harmful**.
If people do not actually study the specs and just
follow these context sensitive derivatives they are prone to feel
bad for doing something that is perfectly fine, or worse, be busted by
the RESTful police:

![vegan police](img/veganpolice.gif)

Which may result on turning the API on a monster trying to
fit it on a misconception of what would be "RESTFul" (which usually
resembles a hierarchical database or a local file system).

# RESTful strikes back

There was I living my life, doing some crappy API's but not feeling
bad about it, people where using it and they worked. Since not a lot
of people asked question about how to use I suppose it was not that
hard although they would not be "RESTful" since sometimes POST
was used not to create stuff and I used to model processes (verbs)
on URL's where appropriate.

There was CRUD too, no problem with that, when it fits. If you do have
collections of stuff and it is pretty clear how you add new ones to
the collection and remove them, go for it, it is great too.

Then, on a cloudy day on a meeting there was some discussion on
being RESTful and a lot of old feelings resurfaced.

What the fuck is REST anyway ? Sorry for the fuck part, but if
what is REST or RESTful is subjective, then discussing it is
pointless, it can be anything you want, even something that
will impair your capacity to think and build API's that
fit well to your problem.

I was on a phase on my life where it has started to be obvious
that the best way to solve these things is to go directly at
the source. Specially since people like to be religious with
this stuff, having access to the source of their beliefs gives
you a lot of power. So I started reading the
[Architectural Styles and the Design of Network-based Software Architectures](https://www.ics.uci.edu/~fielding/pubs/dissertation/top.htm)
dissertation. AFAIK is the origin of the acronym REST.

Since I was a little biased against RESTful stuff I was surprised
at how awesome and different from everything you read about REST
the dissertation was.

The best part of it is the one that does not talk about REST, it actually
builds a framework on how to compare different architectural styles
to see which one fits better to your system. You can even create
your own architectural style by composing existing architectural
constraints, it was considerably enlightening to me and I highly
recommend the read to anyone on the business of developing
REST API's.

How to properly architecture software starts on the dedication
of the dissertation, it has an awesome quote from a book that
is focused on architecture but it is very appliable on software
architecture:

```
Almost everybody feels at peace with nature: listening to the
ocean waves against the shore, by a still lake, in a field of grass,
on a windblown heath.

One day, when we have learned the timeless way again,
we shall feel the same about our towns, and we shall feel as much at
peace in them, as we do today walking by the ocean, or stretched out in
the long grass of a meadow.

-- Christopher Alexander, The Timeless Way of Building (1979)
```

This quote is a source of inspiration on what software architecture should
be about. It is the problem that you are solving, the people that are
going to use that architecture everyday (will live inside of it).

Software has two audiences, other developers that have to evolve the
system and clients that just use the system. The definition of a successful
architecture is when both are extremely pleased, and being pleased comes
through simplicity, just like nature, it simply fits and feels good.

It is a social phenomenon, deeply influenced by human cognition. Because
what is easy to understand and feels confortable is related to cognition.

Of course that the architecture also has to support the problem being
solved, no one likes a building that is confortable but may collapse
on your head. That is why architecting is so hard, you have a lot
of variables that will push your design on different directions,
the decisions of the trade-offs will be your responsibility.

Uniformity is important, so discussing good practices and trying to
enforce uniformity may be good, but uniformity has trade-offs too, so
you need to know when to give it up, the dissertation is also very clear
on this.

The dissertation is pretty big, but totally worth it, I can't quote
everything I find interesting from it here because it would make
this post even bigger than already it is (if you are curious
you can see
[my notes here](https://github.com/katcipis/sophia/blob/master/notes/articles/fielding-dissertation-rest.md),
but you will be best served reading the dissertation).

I will focus just on things that can help you break free from
the tiranny of RESTFulness with a series of quotes from the
dissertation. Since it is the source of REST it should be
a reliable source of guidance (if you like REST at least).

What should guide design decisions on your architecture ?

```
A good architecture is not created in a vacuum. All design decisions at the
architectural level should be made within the context of the functional,
behavioral, and social requirements of the system being designed, which is a 
principle that applies equally to both software architecture and the traditional
field of building architecture.

The guideline that "form follows function" comes from hundreds of years of
experience with failed building projects, but is often ignored by software
practitioners.
```

Elaborating more on how usually function ends up following form, or the
desires of the architect he mentions a
[Monty Python sketch](https://www.youtube.com/watch?v=DyL5mAqFJds):

```
The funny bit within the Monty Python sketch, cited above, is the absurd
notion that an architect, when faced with the goal of designing an urban
block of flats (apartments), would present a building design with all the
components of a modern slaughterhouse.

It might very well be the best slaughterhouse design ever conceived,
but that would be of little comfort to the prospective tenants as they
are whisked along hallways containing rotating knives.
```

If I got a penny for each slaughterhouse I designed just because
I liked the idea and it seemed right to me to do it that way
(or because everyone else is doing slaughterhouses), I would
be rich by now.

And then the ultimate irony:

```
The hyperbole of The Architects Sketch may seem ridiculous,
but consider how often we see software projects begin with adoption of
the latest fad in architectural design, and only later discover whether or
not the system requirements call for such an architecture.

Design-by-buzzword is a common occurrence. At least some of this behavior
within the software industry is due to a lack of understanding of why a
given set of architectural constraints is useful. 
```

He just describes exactly what sadly happened to REST, instead
of being considered as another architectural style, among others,
with its own trade-offs, it has become the latest fad in architectural
design. Design-by-buzzword, there is no way to put it better. Need more
convincing ? Another pearl from the dissertation:

```
Some architectural styles are often portrayed as "silver bullet" solutions for
all forms of software. However, a good designer should select a style that
matches the needs of the particular problem being solved [119].

Choosing the right architectural style for a network-based application requires
an understanding of the problem domain [67] and thereby the communication
needs of the application, an awareness of the variety of architectural styles
and the particular concerns they address, and the ability to anticipate the
sensitivity of each interaction style to the characteristics of
network-based communication
```

Again...oh the irony =/. Want a good example of trade-offs made on REST ?

```
The trade-off, though, is that a uniform interface degrades efficiency,
since information is transferred in a standardized form rather than one
which is specific to an application's needs.

The REST interface is designed to be efficient for large-grain hypermedia
data transfer, optimizing for the common case of the Web, but resulting in
an interface that is not optimal for other forms of architectural interaction.
```

I said that we would come back to uniformity. It is great,
but it has trade-offs.  REST ideas are heavilly based on
large-grain data transfer, does this fit with
what you need ? What are others alternatives ?

Sadly this RESTful mindset seems to hinder the ability to discuss
alternatives to REST. I certainly stopped me from doing it for a
great time because I was too focused on perfecting REST to solve
everything. Ironic that was the REST dissertation that
helped me see my mistake.

# RESTing from REST

Perhaps, in the end, this is just the normal process of learning something.
Or I'm just stupid. But things started to go sideways for me when I stopped
thinking about the problem I was trying to solve and kept thinking about how to
be RESTful.

When the problem did not fit my model of what was
RESTful (whatever that actually is) I was kinda depressed, felt shame about
my API, lost a lot of time trying to make it RESTful and even made it
worse for the sake of being RESTful.

Another problem that I observe is how much time we spend discussing
REST and not studying other architectures for distributed systems.
The REST dissertations lays down a way to compare architectural styles
and provide incentives on thinking on your problem and defining your
own set of architectural constraints.

For the web the demand for standardization is much bigger than from
internal services to solve a smaller/different problem than the
web. On the dissertation one of the focus of REST and the design
of the web was massive anarchic scalability, there is a great
deal of focus on decoupling.

Any experienced developer knows that even decoupling has a price,
always understand the price you are paying and why, the web pays
it because it is the web, you are not the web.

There are systems that need to export API's
on the web, these are excellent cases for REST, or at least to use
an ubiquitous protocol as HTTP, you need to focus on integration
with third parties. But even those usually have inner systems that
are not exported to the web, they are great candidates to
focus on what solves the problem best, not standards.

In some sense this reminds me of discussions on using a lot
of different programming languages, you can create a mess if
you never master a language properly and develop each service
on a different one but you also lose a lot of insights and
growth if you got stuck always with the same one. Architectural
styles seems to be something like that to me, you don't need to
create a mess but standardizing everything does not seem to be a
good way to do things either.

What would be these different architectural styles ? One that I
recently have been studying is the one used on Plan9 and Inferno,
some good articles:

* [Plan9 from Bell Labs](http://doc.cat-v.org/plan_9/4th_edition/papers/9)
* [The Styx Architecture for Distributed Systems](http://doc.cat-v.org/inferno/4th_edition/styx)
* [The Organization of Networks in Plan 9](http://doc.cat-v.org/plan_9/4th_edition/papers/net/)
* [The use of namespaces in Plan 9](http://doc.cat-v.org/plan_9/4th_edition/papers/names)

In the end the idea is not that REST is bad, RESTFul is bad, guidelines
are bad. What is bad is to stop thinking about what you are doing and
to stop searching for different answer that may fit your problems better.
You can't do that if you believe that REST fits any kind of problem and
all API's should be done this way.

# Acknowlegements

Thanks for the following people for their help improving this text:

* [Iury Fukuda](https://github.com/iuryfukuda)
* [Manoel Vilela](https://github.com/ryukinix)
* [Tiago Natel](https://github.com/tiago4orion)
* [Vitor Arins](https://github.com/vitorarins)