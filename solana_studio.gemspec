Gem::Specification.new do |spec|
  spec.name          = "solana_studio"
  spec.version       = "0.1.0"
  spec.authors       = ["Alex McRitchie"]
  spec.email         = ["alex@mcritchie.studio"]

  spec.summary       = "Ruby primitives for Solana: JSON-RPC client, Ed25519 keypairs, Borsh serialization, transaction builder"
  spec.description   = "A lightweight Ruby gem providing generic Solana building blocks — JSON-RPC client with retry, Ed25519 keypair management, Borsh encoding/decoding, and a transaction builder with PDA derivation and Anchor discriminators."
  spec.homepage      = "https://github.com/amcritchie/solana_studio"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.files         = Dir["lib/**/*.rb", "README.md", "LICENSE", "CHANGELOG.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "ed25519", "~> 1.3"
end
