module MoneyTree
  NETWORKS = {
    bitcoin: {
      address_version: '00',
      p2sh_version: '05',
      privkey_version: '80',
      privkey_compression_flag: '01',
      extended_privkey_version: "0488ade4",
      extended_pubkey_version: "0488b21e",
      compressed_wif_chars: %w(K L),
      uncompressed_wif_char: '5',
      protocol_version: 70001
    },
    bitcoin_testnet: {
      address_version: '6f',
      p2sh_version: '05',
      privkey_version: '80',
      privkey_compression_flag: '01',
      extended_privkey_version: "04358394",
      extended_pubkey_version: "043587cf",
      compressed_wif_chars: %w(K L),
      uncompressed_wif_char: '5',
      protocol_version: 70001
    }
  }
end