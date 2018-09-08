+++
author = "Tiago Katcipis"
categories = ["Python"]
date = "2018-09-08"
description = "Python 3, UTF-8 and Locale"
featured = "todo.jpg"
featuredalt = ""
featuredpath = "img"
linktitle = "Python 3, UTF-8 and Locale"
title = "Python 3, UTF-8 and Locale"
type = "post"

+++

# Python 3, UTF-8 and Locale

This post will explore a problem that I had with Python 3 and UTF-8
strings that caught me by surprise and has the objective of helping
other people to don't be caught on the same trap.

It is not intended to be a rant against Python, but to be honest the
problem and the behavior did not make me too happy about it. Perhaps
it was my failure in finding the proper documentation about it, but
for people as stupid as I am it may help.

OK enough of teasing, it is clear that this post is about a problem,
what exactly is the problem ?

# Can't print my string

Yeah, the problem is that stupid, I was not able to print a string.
Of course every simple problem starts as something that seems
pretty complicated and in this case it is not diferent. I was
working with code that integrated a C++ binding and websockets.

The websocket part was responsible for doing speech to text
(using Azure Bing Speech to Text service) and
was developed using asyncio, it is heavily based (to not say copied =P)
from [here](https://github.com/jjuraska/cruzhacks2018).

I was all happy getting results when then I got this wonderful surprise:

```
Task exception was never retrieved
future: <Task finished coro=<SpeechClient.process_response() done, defined at /app/speech.py:222> exception=UnicodeEncodeError('ascii', 'X-RequestId:339e872cfcc64f6db6726fa1c7ba713c\r\nContent-Type:application/json; charset=utf-8\r\nPath:speech.hypothesis\r\n\r\n{"Text":"pre\xe7o","Offset":3900000,"Duration":6200000}', 130, 131, 'ordinal not
in range(128)')>
Traceback (most recent call last):
  File "/app/speech.py", line 245, in process_response
    response_dict = parse_body_json(response)
  File "/app/speech.py", line 363, in parse_body_json
    print(response)
UnicodeEncodeError: 'ascii' codec can't encode character '\xe7' in position 130: ordinal not in range(128)
```

I was working on the whole thing for some weeks already, I was almost done and now
all of sudden I was all like: **GODDAMMIT, STRING ENCODING PROBLEMS, MY LIFE IS OVER !!** .

I worked for years with Python 2 and my experience with this is that string encoding
problems have a great potential to make you waste a lot of good time (is the source code
that is not utf-8 ? is the string contents ? both ? is it a string or a unicode object ?).

With Python 3 I had the impression that it was all utf-8 by default (also strings are no
more just array of bytes, they are always unicode). With that I imagined
that the **print** function would also assume a default of being **utf-8**.

Well my code had a ton of dependencies including bindings to C++, so there was a good
chance that the problem could be pretty complex. As I descended on a spiral of dispair I
had a moment of clarity, these rare moments of clarity comes with years of wasting time chasing
ghosts, so at least this time I did the basic thing of testing a very simple code
sample before ghostbusting all over the place:

```
print("preço")
```

Yeah that is the code of the test. I was COMPLETELY sure it would work but I would test it
anyway. As it is usual in my life, I was wrong (this happens a lot with the TDD practice
of writing the test first and being sure that it will fail, sometimes it doesn't =P).

Actually, thanks to Python I was half right =P. A quick test is my host worked, but the code
itself was being run using docker containers since the dependencies where really nasty to
install (remember the bindings ? SWIG stuff, etc, not fun to install in your local host).

So the next logic step was to try the very idiotic code inside the container, I got this:

```
>>> print("preço")
  File "<stdin>", line 0

    ^
SyntaxError: 'ascii' codec can't decode byte 0xc3 in position 10: ordinal not in range(128)
```

To reproduce all code samples from now on run:

```
docker run -ti ubuntu:18.04
```

Once inside the container run:

```
apt-get update && apt-get install python3
```

Now you are skeptical about the problem, you can check it out on your own.

The full repl:

```
root@4cfd45c6bb22:/# python3
Python 3.6.5 (default, Apr  1 2018, 05:46:30)
[GCC 7.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> print("preço")
  File "<stdin>", line 0

    ^
SyntaxError: 'ascii' codec can't decode byte 0xc3 in position 10: ordinal not in range(128)
>>>
```

I was completely sure that this would work. The good news is that now I have the simplest
code to reproduce a problem ever know to humankind, the bad news is that this is so very
basic that I got a little confused with what was going on, specially because on my host
(and in every other hosts that I have worked with) this always worked for Python 3.

I started stack-overflowing around and found some useful hints, but almost all the problems
that I found where related to the source code not being utf-8 or Python 2. In one of the comments
I found this snippet:

```
import sys
print(sys.getdefaultencoding())
```

OK, lets try it inside my container
