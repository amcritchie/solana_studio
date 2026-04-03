module Solana
  module SplToken
    module_function

    # Derive the Associated Token Address for a wallet + mint
    # Returns [ata_bytes, bump]
    def find_associated_token_address(wallet, mint)
      wallet_bytes = normalize(wallet)
      mint_bytes = normalize(mint)

      Transaction.find_pda(
        [wallet_bytes, Transaction::TOKEN_PROGRAM_ID, mint_bytes],
        Transaction::ASSOCIATED_TOKEN_PROGRAM_ID
      )
    end

    # Build a CreateAssociatedTokenAccount instruction
    # Returns hash compatible with Transaction#add_instruction
    def create_associated_token_account_instruction(payer:, wallet:, mint:)
      payer_bytes = normalize(payer)
      wallet_bytes = normalize(wallet)
      mint_bytes = normalize(mint)
      ata_bytes, _ = find_associated_token_address(wallet_bytes, mint_bytes)

      {
        program_id: Transaction::ASSOCIATED_TOKEN_PROGRAM_ID,
        accounts: [
          { pubkey: payer_bytes, is_signer: true, is_writable: true },
          { pubkey: ata_bytes, is_signer: false, is_writable: true },
          { pubkey: wallet_bytes, is_signer: false, is_writable: false },
          { pubkey: mint_bytes, is_signer: false, is_writable: false },
          { pubkey: Transaction::SYSTEM_PROGRAM_ID, is_signer: false, is_writable: false },
          { pubkey: Transaction::TOKEN_PROGRAM_ID, is_signer: false, is_writable: false }
        ],
        data: "".b
      }
    end

    # Build a SPL Token MintTo instruction (discriminator byte 7)
    # Returns hash compatible with Transaction#add_instruction
    def mint_to_instruction(mint:, destination:, authority:, amount:)
      mint_bytes = normalize(mint)
      dest_bytes = normalize(destination)
      auth_bytes = normalize(authority)

      data = [7].pack("C") + [amount].pack("Q<")

      {
        program_id: Transaction::TOKEN_PROGRAM_ID,
        accounts: [
          { pubkey: mint_bytes, is_signer: false, is_writable: true },
          { pubkey: dest_bytes, is_signer: false, is_writable: true },
          { pubkey: auth_bytes, is_signer: true, is_writable: false }
        ],
        data: data
      }
    end

    # Build a SPL Token Transfer instruction (discriminator byte 3)
    # Returns hash compatible with Transaction#add_instruction
    def transfer_instruction(from:, to:, authority:, amount:)
      from_bytes = normalize(from)
      to_bytes = normalize(to)
      auth_bytes = normalize(authority)

      data = [3].pack("C") + [amount].pack("Q<")

      {
        program_id: Transaction::TOKEN_PROGRAM_ID,
        accounts: [
          { pubkey: from_bytes, is_signer: false, is_writable: true },
          { pubkey: to_bytes, is_signer: false, is_writable: true },
          { pubkey: auth_bytes, is_signer: true, is_writable: false }
        ],
        data: data
      }
    end

    # Normalize base58 strings, Keypair objects, or raw bytes to 32-byte binary
    def normalize(value)
      if value.is_a?(Keypair)
        value.public_key_bytes
      elsif value.is_a?(String) && value.bytesize == 32
        value.b
      elsif value.is_a?(String)
        Keypair.decode_base58(value)
      else
        value
      end
    end
    private_class_method :normalize
  end
end
