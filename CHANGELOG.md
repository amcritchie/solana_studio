# Changelog

## v0.2.0 (2026-04-03)

- SPL Token instruction builders (`create_associated_token_account`, `mint_to`, `transfer`)
- Test suite: Keypair, Borsh, and Transaction tests (9 tests)
- Updated CLAUDE.md with test documentation

## v0.1.0 (2026-04-02)

- Initial release
- `Solana::Client` — JSON-RPC over HTTP with retry logic
- `Solana::Keypair` — Ed25519 keygen, base58, sign, `from_base58` for env var loading
- `Solana::Borsh` — encode/decode primitives (u8, u16, u32, u64, i64, pubkey, string, vec, bool)
- `Solana::Transaction` — transaction builder, PDA derivation, Anchor discriminators, on_curve? check
