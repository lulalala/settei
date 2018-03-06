# Settei

Hash based configuration with flexibility and 12-factor deployment in mind

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

```shell
rake settei:install:rails
```

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
loader.load(:production).as_env_value # loads production.yml and returns XYZ
loader.load(:test).as_env_assignment # loads test.yml and returns APP_CONG=XYZ
```

We welcome PR for different types of loaders, as `SimpleLoader` is not suitable for every situation.

## Deployment

If `deploy.rb` is present, `rake settei:install:rails` would append code to it, so serialized config is passed as an environment variable, compliant to 12-factor deployment.

## Sinatra, Hanami

Settei is really simple so it won't take much time to integrate into other frameworks, the steps are mainly:

1. Designate a folder for storing YAML files.
2. Create a `setting.rb` file, in which `Settei::Base` is initialized (see `templates/setting.rb`)
3. Require it when framework starts.
4. Load and pass serialized production config as environment variable in deploy script (see `templates/_capistrano.rb` or `templates/_mina.rb`).

## Design Philosophies

### Accessible outside of application

Setting should be accessible by itself, because for application like Rails, the boot time is too slow.

### Manage settings using a hash

Using hash to manage settings makes life easier. For one thing it can be nested, acting as a namespace. A hash of setting can also be fetched and used a method call arugments, reducing lines of code.

### Compliant with 12-factor manifesto

Settings can be passed on to deploy server as environment variable.

### PORO

Minimal meta-programming magics are used, so you can add your flavor of magic without causing conflicts.
