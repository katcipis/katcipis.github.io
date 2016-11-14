# Composing in Go

Talk about Go embedding and how it makes it easier to compose
instead of inheritance.

Talk about law of demeter and how Go automatically generates
the wrappers to apply demeter easily but without inheritance
magic.

Evolve examples of how the lack of true inheritance avoid
obscure errors like parent methods calling the
child methods or data.

Show that functions wont accept a type if there is no exact match
of the type. It is a "has a" relation.
