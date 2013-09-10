require 'spec_helper'
require 'money-tree'
include MoneyTree::Support

describe MoneyTree::Support do  

  describe "sha256(str)" do
    it "properly calculates sha256 hash" do
      sha256("abc", ascii: true).should == "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
      sha256("800c28fca386c7a227600b2fe50b7cae11ec86d3bf1fbe471be89827e19d72aa1d").should == "8147786c4d15106333bf278d71dadaf1079ef2d2440a4dde37d747ded5403592"
      sha256("8147786c4d15106333bf278d71dadaf1079ef2d2440a4dde37d747ded5403592").should == "507a5b8dfed0fc6fe8801743720cedec06aa5c6fca72b07c49964492fb98a714"
    end
  end
  
  describe "ripemd160(str)" do
    it "properly calculates ripemd160 hash" do
      ripemd160("abc", ascii: true).should == "8eb208f7e05d987a9b044a8e98c6b087f15a0bfc"
      ripemd160("e8026715af68676e0287ec9aa774f8103e4bddd5505b209263a8ff97c6ea29cc").should == "166db6510884918f31a9d246404760db8154bf84"
    end
  end
  
  describe "hmac_sha512_hex(key, message)" do
    it "properly calculates hmac sha512" do
      hmac_sha512_hex("Jefe", "what do ya want for nothing?").should == "164b7a7bfcf819e2e395fbe73b56e0a387bd64222e831fd610270cd7ea2505549758bf75c05a994a6d034f65f8f0e6fdcaeab1a34d4a6b4b636e070a38bce737"
    end
  end
  
  describe "hex_to_int" do
    it "converts hex to integer" do
      hex_to_int("abcdef0123456789").should == 12379813738877118345
    end
  end
end
