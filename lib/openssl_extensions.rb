# encoding: ascii-8bit

require 'openssl'
require 'ffi'

module MoneyTree
  module OpenSSLExtensions
    extend FFI::Library
    ffi_lib 'ssl'

    NID_secp256k1 = 714
    POINT_CONVERSION_COMPRESSED = 2
    POINT_CONVERSION_UNCOMPRESSED = 4

    attach_function :EC_KEY_free, [:pointer], :int
    attach_function :EC_KEY_get0_group, [:pointer], :pointer
    attach_function :EC_KEY_new_by_curve_name, [:int], :pointer
    attach_function :EC_POINT_free, [:pointer], :int
    attach_function :EC_POINT_add, [:pointer, :pointer, :pointer, :pointer, :pointer], :int
    attach_function :EC_POINT_point2hex, [:pointer, :pointer, :int, :pointer], :string
    attach_function :EC_POINT_hex2point, [:pointer, :string, :pointer, :pointer], :pointer
    attach_function :EC_POINT_new, [:pointer], :pointer
    
    def self.add(point_0, point_1)
      eckey = EC_KEY_new_by_curve_name(NID_secp256k1)
      group = EC_KEY_get0_group(eckey)
      
      point_0_hex = point_0.to_bn.to_s(16)
      point_0_pt = EC_POINT_hex2point(group, point_0_hex, nil, nil)
      point_1_hex = point_1.to_bn.to_s(16)
      point_1_pt = EC_POINT_hex2point(group, point_1_hex, nil, nil)

      sum_point = EC_POINT_new(group)
      success = EC_POINT_add(group, sum_point, point_0_pt, point_1_pt, nil)#BN_CTX_new())
      hex = EC_POINT_point2hex(group, sum_point, POINT_CONVERSION_UNCOMPRESSED, nil)
      EC_KEY_free(eckey)
      EC_POINT_free(sum_point)
      hex
    end
  end
end


class OpenSSL::PKey::EC::Point
  include MoneyTree::OpenSSLExtensions
  
  def add(point)
    sum_point_hex = MoneyTree::OpenSSLExtensions.add(self, point)
    self.class.new group, OpenSSL::BN.new(sum_point_hex, 16)
  end
  
end