# Conceal

Simple OpenSSL-based string encryption using a shared secret. The algorithm, initialization vector, salt, crypttext, and HMAC are all encoded into a single string so it is easy to copy around.

## Requirements

* Ruby 1.9.3 or newer

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'conceal'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install conceal
```

## Usage

This gem provides both a ruby library and some command-line utilities.

### Library

```ruby
encrypted = Conceal.encrypt('some plaintext', key: 'your shared secret', algorithm: 'aes-256-cbc')
decrypted = Conceal.decrypt(encrypted, key: 'your shared secret')
```

### Command-line

```
$ ruby -rsecurerandom -e 'print SecureRandom.urlsafe_base64(32)' | conceal encrypt key.file | pbcopy
$ pbpaste | conceal decrypt key.file | pbcopy
```

## Authors

* Ben Scott (<gamepoet@gmail.com>)
