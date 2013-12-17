module MoneyTree
  class Node
    include Support
    extend Support
    attr_reader :private_key, :public_key, :chain_code, :is_private, :depth, :index, :parent, :is_test
    
    class PublicDerivationFailure < Exception; end
    class InvalidKeyForIndex < Exception; end
    class ImportError < Exception; end
    class PrivatePublicMismatch < Exception; end
    
    def initialize(opts = {})
      opts.each { |k, v| instance_variable_set "@#{k}", v }
    end
    
    def self.from_serialized_address(address)
      hex = from_serialized_base58 address
      version = from_version_hex hex.slice!(0..7)
      self.new({
        is_test: version[:test],
        depth: hex.slice!(0..1).to_i(16),
        fingerprint: hex.slice!(0..7),
        index: hex.slice!(0..7).to_i(16),
        chain_code: hex.slice!(0..63).to_i(16)
      }.merge(key_options(hex, version)))
    end
    
    def self.key_options(hex, version)
      if version[:private_key] && hex.slice(0..1) == '00'
        private_key = MoneyTree::PrivateKey.new key: hex.slice(2..-1)
        { private_key: private_key, public_key: MoneyTree::PublicKey.new(private_key) }
      elsif %w(02 03).include? hex.slice(0..1)
        { public_key: MoneyTree::PublicKey.new(hex) }
      else
        raise ImportError, 'Public or private key data does not match version type'
      end
    end
    
    def self.from_version_hex(hex)
      case hex
      when MoneyTree::NETWORKS[:bitcoin][:extended_privkey_version]
        { private_key: true, test: false }
      when MoneyTree::NETWORKS[:bitcoin][:extended_pubkey_version]
        { private_key: false, test: false }
      when MoneyTree::NETWORKS[:bitcoin_testnet][:extended_privkey_version]
        { private_key: true, test: true }
      when MoneyTree::NETWORKS[:bitcoin_testnet][:extended_pubkey_version]
        { private_key: false, test: true }
      else 
        raise ImportError, 'invalid version bytes'
      end
    end
    
    def is_private?
      index >= 0x80000000 || index < 0
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
    
    def private_derivation_message(i)
      "\x00" + private_key.to_bytes + i_as_bytes(i)
    end
    
    def public_derivation_message(i)
      public_key.to_bytes << i_as_bytes(i)
    end

    def i_as_bytes(i)
      [i].pack('N')
    end
    
    def derive_private_key(i = 0)
      message = i >= 0x80000000 || i < 0 ? private_derivation_message(i) : public_derivation_message(i)
      hash = hmac_sha512 int_to_bytes(chain_code), message
      left_int = left_from_hash(hash)
      raise InvalidKeyForIndex, 'greater than or equal to order' if left_int >= MoneyTree::Key::ORDER # very low probability
      child_private_key = (left_int + private_key.to_i) % MoneyTree::Key::ORDER
      raise InvalidKeyForIndex, 'equal to zero' if child_private_key == 0 # very low probability
      child_chain_code = right_from_hash(hash)
      return child_private_key, child_chain_code
    end
    
    def derive_public_key(i = 0)
      raise PrivatePublicMismatch if i >= 0x80000000
      message = public_derivation_message(i)
      hash = hmac_sha512 int_to_bytes(chain_code), message
      left_int = left_from_hash(hash)
      raise InvalidKeyForIndex, 'greater than or equal to order' if left_int >= MoneyTree::Key::ORDER # very low probability
      factor = BN.new left_int.to_s
      child_public_key = public_key.uncompressed.group.generator.mul(factor).add(public_key.uncompressed.point).to_bn.to_i
      raise InvalidKeyForIndex, 'at infinity' if child_public_key == 1/0.0 # very low probability
      child_chain_code = right_from_hash(hash)
      return child_public_key, child_chain_code
    end
    
    def left_from_hash(hash)
      bytes_to_int hash.bytes.to_a[0..31]
    end
    
    def right_from_hash(hash)
      bytes_to_int hash.bytes.to_a[32..-1]
    end

    def to_serialized_hex(type = :public)
      raise PrivatePublicMismatch if type.to_sym == :private && private_key.nil?
      version_key = type.to_sym == :private ? :extended_privkey_version : :extended_pubkey_version
      hex = MoneyTree::NETWORKS[:bitcoin][version_key] # version (4 bytes)
      hex += depth_hex(depth) # depth (1 byte)
      hex += depth.zero? ? '00000000' : parent.to_fingerprint# fingerprint of key (4 bytes)
      hex += index_hex(index) # child number i (4 bytes)
      hex += chain_code_hex
      hex += type.to_sym == :private ? "00#{private_key.to_hex}" : public_key.compressed.to_hex
    end
    
    def to_serialized_address(type = :public)
      raise PrivatePublicMismatch if type.to_sym == :private && private_key.nil?
      to_serialized_base58 to_serialized_hex(type)
    end
    
    def to_identifier
      public_key.compressed.to_ripemd160
    end
    
    def to_fingerprint
      public_key.compressed.to_fingerprint
    end
    
    def to_address
      address = MoneyTree::NETWORKS[:bitcoin][:address_version] + to_identifier
      to_serialized_base58 address
    end
    
    def subnode(i = 0, opts = {})
      if private_key.nil?
        child_public_key, child_chain_code = derive_public_key(i)
        child_public_key = MoneyTree::PublicKey.new child_public_key
      else
        child_private_key, child_chain_code = derive_private_key(i)
        child_private_key = MoneyTree::PrivateKey.new key: child_private_key
        child_public_key = MoneyTree::PublicKey.new child_private_key
      end
            
      MoneyTree::Node.new depth: depth+1, 
                          index: i, 
                          private_key: private_key.nil? ? nil : child_private_key,
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
      path = path[0..-5] if force_public
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
      if force_public or parts.first == 'M'
        node = nodes.last
        node.strip_private_info!
        node
      else
        nodes.last
      end
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
    
    def strip_private_info!
      @private_key = nil
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
      opts[:seed] = [opts[:seed_hex]].pack("H*") if opts[:seed_hex]
      if opts[:seed]
        @seed = opts[:seed]
        @seed_hash = generate_seed_hash(@seed)
        raise SeedGeneration::ImportError unless seed_valid?(@seed_hash)
        set_seeded_keys
      elsif opts[:private_key] || opts[:public_key]
        raise ImportError, 'chain code required' unless opts[:chain_code]
        @chain_code = opts[:chain_code]
        if opts[:private_key]
          @private_key = opts[:private_key]
          @public_key = MoneyTree::PublicKey.new @private_key
        else opts[:public_key]
          @public_key = opts[:public_key].is_a?(MoneyTree::PublicKey) ? opts[:public_key] : MoneyTree::PublicKey.new(opts[:public_key])
        end
      else
        generate_seed
        set_seeded_keys
      end
    end
    
    def is_private?
      true
    end
    
    def generate_seed
      @seed = OpenSSL::Random.random_bytes(32)
      @seed_hash = generate_seed_hash(@seed)
      raise SeedGeneration::ValidityError unless seed_valid?(@seed_hash)
    end
    
    def generate_seed_hash(seed)
      hmac_sha512 HD_WALLET_BASE_KEY, seed
    end
    
    def seed_valid?(seed_hash)
      return false unless seed_hash.bytesize == 64
      master_key = left_from_hash(seed_hash)
      !master_key.zero? && master_key < MoneyTree::Key::ORDER
    end
    
    def set_seeded_keys
      @private_key = MoneyTree::PrivateKey.new key: left_from_hash(seed_hash)
      @chain_code = right_from_hash(seed_hash)
      @public_key = MoneyTree::PublicKey.new @private_key
    end
  end
end
