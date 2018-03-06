# Settei

Hash based configuration with flexibility and 12-factor app deployment in mind

## Design Philosophies

* Fast as it is accessible without loading Rails
* Ease of management as nested hash is allowed
* 12-factor compliant by serializing as environment variable.
* Minimal meta-programming magics, so you can add your flavor of magic.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'settei'
```

And then execute:

    $ bundle

For Rails, execute this rake task for out-of-the-box setup:

    $ rake settei:install:rails

This task does the following things:

* create `config/setting.rb` for setting up `Setting`.
* load above in `config/application.rb`
* create YAML files `config/environments/default.yml` and `config/environments/production.yml`
* make git ignore YAML files above
* append script to `deploy.rb` so config is pass via environement variable to production

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

`#dig_and_wrap` will return a `Settei::Base` if it the return value is a hash.

For other available methods, [check here](http://www.rubydoc.info/github/lulalala/settei/master/Settei/Base).

If you have `development.yml` or `test.yml`, it will be loaded instead of `default.yml`.

## Why

Rails `secrets.yml` and `credentials.yml.enc` are messy and complex. I already forgot which to version control and which not to.

Not to mention all the major config gems have not been updated for ages.

I want to be 12-factor app compliant, deploy with ease without copy config file to production server. However I hate using environment variables: naming is hard and names tend to be very long. Instead I like nestable hash in `SettingsLogic`.

Compare the following. The old ENV way of manage settings is clunky, and passing more than 5 env vars is also impractical.
```
BOARD_PAGINATION_PER_PAGE=5
BOARD_PAGINATION_MAX_PAGE=10
BOARD_REPLY_OMIT_CONDITION_N_RECENT_ONLY=5
BOARD_REPLY_OMIT_CONDITION_AVOID_ONLY_N_HIDDEN=2
```

In comparison YAML and nested hash is easy. You know why I write SASS instead of CSS.

```yaml
board:
  pagination:
    per_page: 5
    max_page: 10
  reply_omit_condition:
    n_recent_only: 5
    avoid_only_n_hidden: 2
```

Can I have the benefit of env var (12-factor) and benefit of YAML (ease of variable mangement) at the same time?

Yes, if settings are stored in YAML files, but during deploy, transfer the whole YAML **file** as one env var.

I feel it is simpler and more effective.

## Customization

Settei is design to be customizable. One can start by editing the generated `setting.rb` file. The three parts involved are:

### Settei::Base 

`Setting` is an instance of `Settei::Base`, the core class for accessing the configurations. It is initialized by a hash. It is a light wrapper intended for you to extend to.

You can change `Setting` to other constants or a global variable.

You can also replace `Settei::Base` with your own accessor class, or you can just use the hash as is.

#### Ruby < 2.3

`Settei::Base` uses `dig` to access the configuration, available since Ruby 2.3. If your Ruby is not new enough, why not write your own hash wrapper. You can even use `SettingsLogic.new(hash)` 

### Loader

Loaders are responsible for returning the configuration as hash, used to initialize `Settei::Base`.

`Settei::Loaders::SimpleLoader` is one type of loader. It loads from YAML or environment variable. 

When initializing it, you can set:

* `dir`: the full path to directory containing YAML files
* `env_name`: the environment variable name; defaults to APP_CONFIG

```ruby
loader = Settei::Loaders::SimpleLoader.new(dir: 'path/to/dir')
```

To load data, call `load(Rails.env)`. The passed parameter will try to load `development.yml` if it exists, else it loads `default.yml`.

Once data is loaded, we can obtain it in hash form by calling `as_hash`

The deploy script also rely on its ability to serialize the whole hash into one string, suitable for deploying as an environment variable. The methods `as_env_assignment` and `as_env_value` are provided for this.

Here are sample calls:

```ruby
loader.load.as_hash # loads default.yml and returns a hash
loader.load(:production).as_env_value # loads production.yml and returns "XYZ"
loader.load(:test).as_env_assignment # loads test.yml and returns "APP_CONG=XYZ"
```

But no one is stopping you from writing your own loader. For example you might want the loader to encrypt/decrypt ENV value, or you may want to load from .env file.

For more detailed doc of `SimpleLoader`, [check here](http://www.rubydoc.info/github/lulalala/settei/master/Settei/Loaders/SimpleLoader).

### Deploy

If you don't care about 12-factor app, you can roll your own solution to just copy the yml file to production ¯\_(ツ)_/¯.

### Frameworks other than Rails

Settei is designed to be simple so you can integrate it into any frameworks easily. The steps are mainly:

1. Designate a folder for storing YAML files.
2. Create a `setting.rb` file, in which `Settei::Base` is initialized (see `templates/setting.rb`)
3. Require it when framework starts.
4. Load and pass serialized production config as environment variable in deploy script (see `templates/_capistrano.rb` or `templates/_mina.rb`).

## FAQ

**Q:** Would serialized configuration be too big for environment variable?  
**A:** [The upper limit is pretty big.](https://stackoverflow.com/a/1078125/474597)

## Tips

Do away with Rails' secret.yml with something like this:
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

## TODO

* Integrate Rails configurations (e.g. database) into Settei.
* Explore deep merge hash so development.yml can combine with default.yml.
* Make loader configurable so it is easy to add and mix functionality.
* Rake task for heroku setup

## Contribution

Some PR ideas are:

* generators for other frameworks
* loader or its plugin
* plugin for `Settei::Base`

