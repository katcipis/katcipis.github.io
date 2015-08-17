---
layout: post
title: Python Tools
---

Two weeks ago my wife started learning more about software development, more precisely python language, so I decided to write this document to help her in this new journey. In the same time some co-workers of mine needed the same kind of explanation. 

If you are looking for a simple tutorial about `pip`, `virtualenv` and `easy_install` tools, here is your place. Enjoy and try to not sleep while reading it. =)

<!-- more -->

## What is `easy_install`?

Easy Install (easy_install) gives you a quick and painless way to install and manage python packages. It was released in 2004, as part of setuptools. If you don't have `pip tool` in your machine let's use `easy_install tool` to install it.

With the command below we can easily install `pip`. Remember, you have to be `root` or use `sudo` before the command.

```
# easy_install pip
```

If the command succeeded, you are now able to use the `pip` command. Make a test to see if you can find the command in your machine.

```
# type pip
pip is /usr/local/bin/pip
```

Looks fine? Let's move on.

## Pip Installs Packages (pip)

Hey, so you have finished the first step, good! Now let's learn a little bit about the `pip tool`. 

### What is `pip`?

As you can see **PIP** is a recursive acronym that means **Pip Installs Packages**. It is another tool to manage python packages and it is widely used by python developers. If you want to read mored about this amazing tool you can read the [official site](https://pip.pypa.io/en/stable/).

### How to use `pip`?

Pip is a real easy command and is generally used when you need to install a library, framework or any other dependency to your project.

First command you should try is `help`. Pay attention, If you are not using a `virtual environment` you have to be root to install packages.

```
bane:~ paulo$ pip -h

Usage:   
  pip <command> [options]

Commands:
  install                     Install packages.
  uninstall                   Uninstall packages.
  freeze                      Output installed packages in requirements format.
  list                        List installed packages.
  show                        Show information about installed packages.
  search                      Search PyPI for packages.
  wheel                       Build wheels from your requirements.
  help   
```

As you can see it is possible to install, uninstall, search, list and do other management using the command `pip`. Now free your mind and use it.

If we want to search the package called `requests`.

```
$ sudo pip search requests
```

If we want to install the `requests` package.
```
$ sudo pip install requests
```

If we want to uninstall the `requests` package.
```
$ sudo pip uninstall requests
```

You should do that with all packages you want to install.

### Requeriments File

If you have a project and in this project you have some requirements, so you can create a file called `requirements.txt` and inside the file you can add all packages you need.

Look an example of this file.

```
pandas
seaborn
requests
```

Now you can install all requirements using only one command.

```
$ sudo pip install -r requirements.txt
```

If you have all requirements installed in your machine, it is possible to generate the `requirements.txt` file.

```
$ pip freeze > requeriments.txt
```

Nice uhm? :D

## Virtual Environments

A lot of developers don't like to use virtual environments, honestly I don't know why. It is to use and keep your system healthy.

### What is it?

Imagine this situation. You are working in a Project X and you need a library version 1.1, so you install this library in your system, but next month you will work in a Project Z and you need a different version of the same library. What you gonna do?

Virtual environments solve this kind of problems, they keep the dependencies required by different projects in separate places, by creating virtual Python environments for each of them.

### How to install it?

Do you remember the `pip` tool? So, we can use it to install the `virtualenv` package.

```
$ sudo pip install virtualenv
```

### How to use it?

Sometimes the best way to learn is seeing an example. You can work with virtual environments in a new project or existing project. Let's start a new project.

```
$ mkdir test
$ cd test
$ virtualenv venv
Running virtualenv with interpreter /usr/bin/python2
New python executable in venv/bin/python2
Also creating executable in venv/bin/python
Installing setuptools, pip...done
```

Now we have a virtual environment created, we have just to activate it. Let's do that now.

To activate your environment do the command below.

```
$ source venv/bin/activate
```

When you activate the virtual environment the bash prompt will change and add the environment’s name in your prompt.

```
(venv)paulo@lorcan:/tmp/project$
```

Look in my bash the word **(venv)** is telling us the environment is activated. So you do not need to be root to install and manage your python packages, because you will install the packages in your environment, not in your system.

And when you are done working in your virtual environment, you can deactivate it.

```
$ deactivate
```

Easy? :D


## Working with Git

Hum, Do you know who is Linus Torvalds? He is an amazing guy, he is the Linux creator and maintainer. He also is creator of `git tool`. But what is `git`?  In a simple way, it is a system to keep the activity history when we are developing a project.

If you want to start working in a project, the first thing you have to do is clone the project. Look the example below.

```
$ git clone git@github.com:patito/go-adventure.git
```

Now we have cloned the project, we can change it and start working. :D You can use `git status` to see your changes.

```
bane:go-adventure paulo$ git status
On branch master
Your branch is up-to-date with 'origin/master'.
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

    modified:   list.go
```

I can see that I have modified the file `list.go`. So we have to `add` this file, commit it and send to the server. Looks like complicated, but it is not.

Adding a file.

```
$ git add list.go
```

Commiting your changes.

```
$ git commit -m "Change comments at list.go"
```

Pushing your changes.

```
$ git push
```

You can find more info about git at [official website](https://git-scm.com/book/en/v2/Getting-Started-About-Version-Control).

## Finishing

Like I said before this post is just to help my wife and others python beginners. If something is wrong just leave a comment.
