---
layout: post
title: Controlling your exports
---

Today is Friday and I shouldn't be thinking about python or 
any other language. On the contrary, I should be drinking
beers with my friends, eating barbecue and wait for my hangover
in the next day, just like my brothers Nani and Cadi
in Florianopolis/Brazil. But here in Brighton/UK is quite cold
and it is difficult "to do a crazy life". So, lets do something nice 
while they are getting fatter and fatter. 

<!-- more -->

Sometimes when we write a python module we don't want to export
everything that we have inside of the module, but how to do that?
The answer to this question we will explain in this post.

Let's create a new module called `pub.py` and inside of it
implement two functions: `drink()` and `food()`.

```python
# pub.py

# BTW it is not a good beer :D
beer = 'Colonia'

def drink:
    print('Give me a {0} beer!').format(beer)

def food:
    print('I want a sunday roast!')
```

Let's try to import our module.

```
$ python
>>> from pub import *
>>> drink()
Give me a Colonia beer!
>>> food()
I want a sunday roast!
>>> beer
'Colonia'
>>> locals()
{'__builtins__': <module '__builtin__' (built-in)>, 'drink': <function drink at 0x7f0d055095f0>, '__package__': None, 'food': <function food at 0x7f0d05509668>, 'beer': 'Colonia', '__name__': '__main__', '__doc__': None}
```

You can see we have access to both functions and to the `beer` variable. But if we don't want external access to
the `beer` variable. To do that we can use `__all__` variable and tell to our module what we want to export.
Look the example bellow.


```python
# add this line in the module
__all__ = ['drink', 'food']
```

Now do the same test again and you will see the variable won't be available to us. \o/

```
$ python
>>> from pub import *
>>> drink()
Give me a Colonia beer!
>>> food()
I want a sunday roast!
>>> beer
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
NameError: name 'beer' is not defined
>>> locals()
{'__builtins__': <module '__builtin__' (built-in)>, 'drink': <function drink at 0x7f56cabb35f0>, '__package__': None, 'food': <function food at 0x7f56cabb3668>, '__name__': '__main__', '__doc__': None}
```

I hope you enjoyed this post, otherwise go jump in the lake bitch :D.
Now it is time to drink and watch Sons of Anarchy with my wife. \o/

Happy Coding!
