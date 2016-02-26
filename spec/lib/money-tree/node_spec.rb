require 'spec_helper'

# Test vectors from https://en.bitcoin.it/wiki/BIP_0032_TestVectors
describe MoneyTree::Master do
  describe "initialize" do
    describe "without a seed" do
      before do
        @master = MoneyTree::Master.new
      end

      it "generates a random seed 32 bytes long" do
        expect(@master.seed.bytesize).to eql(32)
      end

      it "exports the seed in hex format" do
        expect(@master).to respond_to(:seed_hex)
        expect(@master.seed_hex.size).to eql(64)
      end
    end

    context "testnet" do
      before do
        @master = MoneyTree::Master.new network: :bitcoin_testnet
      end

      it "generates testnet address" do
        expect(%w(m n)).to include(@master.to_address(network: :bitcoin_testnet)[0])
      end

      it "generates testnet compressed wif" do
        expect(@master.private_key.to_wif(network: :bitcoin_testnet)[0]).to eql('c')
      end

      it "generates testnet uncompressed wif" do
        expect(@master.private_key.to_wif(compressed: false, network: :bitcoin_testnet)[0]).to eql('9')
      end

      it "generates testnet serialized private address" do
        expect(@master.to_bip32(:private, network: :bitcoin_testnet).slice(0, 4)).to eql("tprv")
      end

      it "generates testnet serialized public address" do
        expect(@master.to_bip32(network: :bitcoin_testnet).slice(0, 4)).to eql("tpub")
      end

      it "imports from testnet serialized private address" do
        node = MoneyTree::Node.from_bip32 'tprv8ZgxMBicQKsPcuN7bfUZqq78UEYapr3Tzmc9NcDXw8BnBJ47dZYr6SusnfYj7vbAYP9CP8ZiD5aVBTUo1yU5QP56mepKVvuEbu8KZQXMKNE'
        expect(node.to_bip32(:private, network: :bitcoin_testnet)).to eql('tprv8ZgxMBicQKsPcuN7bfUZqq78UEYapr3Tzmc9NcDXw8BnBJ47dZYr6SusnfYj7vbAYP9CP8ZiD5aVBTUo1yU5QP56mepKVvuEbu8KZQXMKNE')
      end

      it "imports from testnet serialized public address" do
        node = MoneyTree::Node.from_bip32 'tpubD6NzVbkrYhZ4YA8aUE9bBZTSyHJibBqwDny5urfwDdJc4W8od3y3Ebzy6CqsYn9CCC5P5VQ7CeZYpnT1kX3RPVPysU2rFRvYSj8BCoYYNqT'
        expect(%w(m n)).to include(node.public_key.to_s(network: :bitcoin_testnet)[0])
        expect(node.to_bip32(network: :bitcoin_testnet)).to eql('tpubD6NzVbkrYhZ4YA8aUE9bBZTSyHJibBqwDny5urfwDdJc4W8od3y3Ebzy6CqsYn9CCC5P5VQ7CeZYpnT1kX3RPVPysU2rFRvYSj8BCoYYNqT')
      end

      it "generates testnet subnodes from serialized private address" do
        node = MoneyTree::Node.from_bip32 'tprv8ZgxMBicQKsPcuN7bfUZqq78UEYapr3Tzmc9NcDXw8BnBJ47dZYr6SusnfYj7vbAYP9CP8ZiD5aVBTUo1yU5QP56mepKVvuEbu8KZQXMKNE'
        subnode = node.node_for_path('1/1/1')
        expect(%w(m n)).to include(subnode.public_key.to_s(network: :bitcoin_testnet)[0])
        expect(subnode.to_bip32(:private, network: :bitcoin_testnet).slice(0,4)).to eql('tprv')
        expect(subnode.to_bip32(network: :bitcoin_testnet).slice(0,4)).to eql('tpub')
      end

      it "generates testnet subnodes from serialized public address" do
        node = MoneyTree::Node.from_bip32 'tpubD6NzVbkrYhZ4YA8aUE9bBZTSyHJibBqwDny5urfwDdJc4W8od3y3Ebzy6CqsYn9CCC5P5VQ7CeZYpnT1kX3RPVPysU2rFRvYSj8BCoYYNqT'
        subnode = node.node_for_path('1/1/1')
        expect(%w(m n)).to include(subnode.public_key.to_s(network: :bitcoin_testnet)[0])
        expect(subnode.to_bip32(network: :bitcoin_testnet).slice(0,4)).to eql('tpub')
      end
    end

    describe "Test vector 1" do
      describe "from a seed" do
        before do
          @master = MoneyTree::Master.new seed_hex: "000102030405060708090a0b0c0d0e0f"
        end

        describe "m" do
          it "has an index of 0" do
            expect(@master.index).to eql(0)
          end

          it "is private" do
            expect(@master.is_private?).to eql(true)
          end

          it "has a depth of 0" do
            expect(@master.depth).to eql(0)
          end

          it "generates master node (Master)" do
            expect(@master.to_identifier).to eql("3442193e1bb70916e914552172cd4e2dbc9df811")
            expect(@master.to_fingerprint).to eql("3442193e")
            expect(@master.to_address).to eql("15mKKb2eos1hWa6tisdPwwDC1a5J1y9nma")
          end

          it "generates a secret key" do
            expect(@master.private_key.to_hex).to eql("e8f32e723decf4051aefac8e2c93c9c5b214313817cdb01a1494b917c8436b35")
            expect(@master.private_key.to_wif).to eql("L52XzL2cMkHxqxBXRyEpnPQZGUs3uKiL3R11XbAdHigRzDozKZeW")
          end

          it "generates a public key" do
            expect(@master.public_key.to_hex).to eql("0339a36013301597daef41fbe593a02cc513d0b55527ec2df1050e2e8ff49c85c2")
          end

          it "generates a chain code" do
            expect(@master.chain_code_hex).to eql("873dff81c02f525623fd1fe5167eac3a55a049de3d314bb42ee227ffed37d508")
          end

          it "generates a serialized private key" do
            expect(@master.to_serialized_hex(:private)).to eql("0488ade4000000000000000000873dff81c02f525623fd1fe5167eac3a55a049de3d314bb42ee227ffed37d50800e8f32e723decf4051aefac8e2c93c9c5b214313817cdb01a1494b917c8436b35")
            expect(@master.to_bip32(:private)).to eql("xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi")
          end

          it "generates a serialized public_key" do
            expect(@master.to_serialized_hex).to eql("0488b21e000000000000000000873dff81c02f525623fd1fe5167eac3a55a049de3d314bb42ee227ffed37d5080339a36013301597daef41fbe593a02cc513d0b55527ec2df1050e2e8ff49c85c2")
            expect(@master.to_bip32).to eql("xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8")
          end
        end

        describe "m/0p" do
          before do
            @node = @master.node_for_path "m/0p"
          end

          it "has an index of 2147483648" do
            expect(@node.index).to eql(2147483648)
          end

          it "is private" do
            expect(@node.is_private?).to eql(true)
          end

          it "has a depth of 1" do
            expect(@node.depth).to eql(1)
          end

          it "generates subnode" do
            expect(@node.to_identifier).to eql("5c1bd648ed23aa5fd50ba52b2457c11e9e80a6a7")
            expect(@node.to_fingerprint).to eql("5c1bd648")
            expect(@node.to_address).to eql("19Q2WoS5hSS6T8GjhK8KZLMgmWaq4neXrh")
          end

          it "generates a private key" do
            expect(@node.private_key.to_hex).to eql("edb2e14f9ee77d26dd93b4ecede8d16ed408ce149b6cd80b0715a2d911a0afea")
            expect(@node.private_key.to_wif).to eql("L5BmPijJjrKbiUfG4zbiFKNqkvuJ8usooJmzuD7Z8dkRoTThYnAT")
          end

          it "generates a public key" do
            expect(@node.public_key.to_hex).to eql("035a784662a4a20a65bf6aab9ae98a6c068a81c52e4b032c0fb5400c706cfccc56")
          end

          it "generates a chain code" do
            expect(@node.chain_code_hex).to eql("47fdacbd0f1097043b78c63c20c34ef4ed9a111d980047ad16282c7ae6236141")
          end

          it "generates a serialized private key" do
            expect(@node.to_serialized_hex(:private)).to eql("0488ade4013442193e8000000047fdacbd0f1097043b78c63c20c34ef4ed9a111d980047ad16282c7ae623614100edb2e14f9ee77d26dd93b4ecede8d16ed408ce149b6cd80b0715a2d911a0afea")
            expect(@node.to_bip32(:private)).to eql("xprv9uHRZZhk6KAJC1avXpDAp4MDc3sQKNxDiPvvkX8Br5ngLNv1TxvUxt4cV1rGL5hj6KCesnDYUhd7oWgT11eZG7XnxHrnYeSvkzY7d2bhkJ7")
          end

          it "generates a serialized public_key" do
            expect(@node.to_serialized_hex).to eql("0488b21e013442193e8000000047fdacbd0f1097043b78c63c20c34ef4ed9a111d980047ad16282c7ae6236141035a784662a4a20a65bf6aab9ae98a6c068a81c52e4b032c0fb5400c706cfccc56")
            expect(@node.to_bip32).to eql("xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw")
          end
        end

        describe "m/0p.pub" do
          before do
            @node = @master.node_for_path "m/0p.pub"
          end

          it "has an index of 2147483648" do
            expect(@node.index).to eql(2147483648)
          end

          it "is private" do
            expect(@node.is_private?).to eql(true)
          end

          it "has a depth of 1" do
            expect(@node.depth).to eql(1)
          end

          it "generates subnode" do
            expect(@node.to_identifier).to eql("5c1bd648ed23aa5fd50ba52b2457c11e9e80a6a7")
            expect(@node.to_fingerprint).to eql("5c1bd648")
            expect(@node.to_address).to eql("19Q2WoS5hSS6T8GjhK8KZLMgmWaq4neXrh")
          end

          it "does not generate a private key" do
            expect(@node.private_key).to be_nil
          end

          it "generates a public key" do
            expect(@node.public_key.to_hex).to eql("035a784662a4a20a65bf6aab9ae98a6c068a81c52e4b032c0fb5400c706cfccc56")
          end

          it "generates a chain code" do
            expect(@node.chain_code_hex).to eql("47fdacbd0f1097043b78c63c20c34ef4ed9a111d980047ad16282c7ae6236141")
          end

          it "does not generate a serialized private key" do
            expect { @node.to_serialized_hex(:private) }.to raise_error(MoneyTree::Node::PrivatePublicMismatch)
          end

          it "generates a serialized public_key" do
            expect(@node.to_serialized_hex).to eql("0488b21e013442193e8000000047fdacbd0f1097043b78c63c20c34ef4ed9a111d980047ad16282c7ae6236141035a784662a4a20a65bf6aab9ae98a6c068a81c52e4b032c0fb5400c706cfccc56")
            expect(@node.to_bip32).to eql("xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw")
          end
        end

        describe "m/0'/1" do
          before do
            @node = @master.node_for_path "m/0'/1"
          end

          it "has an index of 1" do
            expect(@node.index).to eql(1)
          end

          it "is public" do
            expect(@node.is_private?).to eql(false)
          end

          it "has a depth of 2" do
            expect(@node.depth).to eql(2)
          end

          it "generates subnode" do
            expect(@node.to_identifier).to eql("bef5a2f9a56a94aab12459f72ad9cf8cf19c7bbe")
            expect(@node.to_fingerprint).to eql("bef5a2f9")
            expect(@node.to_address).to eql("1JQheacLPdM5ySCkrZkV66G2ApAXe1mqLj")
          end

          it "generates a private key" do
            expect(@node.private_key.to_hex).to eql("3c6cb8d0f6a264c91ea8b5030fadaa8e538b020f0a387421a12de9319dc93368")
            expect(@node.private_key.to_wif).to eql("KyFAjQ5rgrKvhXvNMtFB5PCSKUYD1yyPEe3xr3T34TZSUHycXtMM")
          end

          it "generates a public key" do
            expect(@node.public_key.to_hex).to eql("03501e454bf00751f24b1b489aa925215d66af2234e3891c3b21a52bedb3cd711c")
          end

          it "generates a chain code" do
            expect(@node.chain_code_hex).to eql("2a7857631386ba23dacac34180dd1983734e444fdbf774041578e9b6adb37c19")
          end

          it "generates a serialized private key" do
            expect(@node.to_serialized_hex(:private)).to eql("0488ade4025c1bd648000000012a7857631386ba23dacac34180dd1983734e444fdbf774041578e9b6adb37c19003c6cb8d0f6a264c91ea8b5030fadaa8e538b020f0a387421a12de9319dc93368")
            expect(@node.to_bip32(:private)).to eql("xprv9wTYmMFdV23N2TdNG573QoEsfRrWKQgWeibmLntzniatZvR9BmLnvSxqu53Kw1UmYPxLgboyZQaXwTCg8MSY3H2EU4pWcQDnRnrVA1xe8fs")
          end

          it "generates a serialized public_key" do
            expect(@node.to_serialized_hex).to eql("0488b21e025c1bd648000000012a7857631386ba23dacac34180dd1983734e444fdbf774041578e9b6adb37c1903501e454bf00751f24b1b489aa925215d66af2234e3891c3b21a52bedb3cd711c")
            expect(@node.to_bip32).to eql("xpub6ASuArnXKPbfEwhqN6e3mwBcDTgzisQN1wXN9BJcM47sSikHjJf3UFHKkNAWbWMiGj7Wf5uMash7SyYq527Hqck2AxYysAA7xmALppuCkwQ")
          end
        end

        describe "M/0'/1" do
          before do
            @node = @master.node_for_path "M/0'/1"
          end

          it "has an index of 1" do
            expect(@node.index).to eql(1)
          end

          it "is public" do
            expect(@node.is_private?).to eql(false)
          end

          it "has a depth of 2" do
            expect(@node.depth).to eql(2)
          end

          it "generates subnode" do
            expect(@node.to_identifier).to eql("bef5a2f9a56a94aab12459f72ad9cf8cf19c7bbe")
            expect(@node.to_fingerprint).to eql("bef5a2f9")
            expect(@node.to_address).to eql("1JQheacLPdM5ySCkrZkV66G2ApAXe1mqLj")
          end

          it "does not generate a private key" do
            expect(@node.private_key).to be_nil
          end

          it "generates a public key" do
            expect(@node.public_key.to_hex).to eql("03501e454bf00751f24b1b489aa925215d66af2234e3891c3b21a52bedb3cd711c")
          end

          it "generates a chain code" do
            expect(@node.chain_code_hex).to eql("2a7857631386ba23dacac34180dd1983734e444fdbf774041578e9b6adb37c19")
          end

          it "generates a serialized private key" do
            expect { @node.to_serialized_hex(:private) }.to raise_error(MoneyTree::Node::PrivatePublicMismatch)
          end

          it "generates a serialized public_key" do
            expect(@node.to_serialized_hex).to eql("0488b21e025c1bd648000000012a7857631386ba23dacac34180dd1983734e444fdbf774041578e9b6adb37c1903501e454bf00751f24b1b489aa925215d66af2234e3891c3b21a52bedb3cd711c")
            expect(@node.to_bip32).to eql("xpub6ASuArnXKPbfEwhqN6e3mwBcDTgzisQN1wXN9BJcM47sSikHjJf3UFHKkNAWbWMiGj7Wf5uMash7SyYq527Hqck2AxYysAA7xmALppuCkwQ")
          end
        end

        describe "m/0'/1/2p/2" do
          before do
            @node = @master.node_for_path "m/0'/1/2p/2"
          end

          it "has an index of 2" do
            expect(@node.index).to eql(2)
          end

          it "is public" do
            expect(@node.is_private?).to eql(false)
          end

          it "has a depth of 4" do
            expect(@node.depth).to eql(4)
          end

          it "generates subnode" do
            expect(@node.to_identifier).to eql("d880d7d893848509a62d8fb74e32148dac68412f")
            expect(@node.to_fingerprint).to eql("d880d7d8")
            expect(@node.to_address).to eql("1LjmJcdPnDHhNTUgrWyhLGnRDKxQjoxAgt")
          end

          it "generates a private key" do
            expect(@node.private_key.to_hex).to eql("0f479245fb19a38a1954c5c7c0ebab2f9bdfd96a17563ef28a6a4b1a2a764ef4")
            expect(@node.private_key.to_wif).to eql("KwjQsVuMjbCP2Zmr3VaFaStav7NvevwjvvkqrWd5Qmh1XVnCteBR")
          end

          it "generates a public key" do
            expect(@node.public_key.to_hex).to eql("02e8445082a72f29b75ca48748a914df60622a609cacfce8ed0e35804560741d29")
          end

          it "generates a chain code" do
            expect(@node.chain_code_hex).to eql("cfb71883f01676f587d023cc53a35bc7f88f724b1f8c2892ac1275ac822a3edd")
          end

          it "generates a serialized private key" do
            expect(@node.to_serialized_hex(:private)).to eql("0488ade404ee7ab90c00000002cfb71883f01676f587d023cc53a35bc7f88f724b1f8c2892ac1275ac822a3edd000f479245fb19a38a1954c5c7c0ebab2f9bdfd96a17563ef28a6a4b1a2a764ef4")
            expect(@node.to_bip32(:private)).to eql("xprvA2JDeKCSNNZky6uBCviVfJSKyQ1mDYahRjijr5idH2WwLsEd4Hsb2Tyh8RfQMuPh7f7RtyzTtdrbdqqsunu5Mm3wDvUAKRHSC34sJ7in334")
          end

          it "generates a serialized public_key" do
            expect(@node.to_serialized_hex).to eql("0488b21e04ee7ab90c00000002cfb71883f01676f587d023cc53a35bc7f88f724b1f8c2892ac1275ac822a3edd02e8445082a72f29b75ca48748a914df60622a609cacfce8ed0e35804560741d29")
            expect(@node.to_bip32).to eql("xpub6FHa3pjLCk84BayeJxFW2SP4XRrFd1JYnxeLeU8EqN3vDfZmbqBqaGJAyiLjTAwm6ZLRQUMv1ZACTj37sR62cfN7fe5JnJ7dh8zL4fiyLHV")
          end
        end

        describe "m/0'/1/2'/2/1000000000" do
          before do
            @node = @master.node_for_path "m/0'/1/2'/2/1000000000"
          end

          it "has an index of 1000000000" do
            expect(@node.index).to eql(1000000000)
          end

          it "is public" do
            expect(@node.is_private?).to eql(false)
          end

          it "has a depth of 2" do
            expect(@node.depth).to eql(5)
          end

          it "generates subnode" do
            expect(@node.to_identifier).to eql("d69aa102255fed74378278c7812701ea641fdf32")
            expect(@node.to_fingerprint).to eql("d69aa102")
            expect(@node.to_address).to eql("1LZiqrop2HGR4qrH1ULZPyBpU6AUP49Uam")
          end

          it "generates a private key" do
            expect(@node.private_key.to_hex).to eql("471b76e389e528d6de6d816857e012c5455051cad6660850e58372a6c3e6e7c8")
            expect(@node.private_key.to_wif).to eql("Kybw8izYevo5xMh1TK7aUr7jHFCxXS1zv8p3oqFz3o2zFbhRXHYs")
          end

          it "generates a public key" do
            expect(@node.public_key.to_hex).to eql("022a471424da5e657499d1ff51cb43c47481a03b1e77f951fe64cec9f5a48f7011")
          end

          it "generates a chain code" do
            expect(@node.chain_code_hex).to eql("c783e67b921d2beb8f6b389cc646d7263b4145701dadd2161548a8b078e65e9e")
          end

          it "generates a serialized private key" do
            expect(@node.to_serialized_hex(:private)).to eql("0488ade405d880d7d83b9aca00c783e67b921d2beb8f6b389cc646d7263b4145701dadd2161548a8b078e65e9e00471b76e389e528d6de6d816857e012c5455051cad6660850e58372a6c3e6e7c8")
            expect(@node.to_bip32(:private)).to eql("xprvA41z7zogVVwxVSgdKUHDy1SKmdb533PjDz7J6N6mV6uS3ze1ai8FHa8kmHScGpWmj4WggLyQjgPie1rFSruoUihUZREPSL39UNdE3BBDu76")
          end

          it "generates a serialized public_key" do
            expect(@node.to_serialized_hex).to eql("0488b21e05d880d7d83b9aca00c783e67b921d2beb8f6b389cc646d7263b4145701dadd2161548a8b078e65e9e022a471424da5e657499d1ff51cb43c47481a03b1e77f951fe64cec9f5a48f7011")
            expect(@node.to_bip32).to eql("xpub6H1LXWLaKsWFhvm6RVpEL9P4KfRZSW7abD2ttkWP3SSQvnyA8FSVqNTEcYFgJS2UaFcxupHiYkro49S8yGasTvXEYBVPamhGW6cFJodrTHy")
          end
        end
      end
    end

    describe "Test vector 2" do
      describe "from a seed" do
        before do
          @master = MoneyTree::Master.new seed_hex: "fffcf9f6f3f0edeae7e4e1dedbd8d5d2cfccc9c6c3c0bdbab7b4b1aeaba8a5a29f9c999693908d8a8784817e7b7875726f6c696663605d5a5754514e4b484542"
        end

        describe "m" do
          it "has an index of 0" do
            expect(@master.index).to eql(0)
          end

          it "has a depth of 0" do
            expect(@master.depth).to eql(0)
          end

          it "is private" do
            expect(@master.is_private?).to eql(true)
          end

          it "generates master node (Master)" do
            expect(@master.to_identifier).to eql("bd16bee53961a47d6ad888e29545434a89bdfe95")
            expect(@master.to_fingerprint).to eql("bd16bee5")
            expect(@master.to_address).to eql("1JEoxevbLLG8cVqeoGKQiAwoWbNYSUyYjg")
          end

          it "generates compressed and uncompressed addresses" do
            expect(@master.to_address).to eql("1JEoxevbLLG8cVqeoGKQiAwoWbNYSUyYjg")
            expect(@master.to_address(true)).to eql("1JEoxevbLLG8cVqeoGKQiAwoWbNYSUyYjg")
            expect(@master.to_address(false)).to eql("1AEg9dFEw29kMgaN4BNHALu7AzX5XUfzSU")
          end

          it "generates a secret key" do
            expect(@master.private_key.to_hex).to eql("4b03d6fc340455b363f51020ad3ecca4f0850280cf436c70c727923f6db46c3e")
            expect(@master.private_key.to_wif).to eql("KyjXhyHF9wTphBkfpxjL8hkDXDUSbE3tKANT94kXSyh6vn6nKaoy")
          end

          it "generates a public key" do
            expect(@master.public_key.to_hex).to eql("03cbcaa9c98c877a26977d00825c956a238e8dddfbd322cce4f74b0b5bd6ace4a7")
          end

          it "generates a chain code" do
            expect(@master.chain_code_hex).to eql("60499f801b896d83179a4374aeb7822aaeaceaa0db1f85ee3e904c4defbd9689")
          end

          it "generates a serialized private key" do
            expect(@master.to_serialized_hex(:private)).to eql("0488ade400000000000000000060499f801b896d83179a4374aeb7822aaeaceaa0db1f85ee3e904c4defbd9689004b03d6fc340455b363f51020ad3ecca4f0850280cf436c70c727923f6db46c3e")
            expect(@master.to_bip32(:private)).to eql("xprv9s21ZrQH143K31xYSDQpPDxsXRTUcvj2iNHm5NUtrGiGG5e2DtALGdso3pGz6ssrdK4PFmM8NSpSBHNqPqm55Qn3LqFtT2emdEXVYsCzC2U")
          end

          it "generates a serialized public_key" do
            expect(@master.to_serialized_hex).to eql("0488b21e00000000000000000060499f801b896d83179a4374aeb7822aaeaceaa0db1f85ee3e904c4defbd968903cbcaa9c98c877a26977d00825c956a238e8dddfbd322cce4f74b0b5bd6ace4a7")
            expect(@master.to_bip32).to eql("xpub661MyMwAqRbcFW31YEwpkMuc5THy2PSt5bDMsktWQcFF8syAmRUapSCGu8ED9W6oDMSgv6Zz8idoc4a6mr8BDzTJY47LJhkJ8UB7WEGuduB")
          end
        end

        describe "m/0 (testing imported private key)" do
          before do
            @master = MoneyTree::Master.new private_key: @master.private_key, chain_code: @master.chain_code
            @node = @master.node_for_path "m/0"
          end

          it "has an index of 0" do
            expect(@node.index).to eql(0)
          end

          it "has a depth of 1" do
            expect(@node.depth).to eql(1)
          end

          it "is public" do
            expect(@node.is_private?).to eql(false)
          end

          it "generates subnode" do
            expect(@node.to_identifier).to eql("5a61ff8eb7aaca3010db97ebda76121610b78096")
            expect(@node.to_fingerprint).to eql("5a61ff8e")
            expect(@node.to_address).to eql("19EuDJdgfRkwCmRzbzVBHZWQG9QNWhftbZ")
          end

          it "generates a private key" do
            expect(@node.private_key.to_hex).to eql("abe74a98f6c7eabee0428f53798f0ab8aa1bd37873999041703c742f15ac7e1e")
            expect(@node.private_key.to_wif).to eql("L2ysLrR6KMSAtx7uPqmYpoTeiRzydXBattRXjXz5GDFPrdfPzKbj")
          end

          it "generates a public key" do
            expect(@node.public_key.to_hex).to eql("02fc9e5af0ac8d9b3cecfe2a888e2117ba3d089d8585886c9c826b6b22a98d12ea")
          end

          it "generates a chain code" do
            expect(@node.chain_code_hex).to eql("f0909affaa7ee7abe5dd4e100598d4dc53cd709d5a5c2cac40e7412f232f7c9c")
          end

          it "generates a serialized private key" do
            expect(@node.to_serialized_hex(:private)).to eql("0488ade401bd16bee500000000f0909affaa7ee7abe5dd4e100598d4dc53cd709d5a5c2cac40e7412f232f7c9c00abe74a98f6c7eabee0428f53798f0ab8aa1bd37873999041703c742f15ac7e1e")
            expect(@node.to_bip32(:private)).to eql("xprv9vHkqa6EV4sPZHYqZznhT2NPtPCjKuDKGY38FBWLvgaDx45zo9WQRUT3dKYnjwih2yJD9mkrocEZXo1ex8G81dwSM1fwqWpWkeS3v86pgKt")
          end

          it "generates a serialized public_key" do
            expect(@node.to_serialized_hex).to eql("0488b21e01bd16bee500000000f0909affaa7ee7abe5dd4e100598d4dc53cd709d5a5c2cac40e7412f232f7c9c02fc9e5af0ac8d9b3cecfe2a888e2117ba3d089d8585886c9c826b6b22a98d12ea")
            expect(@node.to_bip32).to eql("xpub69H7F5d8KSRgmmdJg2KhpAK8SR3DjMwAdkxj3ZuxV27CprR9LgpeyGmXUbC6wb7ERfvrnKZjXoUmmDznezpbZb7ap6r1D3tgFxHmwMkQTPH")
          end
        end

        describe "M/0 (testing import of public key)" do
          before do
            @master = MoneyTree::Master.new public_key: "03cbcaa9c98c877a26977d00825c956a238e8dddfbd322cce4f74b0b5bd6ace4a7", chain_code: @master.chain_code
            @node = @master.node_for_path "M/0"
          end

          it "has an index of 0" do
            expect(@node.index).to eql(0)
          end

          it "has a depth of 1" do
            expect(@node.depth).to eql(1)
          end

          it "is public" do
            expect(@node.is_private?).to eql(false)
          end

          it "generates subnode" do
            expect(@node.to_identifier).to eql("5a61ff8eb7aaca3010db97ebda76121610b78096")
            expect(@node.to_fingerprint).to eql("5a61ff8e")
            expect(@node.to_address).to eql("19EuDJdgfRkwCmRzbzVBHZWQG9QNWhftbZ")
          end

          it "does not generate a private key" do
            expect(@node.private_key).to be_nil
          end

          it "generates a public key" do
            expect(@node.public_key.to_hex).to eql("02fc9e5af0ac8d9b3cecfe2a888e2117ba3d089d8585886c9c826b6b22a98d12ea")
          end

          it "generates a chain code" do
            expect(@node.chain_code_hex).to eql("f0909affaa7ee7abe5dd4e100598d4dc53cd709d5a5c2cac40e7412f232f7c9c")
          end

          it "does not generate a serialized private key" do
            expect { @node.to_serialized_hex(:private) }.to raise_error(MoneyTree::Node::PrivatePublicMismatch)
            expect { @node.to_bip32(:private) }.to raise_error(MoneyTree::Node::PrivatePublicMismatch)
          end

          it "generates a serialized public_key" do
            expect(@node.to_serialized_hex).to eql("0488b21e01bd16bee500000000f0909affaa7ee7abe5dd4e100598d4dc53cd709d5a5c2cac40e7412f232f7c9c02fc9e5af0ac8d9b3cecfe2a888e2117ba3d089d8585886c9c826b6b22a98d12ea")
            expect(@node.to_bip32).to eql("xpub69H7F5d8KSRgmmdJg2KhpAK8SR3DjMwAdkxj3ZuxV27CprR9LgpeyGmXUbC6wb7ERfvrnKZjXoUmmDznezpbZb7ap6r1D3tgFxHmwMkQTPH")
          end
        end

        describe "m/0/2147483647'" do
          before do
            @node = @master.node_for_path "m/0/2147483647'"
          end

          it "has an index of 2147483647" do
            expect(@node.index).to eql(4294967295)
          end

          it "has a depth of 2" do
            expect(@node.depth).to eql(2)
          end

          it "is private" do
            expect(@node.is_private?).to eql(true)
          end

          it "generates subnode" do
            expect(@node.to_identifier).to eql("d8ab493736da02f11ed682f88339e720fb0379d1")
            expect(@node.to_fingerprint).to eql("d8ab4937")
            expect(@node.to_address).to eql("1Lke9bXGhn5VPrBuXgN12uGUphrttUErmk")
          end

          it "generates a private key" do
            expect(@node.private_key.to_hex).to eql("877c779ad9687164e9c2f4f0f4ff0340814392330693ce95a58fe18fd52e6e93")
            expect(@node.private_key.to_wif).to eql("L1m5VpbXmMp57P3knskwhoMTLdhAAaXiHvnGLMribbfwzVRpz2Sr")
          end

          it "generates a public key" do
            expect(@node.public_key.to_hex).to eql("03c01e7425647bdefa82b12d9bad5e3e6865bee0502694b94ca58b666abc0a5c3b")
          end

          it "generates a chain code" do
            expect(@node.chain_code_hex).to eql("be17a268474a6bb9c61e1d720cf6215e2a88c5406c4aee7b38547f585c9a37d9")
          end

          it "generates a serialized private key" do
            expect(@node.to_serialized_hex(:private)).to eql("0488ade4025a61ff8effffffffbe17a268474a6bb9c61e1d720cf6215e2a88c5406c4aee7b38547f585c9a37d900877c779ad9687164e9c2f4f0f4ff0340814392330693ce95a58fe18fd52e6e93")
            expect(@node.to_bip32(:private)).to eql("xprv9wSp6B7kry3Vj9m1zSnLvN3xH8RdsPP1Mh7fAaR7aRLcQMKTR2vidYEeEg2mUCTAwCd6vnxVrcjfy2kRgVsFawNzmjuHc2YmYRmagcEPdU9")
          end

          it "generates a serialized public_key" do
            expect(@node.to_serialized_hex).to eql("0488b21e025a61ff8effffffffbe17a268474a6bb9c61e1d720cf6215e2a88c5406c4aee7b38547f585c9a37d903c01e7425647bdefa82b12d9bad5e3e6865bee0502694b94ca58b666abc0a5c3b")
            expect(@node.to_bip32).to eql("xpub6ASAVgeehLbnwdqV6UKMHVzgqAG8Gr6riv3Fxxpj8ksbH9ebxaEyBLZ85ySDhKiLDBrQSARLq1uNRts8RuJiHjaDMBU4Zn9h8LZNnBC5y4a")
          end
        end

        describe "m/0/2147483647'/1" do
          before do
            @node = @master.node_for_path "m/0/2147483647'/1"
          end

          it "has an index of 1" do
            expect(@node.index).to eql(1)
          end

          it "has a depth of 3" do
            expect(@node.depth).to eql(3)
          end

          it "is private" do
            expect(@node.is_private?).to eql(false)
          end

          it "generates subnode" do
            expect(@node.to_identifier).to eql("78412e3a2296a40de124307b6485bd19833e2e34")
            expect(@node.to_fingerprint).to eql("78412e3a")
            expect(@node.to_address).to eql("1BxrAr2pHpeBheusmd6fHDP2tSLAUa3qsW")
          end

          it "generates a private key" do
            expect(@node.private_key.to_hex).to eql("704addf544a06e5ee4bea37098463c23613da32020d604506da8c0518e1da4b7")
            expect(@node.private_key.to_wif).to eql("KzyzXnznxSv249b4KuNkBwowaN3akiNeEHy5FWoPCJpStZbEKXN2")
          end

          it "generates a public key" do
            expect(@node.public_key.to_hex).to eql("03a7d1d856deb74c508e05031f9895dab54626251b3806e16b4bd12e781a7df5b9")
          end

          it "generates a chain code" do
            expect(@node.chain_code_hex).to eql("f366f48f1ea9f2d1d3fe958c95ca84ea18e4c4ddb9366c336c927eb246fb38cb")
          end

          it "generates a serialized private key" do
            expect(@node.to_serialized_hex(:private)).to eql("0488ade403d8ab493700000001f366f48f1ea9f2d1d3fe958c95ca84ea18e4c4ddb9366c336c927eb246fb38cb00704addf544a06e5ee4bea37098463c23613da32020d604506da8c0518e1da4b7")
            expect(@node.to_bip32(:private)).to eql("xprv9zFnWC6h2cLgpmSA46vutJzBcfJ8yaJGg8cX1e5StJh45BBciYTRXSd25UEPVuesF9yog62tGAQtHjXajPPdbRCHuWS6T8XA2ECKADdw4Ef")
          end

          it "generates a serialized public_key" do
            expect(@node.to_serialized_hex).to eql("0488b21e03d8ab493700000001f366f48f1ea9f2d1d3fe958c95ca84ea18e4c4ddb9366c336c927eb246fb38cb03a7d1d856deb74c508e05031f9895dab54626251b3806e16b4bd12e781a7df5b9")
            expect(@node.to_bip32).to eql("xpub6DF8uhdarytz3FWdA8TvFSvvAh8dP3283MY7p2V4SeE2wyWmG5mg5EwVvmdMVCQcoNJxGoWaU9DCWh89LojfZ537wTfunKau47EL2dhHKon")
          end
        end

        describe "m/0/2147483647p/1/2147483646p" do
          before do
            @node = @master.node_for_path "m/0/2147483647p/1/2147483646p"
          end

          it "has an index of 4294967294" do
            expect(@node.index).to eql(4294967294)
          end

          it "has a depth of 4" do
            expect(@node.depth).to eql(4)
          end

          it "is private" do
            expect(@node.is_private?).to eql(true)
          end

          it "generates subnode" do
            expect(@node.to_identifier).to eql("31a507b815593dfc51ffc7245ae7e5aee304246e")
            expect(@node.to_fingerprint).to eql("31a507b8")
            expect(@node.to_address).to eql("15XVotxCAV7sRx1PSCkQNsGw3W9jT9A94R")
          end

          it "generates a private key" do
            expect(@node.private_key.to_hex).to eql("f1c7c871a54a804afe328b4c83a1c33b8e5ff48f5087273f04efa83b247d6a2d")
            expect(@node.private_key.to_wif).to eql("L5KhaMvPYRW1ZoFmRjUtxxPypQ94m6BcDrPhqArhggdaTbbAFJEF")
          end

          it "generates a public key" do
            expect(@node.public_key.to_hex).to eql("02d2b36900396c9282fa14628566582f206a5dd0bcc8d5e892611806cafb0301f0")
          end

          it "generates a chain code" do
            expect(@node.chain_code_hex).to eql("637807030d55d01f9a0cb3a7839515d796bd07706386a6eddf06cc29a65a0e29")
          end

          it "generates a serialized private key" do
            expect(@node.to_serialized_hex(:private)).to eql("0488ade40478412e3afffffffe637807030d55d01f9a0cb3a7839515d796bd07706386a6eddf06cc29a65a0e2900f1c7c871a54a804afe328b4c83a1c33b8e5ff48f5087273f04efa83b247d6a2d")
            expect(@node.to_bip32(:private)).to eql("xprvA1RpRA33e1JQ7ifknakTFpgNXPmW2YvmhqLQYMmrj4xJXXWYpDPS3xz7iAxn8L39njGVyuoseXzU6rcxFLJ8HFsTjSyQbLYnMpCqE2VbFWc")
          end

          it "generates a serialized public_key" do
            expect(@node.to_serialized_hex).to eql("0488b21e0478412e3afffffffe637807030d55d01f9a0cb3a7839515d796bd07706386a6eddf06cc29a65a0e2902d2b36900396c9282fa14628566582f206a5dd0bcc8d5e892611806cafb0301f0")
            expect(@node.to_bip32).to eql("xpub6ERApfZwUNrhLCkDtcHTcxd75RbzS1ed54G1LkBUHQVHQKqhMkhgbmJbZRkrgZw4koxb5JaHWkY4ALHY2grBGRjaDMzQLcgJvLJuZZvRcEL")
          end
        end

        describe "m/0/2147483647p/1/2147483646p/2" do
          before do
            @node = @master.node_for_path "m/0/2147483647p/1/2147483646p/2"
          end

          it "has an index of 2" do
            expect(@node.index).to eql(2)
          end

          it "has a depth of 4" do
            expect(@node.depth).to eql(5)
          end

          it "is public" do
            expect(@node.is_private?).to eql(false)
          end

          it "generates subnode" do
            expect(@node.to_identifier).to eql("26132fdbe7bf89cbc64cf8dafa3f9f88b8666220")
            expect(@node.to_fingerprint).to eql("26132fdb")
            expect(@node.to_address).to eql("14UKfRV9ZPUp6ZC9PLhqbRtxdihW9em3xt")
          end

          it "generates a private key" do
            expect(@node.private_key.to_hex).to eql("bb7d39bdb83ecf58f2fd82b6d918341cbef428661ef01ab97c28a4842125ac23")
            expect(@node.private_key.to_wif).to eql("L3WAYNAZPxx1fr7KCz7GN9nD5qMBnNiqEJNJMU1z9MMaannAt4aK")
          end

          it "generates a public key" do
            expect(@node.public_key.to_hex).to eql("024d902e1a2fc7a8755ab5b694c575fce742c48d9ff192e63df5193e4c7afe1f9c")
          end

          it "generates a chain code" do
            expect(@node.chain_code_hex).to eql("9452b549be8cea3ecb7a84bec10dcfd94afe4d129ebfd3b3cb58eedf394ed271")
          end

          it "generates a serialized private key" do
            expect(@node.to_serialized_hex(:private)).to eql("0488ade40531a507b8000000029452b549be8cea3ecb7a84bec10dcfd94afe4d129ebfd3b3cb58eedf394ed27100bb7d39bdb83ecf58f2fd82b6d918341cbef428661ef01ab97c28a4842125ac23")
            expect(@node.to_bip32(:private)).to eql("xprvA2nrNbFZABcdryreWet9Ea4LvTJcGsqrMzxHx98MMrotbir7yrKCEXw7nadnHM8Dq38EGfSh6dqA9QWTyefMLEcBYJUuekgW4BYPJcr9E7j")
          end

          it "generates a serialized public_key" do
            expect(@node.to_serialized_hex).to eql("0488b21e0531a507b8000000029452b549be8cea3ecb7a84bec10dcfd94afe4d129ebfd3b3cb58eedf394ed271024d902e1a2fc7a8755ab5b694c575fce742c48d9ff192e63df5193e4c7afe1f9c")
            expect(@node.to_bip32).to eql("xpub6FnCn6nSzZAw5Tw7cgR9bi15UV96gLZhjDstkXXxvCLsUXBGXPdSnLFbdpq8p9HmGsApME5hQTZ3emM2rnY5agb9rXpVGyy3bdW6EEgAtqt")
          end
        end
      end
    end

    describe "negative index" do
      before do
        @master = MoneyTree::Master.new seed_hex: "000102030405060708090a0b0c0d0e0f"
        @node = @master.node_for_path "m/0'/-1"
      end

      it "has an index of 1" do
        expect(@node.index).to eql(-1)
      end

      it "is public" do
        expect(@node.is_private?).to eql(true)
      end

      it "has a depth of 2" do
        expect(@node.depth).to eql(2)
      end

      it "generates a serialized private key" do
        expect(@node.to_serialized_hex(:private)).to eql("0488ade4025c1bd648ffffffff0f9ca680ee23c81a305d96b86f811947e65590200b6f74d66ecf83936313a9c900235893db08ad0efc6ae4a1eac5b31a90a7d0906403d139d4d7f3c6796fb42c4e")
        expect(@node.to_bip32(:private)).to eql("xprv9wTYmMFvAM7JHf3RuUidc24a4y2t4gN7aNP5ABreWAqt6BUBcf6xE8RNQxj2vUssYWM8iAZiZi5H1fmKkkpXjtwDCDv1pg8fSfQMk9rhHYt")
      end

      it "generates a serialized public_key" do
        expect(@node.to_serialized_hex).to eql("0488b21e025c1bd648ffffffff0f9ca680ee23c81a305d96b86f811947e65590200b6f74d66ecf83936313a9c902adb7979a5e99bf8acdfec3680bf482feac9898b28808c22d47db62e98de5d3fa")
        expect(@node.to_bip32).to eql("xpub6ASuArnozifbW97u1WFdyA1JczsNU95xwbJfxaGG4WNrxyoLACRCmvjrGEojsRsoZULf5FyZXv6AWAtce2UErsshvkpjNaT1fP6sMgTZdc1")
      end
    end

    describe "importing node" do
      describe ".from_bip32(address)" do
        it "imports a valid private node address" do
          @node = MoneyTree::Node.from_bip32 "xprv9uHRZZhk6KAJC1avXpDAp4MDc3sQKNxDiPvvkX8Br5ngLNv1TxvUxt4cV1rGL5hj6KCesnDYUhd7oWgT11eZG7XnxHrnYeSvkzY7d2bhkJ7"
          expect(@node.private_key.to_hex).to eql("edb2e14f9ee77d26dd93b4ecede8d16ed408ce149b6cd80b0715a2d911a0afea")
          expect(@node.index).to eql(2147483648)
          expect(@node.is_private?).to eql(true)
          expect(@node.depth).to eql(1)
          expect(@node.public_key.to_hex).to eql("035a784662a4a20a65bf6aab9ae98a6c068a81c52e4b032c0fb5400c706cfccc56")
          expect(@node.chain_code_hex).to eql("47fdacbd0f1097043b78c63c20c34ef4ed9a111d980047ad16282c7ae6236141")
          expect(@node.parent_fingerprint).to eql("3442193e")
        end

        it "imports a valid public node address" do
          @node = MoneyTree::Node.from_bip32 "xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw"
          expect(@node.private_key).to be_nil
          expect(@node.index).to eql(2147483648)
          expect(@node.is_private?).to eql(true)
          expect(@node.depth).to eql(1)
          expect(@node.public_key.to_hex).to eql("035a784662a4a20a65bf6aab9ae98a6c068a81c52e4b032c0fb5400c706cfccc56")
          expect(@node.chain_code_hex).to eql("47fdacbd0f1097043b78c63c20c34ef4ed9a111d980047ad16282c7ae6236141")
          expect(@node.parent_fingerprint).to eql("3442193e")
        end
      end
    end

    describe "deriving a child node" do
      describe "#node_for_path" do
        it "correctly derives from a node with a chain code represented in 31 bytes" do
          @node = MoneyTree::Node.from_bip32 "tpubD6NzVbkrYhZ4WM42MZZmUZ7LjxyjBf5bGjEeLf9nJnMZqocGJWu94drvpqWsE9jE7k3h22v6gjpPGnqgBrqwGsRYwDXVRfQ2M9dfHbXP5zA"
          @subnode = @node.node_for_path('m/1')
          expect(@subnode.to_bip32(network: :bitcoin_testnet)).to eql("tpubDA7bCxb3Nrcz2ChXyPqXxbG4q5oiAZUHR7wD3LAiXukuxmT65weWw84XYmjhkJTkJEM6LhNWioWTpKEkQp7j2fgVccj3PPc271xHDeMsaTY")
        end
      end
    end
  end
end
