module MoneyTree
  class Address
    attr_accessor :private_key, :public_key
    
    def initialize(opts = {})
      @private_key = MoneyTree::PrivateKey.new key: opts[:private_key]
      @public_key = MoneyTree::PublicKey.new(@private_key)
    end
    
    def to_s
      public_key.to_s
    end

  end
end
