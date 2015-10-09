---
layout: post
title: Where are my python modules
---

When we are developing software, it doesn't matter which language, it is a best practice
to split the code in small pieces, it helps the legibility and
code organization. When working with C, for example, we create header (\*.h)
files and implementation files (\*.c). When working with python there are module files which
have extension `.py`. To load a module we use the `import` keyword.

<!-- more -->

A question often asked is how to find the location of my python modules.
For example this error message: **ImportError: No module named XXX**. Has it
ever happened to you? :D Here we will try to understand a little bit
more about this problem.

To start I will create a `pub` directory and add to it a module named `drink.py`.
As I'm living in England, to drink a pint is part of my culture now. \o/

```
$ mkdir pub
$ touch pub/drink.py
$ echo "print('give me a pint')" > pub/drink.py
```

Lets try to import the module `drink.py`.

```
$ python
Python 2.7.10 (default, Jul 14 2015, 19:46:27) 
[GCC 4.2.1 Compatible Apple LLVM 6.0 (clang-600.0.39)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> import drink
Traceback (most recent call last):
File "<stdin>", line 1, in <module>
ImportError: No module named drink
```

**ImportError: No module named drink**. The message is clear and tell us that
python doesn't know where our module is. Maybe you are thinking, go to `pub`
directory and run the interpreter from there.

```
$ cd pub/
$ python
>>> import drink
give me a pint
```

It works! Why? And if I have modules in different directories, how to import all
at the same time? In this case we can use `sys.path` that is a list of
strings that specifies the search path for modules.

Ok, lets go back to the previous directory and add `pub` in the `sys.path`.

```
$ cd ..
$ python
>>> import sys
>>> sys.path
['', '/Library/Python/2.7/site-packages/npm-0.1.1-py2.7.egg',
'/Library/Python/2.7/site-packages/optional_django-0.1.0-py2.7.egg', '/tmp',
'/System/Library/Frameworks/Python.framework/Versions/2.7/lib/python27.zip',
'/System/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7',
'/System/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/plat-darwin',
'/System/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/plat-mac',
'/System/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/plat-mac/lib-scriptpackages',
'/System/Library/Frameworks/Python.framework/Versions/2.7/Extras/lib/python',
'/System/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/lib-tk',
'/System/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/lib-old',
'/System/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/lib-dynload',
'/System/Library/Frameworks/Python.framework/Versions/2.7/Extras/lib/python/PyObjC',
'/Library/Python/2.7/site-packages']
```

Have a look in the first value of the list ''. It means that the module will be
firstly searched in the current directory, as a result when we ran the interpreter
inside the pub directory the module was found.

```
>>> import sys
>>> sys.path.append('pub')
>>> import drink
give me a pint
```

Another way to add a directory in `sys.path` is through the `PYTHONPATH`
environment variable.  Come on! Test it!

```
$ export PYTHONPATH=pub
$ python
>>> import drink
give me a pint
```

This was a basic hint, we can find much more information at [docs.python.org](docs.python.org).
I hope I've helped and if you have comments leave me a comment. 

Happy Coding!

## Reference

 * Friends
 * Christian and Grazziella reviewing my bad English.
 * Google
 * Python docs
