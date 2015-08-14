---
layout: post
title: Custom pagination in Laravel 4
---

The default Laravel pagination is built for Twitter Bootstrap 2.0 and I believe that it will be updated to use Twitter Bootstrap 3.0 in Laravel 4.1 (not sure though). So what happens when you want to use the pagination but have to customize it to your needs? It's actually really simple since Laravel allows you to specify your own pagination view where you can access the pagination object.

<!-- more -->

## Specify your own view

Open up `app/config/view.php` and change the `pagination` key to point to the view you want. I'll be using this value:

```php
'pagination' => 'structure/pagination'
```

This will tell Laravel to not use its default view for pagination but instead use this one when it outputs the pagination.

## Customize the view

First you need to create your view, in my case it's `app/views/structure/pagination.blade.php`. My own need was to implement it for [Semantic UI][1], so this example shows how you can customize the view entirely with the `$paginator` object which is an instance of [Illuminate\Pagination\Paginator][2].

```html
@if ($paginator->getLastPage() > 1)
<?php $previousPage = ($paginator->getCurrentPage() > 1) ? $paginator->getCurrentPage() - 1 : 1; ?>
<ul class="ui pagination menu">
  <a href="{{ $paginator->getUrl($previousPage) }}"
    class="item{{ ($paginator->getCurrentPage() == 1) ? ' disabled' : '' }}">
    <i class="icon left arrow"></i> Previous
  </a>
  @for ($i = 1; $i <= $paginator->getLastPage(); $i++)
  <a href="{{ $paginator->getUrl($i) }}"
    class="item{{ ($paginator->getCurrentPage() == $i) ? ' active' : '' }}">
    {{ $i }}
  </a>
  @endfor
  <a href="{{ $paginator->getUrl($paginator->getCurrentPage()+1) }}"
    class="item{{ ($paginator->getCurrentPage() == $paginator->getLastPage()) ? ' disabled' : '' }}">
    Next <i class="icon right arrow"></i>
  </a>
</ul>
@endif
```

 [1]: http://semantic-ui.com/
 [2]: http://laravel.com/api/class-Illuminate.Pagination.Paginator.html