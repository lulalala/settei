# Settei [![Build Status](https://travis-ci.org/lulalala/settei.svg?branch=master)](https://travis-ci.org/lulalala/settei)

Config as YAML file yet still being 12-factor compliant...

...by serializing the file as one environment variable.

![Settei Illustrated](misc/illustrated.png?raw=true "Settei Illustrated")

## Features

* Can be read without loading Rails
* Variable namespacing using nested hash
* Follows 12-factor [rule 3](https://12factor.net/config) - store config in the environment
* Customizable due to loosely coupled PORO parts


## Installation

Insert into Gemfile:

```ruby
gem 'settei'
# gem 'dig_rb' # for Ruby < 2.3
```

And then execute:

    $ bundle

For Rails, execute this rake task for out-of-the-box setup:

    $ rake settei:install:rails

This task does the following things:

* create `config/setting.rb` for setting up `Setting`
* require the above in `config/application.rb`
* create YAML files `config/environments/default.yml` and `config/environments/production.yml`
* make git ignore YAML files above
* append script to `deploy.rb` so config is passed via env var to production

## Usage

If `config/environments/default.yml` contains the following:

```yaml
the_answer_to_life_the_universe_and_everything: 42
google:
  api: foo
```

Then you can access those like this:

```ruby
Setting.dig(:the_answer_to_life_the_universe_and_everything)
Setting.dig(:google, :api)
```

`#dig` is used to access its values. It's convenient because it does not err if nested hash is absent.

`#dig_and_wrap` will return a `Settei::Base` if the return value is a hash.

For other available methods, [check here](http://www.rubydoc.info/github/lulalala/settei/master/Settei/Base).

If you have `development.yml` or `test.yml`, it will be loaded instead of `default.yml`.

### Deploy

If you use Capistrano or Mina, the `deploy.rb` is modified so deploy process will serialize `production.yml` into one long string, and pass it to remote server as **a single environment variable**. There it is de-serialized and loaded, and the rest works the same way.

If you use Heroku, use `rake settei:heroku:config:set app=[app_name]` to upload your config. You need heroku-cli and authenticate first.

## Why

Most config gems have not been updated for ages, and do not meet my needs:

I want to be 12-factor compliant, but I also hate using environment variables. See the following example: naming is hard and names tend to be very long. Passing more env vars also becomes more impractical.

```
BOARD_PAGINATION_PER_PAGE=5
BOARD_PAGINATION_MAX_PAGE=10
BOARD_REPLY_OMIT_CONDITION_N_RECENT_ONLY=5
BOARD_REPLY_OMIT_CONDITION_AVOID_ONLY_N_HIDDEN=2
```

In comparison YAML allows nested hashes, so we can manage them using namespaces.

```yaml
board:
  pagination:
    per_page: 5
    max_page: 10
  reply_omit_condition:
    n_recent_only: 5
    avoid_only_n_hidden: 2
```

Can I have the benefit of env var (12-factor) and the benefit of YAML (ease of variable management) at the same time?

Yes, if settings are stored in YAML files, but during deploy, transfer the whole YAML **file** as one env var.

I feel it is simpler and more effective.

## Tips

Rails `secrets.yml` and `credentials.yml.enc` are needlessly complex, and now we are able to ignore them:

Do away with Rails 4.1 secret.yml with something like this:
```ruby
# secret_token.rb
Foo::Application.config.secret_token = Setting.dig(:rails, :secret_token)
Foo::Application.config.secret_key_base = Setting.dig(:rails, :secret_key_base)
```

Similarly with Rails 5.2's credentials:

```ruby
# application.rb
config.secret_token = Setting.dig(:rails, :secret_token) 
config.secret_key_base = Setting.dig(:rails, :secret_key_base) 
```

Maybe we can get rid of `database.yml` one day too.

## Customization

The default setup is probably good enough for 90% of the users. However if you have advanced requirements, you can easily customize.

One can start by editing the generated `setting.rb` file. The three parts are `Settei::Base`, loader and deploy script:

### Settei::Base

`Setting` is an instance of `Settei::Base`, the accessor of the configurations. It is initialized by a hash.

You can change `Setting` to other constants or a global variable.

You can also extend `Settei::Base`, or replace it with other classes such as `SettingsLogic.new(hash)`, or you can just use the hash without it.

### Loader

Loaders are responsible for returning the configuration as hash, used to initialize `Settei::Base`.

`Settei::Loaders::SimpleLoader` is one type of loader. It loads from YAML or environment variable. 

When initializing it, you can set:

* `dir`: the full path to directory containing YAML files
* `env_name`: the environment variable name; defaults to APP_CONFIG

```ruby
loader = Settei::Loaders::SimpleLoader.new(dir: 'path/to/dir')
```

To load data, call `load(Rails.env)`. In development environment, it tries to load `development.yml` if it exists, else it loads `default.yml`.

Once data is loaded, we can obtain it in hash form by calling `as_hash`.

The deploy script also relies on loader's ability to serialize the whole hash into one string, suitable for deploying as environment variable. The methods `as_env_assignment` and `as_env_value` are provided for this purpose, e.g.:

```ruby
loader.load.as_hash # loads default.yml and returns a hash
loader.load(:production).as_env_value # loads production.yml and returns "XYZ"
loader.load(:test).as_env_assignment # loads test.yml and returns "APP_CONG=XYZ"
```

But no one is stopping you from writing your own loader. For example you might want the loader to encrypt/decrypt ENV value, or you may want to load from .env file.

For more detailed doc of `SimpleLoader`, [check here](http://www.rubydoc.info/github/lulalala/settei/master/Settei/Loaders/SimpleLoader).

### Deploy script

If you have more complex deploy requirements, just edit/revert the changes on `deploy.rb`.

### Frameworks other than Rails

Settei is designed to be simple so you can integrate it into any frameworks easily. The steps are mainly:

1. Designate a folder for storing YAML files.
2. Create a `setting.rb` file, in which `Settei::Base` is initialized (see `templates/setting.rb`).
3. Require it when framework starts.
4. Load production.yml, pass its serialized form as environment variable to production (see `templates/_capistrano.rb` or `templates/_mina.rb`).

## FAQ

**Q:** Would serialized configuration be too big for environment variable?  
**A:** [The upper limit is pretty big.](https://stackoverflow.com/a/1078125/474597)

## Contribution

The slogan "YAML config yet still 12-factor compliant" is not entirely correct. Why not load from TOML or .env? If there is a need we can accommodate for that.

PRs are welcomed. Some ideas are:

* generators for other frameworks
* loader or its plugins
* plugin for `Settei::Base`
* explore deep merge hash so development.yml can combine with default.yml
* make loader configurable so it is easy to add and mix functionality
* rake task for heroku setup
