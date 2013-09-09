# encoding ascii-8bit

require 'openssl'
require 'pry'

module MoneyTree
  class Key
    include OpenSSL
    include Support
    class KeyInvalid < Exception; end
    class KeyGenerationFailure < Exception; end
    class KeyImportFailure < Exception; end
    class KeyFormatNotFound < Exception; end
    class InvalidWIFFormat < Exception; end
    
    attr_reader :options, :key
    attr_accessor :ec_key
    
    GROUP_NAME = 'secp256k1'
    GROUP_UNCOMPRESSED = "0479be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8".to_i(16)
    GROUP_COMPRESSED = "0279be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798".to_i(16)
    ORDER = "fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141".to_i(16)
    
    def valid?(eckey = nil)
      eckey ||= ec_key
      eckey.nil? ? false : eckey.check_key
    end
    
    def to_bytes
      hex_to_bytes to_hex
    end
    
    def to_i
      bytes_to_int to_bytes
    end
  end
  
  class PrivateKey < Key
    
    attr_reader :raw_key
    
    def initialize(opts = {})
      @options = opts
      # @ec_key = EC_KEY_new_by_curve_name(NID_secp256k1)
      @ec_key = PKey::EC.new 'secp256k1'
      if @options[:key]
        @raw_key = @options[:key]
        @key = parse_raw_key
        import
      else
        generate
        @key = to_hex
      end
    end
    
    def generate
      ec_key.generate_key
    end
    
    def import
      ec_key.private_key = BN.new(key, 16)
      set_public_key
    end
    
    def calculate_public_key(opts = {})
      opts[:compressed] = true unless opts[:compressed] == false
      group = ec_key.group
      group.point_conversion_form = opts[:compressed] ? :compressed : :uncompressed
      point = group.generator.mul ec_key.private_key
    end
    
    def set_public_key(opts = {})
      ec_key.public_key = calculate_public_key(opts)
    end
    
    def parse_raw_key
      result = if raw_key.is_a?(Bignum) then int_to_hex(raw_key)
      elsif hex_format? then raw_key
      elsif compressed_wif_format? then from_wif
      elsif uncompressed_wif_format? then from_wif
      elsif base64_format? then from_base64
      else 
        raise raw_key.inspect
        raise KeyFormatNotFound
      end
      result.downcase
    end
    
    def from_wif(wif = raw_key)
      compressed = wif.length == 52
      validate_wif(wif)
      hex = decode_base58(wif)
      last_char = compressed ? -11 : -9
      hex.slice(2..last_char)
    end
    
    def from_base64
      decode_base64(raw_key)
    end
    
    def compressed_wif_format?
      raw_key.length == 52 && MoneyTree::NETWORKS[:bitcoin][:compressed_wif_chars].include?(raw_key.slice(0))
    end
    
    def uncompressed_wif_format?
      raw_key.length == 51 && raw_key.slice(0) == MoneyTree::NETWORKS[:bitcoin][:uncompressed_wif_char]
    end
    
    def base64_format?
      raw_key.length == 44
    end
    
    def hex_format?
      raw_key.length == 64 && !raw_key[/\H/]
    end
    
    def to_hex
      int_to_hex @ec_key.private_key
    end
    
    def to_wif(opts = {})
      opts[:compressed] = true unless opts[:compressed] == false
      source = MoneyTree::NETWORKS[:bitcoin][:privkey_version] + to_hex
      source += MoneyTree::NETWORKS[:bitcoin][:privkey_compression_flag] if opts[:compressed]
      hash = sha256(source)
      hash = sha256(hash)
      checksum = hash.slice(0..7)
      source_with_checksum = source + checksum
      encode_base58(source_with_checksum)
    end

    def wif_valid?(wif)
      hex = decode_base58(wif)
      return false unless hex.slice(0..1) == MoneyTree::NETWORKS[:bitcoin][:privkey_version]
      checksum = hex.chars.to_a.pop(8).join
      source = hex.slice(0..-9)
      hash = sha256(source)
      hash = sha256(hash)
      hash_checksum = hash.slice(0..7)
      checksum == hash_checksum
    end
    
    def validate_wif(wif)
      raise InvalidWIFFormat unless wif_valid?(wif)
    end
    
    def to_base64
      encode_base64(to_hex)
    end
    
    def to_s
      to_wif
    end
    
  end
  
  class PublicKey < Key
    attr_reader :private_key
    
    def initialize(p_key, opts = {})
      raise "Must initialize with a MoneyTree::PrivateKey" unless p_key.is_a?(PrivateKey)
      @private_key = p_key
      @ec_key = @private_key.ec_key
      @options = opts
      @key = @options[:key] || to_hex
    end
    
    def to_hex(opts = {})
      int_to_hex to_i(opts)
    end
    
    def to_i(opts = {})
      private_key.calculate_public_key(opts).to_bn.to_i
    end
    
    def to_ripemd160(opts = {})
      hash = sha256 to_hex(opts)
      ripemd160 hash
    end
    
    def to_address(opts = {})
      hash = to_ripemd160(opts)
      address = MoneyTree::NETWORKS[:bitcoin][:address_version] + hash
      to_serialized_base58 address
    end
    
    def to_fingerprint(opts = {})
      hash = to_ripemd160(opts)
      hash.slice(0..7)
    end

    def to_s(opts = {})
      to_address(opts)
    end
    
    def to_bytes(opts = {})
      int_to_bytes to_i(opts)
    end
  end
end
