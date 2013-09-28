Speckle
===

Behaviour driven development framework for testing Vim plugins written in [Riml][1].

[![Build Status](https://travis-ci.org/dsawardekar/speckle.png)](https://travis-ci.org/dsawardekar/speckle)

### About Riml
For people unfamiliar with `Riml`. [Riml][1] is a programming language that compiles to Vimscript. It's constructs are very similar to languages like `Ruby` and `Coffeescript`. It also provides a layer of abstraction to write OOP code that is converted to Vimscript's Funcref prototype chains.

### How Speckle works
Speckle uses `Riml`s object-oriented constructs to provide
a BDD testing framework for Riml. You can use it for both unit testing and functional testing. Using Riml and Speckle you can write Vim plugins using common OOP software idioms and have the same familar tools available in your development workflow.

Speckle is both a test compiler and test execution engine. It does compilation of the `_riml` specs with [Riml][1] and runs them in a Vim instance, capturing assertions, stacktraces and errors and reports them back after
closing the launched vim instance.

[1]:https://github.com/luke-gru/riml

Installation
===

    $ gem install speckle

Basic Usage
===

Here's an example using Speckle.

```ruby
riml_include 'dsl.riml'

class MyFirstSpec
  defm describe
    return 'My First Spec'
  end

  defm it_can_check_equality_of_strings
    my_string = 'v' . 'i' . 'm'
    expect(my_string).to_equal(vim)
  end
end
```

A test example is a `Riml` class with a test method that begins with `it`. You can optionally provide a `describe` method to change the displayed name for test in the reporter output.

Note the `riml_include dsl.riml`. This include provides Speckle's `expect` dsl for use inside the test examples. The path to this include is autoconfigured by Speckle. For including your own classes specify the path like `-I lib`. Where lib is the directory containing your Vim plugin .riml files.

Speckle looks for tests in the `spec` folder by default. The tests should be named in the form `{name}_spec.riml`. The above example could be saved as
`spec/my_first_spec.riml`. To run this test use,

    $ speckle

If the test succeeded you will get a message like,

```log
✓ 1 tests completed (5ms)
Passed: 1, Failures: 0, Errors: 0, Assertions: 1
```

If you change the input string to only `vi` and run it again you will
see a message like,

```log
EqualityMatcher #it can check equality of strings
    AssertionError: expected “vi” to equal “vim”


✖ 1 tests completed (5ms)
Passed: 0, Failures: 1, Errors: 0, Assertions: 0
```

Matchers
===

### Equivalence

```ruby
expect(actual).to_equal(expected)  # passes if actual == expected
expect(actual).to_not_equal(expected) # passes if actual != expected
```

Note: A type mismatch will be thrown when comparing values with
different types.

### Comparisons

```ruby
expect(actual).to_be_gt(expected) # -ve to_not_be_gt
expect(actual).to_be_gte(expected) # -ve to_not_be_gte
expect(actual).to_be_lte(expected) # -ve to_not_be_lte
expect(actual).to_be_lt(expected) # -ve to_not_be_lt
expect(actual).to_be_within([delta, expected]) # -ve to_not_be_within
expect(actual).to_be_between([min, max]) # -ve to_not_be_between
```

### Regular expressions

```ruby
expect(actual).to_match(pattern) # -ve to_not_match
```

### Boolean

```ruby
expect(actual).to_be_true(expected) # -ve to_be_false
expect(actual).to_be_ok(expected) # -ve to_not_be_ok
```

### Existance

```ruby
expect(actual).to_exist()  # passes if exists(actual) is not false
expect(actual).to_not_exist() # -ve
```

### Dictionary
```ruby
expect(actual).to_have_key(expected) # passes if actual is a dict with key expected
expect(actual).to_not_have_key(expected) # -ve
```
### Length

```ruby
expect(actual).to_have_length(expected)  # passes if len(actual) == expected
expect(actual).to_not_have_length(expected) # -ve
```

## Custom Matchers

In addition to the above default matchers you can create custom
matchers easily.

Consider a Person class in Riml.

```ruby
class Person
  def initialize(name)
    self.name = name
  end

  defm get_name()
    return self.name
  end
end
```

To write matcher to check if a person has the correct name we can
write a `PersonNameMatcher`. The class must implement the methods, `match`, `failure_message_for_match` and `failure_message_for_mismatch` as shown below.

```ruby
class PersonNameMatcher
  defm match(expected, actual)
    self.result = actual.get_name()
    return self.result == expected
  end

  defm failure_message_for_match(expected, actual)
    return "expected person name to be “#{expected}” but was “#{self.result}”"
  end

  defm failure_message_for_mismatch(expected, actual)
    return "expected person name to not be “#{expected}” but was “#{self.result}”"
  end
end

```

Then inside your spec you need to register this matcher using `define_matcher`,

```ruby
matcher = new PersonNameMatcher()
define_matcher('to_have_name', 'to_not_have_name', matcher)
```

Now in a test you can use the custom matcher methods, `to_have_name`, and it's negative `to_not_have_name`.

```ruby
defm it_can_check_for_persons_name
  expect(self.person).to_have_name('john')
end

defm it_can_check_for_negation_of_persons_name
  expect(self.person).to_not_have_name('foo')
end
```

Hooks
===

Speckle supports `before`, `before_each`, `after` and `after_each` hooks
that will be run before/after the entire suite or before/after every test.

```ruby
defm before
end

defm before_each
end

defm after
end

defm after_each
end
```

Logging (alternate to echomsg)
===

Speckle provides a logger that captures output messages without
halting execution of tests. This allows development of vim plugins
without needing to use `echomsg` extensively.

The logger api is,

```
get_logger().log(msg, ...)
get_logger().info(msg, ...)
get_logger().warn(msg, ...)
get_logger().error(msg, ...)
get_logger().debug(msg, ...)
```

When running the tests the error messages are shown inline like below.

```log
LoggerSpec
  ✓ it logs a message

      log: Hello World
      log: A test warning
      log: An error warning

```

Stacktraces
===

Another useful feature of Speckle is it displays stacktraces in a
meaningful form to help with debugging.

The example below has a call to an undefined function.

```ruby
defm it_has_unknown_function
  CallFooFunction()
end
```

When this test is run the following stacktrace will be shown.

```ruby
VariousErrorsSpec #it has unknown function
    Vim(call):E117: Unknown function: <SNR>144_CallFooFunction
       at <SNR>143_s:Speckle_run
       at <SNR>143_s:Runner_start
       at <SNR>143_s:SpecRunner_start
       at <SNR>144_s:VariousErrorsSpec_it_has_unknown_function, line 2
```

Isolated Testing
===

Speckle can be made to run only specific tests using the `--grep` option. For example, to only run tests in the `spec/models` folder use

        $ speckle --grep spec/models

Further to only run specific tests we can tag the test with a keyword, and then use `--tag keyword` to run only those tests. Tagging is done by adding a `_tagname` suffix to the test method name. For example to tag a spec with the tag `perf`, you would use,

```ruby
defm it_will_work_perf
end
```

And run the test with,

        $ speckle --tag perf

Both these flags can be combined to limit the tests run.

Complete Usage
===

    $ speckle [options] [file(s) OR directory]
    -a, --all                        Compile and run tests (default)
    -t, --test                       Only run tests
    -c, --compile                    Only compile tests

Options:

    -I, --libs <libs>                Specify additional riml library path(s)
    -g, --grep <pattern>             Only run tests matching the pattern
    -i, --invert                     Inverts --grep matches
    -r, --reporter <reporter>        Specify the reporter to use (spec, min, dot, tap, fivemat)
    -b, --bail                       Bail on first test failure
    -w, --watch                      Watch tests for changes
    -m, --vim <vim>                  Vim program used to test, default(vim)
    -s, --slow-threshold <ms>        Threshold in milliseconds to indicate slow tests
    -k, --skip-vimrc                 Does not load ~/.vimrc file
    -C, --no-colors                  Disable color output
    -v, --verbose                    Display verbose output
    -D, --debug                      Display debug output
    -V, --version                    Print Speckle version
    -h, --help                       Print Speckle help

## Contributing

1. Speckle uses [git flow](https://github.com/nvie/gitflow) based branching model.
2. Pull requests should go against the `develop` branch.
3. Try to include failing tests if possible.
