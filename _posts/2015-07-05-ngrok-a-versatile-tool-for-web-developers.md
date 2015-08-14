---
layout: post
title: ngrok, a versatile tool for web developers
---

In most cases your development machine will be local only, sitting behind a NAT or a firewall. So what happens when you need to show your progress externally or on a mobile device, or when you have to test a web hook from an external provider? This is possible, and a very simple task using **ngrok**. It's [completely open source](https://github.com/inconshreveable/ngrok), created by Alan Shreve ([@inconshreveable](https://twitter.com/inconshreveable)) and it's free! Some premium features you have to pay for, but for the most part you can use it in all its glory for no expense. It describes itself as:

> ngrok is a reverse proxy that creates a secure tunnel from a public endpoint to a locally running web service. ngrok captures and analyzes all traffic over the tunnel for later inspection and replay.

<!-- more --> 

What this translates to is that you run ngrok on your development machine, a subdomain on ngrok.com is created such as `somerandomdomain.ngrok.com` that will act as a reverse proxy to your development machine. That way any request to the subdomain will be proxied to your development machine, and on top of that you can analyze the requests and even replay them.

Using a push queue provider or a provider for websockets that you want to try or test? Then you can easily set up a reverse proxy, add that url in the provider and have it make the requests there so they get proxied to your development machine and you can test things out. 

To install it, take a look at their [download page](https://ngrok.com/download).

## Setting up a simple tunnel

Once you have it installed, you can run the command `ngrok 80` in a terminal and you've started a reverse proxy to your machine. It will look something like this:

```
ngrok

Tunnel Status                 online
Version                       1.7/1.7
Forwarding                    http://78e2eb80.ngrok.com -> 127.0.0.1:80
Forwarding                    https://78e2eb80.ngrok.com -> 127.0.0.1:80
Web Interface                 127.0.0.1:4040
# Conn                        0
Avg Conn Time                 0.00ms
```

In this example we want to forward request on port 80, this could of course be any port you need. Ngrok will create a random subdomain for you and you can visit `http://127.0.0.1:4040` for the web interface were you can analyze and replay requests.

## Using it with Vagrant

One thing I commonly do is using this when I develop REST APIs, which I always do in a Vagrant machine. Why? Because say you have authenticated requests, using HTTP headers for authentication and want to make that request multiple times. Either you have to just make the request over and over again in the consumer of the API, typically a web site, where you have to manually use the user interface for it. Or you have to set up an external application or browser extension for making the requests, which can be a hassle for setting authentication headers and anything else needed.

Instead I manually make a request in the consumer of the API, then I can over and over again send this exact same request to the API by replaying it in the web interface for ngrok. That way debugging and testing becomes a lot easier, since requests will fail and you need to change the API code and try it again over and over.

To set up a tunnel to your Vagrant machine, you could either install it inside the Vagrant machine and run `ngrok 80` inside of it. But I prefer having it on my local machine, and then simply running `ngrok 192.168.1.200:80` (or whatever IP your Vagrant machine has). Ngrok will receive the requests and forward it to that IP address and port.

## Ngrok configuration file

If you do not feel like getting a random subdomain each time you run ngrok, you can register on [ngrok.com](http://www.ngrok.com) to get an auth token. Using that, you can add it to the ngrok configuration file and add as many tunnels you'd like with custom subdomains as long as no one else is using them. You can find where the default location for your configuration file based on your environment [here](https://ngrok.com/docs#default-config-location).

So now we can set up the auth token in configuration file:

{% highlight yaml %}
auth_token: "r4nd0m5tr1ng"
{% endhighlight %}

After this we can specify our tunnels, let's call it `vagrant` and points to our Vagrant machine.

{% highlight yaml %}
tunnels:
  vagrant:
    subdomain: "codingswag-vagrant"
    proto:
      http: "192.168.1.200:80"
{% endhighlight %}

If we now run `ngrok start vagrant` we will see this output:

```
ngrok

Tunnel Status                 online
Version                       1.7/1.7
Forwarding                    http://codingswag-vagrant.ngrok.com -> 192.168.1.200:80
Web Interface                 127.0.0.1:4040
# Conn                        0
Avg Conn Time                 0.00ms
```

Which tells us we have a "permanent" subdomain on ngrok.com everytime we run it!
