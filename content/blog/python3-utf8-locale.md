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
problem and the behavior did not make me too happy about Python. Perhaps
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
more just array of bytes, they are [always unicode](https://docs.python.org/3/howto/unicode.html#the-string-type)).
With that I imagined that the **print** function would also assume a default of being **utf-8**.

Another important information is that this was happening inside a docker container using
the [ubuntu 18.04](https://hub.docker.com/_/ubuntu/) image, the main reason for using containers
was the fact that my code had a ton of dependencies including bindings to C++ (besides the obvious reason
that if you are not using containers you are not cool).

So giving the dependencies and the environment there was a good chance that the
problem could be pretty complex. As I descended on a spiral of dispair I
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
itself was being run using docker container.

So the next logic step was to try the very idiotic code inside the container, I got this:

```
>>> print("preço")
  File "<stdin>", line 0

    ^
SyntaxError: 'ascii' codec can't decode byte 0xc3 in position 10: ordinal not in range(128)
```

At this point I was all like...

![really](https://raw.githubusercontent.com/katcipis/memes/master/reallydog.jpg)

Once again wrong, but life goes on and I had a bug to fix.

![shrug](https://raw.githubusercontent.com/katcipis/memes/master/shrug.jpg)

To reproduce all code samples from now on run:

```
docker run -ti ubuntu:18.04
```

Once inside the container run:

```
apt-get update && apt-get install python3
```

The good news is that now I have the simplest
code to reproduce a problem ever know to humankind, the bad news is that this is so very
basic that I got a little confused with what was going on, specially because on my host
(and in every other hosts that I have worked with) this always worked for Python 3, I was like:

![wat](https://raw.githubusercontent.com/katcipis/memes/master/wat2.jpg)

I started stack-overflowing around and found some useful hints, but almost all the problems
that I found where related to the source code not being utf-8 or Python 2 (neither my case).
In one of the comments I found this snippet:

```
import sys
print(sys.getdefaultencoding())
```

OK, lets try it inside the container:

```
root@1124aa23a637:/# python3
Python 3.6.5 (default, Apr  1 2018, 05:46:30)
[GCC 7.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import sys
>>> print(sys.getdefaultencoding())
utf-8
>>> print("preço")
  File "<stdin>", line 0

    ^
SyntaxError: 'ascii' codec can't decode byte 0xc3 in position 10: ordinal not in range(128)
```

Again I was pretty sure that the default encoding would be ascii, but it is not, so
besides the intuitive option of checking the **DEFAULT ENCODING OF THE SYSTEM** there
was something else changing the behavior of the system. Other comments on stack overflow
mentioned some problems with lack of locale configuration, it was the next candidate.

# Locale

Lets checkout the locale configuration:

```
>>> import locale
>>> print(locale.getlocale())
(None, None)
```

Hmm, lets review the consistency of the behavior being shown:

* The default encoding for source code is utf-8
* The sys default encoding is also utf-8
* The default locale if none is configured is..duh...None
* print uses ascii =D

Yeah, even if this was well documented (perhaps I just missed something obvious on the docs)
it does not seems consistent at all. I would guess that this is probably consistent with
something else, which generates a theoretic consistency that makes someone happy about it
but in practice sux, or it is just a tradeoff and I'm on the end that pays for it not the
one that gains from it.

So now I could test this hypothesis by running inside the container:

```
apt-get install locales
```

And then:

```
root@1124aa23a637:/# locale-gen en_US.UTF-8
Generating locales (this might take a while)...
  en_US.UTF-8... done
Generation complete.
root@1124aa23a637:/# export LANG=en_US.UTF-8\342\213\205\342\213\205
root@1124aa23a637:/# export LANGUAGE=en_US:en
root@1124aa23a637:/# export LC_ALL=en_US.UTF-8\342
root@1124aa23a637:/# export LANG=en_US.UTF-8
root@1124aa23a637:/# export LC_ALL=en_US.UTF-8
root@1124aa23a637:/# python3
Python 3.6.5 (default, Apr  1 2018, 05:46:30)
[GCC 7.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import locale
>>> print(locale.getlocale())
('en_US', 'UTF-8')
>>> print("preço")
preço
>>>
```

Success, it was indeed the lack of locale configuration with the default choice of using ascii.
Now that I knew exactly what was going on it was easier to find some discussion about it,
like this [one](https://bugs.python.org/issue19846).

The issue mentions the **sys.getfilesystemencoding()** which seems to be the one that would
actually show ascii, lets take a look with a fresh container:

```
root@025b95a197f9:/# python3
Python 3.6.5 (default, Apr  1 2018, 05:46:30)
[GCC 7.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import sys
>>> print(sys.getfilesystemencoding())
ascii
```

And now everything makes sense, well at least the why it was trying to decode as an ascii
string instead of utf-8, but the decision to use ascii as a default still puzzles me.

Anything that comes from the operational system that is ascii would work perfectly fine
with utf-8 since they are compatible. One sort of problem is allowing a filename that is
utf-8 but the operational system doesn't support it, but then I fail to understand how this
is related to print itself, print is writing to os.stdout, why should I be constrained on what
I can write in files ? Having problems with system calls like open would make sense, limiting
what I can write in a file or which encoding I must use to do it does not.

But I'm pretty far from being an expert on the subject, actually this was the first time
that I had a problem like that. For example, reading [this](https://unix.stackexchange.com/questions/2089/what-charset-encoding-is-used-for-filenames-and-paths-on-linux)
it seems that Glib goes with utf-8 as default while QT uses the locale. But still I don't get it
because everyone is talking about filenames and paths but my problem was print to stdout
(which does not seem related to filenames and paths).

Anyway I hope this helps other people that go through a similar problem when using Python 3
with a container without locale configuration (which is the default ubuntu 18.04 image).

