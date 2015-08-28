---
layout: post
title: Reference Counting
---

I wrote this a lonnng time ago and now I have just translated it.

"Memory management? Why? Hardware is cheap, I won't release the memory". 
"I'm crazy life, I make popcorn without a lid and I don't release the memory". 
"Do you only release the memory to impress intern?". If you think like that,
you are like me and you can go watch The Big Bang Theory. But for those who are
too square and like a safe life I will show a different solution.

<!-- more -->

The memory management is one of the biggest  headaches for C developers, do this task manually 
using *malloc()* and *free()* works, but if you forget a *free()* you may cause a memory leak,
if you use it in a wrong way, you might corrupt your software. This task don’t have to be
hard if we use a good technique.

## How it works?

Reference counting is a simple technique of memory management. Its operation is based on an 
internal counter of the object. This counter starts in 1 (one) when the object is created.
If the developer wants to use the object, he calls the “ref” method, this way the internal
counter will be increased in one, if the developer doesn't need the object anymore, he has
to call “unref” method and the internal counter will be decreased in one. When the internal
counter is zero means that the object is not being used and the memory can be released.

## Example

Let’s create an example to show how this technique works. We gonna create a Person object that contains name,
surname and age. This is just an example, so don’t worry about variable names or error handling, the idea
here is to show the concept of reference counting. In our example we gonna implement these methods:

 - person_new(): Responsible to create a new Person;
 - _person_destroy(): Static method responsible to release the memory;
 - person_ref():  Method responsible to retain the object;
 - person_unref(): Method responsible to release the object;
 - person_print(): Method responsible to print the object Person information;

## Header File

The header file looks like this.

```c
#ifndef _PERSON_H_
#define _PERSON_H_

typedef struct {
    char *first_name;
    char *last_name;
    unsigned int age;
    unsigned ref;
} Person;

/*  Method to create the persong object */
Person* person_new(char *first_name,
                   char *last_name,
                   unsigned int age);

/* Retain the object */
void person_ref(Person *obj);

/* Release the object */
void person_unref(Person *obj);

/* Print object information */
void person_print(Person *obj);

#endif /* _PERSON_H_ */
```

## The person_new() method

Let’s create the method responsible to create the Person object.

```c
Person *person_new (char *first_name, 
                    char *last_name, 
                    unsigned int age)
{
        if (NULL == first_name) {
            printf("Invalid first_name!\n");
            return NULL;
        }

        if (NULL == last_name) {
            printf("Invalid last_name!\n");
            return NULL;
        }

        Person *obj = (Person *)malloc(sizeof(Person));
        if (NULL == obj) {
                printf("%s Out of Memory!\n", __FUNCTION__);
                return NULL;
        }

        obj->first_name = strdup(first_name);
        obj->last_name = strdup(last_name);
        obj->age = age;
        obj->ref = 1;   /*  Reference Counting */

        printf("Creating object[%p] Person\n", obj);
        return obj;
}
```

## ref and unref methods

Remember that we have to use *person_ref()* method to retain the object and we increase the counter.

```c
void person_ref(Person *obj)
{
    if (NULL == obj) {
       printf("Person Obj is NULL");
       return;
    }
    obj->ref++; /*  Increasing the counter */
}
```

The *person_unref()* method is responsible to release the object, decrease the counter
and verify if counter is 0 to release the memory.

```c
void person_unref(Person *obj)
{
    if (NULL == obj) {
       printf("Person Obj is NULL");
       return;
    }

    /*  Decreasing the counter 
     *  verify if counter is 0
     */
    if (--obj->ref == 0) {
        printf("Memory Release obj[%p]\n", obj);
        _person_destroy(obj);
    }
}
```

## Releasing the memory

This static method is the real responsible for releasing the memory. We call this method inside of 
*person_unref()*. Look the code below that we are using *free()* function.

```c
static void _person_destroy(Person *obj)
{
    if (NULL == obj) {
        printf("Person object is NULL!\n");
        return;
    }

    if (NULL != obj->first_name) {
        free(obj->first_name);
    }

    if (NULL != obj->last_name) {
        free(obj->last_name);
    }

    free(obj);
}
```

## Main function

Now let's use our functions and see if the technique really works.

```c
#include <stdio.h>

#include "person.h"

int main()
{
    Person *father = person_new("Jose", "Rico", 65);
    Person *mother = person_new("Beth", "Perigueti", 21);

    person_print(father);
    person_print(mother);

    person_ref(father);
    person_unref(father);

    /* New method - Unref */
    person_unref(father);
    person_unref(mother);

    return 0;
}
```
## Makefile

Yeah, because I know you are lazy, I did a Makefile. :D

```c
CC      := gcc

CFLAGS  := -W -Wall -Werror -I.

BIN     := person

SRC := main.c person.c
OBJ := $(patsubst %.c,%.o,$(SRC))
%.o: %.c
                $(CC) $(CFLAGS) -o $@ -c $<
all: $(OBJ)
                $(CC) $(CFLAGS) -o $(BIN) $(OBJ)

clean:
                $(RM) $(BIN) $(OBJ) *.o $(LIB)
```

Reference counting is really nice because the developers don't have to manage *malloc()*, *free()* and pointers. We create an abstraction. I hope you enjoyed and let me know if I did something wrong.

