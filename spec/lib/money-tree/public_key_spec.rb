require 'spec_helper'
require 'money-tree'

describe MoneyTree::PublicKey do
  before do
    @private_key = MoneyTree::PrivateKey.new key: "5eae5375fb5f7a0ea650566363befa2830ef441bdcb19198adf318faee86d64b"
    @key = MoneyTree::PublicKey.new @private_key
  end
  
  describe "to_hex(compressed: false)" do
    it "has 65 bytes" do
      @key.to_hex(compressed: false).length.should == 130
    end
    
    it "is a valid hex" do
      @key.to_hex(compressed: false).should == '042dfc2557a007c93092c2915f11e8aa70c4f399a6753e2e908330014091580e4b11203096f1a1c5276a73f91b9465357004c2103cc42c63d6d330df589080d2e4'      
    end
  end
  
  describe "to_hex" do
    it "has 33 bytes" do
      @key.to_hex.length.should == 66
    end
  
    it "is a valid compressed hex" do
      @key.to_hex.should == '022dfc2557a007c93092c2915f11e8aa70c4f399a6753e2e908330014091580e4b'      
    end
  end
  
  describe "to_address(compressed: false)" do
    it "has 34 characters" do
      @key.to_address(compressed: false).length.should == 34
    end
    
    it "is a valid bitcoin address" do
      @key.to_address(compressed: false).should == '133bJA2xoVqBUsiR3uSkciMo5r15fLAaZg'      
    end
  end
  
  describe "to_compressed_address" do
    it "has 34 characters" do
      @key.to_address.length.should == 34
    end
    
    it "is a valid compressed bitcoin address" do
      @key.to_address.should == '13uVqa35BMo4mYq9LiZrXVzoz9EFZ6aoXe'      
    end
  end
end
