require 'spec_helper'
require 'money-tree'

# Test vectors from https://en.bitcoin.it/wiki/BIP_0032_TestVectors
describe MoneyTree::Master do
  describe "initialize" do
    describe "without a seed" do
      before do
        @master = MoneyTree::Master.new
      end
      
      it "generates a random seed 32 bytes long" do
        @master.seed.bytesize.should == 32
      end
    end
    
    describe "Test vector 1" do
      describe "from a seed" do
        before do
          @master = MoneyTree::Master.new seed_hex: "000102030405060708090a0b0c0d0e0f"
        end
      
        describe "m" do
          it "has an index of 0" do
            @master.index.should == 0
          end
          
          it "is private" do
            @master.is_private.should == true
          end
        
          it "has a depth of 0" do
            @master.depth.should == 0
          end
          
          it "generates master node (Master)" do
            @master.to_identifier.should == "3442193e1bb70916e914552172cd4e2dbc9df811"
            @master.to_fingerprint.should == "3442193e"
            @master.to_address.should == "15mKKb2eos1hWa6tisdPwwDC1a5J1y9nma"
          end
      
          it "generates a secret key" do
            @master.private_key.to_hex.should == "e8f32e723decf4051aefac8e2c93c9c5b214313817cdb01a1494b917c8436b35"
            @master.private_key.to_wif.should == "L52XzL2cMkHxqxBXRyEpnPQZGUs3uKiL3R11XbAdHigRzDozKZeW"
          end
      
          it "generates a public key" do
            @master.public_key.to_hex.should == "0339a36013301597daef41fbe593a02cc513d0b55527ec2df1050e2e8ff49c85c2"
          end
      
          it "generates a chain code" do
            @master.chain_code_hex.should == "873dff81c02f525623fd1fe5167eac3a55a049de3d314bb42ee227ffed37d508"
          end
      
          it "generates a serialized private key" do
            @master.to_serialized_hex(:private).should == "0488ade4000000000000000000873dff81c02f525623fd1fe5167eac3a55a049de3d314bb42ee227ffed37d50800e8f32e723decf4051aefac8e2c93c9c5b214313817cdb01a1494b917c8436b35"
            @master.to_serialized_address(:private).should == "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi"
          end
            
          it "generates a serialized public_key" do
            @master.to_serialized_hex.should == "0488b21e000000000000000000873dff81c02f525623fd1fe5167eac3a55a049de3d314bb42ee227ffed37d5080339a36013301597daef41fbe593a02cc513d0b55527ec2df1050e2e8ff49c85c2"
            @master.to_serialized_address.should == "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8"
          end
        end
      
        describe "m/0p" do
          before do
            @node = @master.node_for_path "m/0p"
          end
        
          it "has an index of 2147483648" do
            @node.index.should == 2147483648
          end
          
          it "is private" do
            @node.is_private.should == true
          end
        
          it "has a depth of 1" do
            @node.depth.should == 1
          end
    
          it "generates subnode" do
            @node.to_identifier.should == "5c1bd648ed23aa5fd50ba52b2457c11e9e80a6a7"
            @node.to_fingerprint.should == "5c1bd648"
            @node.to_address.should == "19Q2WoS5hSS6T8GjhK8KZLMgmWaq4neXrh"
          end
    
          it "generates a private key" do
            @node.private_key.to_hex.should == "edb2e14f9ee77d26dd93b4ecede8d16ed408ce149b6cd80b0715a2d911a0afea"
            @node.private_key.to_wif.should == "L5BmPijJjrKbiUfG4zbiFKNqkvuJ8usooJmzuD7Z8dkRoTThYnAT"
          end
    
          it "generates a public key" do
            @node.public_key.to_hex.should == "035a784662a4a20a65bf6aab9ae98a6c068a81c52e4b032c0fb5400c706cfccc56"
          end
        
          it "generates a chain code" do
            @node.chain_code_hex.should == "47fdacbd0f1097043b78c63c20c34ef4ed9a111d980047ad16282c7ae6236141"
          end
        
          it "generates a serialized private key" do
            @node.to_serialized_hex(:private).should == "0488ade4013442193e8000000047fdacbd0f1097043b78c63c20c34ef4ed9a111d980047ad16282c7ae623614100edb2e14f9ee77d26dd93b4ecede8d16ed408ce149b6cd80b0715a2d911a0afea"
            @node.to_serialized_address(:private).should == "xprv9uHRZZhk6KAJC1avXpDAp4MDc3sQKNxDiPvvkX8Br5ngLNv1TxvUxt4cV1rGL5hj6KCesnDYUhd7oWgT11eZG7XnxHrnYeSvkzY7d2bhkJ7"
          end
              
          it "generates a serialized public_key" do
            @node.to_serialized_hex.should == "0488b21e013442193e8000000047fdacbd0f1097043b78c63c20c34ef4ed9a111d980047ad16282c7ae6236141035a784662a4a20a65bf6aab9ae98a6c068a81c52e4b032c0fb5400c706cfccc56"
            @node.to_serialized_address.should == "xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw"
          end
        end
      
        describe "m/0'/1" do
          before do
            @node = @master.node_for_path "m/0'/1"
          end
        
          it "has an index of 1" do
            @node.index.should == 1
          end
          
          it "is public" do
            @node.is_private.should == false
          end
        
          it "has a depth of 2" do
            @node.depth.should == 2
          end
          
          it "generates subnode" do
            @node.to_identifier.should == "bef5a2f9a56a94aab12459f72ad9cf8cf19c7bbe"
            @node.to_fingerprint.should == "bef5a2f9"
            @node.to_address.should == "1JQheacLPdM5ySCkrZkV66G2ApAXe1mqLj"
          end
              
          it "generates a private key" do
            @node.private_key.to_hex.should == "3c6cb8d0f6a264c91ea8b5030fadaa8e538b020f0a387421a12de9319dc93368"
            @node.private_key.to_wif.should == "KyFAjQ5rgrKvhXvNMtFB5PCSKUYD1yyPEe3xr3T34TZSUHycXtMM"
          end
              
          it "generates a public key" do
            @node.public_key.to_hex.should == "03501e454bf00751f24b1b489aa925215d66af2234e3891c3b21a52bedb3cd711c"
          end
        
          it "generates a chain code" do
            @node.chain_code_hex.should == "2a7857631386ba23dacac34180dd1983734e444fdbf774041578e9b6adb37c19"
          end
        
          it "generates a serialized private key" do
            @node.to_serialized_hex(:private).should == "0488ade4025c1bd648000000012a7857631386ba23dacac34180dd1983734e444fdbf774041578e9b6adb37c19003c6cb8d0f6a264c91ea8b5030fadaa8e538b020f0a387421a12de9319dc93368"
            @node.to_serialized_address(:private).should == "xprv9wTYmMFdV23N2TdNG573QoEsfRrWKQgWeibmLntzniatZvR9BmLnvSxqu53Kw1UmYPxLgboyZQaXwTCg8MSY3H2EU4pWcQDnRnrVA1xe8fs"
          end
                
          it "generates a serialized public_key" do
            @node.to_serialized_hex.should == "0488b21e025c1bd648000000012a7857631386ba23dacac34180dd1983734e444fdbf774041578e9b6adb37c1903501e454bf00751f24b1b489aa925215d66af2234e3891c3b21a52bedb3cd711c"
            @node.to_serialized_address.should == "xpub6ASuArnXKPbfEwhqN6e3mwBcDTgzisQN1wXN9BJcM47sSikHjJf3UFHKkNAWbWMiGj7Wf5uMash7SyYq527Hqck2AxYysAA7xmALppuCkwQ"
          end
        end
        
        describe "m/0'/1/2p/2" do
          before do
            @node = @master.node_for_path "m/0'/1/2p/2"
          end
        
          it "has an index of 2" do
            @node.index.should == 2
          end
          
          it "is public" do
            @node.is_private.should == false
          end
        
          it "has a depth of 4" do
            @node.depth.should == 4
          end
          
          it "generates subnode" do
            @node.to_identifier.should == "d880d7d893848509a62d8fb74e32148dac68412f"
            @node.to_fingerprint.should == "d880d7d8"
            @node.to_address.should == "1LjmJcdPnDHhNTUgrWyhLGnRDKxQjoxAgt"
          end
              
          it "generates a private key" do
            @node.private_key.to_hex.should == "0f479245fb19a38a1954c5c7c0ebab2f9bdfd96a17563ef28a6a4b1a2a764ef4"
            @node.private_key.to_wif.should == "KwjQsVuMjbCP2Zmr3VaFaStav7NvevwjvvkqrWd5Qmh1XVnCteBR"
          end
              
          it "generates a public key" do
            @node.public_key.to_hex.should == "02e8445082a72f29b75ca48748a914df60622a609cacfce8ed0e35804560741d29"
          end
        
          it "generates a chain code" do
            @node.chain_code_hex.should == "cfb71883f01676f587d023cc53a35bc7f88f724b1f8c2892ac1275ac822a3edd"
          end
        
          it "generates a serialized private key" do
            @node.to_serialized_hex(:private).should == "0488ade404ee7ab90c00000002cfb71883f01676f587d023cc53a35bc7f88f724b1f8c2892ac1275ac822a3edd000f479245fb19a38a1954c5c7c0ebab2f9bdfd96a17563ef28a6a4b1a2a764ef4"
            @node.to_serialized_address(:private).should == "xprvA2JDeKCSNNZky6uBCviVfJSKyQ1mDYahRjijr5idH2WwLsEd4Hsb2Tyh8RfQMuPh7f7RtyzTtdrbdqqsunu5Mm3wDvUAKRHSC34sJ7in334"
          end
                
          it "generates a serialized public_key" do
            @node.to_serialized_hex.should == "0488b21e04ee7ab90c00000002cfb71883f01676f587d023cc53a35bc7f88f724b1f8c2892ac1275ac822a3edd02e8445082a72f29b75ca48748a914df60622a609cacfce8ed0e35804560741d29"
            @node.to_serialized_address.should == "xpub6FHa3pjLCk84BayeJxFW2SP4XRrFd1JYnxeLeU8EqN3vDfZmbqBqaGJAyiLjTAwm6ZLRQUMv1ZACTj37sR62cfN7fe5JnJ7dh8zL4fiyLHV"
          end
        end
        
        describe "m/0'/1/2'/2/1000000000" do
          before do
            @node = @master.node_for_path "m/0'/1/2'/2/1000000000"
          end
        
          it "has an index of 1000000000" do
            @node.index.should == 1000000000
          end
          
          it "is public" do
            @node.is_private.should == false
          end
        
          it "has a depth of 2" do
            @node.depth.should == 5
          end
          
          it "generates subnode" do
            @node.to_identifier.should == "d69aa102255fed74378278c7812701ea641fdf32"
            @node.to_fingerprint.should == "d69aa102"
            @node.to_address.should == "1LZiqrop2HGR4qrH1ULZPyBpU6AUP49Uam"
          end
              
          it "generates a private key" do
            @node.private_key.to_hex.should == "471b76e389e528d6de6d816857e012c5455051cad6660850e58372a6c3e6e7c8"
            @node.private_key.to_wif.should == "Kybw8izYevo5xMh1TK7aUr7jHFCxXS1zv8p3oqFz3o2zFbhRXHYs"
          end
              
          it "generates a public key" do
            @node.public_key.to_hex.should == "022a471424da5e657499d1ff51cb43c47481a03b1e77f951fe64cec9f5a48f7011"
          end
        
          it "generates a chain code" do
            @node.chain_code_hex.should == "c783e67b921d2beb8f6b389cc646d7263b4145701dadd2161548a8b078e65e9e"
          end
        
          it "generates a serialized private key" do
            @node.to_serialized_hex(:private).should == "0488ade405d880d7d83b9aca00c783e67b921d2beb8f6b389cc646d7263b4145701dadd2161548a8b078e65e9e00471b76e389e528d6de6d816857e012c5455051cad6660850e58372a6c3e6e7c8"
            @node.to_serialized_address(:private).should == "xprvA41z7zogVVwxVSgdKUHDy1SKmdb533PjDz7J6N6mV6uS3ze1ai8FHa8kmHScGpWmj4WggLyQjgPie1rFSruoUihUZREPSL39UNdE3BBDu76"
          end
                
          it "generates a serialized public_key" do
            @node.to_serialized_hex.should == "0488b21e05d880d7d83b9aca00c783e67b921d2beb8f6b389cc646d7263b4145701dadd2161548a8b078e65e9e022a471424da5e657499d1ff51cb43c47481a03b1e77f951fe64cec9f5a48f7011"
            @node.to_serialized_address.should == "xpub6H1LXWLaKsWFhvm6RVpEL9P4KfRZSW7abD2ttkWP3SSQvnyA8FSVqNTEcYFgJS2UaFcxupHiYkro49S8yGasTvXEYBVPamhGW6cFJodrTHy"
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
            @master.index.should == 0
          end
        
          it "has a depth of 0" do
            @master.depth.should == 0
          end
          
          it "is private" do
            @master.is_private.should == true
          end
          
          it "generates master node (Master)" do
            @master.to_identifier.should == "bd16bee53961a47d6ad888e29545434a89bdfe95"
            @master.to_fingerprint.should == "bd16bee5"
            @master.to_address.should == "1JEoxevbLLG8cVqeoGKQiAwoWbNYSUyYjg"
          end
      
          it "generates a secret key" do
            @master.private_key.to_hex.should == "4b03d6fc340455b363f51020ad3ecca4f0850280cf436c70c727923f6db46c3e"
            @master.private_key.to_wif.should == "KyjXhyHF9wTphBkfpxjL8hkDXDUSbE3tKANT94kXSyh6vn6nKaoy"
          end
      
          it "generates a public key" do
            @master.public_key.to_hex.should == "03cbcaa9c98c877a26977d00825c956a238e8dddfbd322cce4f74b0b5bd6ace4a7"
          end
      
          it "generates a chain code" do
            @master.chain_code_hex.should == "60499f801b896d83179a4374aeb7822aaeaceaa0db1f85ee3e904c4defbd9689"
          end
      
          it "generates a serialized private key" do
            @master.to_serialized_hex(:private).should == "0488ade400000000000000000060499f801b896d83179a4374aeb7822aaeaceaa0db1f85ee3e904c4defbd9689004b03d6fc340455b363f51020ad3ecca4f0850280cf436c70c727923f6db46c3e"
            @master.to_serialized_address(:private).should == "xprv9s21ZrQH143K31xYSDQpPDxsXRTUcvj2iNHm5NUtrGiGG5e2DtALGdso3pGz6ssrdK4PFmM8NSpSBHNqPqm55Qn3LqFtT2emdEXVYsCzC2U"
          end
            
          it "generates a serialized public_key" do
            @master.to_serialized_hex.should == "0488b21e00000000000000000060499f801b896d83179a4374aeb7822aaeaceaa0db1f85ee3e904c4defbd968903cbcaa9c98c877a26977d00825c956a238e8dddfbd322cce4f74b0b5bd6ace4a7"
            @master.to_serialized_address.should == "xpub661MyMwAqRbcFW31YEwpkMuc5THy2PSt5bDMsktWQcFF8syAmRUapSCGu8ED9W6oDMSgv6Zz8idoc4a6mr8BDzTJY47LJhkJ8UB7WEGuduB"
          end
        end
      
        describe "m/0" do
          before do
            @node = @master.node_for_path "m/0"
          end
        
          it "has an index of 0" do
            @node.index.should == 0
          end
        
          it "has a depth of 1" do
            @node.depth.should == 1
          end
          
          it "is public" do
            @node.is_private.should == false
          end
    
          it "generates subnode" do
            @node.to_identifier.should == "5a61ff8eb7aaca3010db97ebda76121610b78096"
            @node.to_fingerprint.should == "5a61ff8e"
            @node.to_address.should == "19EuDJdgfRkwCmRzbzVBHZWQG9QNWhftbZ"
          end
    
          it "generates a private key" do
            @node.private_key.to_hex.should == "abe74a98f6c7eabee0428f53798f0ab8aa1bd37873999041703c742f15ac7e1e"
            @node.private_key.to_wif.should == "L2ysLrR6KMSAtx7uPqmYpoTeiRzydXBattRXjXz5GDFPrdfPzKbj"
          end
    
          it "generates a public key" do
            @node.public_key.to_hex.should == "02fc9e5af0ac8d9b3cecfe2a888e2117ba3d089d8585886c9c826b6b22a98d12ea"
          end
        
          it "generates a chain code" do
            @node.chain_code_hex.should == "f0909affaa7ee7abe5dd4e100598d4dc53cd709d5a5c2cac40e7412f232f7c9c"
          end
        
          it "generates a serialized private key" do
            @node.to_serialized_hex(:private).should == "0488ade401bd16bee500000000f0909affaa7ee7abe5dd4e100598d4dc53cd709d5a5c2cac40e7412f232f7c9c00abe74a98f6c7eabee0428f53798f0ab8aa1bd37873999041703c742f15ac7e1e"
            @node.to_serialized_address(:private).should == "xprv9vHkqa6EV4sPZHYqZznhT2NPtPCjKuDKGY38FBWLvgaDx45zo9WQRUT3dKYnjwih2yJD9mkrocEZXo1ex8G81dwSM1fwqWpWkeS3v86pgKt"
          end
              
          it "generates a serialized public_key" do
            @node.to_serialized_hex.should == "0488b21e01bd16bee500000000f0909affaa7ee7abe5dd4e100598d4dc53cd709d5a5c2cac40e7412f232f7c9c02fc9e5af0ac8d9b3cecfe2a888e2117ba3d089d8585886c9c826b6b22a98d12ea"
            @node.to_serialized_address.should == "xpub69H7F5d8KSRgmmdJg2KhpAK8SR3DjMwAdkxj3ZuxV27CprR9LgpeyGmXUbC6wb7ERfvrnKZjXoUmmDznezpbZb7ap6r1D3tgFxHmwMkQTPH"
          end
        end
        
        describe "m/0/2147483647'" do
          before do
            @node = @master.node_for_path "m/0/2147483647'"
          end
        
          it "has an index of 2147483647" do
            @node.index.should == 4294967295
          end
        
          it "has a depth of 2" do
            @node.depth.should == 2
          end
          
          it "is private" do
            @node.is_private.should == true
          end
            
          it "generates subnode" do
            @node.to_identifier.should == "d8ab493736da02f11ed682f88339e720fb0379d1"
            @node.to_fingerprint.should == "d8ab4937"
            @node.to_address.should == "1Lke9bXGhn5VPrBuXgN12uGUphrttUErmk"
          end
            
          it "generates a private key" do
            @node.private_key.to_hex.should == "877c779ad9687164e9c2f4f0f4ff0340814392330693ce95a58fe18fd52e6e93"
            @node.private_key.to_wif.should == "L1m5VpbXmMp57P3knskwhoMTLdhAAaXiHvnGLMribbfwzVRpz2Sr"
          end
            
          it "generates a public key" do
            @node.public_key.to_hex.should == "03c01e7425647bdefa82b12d9bad5e3e6865bee0502694b94ca58b666abc0a5c3b"
          end
        
          it "generates a chain code" do
            @node.chain_code_hex.should == "be17a268474a6bb9c61e1d720cf6215e2a88c5406c4aee7b38547f585c9a37d9"
          end
        
          it "generates a serialized private key" do
            @node.to_serialized_hex(:private).should == "0488ade4025a61ff8effffffffbe17a268474a6bb9c61e1d720cf6215e2a88c5406c4aee7b38547f585c9a37d900877c779ad9687164e9c2f4f0f4ff0340814392330693ce95a58fe18fd52e6e93"
            @node.to_serialized_address(:private).should == "xprv9wSp6B7kry3Vj9m1zSnLvN3xH8RdsPP1Mh7fAaR7aRLcQMKTR2vidYEeEg2mUCTAwCd6vnxVrcjfy2kRgVsFawNzmjuHc2YmYRmagcEPdU9"
          end
              
          it "generates a serialized public_key" do
            @node.to_serialized_hex.should == "0488b21e025a61ff8effffffffbe17a268474a6bb9c61e1d720cf6215e2a88c5406c4aee7b38547f585c9a37d903c01e7425647bdefa82b12d9bad5e3e6865bee0502694b94ca58b666abc0a5c3b"
            @node.to_serialized_address.should == "xpub6ASAVgeehLbnwdqV6UKMHVzgqAG8Gr6riv3Fxxpj8ksbH9ebxaEyBLZ85ySDhKiLDBrQSARLq1uNRts8RuJiHjaDMBU4Zn9h8LZNnBC5y4a"
          end
        end
        
        describe "m/0/2147483647'/1" do
          before do
            @node = @master.node_for_path "m/0/2147483647'/1"
          end
        
          it "has an index of 1" do
            @node.index.should == 1
          end
        
          it "has a depth of 3" do
            @node.depth.should == 3
          end
          
          it "is private" do
            @node.is_private.should == false
          end
            
          it "generates subnode" do
            @node.to_identifier.should == "78412e3a2296a40de124307b6485bd19833e2e34"
            @node.to_fingerprint.should == "78412e3a"
            @node.to_address.should == "1BxrAr2pHpeBheusmd6fHDP2tSLAUa3qsW"
          end
            
          it "generates a private key" do
            @node.private_key.to_hex.should == "704addf544a06e5ee4bea37098463c23613da32020d604506da8c0518e1da4b7"
            @node.private_key.to_wif.should == "KzyzXnznxSv249b4KuNkBwowaN3akiNeEHy5FWoPCJpStZbEKXN2"
          end
            
          it "generates a public key" do
            @node.public_key.to_hex.should == "03a7d1d856deb74c508e05031f9895dab54626251b3806e16b4bd12e781a7df5b9"
          end
        
          it "generates a chain code" do
            @node.chain_code_hex.should == "f366f48f1ea9f2d1d3fe958c95ca84ea18e4c4ddb9366c336c927eb246fb38cb"
          end
        
          it "generates a serialized private key" do
            @node.to_serialized_hex(:private).should == "0488ade403d8ab493700000001f366f48f1ea9f2d1d3fe958c95ca84ea18e4c4ddb9366c336c927eb246fb38cb00704addf544a06e5ee4bea37098463c23613da32020d604506da8c0518e1da4b7"
            @node.to_serialized_address(:private).should == "xprv9zFnWC6h2cLgpmSA46vutJzBcfJ8yaJGg8cX1e5StJh45BBciYTRXSd25UEPVuesF9yog62tGAQtHjXajPPdbRCHuWS6T8XA2ECKADdw4Ef"
          end
              
          it "generates a serialized public_key" do
            @node.to_serialized_hex.should == "0488b21e03d8ab493700000001f366f48f1ea9f2d1d3fe958c95ca84ea18e4c4ddb9366c336c927eb246fb38cb03a7d1d856deb74c508e05031f9895dab54626251b3806e16b4bd12e781a7df5b9"
            @node.to_serialized_address.should == "xpub6DF8uhdarytz3FWdA8TvFSvvAh8dP3283MY7p2V4SeE2wyWmG5mg5EwVvmdMVCQcoNJxGoWaU9DCWh89LojfZ537wTfunKau47EL2dhHKon"
          end
        end
        
        describe "m/0/2147483647p/1/2147483646p" do
          before do
            @node = @master.node_for_path "m/0/2147483647p/1/2147483646p"
          end
        
          it "has an index of 4294967294" do
            @node.index.should == 4294967294
          end
        
          it "has a depth of 4" do
            @node.depth.should == 4
          end
          
          it "is private" do
            @node.is_private.should == true
          end
            
          it "generates subnode" do
            @node.to_identifier.should == "31a507b815593dfc51ffc7245ae7e5aee304246e"
            @node.to_fingerprint.should == "31a507b8"
            @node.to_address.should == "15XVotxCAV7sRx1PSCkQNsGw3W9jT9A94R"
          end
            
          it "generates a private key" do
            @node.private_key.to_hex.should == "f1c7c871a54a804afe328b4c83a1c33b8e5ff48f5087273f04efa83b247d6a2d"
            @node.private_key.to_wif.should == "L5KhaMvPYRW1ZoFmRjUtxxPypQ94m6BcDrPhqArhggdaTbbAFJEF"
          end
            
          it "generates a public key" do
            @node.public_key.to_hex.should == "02d2b36900396c9282fa14628566582f206a5dd0bcc8d5e892611806cafb0301f0"
          end
        
          it "generates a chain code" do
            @node.chain_code_hex.should == "637807030d55d01f9a0cb3a7839515d796bd07706386a6eddf06cc29a65a0e29"
          end
        
          it "generates a serialized private key" do
            @node.to_serialized_hex(:private).should == "0488ade40478412e3afffffffe637807030d55d01f9a0cb3a7839515d796bd07706386a6eddf06cc29a65a0e2900f1c7c871a54a804afe328b4c83a1c33b8e5ff48f5087273f04efa83b247d6a2d"
            @node.to_serialized_address(:private).should == "xprvA1RpRA33e1JQ7ifknakTFpgNXPmW2YvmhqLQYMmrj4xJXXWYpDPS3xz7iAxn8L39njGVyuoseXzU6rcxFLJ8HFsTjSyQbLYnMpCqE2VbFWc"
          end
              
          it "generates a serialized public_key" do
            @node.to_serialized_hex.should == "0488b21e0478412e3afffffffe637807030d55d01f9a0cb3a7839515d796bd07706386a6eddf06cc29a65a0e2902d2b36900396c9282fa14628566582f206a5dd0bcc8d5e892611806cafb0301f0"
            @node.to_serialized_address.should == "xpub6ERApfZwUNrhLCkDtcHTcxd75RbzS1ed54G1LkBUHQVHQKqhMkhgbmJbZRkrgZw4koxb5JaHWkY4ALHY2grBGRjaDMzQLcgJvLJuZZvRcEL"
          end
        end
        
        describe "m/0/2147483647p/1/2147483646p/2" do
          before do
            @node = @master.node_for_path "m/0/2147483647p/1/2147483646p/2"
          end
        
          it "has an index of 2" do
            @node.index.should == 2
          end
        
          it "has a depth of 4" do
            @node.depth.should == 5
          end
          
          it "is public" do
            @node.is_private.should == false
          end
            
          it "generates subnode" do
            @node.to_identifier.should == "26132fdbe7bf89cbc64cf8dafa3f9f88b8666220"
            @node.to_fingerprint.should == "26132fdb"
            @node.to_address.should == "14UKfRV9ZPUp6ZC9PLhqbRtxdihW9em3xt"
          end
            
          it "generates a private key" do
            @node.private_key.to_hex.should == "bb7d39bdb83ecf58f2fd82b6d918341cbef428661ef01ab97c28a4842125ac23"
            @node.private_key.to_wif.should == "L3WAYNAZPxx1fr7KCz7GN9nD5qMBnNiqEJNJMU1z9MMaannAt4aK"
          end
            
          it "generates a public key" do
            @node.public_key.to_hex.should == "024d902e1a2fc7a8755ab5b694c575fce742c48d9ff192e63df5193e4c7afe1f9c"
          end
        
          it "generates a chain code" do
            @node.chain_code_hex.should == "9452b549be8cea3ecb7a84bec10dcfd94afe4d129ebfd3b3cb58eedf394ed271"
          end
        
          it "generates a serialized private key" do
            @node.to_serialized_hex(:private).should == "0488ade40531a507b8000000029452b549be8cea3ecb7a84bec10dcfd94afe4d129ebfd3b3cb58eedf394ed27100bb7d39bdb83ecf58f2fd82b6d918341cbef428661ef01ab97c28a4842125ac23"
            @node.to_serialized_address(:private).should == "xprvA2nrNbFZABcdryreWet9Ea4LvTJcGsqrMzxHx98MMrotbir7yrKCEXw7nadnHM8Dq38EGfSh6dqA9QWTyefMLEcBYJUuekgW4BYPJcr9E7j"
          end
              
          it "generates a serialized public_key" do
            @node.to_serialized_hex.should == "0488b21e0531a507b8000000029452b549be8cea3ecb7a84bec10dcfd94afe4d129ebfd3b3cb58eedf394ed271024d902e1a2fc7a8755ab5b694c575fce742c48d9ff192e63df5193e4c7afe1f9c"
            @node.to_serialized_address.should == "xpub6FnCn6nSzZAw5Tw7cgR9bi15UV96gLZhjDstkXXxvCLsUXBGXPdSnLFbdpq8p9HmGsApME5hQTZ3emM2rnY5agb9rXpVGyy3bdW6EEgAtqt"
          end
        end
      end
    end

  end
end
