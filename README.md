# Speckle

Behaviour driven development framework for the Riml programming language.

## Installation

    $ gem install speckle

## Usage

    $ speckle [options] [file(s) OR directory]
    -a, --all                        Compile and run tests (default)
    -t, --test                       Only run tests
    -c, --compile                    Only compile tests

Options:

    -I, --libs <libs>                Specify additional riml library path(s)
    -g, --grep <pattern>             Only run tests matching the pattern
    -i, --invert                     Inverts --grep matches
    -r, --reporter <reporter>        Specify the reporter to use (spec, min, dot, tap)
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

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
