require 'thor'

module Conceal
  class CLI < Thor
    map %w(d de dec) => :decrypt
    map %w(e en enc) => :encrypt
    map %w(-v --version) => :version

    option :newline, aliases: '-n', type: :boolean, desc: 'print a trailing newline character'
    desc 'decrypt [OPTIONS] KEY_FILE', 'decrypt stdin using the given key file'
    def decrypt(key_file)
      require 'conceal'

      # load the key
      raise Thor::Error, 'ERROR: key file is not readable or does not exist' unless File.readable?(key_file)
      key = IO.read(key_file)

      # decrypt from stdin
      encrypted_data = $stdin.read
      plaintext = Conceal.decrypt(encrypted_data, key: key)

      $stdout.write(plaintext)
      $stdout.write("\n") if options[:newline]
    end

    option :newline, aliases: '-n', type: :boolean, desc: 'print a trailing newline character'
    desc 'encrypt [OPTIONS] KEY_FILE', 'encrypt stdin using the given key file'
    def encrypt(key_file)
      require 'conceal'

      # load the key
      raise Thor::Error, 'ERROR: key file is not readable or does not exist' unless File.readable?(key_file)
      key = IO.read(key_file)

      # encrypt from stdin
      plaintext = $stdin.read
      encrypted_data = Conceal.encrypt(plaintext, key: key)

      $stdout.write(encrypted_data)
      $stdout.write("\n") if options[:newline]
    end

    desc 'version', 'display the version and exit'
    def version
      require 'conceal/version'
      puts VERSION
    end

  protected
    def self.exit_on_failure?
      true
    end
  end
end
