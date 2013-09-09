[![Build Status](https://travis-ci.org/wink/money-tree.png)](https://travis-ci.org/wink/money-tree) [![Coverage Status](https://coveralls.io/repos/wink/money-tree/badge.png?branch=master)](https://coveralls.io/r/wink/money-tree?branch=master) [![Gem Version](https://badge.fury.io/rb/money-tree.png)](http://badge.fury.io/rb/money-tree)
# MoneyTree

MoneyTree is a Ruby implementation of Bitcoin Wallets. Specifically, it supports [Hierachical Deterministic wallets](https://en.bitcoin.it/wiki/Deterministic_Wallet) according to the protocol specified in [BIP0032](https://en.bitcoin.it/wiki/BIP_0032).

If you find this helpful, please consider a small Bitcoin donation to 1nj2kie1hATcFbAaD7dEY53QaxNgt4KBp

## Installation

Add this line to your application's Gemfile:

    gem 'money-tree'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install money-tree

## Prerequisites
MoneyTree will only work with Ruby 2.0.0 and greater. This is because the version of OpenSSL included with previous versions of Ruby did not include an OpenSSL::PKey::EC::Point#mul (point multiplication) method, which is required in order to calculate a Bitcoin public key from a private key.

## Usage

Documentation coming very soon! For now, please feel free to browse the source and specs.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
