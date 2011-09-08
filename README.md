# Guard::Reloader

Reloader guard automatically reload file definition and launch proper tests when files are modified or created.

## Install

Please be sure to have [Guard](https://github.com/guard/guard) and Test::Unit installed before continue.

If you're using Bundler, add it to your `Gemfile` (inside the `development` group):

```ruby
gem 'guard-reloader'
```

and run:

```bash
$ bundle install
```

or manually install the gem:

```bash
$ gem install guard-reloader
```

Add Guard definition to your `Guardfile` by running this command:

```bash
$ guard init reloader
```

## Usage

```bash
$ cd [path-to-your-rails-project]
$ guard
```

## Guardfile

Guard::Reloader at the moment support only modification in model and controller.

```ruby
guard 'reloader' do
  watch(%r{^app/models/(.+)\.rb$})
  watch(%r{^test/unit/(.+)\.rb$})
  watch(%r{^app/controllers/(.+)\.rb$})
  watch(%r{^test/functional/(.+)\.rb$})
end
```

Please read the [Guard documentation](https://github.com/guard/guard#readme) for more info about the Guardfile DSL.

## Author

[Fajar Firdaus](https://github.com/fajarmf)


## Kudos

Many thanks to [Watchmen](https://github.com/watchmen) member.
