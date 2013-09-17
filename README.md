[![Build Status](https://travis-ci.org/wink/money-tree.png)](https://travis-ci.org/wink/money-tree) [![Coverage Status](https://coveralls.io/repos/wink/money-tree/badge.png?branch=master)](https://coveralls.io/r/wink/money-tree?branch=master) [![Code Climate](https://codeclimate.com/github/wink/money-tree.png)](https://codeclimate.com/github/wink/money-tree) [![Gem Version](https://badge.fury.io/rb/money-tree.png)](http://badge.fury.io/rb/money-tree)
# MoneyTree
### RSpec tested. Big Brother removed.

MoneyTree is a Ruby implementation of Bitcoin Wallets. Specifically, it supports [Hierachical Deterministic wallets](https://en.bitcoin.it/wiki/Deterministic_Wallet) according to the protocol specified in [BIP0032](https://en.bitcoin.it/wiki/BIP_0032).

___
If you find this helpful, please consider a small Bitcoin donation to<br>1nj2kie1hATcFbAaD7dEY53QaxNgt4KBp
![Donate BTC](https://raw.github.com/wink/money-tree/master/donation_btc_qr_code.gif)
___

## Why would I want an HD Wallet?
Hierarchical Deterministic (HD) Bitcoin Wallets offer several advantages over traditional Bitcoin wallets.

One of the problems with traditional Bitcoin wallets is that the wallet may hold a whole bunch of keypairs, each with Bitcoins attached to them. When you want to back up your wallet, you backup all of the current keys that you control in that wallet. However, if you later generate a new key, you need to make a brand new back up of your wallet. In fact, you need to back up your wallet every time you generate a new key.

### Easy backups

HD wallets allow you to create a huge number of Bitcoin keys (keypairs) that all derive from a parent master key. This means that if you control the master key, you can generate the entire tree of children keys. So instead of needing to make repeated backups of your wallet, you can create a single backup when you create the wallet, and from then on to the end of time, you will never need to make a new backup, because you can just recreate ALL of the child keys from your master key.

### Safely store your private keys offline
Additionally, HD wallets introduce cool new features to wallets, like being able to derive the entire tree of public keys from a parent public key without needing ANY private keys. For instance, let's say you have your master private key backed up on a paper wallet and stored offline in a safe somewhere, but you have the master public key available. Using just this public key, you can generate an entire tree of receive-only child public keys.

For instance, let's say you wanted to open a Bitcoin ecommerce website. With HD wallets, you can keep your master private key offline, and only put your public key onto the public webserver. Your website can then use that key to generate a receiving address for each and every product on your site, a unique address for each one of your customers, or even a key unique to each customer/product combo. (The uses are left up to your imagination.) And since the private key is stored offline, nobody will ever be able to hack your site and steal your Bitcoins.

### Access controls
One bonus feature of HD Wallets is that they give you a lot of control over who in your organization has access to which keys. Like an organizational chart for a business, HD wallets are arranged in a tree formation. You could create whole branches of keypairs for each department in your organization, and by giving each department only the private key at the top of their department branch, each department will only be able to spend the coins on their branch. However, since you hold the master key, you can watch and spend ALL coins in the entire tree.

### Accounting
Want to give your accountant access to view all transactions, but you don't want to give her access to spend any of your coins? No problem. You can simply give her the public key at any level in the tree that you desire, and she will be able to view transactions below that key in the tree, but won't be able to spend any of the coins.

## Where can I learn more?
- [A quick primer on deterministic wallets](https://en.bitcoin.it/wiki/Deterministic_wallet)
- [The official HD Wallet spec on the Bitcoin wiki](https://en.bitcoin.it/wiki/BIP_0032)
- [An awesome talk by Pieter Wuille at Bitcoin 2013 Conference](http://youtu.be/cfkCs4NdNss)

## Installation

Add this line to your application's Gemfile:

    gem 'money-tree'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install money-tree

## Prerequisites
MoneyTree will only work with Ruby 2.0.0 and greater. This is because the version of OpenSSL included with previous versions of Ruby did not include an OpenSSL::PKey::EC::Point#mul (point multiplication) method, which is required in order to calculate a Bitcoin public key from a private key.

If you have a serious problem with this and REALLY need it to work on previous versions of Ruby, bring it up in the Issues section on Github, and I'll try to get to it. Or better yet, submit a pull request with matching spec! (Hint: you'll need to use FFI and the OpenSSL c library directly)

## Usage

These instructions assume you have a decent understanding of how Bitcoin wallets operate and a cursory knowledge of how a [Hierarchical Deterministic Bitcoin Wallet (HD Wallet)](https://en.bitcoin.it/wiki/BIP_0032) works.

### Create a Master Node (seed)

To create a new HD Wallet, we're going to create a tree structure of private/public keypairs (nodes).  You'll first want to start with a master node. This master node should be seeded with at least 16 random bytes but preferably 32 random bytes from a cryptographically secure PRNG (pseudo-random number generator). 

DO NOT use a user generated password. Keep in mind that whoever controls the seed controls ALL coins in the entire tree, so it should not be left up to a human brain, because humans tend to follow patterns and patterns are subject to brute force attacks. Luckily, I've already included the seed generation by default so you don't need to create this on your own.

```ruby
# Create a new master node (with automatic seed generation)
@master = MoneyTree::Master.new
=> MoneyTree::Master instance
@master.seed
=> "N\xC5\x9DD\xAA\xCC\x80a\a\x96%8\xC8\x86\x81\x90\t\x82&\xE4\x97Ay\xECs\xD8\xB1M\xEA\xE6|\xEF"

# Or import an existing seed
@master = MoneyTree::Master.new seed_hex: "000102030405060708090a0b0c0d0e0f"
=> MoneyTree::Master instance
@master.seed
=> "\x00\x01\x02\x03\x04\x05\x06\a\b\t\n\v\f\r\x0E\x0F"
```

### Get info from a Node
`MoneyTree::Master` inherits from `MoneyTree::Node`, and you can do a lot of fun stuff with a node.

```ruby
# Here are some things you can do with a node.
@master.index # The index is a sequential identifier in relation to its parent node. (i.e. the nth child of its parent)
=> 0
@master.depth # How many steps down the tree this node is. (The master node is at depth 0, its direct child is at depth 1, and so on...)
=> 0
@master.to_identifier
=> "3442193e1bb70916e914552172cd4e2dbc9df811"
@master.to_fingerprint
=> "3442193e"
@master.to_address
=> "15mKKb2eos1hWa6tisdPwwDC1a5J1y9nma"
@master.private_key.to_hex
=> "e8f32e723decf4051aefac8e2c93c9c5b214313817cdb01a1494b917c8436b35"
@master.private_key.to_wif
=> "L52XzL2cMkHxqxBXRyEpnPQZGUs3uKiL3R11XbAdHigRzDozKZeW"
@master.public_key.to_hex
=> "0339a36013301597daef41fbe593a02cc513d0b55527ec2df1050e2e8ff49c85c2"
@master.chain_code_hex 
=> "873dff81c02f525623fd1fe5167eac3a55a049de3d314bb42ee227ffed37d508" # Look up chain codes in the BIP0032 spec
@master.to_serialized_hex(:private)
=> "0488ade4000000000000000000873dff81c02f525623fd1fe5167eac3a55a049de3d314bb42ee227ffed37d50800e8f32e723decf4051aefac8e2c93c9c5b214313817cdb01a1494b917c8436b35"
@master.to_serialized_address(:private)
=> "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi"
@master.to_serialized_hex
=> "0488b21e000000000000000000873dff81c02f525623fd1fe5167eac3a55a049de3d314bb42ee227ffed37d5080339a36013301597daef41fbe593a02cc513d0b55527ec2df1050e2e8ff49c85c2"
@master.to_serialized_address
=> "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8"
```

### Generate a child Node
In HD Wallets, we refer to children nodes by their path in relation to the master node. This is determined using a slash-delimited string where each part of the delimited string represents a node in increasing depth. For instance, the path "m/0/3" walks down the tree starting with "m" the master key. The first part "m" represents the master key at depth 0. The next part "0" (i=0) represents the first child (sequentially) of "m" (depth 1). The last part "3" (i=3) represents the fourth child node of the previous node (depth 2), and so on down the line. You can create as many depths of nodes as you like.

#### Chain codes
In HD wallets, chain codes are the mathematical glue that binds a parent node to its child node. We use chain codes in order to create a mathematical relationship between a parent and its child. You don't necessarily need to understand how chain codes work because this library abstracts it for you, but you do at least need to know that for any given node, if you'd like to calculate its child node, you'll need three pieces of information. The parent node's key (either private or public), the sequential index value of i for the child and the parent node's chain code.

You don't need to worry about chain codes if you are creating or importing from a Master key (it's always the same for all HD wallet master keys), however if you are trying to import a derived child key at some lower depth in the tree, you'll need the chain code. Luckily, whenever we export a node to a wallet file, we encode it in a special format that includes all of the relevant info (including chain code) that we need to reconstruct the node in a single convenient serialized address.

#### Serialized Addresses
Beacause we need multiple pieces of info to reconstruct nodes in a tree, when we're dealing with HD wallets, we pass around a serialized address format that encodes both the key and the chain code. It lookes like this:

```ruby
"xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi" # private key
"xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8" # public key
```

In addition to the key and the chain code, this encoding also includes info about the depth and index of the key, along with a fingerprint of its parent key (which I presume is for quickly sorting a big pile of keys into a tree).   
  
These are the addresses that you should use to represent each node in the tree structure, however these are NOT the bitcoin addresses you should pass around for receiving money. These are more for storing inside a wallet file so that you can reconstruct the tree.

To export a node to a serialized address, you can do:

```ruby
@node.to_serialized_address(:private) # for private keys
=> "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi"
@node.to_serialized_address
=> "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8"
```
    
To import from a serialized address: (either public or private)
```ruby
@node = MoneyTree::Node.from_serialized_address "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi"
=> MoneyTree::Node instance
```

#### Private derivation vs public derivation
You'll recall that HD Wallets allow us to generate an entire tree of private/public keypairs with a single parent private key. When we wish to generate child keypairs (that is, we want both the child private key and the child public key), we MUST have access to the parent private key. Using what's called "private derivation", we take the parent private key and its associated chain code along with a given index value (i.e. 0 = 1st child, 1 = 2nd child, (i-1) = ith child...), and we cryptomash&trade; them together to form a child private key and a new child chain code. This child key can then be used to generate its associated public key (in the same way we normally create Bitcoin public keys from private keys). The new chain code can be used to derive children of this child key and this process can keep repeating itself down the tree.

However, an added benefit of HD Wallets is that with JUST a public key, we can generate ALL public keys below that key. But how do we do this, since we don't have any private keys? We usually just put our private key in the Cryptomatic 2000 and out comes a public key. We accomplish this by using a second type of derivation called "public derivation". Using the power of a lot of math and elliptic curve formulae that look like it's straight out of _Good Will Hunting_, we can calculate the child public key directly from a parent public key. However, we cannot calculate the child private key. Therefore, if you only have a public key, you will only be able to derive other public keys. (That's a feature, not a bug.)

<!-- #### Values of i and what they mean
When we want to derive a key -->


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
