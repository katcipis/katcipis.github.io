---
layout: post
title: The depths of AngularJS's watches
---

When you want to watch for changes in AngularJS, it is fairly kind to you by default. The kindness comes from trying to optimize performance for you. This is because each watch expressions will run at least once during each [$digest](https://docs.angularjs.org/api/ng/type/$rootScope.Scope#$digest) loop. I'll not go into when the $digest loop executes and why, and I'll also use watches in controllers in my examples which you should never do, but that's a [whole other discussion](http://www.benlesh.com/2013/10/title.html).

<!-- more -->

## Watch in its simplest form

Here is an example of the most basic watch expressions available, using [$watch](https://docs.angularjs.org/api/ng/type/$rootScope.Scope#$watch). It does something you probably would never do in a real world application. It will watch for value changes on `$scope.name` and reassign this value to `$scope.nameAgain`.

<iframe width="100%" height="150" src="http://jsfiddle.net/modess/ruLqH/embedded/" allowfullscreen="allowfullscreen" frameborder="0"></iframe>

## A little deeper

Now let's take a look at an example that will not work. We have our `$scope.people` and the ability to push new objects to it. But when pushing a new person to the array, the number of people is not updated correctly even though we have a watch on `people`.

<iframe width="100%" height="300" src="http://jsfiddle.net/modess/AyF8H/embedded/" allowfullscreen="allowfullscreen" frameborder="0"></iframe>

So why is that? It's because AngularJS's watch method is designed for speed. Therefore it won't work on a collection. If we want to watch for changes in a collection when manipulating it we need to use [$watchCollection](https://docs.angularjs.org/api/ng/type/$rootScope.Scope#$watchCollection), which is designed for this.

<iframe width="100%" height="300" src="http://jsfiddle.net/modess/vEFS7/1/embedded/" allowfullscreen="allowfullscreen" frameborder="0"></iframe>

## And down into the rabbit hole

Let's add a function for incrementing number of clicks to each person. Why you would need that I have no idea of, but we need some kind of example right? We'll add a `clicks` property to each person that increments on a button click, and then a counter for all clicks. We'll use `$watchCollection` and see what happens.

<iframe width="100%" height="350" src="http://jsfiddle.net/modess/cUCA5/embedded/" allowfullscreen="allowfullscreen" frameborder="0"></iframe>

We can increment clicks for each person, but we can't get the counter for total clicks to work. That is because once again the collection watch is built for performance, and it won't watch for property changes inside the collection.

For watching on property changes within a collection we need to go back to using `$watch` again. But this time we will pass `true` as a third parameter to it. That is `$watch('collection', function() {}, true)`.

<iframe width="100%" height="350" src="http://jsfiddle.net/modess/9Dfaa/1/embedded/" allowfullscreen="allowfullscreen" frameborder="0"></iframe>

Success! Our total counter works. We're now using the slowest version of watch, in this extremely simple example it won't matter anything though.


## To summarize

When we want to watch for **property value changes**, whether it's a simple scope property or a property on a collection, we use `$watch`. Just note the implementation is different for the two use cases.

When we want to watch for manipulation of **collections**, when adding or removing items for example, we use `$watchCollection`.

There is one special case for using a regular `$watch` when watching for manipulation of a collection. It won't be very useful in a lot of application, but it's worth mentioning. That is when you **reassign a collection**, then a simple watch for the collection variable works. Take a look at this (shitty) code:

<iframe width="100%" height="450" src="http://jsfiddle.net/modess/MvvvY/1/embedded/" allowfullscreen="allowfullscreen" frameborder="0"></iframe>

Here we're pushing all objects into a new collection and then reassigning the old collection to the new one. And as you can see, a regular watch expression works fine there.