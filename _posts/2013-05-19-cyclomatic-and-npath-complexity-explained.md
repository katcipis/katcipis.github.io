---
layout: post
title: Cyclomatic and NPath complexity explained
---

If you happen to be using [PHP Mess Detector][1] (which you should for any larger project) you have probably stumbled upon these two, but do you really know what they stand for? They sound really scary, but they're basically fancy words for quite simple concepts. So let's go through them and also find out why they're important for maintainable and testable code. Both of these concepts are used in static code analysis and are measurements of how complex a function is.

<!-- more -->

## Cyclomatic complexity 

This is a very straight forward concept, it's pretty well [documented][2] in PHPMD's documentation and what does is pretty much count some statements. The standard threshold for this complexity is 10 points, so if you have a function with higher complexion than that, you should try to reduce it. 

It will begin by adding 1 point for the function declaration, after that it will add 1 point for every `if`, `while`, `for` and `case`. I'll just copy and paste the example code from PHPMD's documentation to illustrate this, of how this function ends up with a cyclomatic complexity of 12.

```php
<?php
class Foo {
1   public function example()  {
2       if ($a == $b)  {
3           if ($a1 == $b1) {
                fiddle();
4           } else if ($a2 == $b2) {
                fiddle();
            }  else {
                fiddle();
            }
5       } else if ($c == $d) {
6           while ($c == $d) {
                fiddle();
            }
7        } else if ($e == $f) {
8           for ($n = 0; $n > $h; $n++) {
                fiddle();
            }
        } else{
            switch ($z) {
9               case 1:
                    fiddle();
                    break;
10              case 2:
                    fiddle();
                    break;
11              case 3:
                    fiddle();
                    break;
12              default:
                    fiddle();
                    break;
            }
        }
    }
}
```

Not that hard, huh? 

## NPath complexity

Now this one is a bit trickier since the PHPMD [documentation][3] really suck. This is what is says about it: 

> The NPath complexity of a method is the number of acyclic execution paths through that method. 

Wait, what? At least to me that made zero sense when I first read it. But as previously stated, it's just a lot of fancy talk for simple stuff. The simple explanation is that how many "paths" there are in the flow of your code in the function. Let's write ut a simple example function.

```php
<?php
function foo($a, $b) {
    if ($a > 10) {
        echo 1;
    } else {
        echo 2;
    }
    if ($a > $b) {
        echo 3;
    } else {
        echo 4;
    }
}

foo(1, 2); // Outputs 24
foo(11, 1); // Outputs 13
foo(11, 20); // Outputs 14
foo(5, 1); // Outputs 23
```

So here we have function with 4 possible outcomes, since we have 2 statements that have 2 possible outcomes each (`2 * 2 = 4`). That means that the functions Npath complexity is 4. If we would add another statement with 2 possible outcomes we would get a complexity of 8 since `2 * 2 * 2 = 8`. 

So the NPath complexity is exponential and could easily get out of hand, in old legacy code don't be surprised if you find functions with complexity over 100 000. The default value of the threshold for this complexity is 200, staying under that value is something you should strive for. 

## So why is the complexity important?

Simple code is always better than complex code. This applies to areas as readability, maintainability and testability. Consider writing a unit test and you have a function with an NPath complexity of 16. This means that if you need want 100% code coverage you need to test for 16 possible outcomes and that would end up in pretty messy tests. This goes again the entire philosophy of unit testing since you want as much isolation as possible when writing your tests. That's why you should always try to reduce complexity in your application. 

So don't be scared of these seemingly scary concepts but instead embrace them and use them to your advantage.

 [1]: http://phpmd.org/ "PHP Mess Detector"
 [2]: http://phpmd.org/rules/codesize.html#cyclomaticcomplexity "PHPMD - Cyclomatic Complexity"
 [3]: http://phpmd.org/rules/codesize.html#npathcomplexity "NPath Complexity"