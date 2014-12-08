require 'spec_helper'

describe MoneyTree::OpenSSLExtensions do
  include MoneyTree::OpenSSLExtensions

  context "with inputs" do
    let(:key1) { OpenSSL::PKey::EC.new("secp256k1").generate_key }
    let(:key2) { OpenSSL::PKey::EC.new("secp256k1").generate_key }
    let(:point_1) { key1.public_key }
    let(:point_2) { key2.public_key }
    let(:point_infinity) { key1.public_key.set_to_infinity! }

    it "requires valid points" do
      expect { MoneyTree::OpenSSLExtensions.add(0, 0) }.to raise_error(ArgumentError)
      expect { MoneyTree::OpenSSLExtensions.add(nil, nil) }.to raise_error(ArgumentError)
      expect { MoneyTree::OpenSSLExtensions.add(point_1, 0) }.to raise_error(ArgumentError)
      expect { MoneyTree::OpenSSLExtensions.add(0, point_2) }.to raise_error(ArgumentError)
      expect { MoneyTree::OpenSSLExtensions.add(point_infinity, point_2) }.to raise_error(ArgumentError)
      expect { MoneyTree::OpenSSLExtensions.add(point_1, point_2) }.to_not raise_error
    end
  end
  
end
