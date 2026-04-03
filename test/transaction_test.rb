require_relative "test_helper"

class TransactionTest < Minitest::Test
  def test_anchor_discriminator
    disc = Solana::Transaction.anchor_discriminator("initialize")
    assert_equal 8, disc.bytesize

    # Should be deterministic
    disc2 = Solana::Transaction.anchor_discriminator("initialize")
    assert_equal disc, disc2
  end

  def test_anchor_discriminator_different_names
    init_disc = Solana::Transaction.anchor_discriminator("initialize")
    deposit_disc = Solana::Transaction.anchor_discriminator("deposit")
    refute_equal init_disc, deposit_disc
  end

  def test_pda_derivation_deterministic
    program_id = Solana::Keypair.generate.public_key_bytes
    seeds = ["vault_state".b]

    pda1, bump1 = Solana::Transaction.find_pda(seeds, program_id)
    pda2, bump2 = Solana::Transaction.find_pda(seeds, program_id)

    assert_equal pda1, pda2
    assert_equal bump1, bump2
    assert_equal 32, pda1.bytesize
    assert_kind_of Integer, bump1
    assert bump1 >= 0 && bump1 <= 255
  end

  def test_pda_is_not_on_curve
    program_id = Solana::Keypair.generate.public_key_bytes
    seeds = ["test_pda".b]

    pda, _ = Solana::Transaction.find_pda(seeds, program_id)
    refute Solana::Transaction.on_curve?(pda), "PDA should not be on the Ed25519 curve"
  end

  def test_on_curve_with_real_pubkey
    kp = Solana::Keypair.generate
    assert Solana::Transaction.on_curve?(kp.public_key_bytes), "Real public key should be on the Ed25519 curve"
  end

  def test_pda_with_base58_program_id
    kp = Solana::Keypair.generate
    address = kp.to_base58
    seeds = ["test".b]

    pda, bump = Solana::Transaction.find_pda(seeds, address)
    assert_equal 32, pda.bytesize
    assert bump >= 0 && bump <= 255
  end

  def test_pda_with_multiple_seeds
    program_id = Solana::Keypair.generate.public_key_bytes
    user_key = Solana::Keypair.generate.public_key_bytes
    seeds = ["user_account".b, user_key]

    pda, bump = Solana::Transaction.find_pda(seeds, program_id)
    assert_equal 32, pda.bytesize
    refute Solana::Transaction.on_curve?(pda)
  end

  def test_system_program_id_is_zero_bytes
    assert_equal "\x00" * 32, Solana::Transaction::SYSTEM_PROGRAM_ID
  end

  def test_token_program_id_decodes
    assert_equal 32, Solana::Transaction::TOKEN_PROGRAM_ID.bytesize
  end

  def test_transaction_requires_blockhash
    tx = Solana::Transaction.new
    kp = Solana::Keypair.generate
    tx.add_signer(kp)
    tx.add_instruction(
      program_id: Solana::Transaction::SYSTEM_PROGRAM_ID,
      accounts: [{ pubkey: kp.public_key_bytes, is_signer: true, is_writable: true }],
      data: "\x00"
    )

    assert_raises(RuntimeError) { tx.serialize }
  end

  def test_transaction_requires_signers
    tx = Solana::Transaction.new
    blockhash = Solana::Keypair.encode_base58("\x01" * 32)
    tx.set_recent_blockhash(blockhash)
    tx.add_instruction(
      program_id: Solana::Transaction::SYSTEM_PROGRAM_ID,
      accounts: [],
      data: "\x00"
    )

    assert_raises(RuntimeError) { tx.serialize }
  end

  def test_transaction_serializes
    tx = Solana::Transaction.new
    kp = Solana::Keypair.generate
    blockhash = Solana::Keypair.encode_base58("\x01" * 32)

    tx.set_recent_blockhash(blockhash)
    tx.add_signer(kp)
    tx.add_instruction(
      program_id: Solana::Transaction::SYSTEM_PROGRAM_ID,
      accounts: [{ pubkey: kp.public_key_bytes, is_signer: true, is_writable: true }],
      data: "\x00"
    )

    serialized = tx.serialize
    assert serialized.bytesize > 0

    # Should also work as base64
    b64 = tx.serialize_base64
    assert b64.is_a?(String)
    assert b64.length > 0
  end
end
