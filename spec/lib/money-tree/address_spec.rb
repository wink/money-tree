require 'spec_helper'

describe MoneyTree::Address do
  describe "initialize" do
    it "generates a private key by default" do
      address = MoneyTree::Address.new
      address.private_key.key.length.should == 64
    end
    
    it "generates a public key by default" do
      address = MoneyTree::Address.new
      address.public_key.key.length.should == 66
    end
        
    it "imports a private key in hex form" do
      address = MoneyTree::Address.new private_key: "5eae5375fb5f7a0ea650566363befa2830ef441bdcb19198adf318faee86d64b"
      address.private_key.key.should == "5eae5375fb5f7a0ea650566363befa2830ef441bdcb19198adf318faee86d64b"
      address.public_key.key.should == "022dfc2557a007c93092c2915f11e8aa70c4f399a6753e2e908330014091580e4b"
      address.to_s.should == "13uVqa35BMo4mYq9LiZrXVzoz9EFZ6aoXe"
      address.private_key.to_s.should == "KzPkwAXJ4wtXHnbamTaJqoMrzwCUUJaqhUxnqYhnZvZH6KhgmDPK"
      address.public_key.to_s.should == "13uVqa35BMo4mYq9LiZrXVzoz9EFZ6aoXe"
    end
    
    it "imports a private key in compressed wif format" do
      address = MoneyTree::Address.new private_key: "KzPkwAXJ4wtXHnbamTaJqoMrzwCUUJaqhUxnqYhnZvZH6KhgmDPK"
      address.private_key.key.should == "5eae5375fb5f7a0ea650566363befa2830ef441bdcb19198adf318faee86d64b"
      address.public_key.key.should == "022dfc2557a007c93092c2915f11e8aa70c4f399a6753e2e908330014091580e4b"
      address.to_s.should == "13uVqa35BMo4mYq9LiZrXVzoz9EFZ6aoXe"
    end
    
    it "imports a private key in uncompressed wif format" do
      address = MoneyTree::Address.new private_key: "5JXz5ZyFk31oHVTQxqce7yitCmTAPxBqeGQ4b7H3Aj3L45wUhoa"
      address.private_key.key.should == "5eae5375fb5f7a0ea650566363befa2830ef441bdcb19198adf318faee86d64b"
      address.public_key.key.should == "022dfc2557a007c93092c2915f11e8aa70c4f399a6753e2e908330014091580e4b"
    end
  end
  
  describe "to_s" do
    before do
      @address = MoneyTree::Address.new private_key: "5eae5375fb5f7a0ea650566363befa2830ef441bdcb19198adf318faee86d64b"
    end
    
    it "returns compressed base58 public key" do
      @address.to_s.should == "13uVqa35BMo4mYq9LiZrXVzoz9EFZ6aoXe"
      @address.public_key.to_s.should == "13uVqa35BMo4mYq9LiZrXVzoz9EFZ6aoXe"
    end
    
    it "returns compressed WIF private key" do
      @address.private_key.to_s.should == "KzPkwAXJ4wtXHnbamTaJqoMrzwCUUJaqhUxnqYhnZvZH6KhgmDPK"
    end
  end
end
