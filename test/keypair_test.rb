require_relative "test_helper"

class KeypairTest < Minitest::Test
  def test_generate_creates_valid_keypair
    kp = Solana::Keypair.generate
    assert_equal 32, kp.public_key_bytes.bytesize
    assert_equal 64, kp.to_bytes.bytesize
    assert kp.to_base58.length > 0
  end

  def test_base58_roundtrip
    kp = Solana::Keypair.generate
    address = kp.to_base58

    decoded = Solana::Keypair.decode_base58(address)
    re_encoded = Solana::Keypair.encode_base58(decoded)

    assert_equal address, re_encoded
  end

  def test_from_base58_secret_key_roundtrip
    kp = Solana::Keypair.generate
    secret_b58 = Solana::Keypair.encode_base58(kp.to_bytes)

    restored = Solana::Keypair.from_base58(secret_b58)
    assert_equal kp.to_base58, restored.to_base58
  end

  def test_from_bytes_array
    kp = Solana::Keypair.generate
    bytes_array = kp.to_bytes.bytes

    restored = Solana::Keypair.from_bytes(bytes_array)
    assert_equal kp.to_base58, restored.to_base58
  end

  def test_sign_produces_valid_signature
    kp = Solana::Keypair.generate
    message = "Hello Solana"

    signature = kp.sign(message)
    assert_equal 64, signature.bytesize

    # Verify signature using ed25519 gem
    assert kp.verify_key.verify(signature, message)
  end

  def test_address_alias
    kp = Solana::Keypair.generate
    assert_equal kp.to_base58, kp.address
  end

  def test_pubkey_from_base58
    kp = Solana::Keypair.generate
    address = kp.to_base58

    pubkey_bytes = Solana::Keypair.pubkey_from_base58(address)
    assert_equal 32, pubkey_bytes.bytesize
    assert_equal kp.public_key_bytes, pubkey_bytes
  end

  def test_decode_base58_preserves_leading_zeros
    # Base58 '1' represents a zero byte
    decoded = Solana::Keypair.decode_base58("1" * 5 + "2")
    assert_equal 0, decoded.bytes[0]
    assert_equal 0, decoded.bytes[1]
  end

  def test_from_json_file
    kp = Solana::Keypair.generate
    tmpfile = "/tmp/test_keypair_#{Process.pid}.json"

    File.write(tmpfile, JSON.generate(kp.to_bytes.bytes))
    restored = Solana::Keypair.from_json_file(tmpfile)

    assert_equal kp.to_base58, restored.to_base58
  ensure
    File.delete(tmpfile) if File.exist?(tmpfile)
  end
end
