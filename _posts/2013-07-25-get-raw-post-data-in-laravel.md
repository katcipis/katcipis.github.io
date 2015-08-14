---
layout: post
title: Get raw POST data in Laravel
---

I recently stumbled upon an interesting problem when trying to retrieve the raw POST body in Laravel. This happened when I was sending POST/PUT requests from AngularJS to a REST API that was built with Laravel. I did a lot of trial and error before I figured out the problem.

<!-- more -->

To start of with we take a look at how we get the raw POST data in PHP. It's a fairly simple command:

```php
<?php
$rawPostData = file_get_contents("php://input");
```

The `php://input` is an [I/O stream][1] that you can read the raw POST data from. What is interesting though is that it can **only be read once**. And this is what caused me not being able to fetch it in this simple matter.

## Why is that?

If you are familiar with Laravel you probably know that a lot of its core is built upon Symfony components, and the [HTTP request handler][2] is one of those components. If we dig in to the class `Symfony\Component\HttpFoundation\Request` we find this interesting line:

```php
<?php
$this->content = file_get_contents('php://input');
```

Now you remember what I said about the I/O stream, right? I will repeat that, **it can only be read once**. Since the Symfony component reads the I/O stream, it's empty after that. This results in that you can not access straight in your application with the simple approach I wrote before.

## What then?

Lucky for us, the request instance is accessible through the Request [facade][3] in Laravel. The request instance then have the raw POST data set as its content.

```php
<?php
// First we fetch the Request instance
$request = Request::instance();

// Now we can get the content from it
$content = $request->getContent();
```

Now we have the raw POST data in `$content`, simple as that.

 [1]: http://us.php.net/manual/en/wrappers.php.php
 [2]: http://symfony.com/doc/2.0/components/http_foundation/introduction.html#request
 [3]: http://laravel.com/docs/facades