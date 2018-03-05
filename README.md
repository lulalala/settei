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

```ruby
rake settei:rails:install
```

A `config/setting.rb` file is added for basic setup.
 
Three YAML files are added for each environment (e.g. `config/environments/development.yml`). You should add settings inside those. They are ignored by git.

In your app, you can access the settings like this:

```ruby
Setting.dig(:google, :api, :secret)
```

## Deployment

If `deploy.rb` is present, `rake settei:rails:install` would append code to it, so serialized config is passed as an environment variable, compliant to 12-factor deployment.

For other web frameworks, imitate what's being appended in `templates/_capistrano.rb` or `templates/_mina.rb`. It's really simple code.

## Accessor and Loader

**Accessor** is the class that reads your hash configuration. You can then add convenience methods into it.

**Loader** loads a hash from sources (e.g. YAML or environment variable), which can then be passed to accessor. It can also serialize the whole hash into one string, suitable for environment variables.

## Design Philosophies

### Accessible outside of application

Setting should be accessible by itself, because for application like Rails, the boot time is too slow.

### Manage settings using a hash

Using hash to manage settings makes life easier. For one thing it can be nested, acting as a namespace. A hash of setting can also be fetched and used a method call arugments, reducing lines of code.

### Compliant with 12-factor manifesto

Settings can be passed on to deploy server as environment variable.

### PORO

Minimal meta-programming magics are used, so you can add your flavor of magic without causing conflicts.
