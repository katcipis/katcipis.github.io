---
layout: post
title: Atomic deploy for PHP applications
---

Once your application reaches a critical mass of users, you want to be able to deploy without any abruptions in the service. Users could be really frustrated if they work on something and suddenly when they try to save they get a message saying the service is currently unavailable and their work is nowhere to be found. It's a horrendous user experience. Striving for your deployment to be as fast and responsive as possible just won't cut it. We need to make them atomic. 

<!-- more -->

Atomic deploy is when you switch between the previously deployed version and the new one as quick as possible. I'm talking milliseconds or even less, anything slower than that can't be considered atomic. Doing this without your users even noticing is key. Your application does not need to be very complex or be deployed on an advanced infrastructure. It's enough that somewhere in your deploy process the different parts can come out of sync from each other. Dependencies could get out of sync with your code, if the code is updated before dependencies. Then it will break your application. 

There is a few things that need to be in order when constructing a deploy process for atomic deploys. I'll go through them in a theoretical manner. How it is achieved in the real world is very situational and can be done by using almost any tool that allows for automation in the deploy process. It can even be achieved manually but that is something I strongly discourage.

## Concept of builds 

Even though we as PHP developers seldom have to consider the concept of builds of our application, we must internalize this for achieving atomic deploys. If we can not create a separate build while deploying, it's not possible. However it's a very simple way of doing this, all we need to do is create a build in a separate folder that we at a later point replace the previous build with. 

Having an appropriate folder structure for allowing this is really simple. I'll later in this post propose a structure but there is other components to this that I want to discuss prior to it. For now just consider a folder with your application with all dependencies and configuration complete as a build. 

When switching builds you should also save a number of older builds, perhaps the five or ten previous builds. This allows for quick rollbacks and can be crucial if a deploy needs to be reversed. How many you should save is impossible to answer, just go with a number you feel comfortable with. 

## File persisted data (shared data) 

When switching out a previously deployed build for the new one, we must assure that no file persisted data is lost. One example of this is if your application stores session data inside your application folder. If we switch out the old build for a clean new one, users might be logged out or data could be lost. Never an ideal scenario. This could potentially be worse than shutting down your application while deploying since the user won't even understand what suddenly happened. 

There could be file persisted data that you do not care if it gets lost or even prefer that it does. If your application has a cache for rendered templates, you probably prefer if that cache is wiped so your underlying logic and presented views won't get out of sync. In these cases, just make sure that your new build replaces these folders. 

What is important is to identify the files and/or folders that needs to be untouched between builds. I refer to these files or folders as **shared data** and I'll show how to deal with this in the proposed folder structure. 

## Symbolic folder links

Although it's not really necessary, but to grok symbolic folder links (symlinks) is strongly advised. What we want to do with symlinks is also possible by just copying or moving directories too. But to make things as atomic as possible we should leverage symlinks since they are pretty much instant.

A symlink is just a folder or a file that appears it exists in its location. But the file or folder is actually just a reference to a file or a folder in another location. It allows us to instantly switch out what folder a symlink is pointing to. When we deploy and want to switch out the old build, we just update a symlink to point to our new build instead. Likewise we'll do this for shared data. That way we make the switch extremely fast and can make sure that our shared data is there when we need it and is stored in one location only.

For Linux users, it's the [ln](http://linux.about.com/od/commands/l/blcmdl1_ln.htm) command. It's possible in Windows, but it's complicated and I suggest doing a [Google search](http://lmgtfy.com/?q=windows+symbolic+links) for it.

## Proposed folder structure

The proposed folder structure needs to reside inside a root directory somewhere. Where that is doesn't really matter, it just needs to contain the following structure. How you develop your application is not of importance, this assumes that the folder structure is on the server serving the application.

**application/** - the folder where the application resides and this is what we'll make builds from.

**builds/** - this folder contains the *X* number of builds that I discussed earlier. Perhaps the current one and the four previous to that. I suggest naming all builds with a timestamp with date and time down to seconds, you never want a build to overwrite a previous build by accident.

**shared/** - any shared data that needs to be persisted between builds will reside here. It can be both files and folders.

**latest/** - symlink to the current build that is deployed. Your web server will use this folder as its document root for your site. Unless there is a subfolder that should be served, depending on your set up and framework.

It could look something like this:

    <root folder>/
        application/
            composer.lock
            composer.json
            index.php
            sessions/ <- symlink to shared/sessions/
            vendor/
        builds/
            20141227-095321/
            20141229-151010/
            20150114-160247/
            20150129-083519/
            20150129-142832/ <- latest build
        shared/
            sessions/
        latest/ <- symlink to builds/20150129-142832/
            
## Deploy process

The process is straight forward.

1. Update the code in *application/*, perhaps through pulling the latest changes from a remote repository.
2. Update dependencies, this is also done in *application/*.
3. Copy *application/* to *builds/\<current timestamp\>/*.
4. Update the symlink *latest/* to point to the new build that was copied.
5. Remove excessive builds in *builds/*.

You now have an atomic deploy process!

## Rollback process

1. Update the symlink *latest/* to point to the previous build.

Sorry, it's not more complicated than that.

## Further reading

This was a simple theoretical example on how to achieve atomic deploys. Applications of more complexity or are deploying on a more advanced infrastructure will require a few more requirements. No real technical aspects was considered here. 

I'm writing a book on [Deploying PHP Applications](https://leanpub.com/deploying-php-applications). I suggest reading it if you want to read more on how you can solve this using different deploy tools and handle more complexity.