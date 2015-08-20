---
layout: post
title: Coding with my wife
---

About two weeks ago Grazziella, my wife, started learning how to code in Python. I am still not sure about the real reasons for her starting on this crazy journey, however I believe it might have been curiosity. She has been hearing, almost daily, words like: bug, refactory, code, class, python, C, linux, among others, for about four years. She definitely is tired of those words flutuating in our humble flat. And, to get worst, most of the times that we see my friends the subject does not change.

<!-- more -->

Well, she already had asked me about programming few months ago and showed a hint of will in starting to code. I did not give much attention to the matter in that time because in my opinion nobody in their right mind would demonstrate such will. I honestly thought she said that just for the sake of saying it. I was wrong, though! 

Two weeks ago she started reading the book *Python - Visual Quickstart Guide* and attendind *pythonlearn.com*. After her first week reading the book, clarifying doubts on the Internet and watching online video tutorials she was already able to use resources such as: loops, flow of control, functions and error handling try-except. As a good husband who wants to retire at 35, I have encouraged her to keep learning more about software development and become a successful developer.

Every night now are always very similar, after a walk on the seaside, bath and dinner, we are ready to start coding. Now we have a physical kanban at home, hahaha, and I'm not joking, look the picture below. Every week we add more activities in the kanban and take away the old ones. The tickets are organized by color, green are used for nerd tasks, pink for home tasks and yellow for the others. Lately I get only the pink ones. :(

![](/public/img/kanban1.jpg)

![](/public/img/kanban2.jpg)

I know, it doesn't look great, but do not judge a book by its cover. Actually it is a paperboard that comes with the varidesk.

This learning with my wife remembers me my first year at university, when I started learning about computer languages. I used to lose myself in my loops and variables inside of my "spaghetti code".

To follow this learning process about programming is really pleasant, fun and interesting. I can see her doubts and mistakes just like I did when I was learning. In this moment she doesn't care about legibility, reuse, indentation and comments in the code, she only wants to fix the code, execute and see it working.

She is faring an extremely stubborn programmer, hahaha, I will explain why. Most of my friends hate if you complain about their code, she isn't different. The code for them is like a child, you can't point its defects. At first, she is going to the same way.

I took long time to learn how to program, I didn't have much interest about computer science in that time, but unlike me, she is doing a good job. I will not lie here, her gaffes are really funny. It happens with everyone when is learning something new. Only those who do not try not make mistakes. One day she had to develop a function and the result should be a boolean (True or False). I was working when she sent me her code and I started laughing loudly.


```python
return 'True'
```

At university I had a programming professor called Habib, once he got in the classroom to deliver our assembly language tests. The first thing he said was: **"I had to correct these tests with a glass of water with sugar"**. He said that because he always laughed correcting our tests, probably a lot of gaffes. He also used to say: **"My three years old son has corrected your tests"**.  In that moment we were all waiting for the worst. Now I understand better that feeling he had correcting my tests and I quite enjoy doing the same now. 

The bugs are part of the daily lives of all programmers, like I said: Only make bugs who develops. Then if you are learning about computer languages, like my wife, don't be ashamed, this is part of learning process. My advice: save your first programs and after one year learning about software development open them and have fun.

**"All programmers are playwrights and all computers are lousy actors" (unknown author)**

We don't know if Grazzi will work as a software developer one day, but this is not the point and it is not what we are aiming. We are loving the fact that both of us are learning more about computer languages, it is really enriching, we are spending our spare time in something really nice. 

In this short period of time she had been learning: Linux command line, python language, sublime editor and putting codes on github. Look her last code after two weeks learning.

```python
#!/usr/bin/env python
# -*- coding: utf-8 -*-

def reverse_str(name):

    """ Return the reverse string. """

    rev_name = ''

    for n in range(len(name)):
        rev_name += name[-1 - n] 

    return rev_name

if __name__ == '__main__':
    print(reverse_str('Arara'))
```

Teaching and learning more about programming languages with her is being an amazing experience. If you are reading this post, what about doing the same with your wife, children, father, mother or uncle?

Happy Hacking Grazzi!

