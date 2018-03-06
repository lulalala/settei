# Settei

Hash based configuration with flexibility and 12-factor app deployment in mind

## Design Philosophies

* Fast as it is accessible without loading Rails
* Ease of management as nested hash is allowed
* 12-factor compatible by serializing as environment variable.
* Minimal meta-programming magics, so you can add your flavor of magic.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'settei'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install settei

## Usage

For Rails, a rake task is available for simple setup:

    $ settei:install:rails

A `config/setting.rb` file is added for basic setup.
 
YAML files are added under `config/environments` and is ignored by git.

In your app, you can access the settings like this:

```ruby
Setting.dig(:google, :api, :secret)
```

## Settei::Base

`Settei::Base` is the core class for accessing the configurations. It is initialized by a hash. It is a light wrapper intended for you to extend.

`#dig` is used to access its values. It's convenient because it does not err if nested hash is absent.

`#dig_and_wrap` will return a `Settei::Base` if it the return value is a hash.

Install script maps `Setting` to an instance of `Settei::Base`, for convenience.

## Loader

`Settei::Loaders::SimpleLoader` is responsible for providing the hash to initialize `Settei::Base`. It loads from a source such as YAML or environment variable. It can also serialize the whole hash into one string, suitable for deploying via environment variables.

```ruby
loader = Settei::Loaders::SimpleLoader.new(dir: 'path/to/dir')
loader.load.as_hash # loads default.yml and returns a hash
loader.load(:production).as_env_value # loads production.yml and returns "XYZ"
loader.load(:test).as_env_assignment # loads test.yml and returns "APP_CONG=XYZ"
```

We welcome PRs for different types of loaders, as `SimpleLoader` is not suitable for every situation.

## Deployment

If `deploy.rb` is present, `rake settei:install:rails` will append code to it, allow serialized config to be passed as an environment variable.

## Frameworks other than Rails

Settei is designed to be simple so you can integrate it into any frameworks easily. The steps are mainly:

1. Designate a folder for storing YAML files.
2. Create a `setting.rb` file, in which `Settei::Base` is initialized (see `templates/setting.rb`)
3. Require it when framework starts.
4. Load and pass serialized production config as environment variable in deploy script (see `templates/_capistrano.rb` or `templates/_mina.rb`).

We also welcome PRs for generators of other frameworks too.

# Ruby < 2.3

`Settei::Base` uses `dig` to access the configuration, available since Ruby 2.3. If your Ruby is not new enough, don't be afraid. Write your own hash accessor literally takes minutes. You can even use `SettingsLogic.new(hash)` .

# FAQ

**Q:** Would serialized configuration be too big for environment variable?  
**A:** [The upper limit is pretty big.](https://stackoverflow.com/a/1078125/474597)


## TODO

* Integrate Rails configurations (e.g. database) into Settei.
* Explore deep merge hash so development.yml can combine with default.yml.
* Make loader configurable so it is easy to add and mix functionality.

