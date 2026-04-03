# SolanaStudio Gem

Generic Solana primitives for Ruby. Extracted from Turf Monster's `app/services/solana/` layer.

## Architecture

- `Solana::Keypair` — Ed25519 key management, base58 encode/decode
- `Solana::Client` — JSON-RPC HTTP client with retry (rate limit + blockhash expiry)
- `Solana::Borsh` — Borsh binary serialization (little-endian)
- `Solana::Transaction` — Transaction builder, PDA derivation, Anchor discriminators

## Design Decisions

- **No Rails dependency** — pure Ruby + ed25519 gem only
- **`Solana::*` namespace** preserved from source app for zero-migration
- **No encryption** — Rails-specific `encrypt`/`from_encrypted` stays in consumer apps
- **`from_base58`** added for loading keypairs from env vars (12-factor friendly)
- **Client defaults** to `SOLANA_RPC_URL` env var or devnet

## Consumer Apps

- **Turf Monster** — keeps `Solana::Config`, `Solana::Vault`, `Solana::Reconciler`, `Solana::AuthVerifier`
- **McRitchie Studio** — can use for future Solana features

## Repo

- GitHub: https://github.com/amcritchie/solana_studio
- Install: `gem "solana_studio", git: "https://github.com/amcritchie/solana_studio.git"`
