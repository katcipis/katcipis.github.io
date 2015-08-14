---
layout: post
title: Deploying with Git hooks
---

Using Git hooks to deploy your application is one of the most simple and most useful tool there is. Seriously, use them. Of course you need to use Git as your version control system, but hopefully you are already using it. You can achieve pretty much anything with your deploys with a simple setup. 

If you want to deploy your application with a simple `git push` to your production server and automate all the necessary steps, this post is for you.

<!-- more -->

This post will go through what Git hooks are and how to use them. It will be a kind of teaser/shameless plug for the book I'm writing: [Deploying PHP applications](https://leanpub.com/deploying-php-applications). The book will cover the entire deploy process and discuss many more advanced topics, I recommend you check it out.

## The application

Quite simple actually. On your local environment your application will be located in `~/dev/app` and on your production server it will be located in `/var/www/app.git`. This is all we need to know. Let's go.

## Git hooks

There are a numerous of different hooks available for you. 17 ones to be specific: *applypatch-msg*, *pre-applypatch*, *post-applypatch*, *pre-commit*, *prepare-commit-msg*, *commit-msg*, *post-commit*, *pre-rebase*, *post-checkout*, *post-merge*, *pre-receive*, *update*, *post-receive*, *post-update*, *pre-auto-gc*, *post-rewrite* and *pre-push*.

With these hooks you are able to hook in and perform commands before or after certain actions in Git. This could either be client or server side. The *pre-commit* hook is a client side one and will be triggered before making a commit. Want to reject commits that does not comply with your coding standard? Not a problem. The *update* hook on the other hand is a server side one and will be triggered on the remote just before it updates the refs when you do a push. In this we will focus on **post-receive** and **post-update** which both are server side hooks.

The hooks resides in `.git/hooks` of your repository. Therefore they are not in the actual repository. But if you want to version control them you can create a `hooks` folder in your repository and create a symbolic link to `.git/hooks` from that. Each and every one of your hooks needs to be executable in order to work properly.

One thing to mention about running hooks are that the their working directory when executing is the `.git` folder (the `GIT_DIR` environment variable). This can be unset or you can change the working directory in the actual hook itself.

### Language agnostic

One of the best features about Git hooks is that they don't care what language they are written in. As long as they are executable everything is fine.

Like Bash? Not a problem.

```bash
#!/bin/bash 
echo "Hello World!"
```

Prefer Python? Sure.

```python
#!/usr/local/bin/python
print "Hello world"
```

I'll stick to Bash in my examples, since then we don't have to worry about a specific language being installed on the system.

## Set up your server

Fire up a terminal and log in remotely to your server. We'll start off setting up an empty repository in `/var/www/app.git`.

```
mkdir -p /var/www/app.git
cd /var/www/app.git
git init
```

This is all we need to do on the remote for now. Of course you need to set up your web server to serve that folder for some domain. If you're reading this I'll assume that you are proficient in configuring your web server.

## Set up your local environment

Once more fire up the terminal if you don't have it open. Let's create our local repository. You can skip this step if you already have your repository ready.

```
mkdir -p ~/dev/app
cd ~/dev/app
git init
```

Now you have a local repository. We need to connect that to the server, so we want to add a remote pointing to it.

```
git remote add production <user>@<yourhost>:/var/www/app.git/
```

You have now successfully created a set up where you can push from your local environment straight to your server! Let's try it and see that it works.

```
echo "<?php\necho 'Hello world';" > index.php
git add .
git commit -m "Initial commit"
git push production master
```

Did it work? Sweet. If you have your web server set up properly, you should be able to go to the domain and see "Hello world".

## Set up deploy hooks

Now when you have a setup that is able to push straight to your production environment, let's get the hooks in place to deal with automation of deploy tasks. Since both hooks we're going to utilize are server side hooks, we'll create them on the server.

### post-receive

This hook will be triggered on the remote when you have pushed to it and all the refs have been updated. Its task will be nothing fancy, just making sure your working copy is set to the latest ref.

Remotely login to your server and run these commands to create an empty hook.

```
cd /var/www/app.git
touch .git/hooks/post-receive
chmod +x .git/hooks/post-receive
```

Now let's fill that hook with the following stuff:

```bash
#!/bin/bash
cd ..
unset GIT_DIR
env -i git reset --hard
git checkout -f
```

The commands are pretty much boilerplate and you don't have to worry so much about them. It does a hard reset of your repository and then forces a checkout of the latest ref. Without these you would have to manually move the HEAD pointer on your remote.

### post-update

Now this is where it gets interesting. This is where you can run all the commands you need. First we create the hook.

```
cd /var/www/app.git
touch .git/hooks/post-update
chmod +x .git/hooks/post-update
```

We start off by moving ourself into the root of our repository, since hooks working directory are `.git`. Just as we did in the *post-receive* hook.

```bash
#!/bin/bash
cd ..
unset GIT_DIR
```

Let us assume that we need to update dependencies through Composer. In our simple demo application we just have an index file. But in any real world application this will probably be the case. Then we could add this to the hook:

```
echo "[*] Running Composer update"
composer update --no-dev
```

And there we have it! Every time you do a `git push production master`, the hooks will run and you don't have to manually run them. The commands are arbitrary, and any commands you can run in the terminal on your server, you can run here.

## Further possibilities

There are a lot of other possibilities we can achieve with these hooks. I will discuss many of them in my book [Deploying PHP applications](https://leanpub.com/deploying-php-applications) (Okay I wasn't really done with the shameless plug yet). But some of them are:

* Atomic deploys
* Abort deploys on errors
* Updating front end dependencies
* Making builds
* Running test suites
* Cache busting
* Updating revision numbers for static assets
* Database migrations
* Notifications of (un)successful deploys
