# Attribute

## Introduction

A class that publishes a getter or setter for an instance variable invites
client classes to become too intimate with its inner workings, and in
particular with its representation of state.

## Example

Given:

```Ruby
class Klass
  attr_accessor :dummy
end
```

`reek` would emit the following warning:

```
reek test.rb

test.rb -- 1 warning:
  [2]:Klass declares the writeable attribute dummy (Attribute)
```

## Support in Reek

When this detector is enabled it raises a warning for every public
`attr_writer`, `attr_accessor`, and `attr` with the writeable flag set to true.

Reek does not raise warnings for attribute getters.

## Configuration

`Attribute` supports only the [Basic Smell Options](Basic-Smell-Options.md).
