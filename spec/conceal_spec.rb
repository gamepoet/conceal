require 'spec_helper'

describe Conceal do
  let(:key) { SecureRandom.hex(128) }

  it 'has a version number' do
    expect(Conceal::VERSION).not_to be nil
  end

  it 'encrypt then decrypt returns the same original plaintext' do
    expect(Conceal.decrypt(Conceal.encrypt('hello', key: key), key: key)).to eq('hello')
  end

  describe '#encrypt' do
    it 'does not return the plaintext' do
      expect(Conceal.encrypt('hello', key: key)).not_to eq('hello')
    end

    it 'outputs different values each time (different iv/salt)' do
      first  = Conceal.encrypt('hello', key: key)
      second = Conceal.encrypt('hello', key: key)

      expect(first).not_to eq(second)
    end
  end
end
