# Using `reek` inside your Ruby application

## Installation

Either standalone via

```bash
gem install reek
```

or by adding

```
gem 'reek'
```

to your Gemfile.

## Quick start

Assuming you have a file called "dirty.rb" with the following content

```Ruby
class Dirty
  def m(a,b,c)
    puts a,b
  end
end
```

in your working directory you can run `reek` on this file like this:

```ruby
require 'reek'

source = Pathname.new 'dirty.rb'

reporter = Reek::Report::TextReport.new
examiner = Reek::Examiner.new(source)
reporter.add_examiner examiner
reporter.show
```

This would output on STDOUT:

```
dirty.rb -- 4 warnings:
  [2]:Dirty#m has the name 'm' (UncommunicativeMethodName)
  [2]:Dirty#m has the parameter name 'a' (UncommunicativeParameterName)
  [2]:Dirty#m has the parameter name 'b' (UncommunicativeParameterName)
  [2]:Dirty#m has unused parameter 'c' (UnusedParameters)
```

Note that `Reek::Examiner.new` can take `source` as `String`, `Pathname`, `File` or `IO`.

## Choosing your output format

Besides normal text output, `reek` can generate output in YAML,
JSON, HTML and XML by using the following Report types:

```
TextReport
YAMLReport
JSONReport
HTMLReport
XMLReport
```

## Configuration

You can pass an `AppConfiguration` object to your `Examiner` which will allow you to make
this a configurable as when running `reek` standalone (see [configuration file](../README.md#configuration-file)
and [configuration loading](../README.md#configuration-loading) for details).

Let's say you have the following file in your root directory called "dirty.rb":

```Ruby
class C
end
```

This file would normally reek of `IrresponsibleModule` and `UncommunicativeModuleName`.

Given you have the following configuration file called `config.reek` in your root directory as well:

```Yaml
---
IrresponsibleModule:
  enabled: false
```

You can now use this like that:

```Ruby
require 'reek'

path = Pathname.new 'config.reek'
configuration = Reek::Configuration::AppConfiguration.new OpenStruct.new(config_file: path)
# We are are aware that having pass something like `OpenStruct.new(config_file: path)`is
# not exactly elegant and will fix this in the future

source = Pathname.new 'dirty.rb'

reporter = Reek::Report::TextReport.new
examiner = Reek::Examiner.new(source)
reporter.add_examiner examiner
reporter.show

```

which now would only report the `UncommunicativeModuleName`, but not the `IrresponsibleModule`:

```
dirty.rb -- 1 warning:
  C has the name 'C' (UncommunicativeModuleName)
```

## Accessing the smell warnings directly

You can also access the smells detected by an examiner directly:

```ruby
require 'reek'

source = <<-END
  class C
  end
END

examiner = Reek::Examiner.new(source)
examiner.smells.each do |smell|
  puts smell.message
end
```

`Examiner#smells` returns a list of `SmellWarning` objects.
