---
published: false
title: Good Design
layout: post
---

# SOLID

# Four rules of simple design

# Other interesting characteristics

## Symmetic

## Uniform

## Orthogonal

## Make it seem simple

## Bonus Round From Embedded Muse

Charles Manning

The last two months or so, I've been burning some null cycles trying to ponder what makes for well designed vs poorly designed software body, and it is very challenging to get a handle on any objective measures.

Over the last 36+ years - including some time tutoring CS at university and many years as a consultant, I've seen a lot of code. Some has been well designed and some terribly designed. Unfortunately the terrible is vastly more common than the beautiful.

But that assessment has been rather subjective - even very difficult to articulate.

Software is very abstract. From the outside you cannot see software duct tape. Nor can you see a an over-engineered monstrosity that is equivalent to a car built out of I-beams and craft glue.

With enough effort, even the most awfully designed software can be made to run - even reliably, so working or not working is not a good measure.

So far my pondering has only given me two measurements:

1) How long it takes to fix a bug once clear symptoms are known, Does it take a few minutes? Does it take days? Poorly designed code has convoluted code paths which make it very difficult to nail down where something is going wrong. Both well designed and poorly designed code have bugs, but poorly designed code is harder to fix, meaning the bugs live longer and take more effort to kill.

In the 1980s IBM tried developing some quality metrics. One they used was bugs tracked on a module by module basis. What they found was that bugs were not randomly scattered around. Some modules would tend to have more bugs than others. Certainly some modules are more difficult to design than others, but some must surely be attributed to good vs poor design.

2) Code complexity for the job at hand. When there's an order of magnitude more files and code than there should be then the chances are that the code body is poorly designed. The "code effectiveness" is very low and there's a lot of "lazy" code coming along for the ride.

That "lazy code" is often a result of trying to band-aid over corner cases where the main code path fails, or code duplication. Both are signs of poor design.

Neither of these are very satisfactory measures.
