
# Insights from business logic

Talk about direct instrumentation VS blackbox extraction.

Talk about the 3 approaches I used:

* Using metric stuff directly
* Injecting metric stuff (interfaces)
* Exposing interesting info as events direct as domain logic

Advantages of exposing events:

* Decoupled
* Easier to test (the idea came from there)
* Easier to have more than one UI for the insights

Was upset with the intrusion of instrumentation, perhaps
this kind of insight should be modeled on the domain logic,
there comes the event like approach.
