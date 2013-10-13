xmlish
======

String interpolation from xml-like text.

Usage Examples
--------------

A simple example

```ruby
template = "Press <red><bold>ENTER</bold></red> or <bold><red>ESC</red></bold>"
callbacks = {
  'red' => lambda { |str| "$#{str}$" },
  'bold' => lambda { |str| "**#{str}**" }
}
Xmlish.parse(template, callbacks) #=> "Press $**ENTER**$ or **$ESC$**"
```

See spec directory for more examples.
