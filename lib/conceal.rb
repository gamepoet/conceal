require 'conceal/version'
require 'base64'
require 'openssl'
require 'securerandom'

module Conceal
  class << self
    FORMAT_VERSION  = 1
    FIELD_SEPARATOR = ':'

    # Encrypts the given plaintext string.
    #
    # @param plaintext  [String]  the plaintext string to encrypt
    # @param opts       [Hash]    additional options
    #
    # @option opts [String] :algorithm  the cipher algorithm to use (defaults to 'aes-25c-cbc')
    # @option opts [String] :key        the secret shared key
    def encrypt(plaintext, opts = {})
      opts = {
        algorithm: 'aes-256-cbc',
      }.merge(opts)
      key       = opts[:key]
      algorithm = opts[:algorithm]
      raise ArgumentError.new(':key option missing') if key.to_s.empty?
      salt = SecureRandom.hex(128)

      # setup the cipher
      cipher = OpenSSL::Cipher::Cipher.new(algorithm)
      cipher.encrypt
      iv = cipher.random_iv
      cipher.iv = iv
      cipher.key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(key, salt, 2000, cipher.key_len)

      # encrypt
      ciphertext = cipher.update(plaintext)
      ciphertext << cipher.final

      # MAC
      digest = OpenSSL::Digest.new('sha256')
      hmac = OpenSSL::HMAC.digest(digest, key, ciphertext)

      [
        FORMAT_VERSION,
        algorithm,
        encode64(iv),
        encode64(salt),
        encode64(hmac),
        encode64(ciphertext),
      ].join(FIELD_SEPARATOR)
    end

    # Decrypts the given encrypted string.
    #
    # @param data [String]    the encrypted string to decrypt
    # @param opts [Hash]      additional options
    #
    # @option opts [String] :key    the secret shared key
    def decrypt(data, opts = {})
      key = opts[:key]
      raise ArgumentError.new(':key option missing') if key.to_s.empty?

      ver, algorithm, iv64, salt64, hmac64, ciphertext64 = data.split(FIELD_SEPARATOR, 6)
      raise ArgumentError.new('ciphertext has unknown version') unless ver == FORMAT_VERSION.to_s

      iv         = Base64.decode64(iv64)
      salt       = Base64.decode64(salt64)
      hmac       = Base64.decode64(hmac64)
      ciphertext = Base64.decode64(ciphertext64)

      # validate the hmac
      digest = OpenSSL::Digest.new('sha256')
      actual_hmac = OpenSSL::HMAC.digest(digest, key, ciphertext)
      raise ArgumentError.new('HMAC mismatch') unless actual_hmac == hmac

      # decrypt
      cipher = OpenSSL::Cipher::Cipher.new(algorithm)
      cipher.decrypt
      cipher.iv = iv
      cipher.key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(key, salt, 2000, cipher.key_len)

      plaintext = cipher.update(ciphertext)
      plaintext << cipher.final
      plaintext
    end

    private
      def encode64(value)
        Base64.encode64(value).gsub(/[\r\n]/, '')
      end
  end
end
