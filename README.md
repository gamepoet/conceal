# Conceal

Simple OpenSSL-based string encryption using a shared secret.

## Requirements

* Ruby 1.9.3 or newer

## Installation

Add this line to your application's Gemfile:

    gem 'conceal'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install conceal

## Usage

```ruby
encrypted = Conceal.encrypt('some plaintext', key: 'your shared secret', algorithm: 'aes-256-cbc')
decrypted = Conceal.decrypt(encrypted, key: 'your shared secret')
```

## Authors

* Ben Scott (<gamepoet@gmail.com>)
