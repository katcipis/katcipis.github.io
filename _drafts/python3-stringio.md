
Elaborate on how awesome io.StringIO is:

```
from io import StringIO

print("\nwriting on an empty StringIO and reading it")
s = StringIO()
print("read[{}]".format(s.read()))
print("write[{}]".format(s.write("hello")))
print("read[{}]".format(s.read()))

print("\nreading from a StringIO created with contents on constructor")
n = StringIO("hello")
print("read[{}]".format(n.read()))

print("\nactually writing erases the data that was passed on the constructor o.O")
m = StringIO("holla")
print(m.write("mundo"))
print("read[{}]\n".format(m.read()))
```

And yes, this is in the language stdlib.
