module MoneyTree
  class Node
    include Support
    attr_reader :private_key, :public_key, :chain_code, :is_private, :depth, :index, :parent
    
    class PublicDerivationFailure < Exception; end
    class InvalidKeyForIndex < Exception; end
    
    def initialize(opts = {})
      @depth = opts[:depth]
      @index = opts[:index]
      @is_private = opts[:is_private]
      @private_key = opts[:private_key]
      @public_key = opts[:public_key]
      @chain_code = opts[:chain_code]
      @parent = opts[:parent]
    end
    
    def index_hex(i = index)
      if i < 0
        [i].pack('l>').unpack('H*').first
      else
        i.to_s(16).rjust(8, "0")
      end
    end
    
    def depth_hex(depth)
      depth.to_s(16).rjust(2, "0")
    end
    
    def private_derivation_private_key_message(i)
      "\x00" + private_key.to_bytes + i_as_bytes(i)
    end
    
    def public_derivation_private_key_message(i)
      public_key.to_bytes << i_as_bytes(i)
    end
    
    # TODO: Complete public key derivation message
    # def public_derivation_public_key_message(i)
    #   public_key.to_bytes + i_as_bytes(i)
    # end
    
    def i_as_bytes(i)
      [i].pack('N')
    end
    
    def derive_private_key(i = 0)
      message = i >= 0x80000000 ? private_derivation_private_key_message(i) : public_derivation_private_key_message(i)
      hash = hmac_sha512 int_to_bytes(chain_code), message
      left_int = left_from_hash(hash)
      raise InvalidKeyForIndex if left_int >= MoneyTree::Key::ORDER # very low probability
      child_private_key = (left_int + private_key.to_i) % MoneyTree::Key::ORDER
      raise InvalidKeyForIndex if child_private_key == 0 # very low probability
      child_chain_code = right_from_hash(hash)
      return child_private_key, child_chain_code
    end
    
    def left_from_hash(hash)
      bytes_to_int hash.bytes.to_a[0..31]
    end
    
    def right_from_hash(hash)
      bytes_to_int hash.bytes.to_a[32..-1]
    end

    # TODO: Complete public key derivation
    # def derive_public_key(i = 0, opts = {})
    #   raise PublicDerivationFailure unless i < 0x80000000
    #   hash = hmac_sha512([chain_code].pack("H*"), public_key.to_hex + index_hex(i))
    #   temp_key = MoneyTree::PrivateKey.new key: hash[0..63]
    #   temp_pub_key = MoneyTree::PublicKey.new temp_key
    #   child_public_key = (temp_key.to_hex.to_i(16) + temp_pub_key.to_hex.to_i(16))
    #   child_chain_code = hash[64..-1]
    #   return child_public_key, child_chain_code
    # end
    
    def to_serialized_hex(type = :public)
      version_key = type.to_sym == :private ? :extended_privkey_version : :extended_pubkey_version
      hex = MoneyTree::NETWORKS[:bitcoin][version_key] # version (4 bytes)
      hex += depth_hex(depth) # depth (1 byte)
      hex += depth.zero? ? '00000000' : parent.to_fingerprint# fingerprint of key (4 bytes)
      hex += index_hex(index) # child number i (4 bytes)
      hex += chain_code_hex
      hex += type.to_sym == :private ? "00#{private_key.to_hex}" : public_key.to_hex
    end
    
    def to_serialized_address(type = :public)
      to_serialized_base58 to_serialized_hex(type)
    end
    
    def to_identifier
      public_key.to_ripemd160
    end
    
    def to_fingerprint
      public_key.to_fingerprint
    end
    
    def to_address
      address = MoneyTree::NETWORKS[:bitcoin][:address_version] + to_identifier
      to_serialized_base58 address
    end
    
    def subnode(i = 0, opts = {})
      # opts[:as_private] = is_private? unless opts[:as_private] == false
      child_private_key, child_chain_code = derive_private_key(i)
      child_private_key = MoneyTree::PrivateKey.new key: child_private_key
      child_public_key = MoneyTree::PublicKey.new child_private_key
      index = i 
      
      MoneyTree::Node.new depth: depth+1, 
                                index: i, 
                                is_private: i >= 0x80000000 || i < 0,
                                private_key: child_private_key,
                                public_key: child_public_key,
                                chain_code: child_chain_code,
                                parent: self
    end
    
    # path: a path of subkeys denoted by numbers and slashes. Use
    #     p or i<0 for private key derivation. End with .pub to force
    #     the key public.
    # 
    # Examples:
    #     1p/-5/2/1 would call subkey(i=1, is_prime=True).subkey(i=-5).
    #         subkey(i=2).subkey(i=1) and then yield the private key
    #     0/0/458.pub would call subkey(i=0).subkey(i=0).subkey(i=458) and
    #         then yield the public key
    # 
    # You should choose either the p or the negative number convention for private key derivation.
    def node_for_path(path)
      force_public = path[-4..-1] == '.pub'
      path = path[0..-4] if force_public
      parts = path.split('/')
      nodes = []
      parts.each_with_index do |part, depth|
        if part =~ /m/i
          nodes << self
        else
          i = parse_index(part)
          nodes << nodes.last.subnode(i)
        end
      end
      nodes.last
    end
    
    def parse_index(path_part)
      is_prime = %w(p ').include? path_part[-1]
      i = path_part.to_i
      
      i = if i < 0
        i
      elsif is_prime
        i | 0x80000000
      else
        i & 0x7fffffff
      end
    end
    
    def chain_code_hex
      int_to_hex chain_code
    end
  end
  
  class Master < Node
    module SeedGeneration
      class Failure < Exception; end
      class RNGFailure < Failure; end
      class LengthFailure < Failure; end
      class ValidityError < Failure; end
      class ImportError < Failure; end
      class TooManyAttempts < Failure; end
    end
    
    HD_WALLET_BASE_KEY = "Bitcoin seed"
    RANDOM_SEED_SIZE = 32
    
    attr_reader :seed, :seed_hash
    
    def initialize(opts = {})
      @depth = 0
      @index = 0
      @is_private = true
      @seed_generation_attempt = 0
      opts[:seed] = [opts[:seed_hex]].pack("H*") if opts[:seed_hex]
      if opts[:seed]
        @seed = opts[:seed]
        @seed_hash = generate_seed_hash(@seed)
        raise SeedGeneration::ImportError unless seed_valid?(@seed_hash)
      else
        generate_seed_until_valid
      end
      set_master_keys
    end
    
    def generate_seed_until_valid
      @seed = generate_seed
      @seed_hash = generate_seed_hash(@seed)
      raise SeedGeneration::ValidityError unless seed_valid?(@seed_hash)
    end
    
    def generate_seed
      OpenSSL::Random.random_bytes(32)
    end
    
    def generate_seed_hash(seed)
      hmac_sha512 HD_WALLET_BASE_KEY, seed
    end
    
    def seed_valid?(seed_hash)
      return false unless seed_hash.bytesize == 64
      master_key = left_from_hash(seed_hash)
      !master_key.zero? && master_key < MoneyTree::Key::ORDER
    end
    
    def set_master_keys
      @private_key = MoneyTree::PrivateKey.new key: left_from_hash(seed_hash)
      @chain_code = right_from_hash(seed_hash)
      @public_key = MoneyTree::PublicKey.new @private_key
    end
  end
end
