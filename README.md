# Magic Admin Elixir SDK

The Magic Admin Elixir SDK provides convenient ways for developers to interact with
Magic API endpoints and an array of utilities to handle DID Token.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `magic_admin` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:magic_admin, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/magic_admin](https://hexdocs.pm/magic_admin).

## Usage

### Validating Tokens

The `Token.validate!/1` function returns `true` if the token is valid, or raises a
`DIDTokenError` with a message describing why the token is invalid.

```elixir
true = Magic.Token.validate!(did_token)
```

The `Token.decode!/1` function returns a map of `proof`, `claim` and `message`, or raises
a `DIDTokenError` if it is malformed. `claim` is the parsed map of claims made by the decoded
token. `proof` is the secp256k1 signature over a hash of `message` which is the JSON
encoded version of `claim`.

```elixir
%{proof: proof, claim: claim, message: message} = Magic.Token.decode!(did_token)
```

The `Token` module also includes a couple of utility functions for accessing the issuer
and public address attributes of a token.

```elixir
issuer = Magic.Token.get_issuer(did_token)
address = Magic.Token.get_public_address(did_token)
```

### Accessing Users

TODO

## Attribution

This Elixir library is based on the official Ruby implementation: https://github.com/magiclabs/magic-admin-ruby
