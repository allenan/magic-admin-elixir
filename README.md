# Magic Admin Elixir SDK

The Magic Admin Elixir SDK provides convenient ways for developers to interact with
Magic API endpoints and an array of utilities to handle DID Token.

Additional documentation can be found at [https://hexdocs.pm/magic_admin](https://hexdocs.pm/magic_admin).

## Installation

The package can be installed by adding `magic_admin` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:magic_admin, "~> 0.7.0"}
  ]
end
```

## Configuration

To make API calls, it is necessary to configure your Magic secret key.

```elixir
use Mix.Config

config :magic_admin, secret_key: System.get_env("MAGIC_SECRET")
# OR
config :magic_admin, secret_key: "sk_live_XXXXXXXXXXX"
```

## Usage

### Tokens

#### Validate Tokens

The `Token.validate/1` function returns `:ok` if the token is valid, or an error tuple
with a message describing why the token is invalid.

```elixir
:ok = Magic.Token.validate(did_token)
{:error, {:did_token_error, message}} = Magic.Token.validate(invalid_did_token)
```

The `Token.validate!/1` function returns `true` if the token is valid, or raises a
`DIDTokenError` with a message describing why the token is invalid.

```elixir
true = Magic.Token.validate!(did_token)
```

#### Decode Tokens

The `Token.decode/1` function returns a map of `proof`, `claim` and `message`, or an error
tuple if it is malformed. `claim` is the parsed map of claims made by the decoded
token. `proof` is the secp256k1 signature over a hash of `message` which is the JSON
encoded version of `claim`.

```elixir
{:ok, %{proof: proof, claim: claim, message: message}} = Magic.Token.decode(did_token)
{:error, {:did_token_error, message}} = Magic.Token.decode(invalid_did_token)
```

The `Token.decode!/1` function returns a map of `proof`, `claim` and `message`, or raises
a `DIDTokenError` if it is malformed.

```elixir
%{proof: proof, claim: claim, message: message} = Magic.Token.decode!(did_token)
```

#### Get Token Attributes

The `Token` module also includes a couple of utility functions for accessing the issuer
and public address attributes of a token.

```elixir
issuer = Magic.Token.get_issuer(did_token)
address = Magic.Token.get_public_address(did_token)
```

### Users

#### Get User Metadata

Metadata for a user can be retrieved by supplying issuer, public key, or the full DID Token:

```elixir
Magic.User.get_metadata_by_issuer(issuer)
Magic.User.get_metadata_by_public_address(public_address)
Magic.User.get_metadata_by_token(did_token)
# => {:ok, %{email: "fake@example.com", issuer: "did:ethr:0x00000000000000000000000000000", public_address: "0x00000000000000000000000000000000"}}
 ```

#### Log Out a User

Logs a user out of all Magic SDK sessions by the supplied issuer, public address, or the full DID Token:

```elixir
Magic.User.logout_by_issuer(issuer)
Magic.User.logout_by_public_address(public_address)
Magic.User.logout_by_token(did_token)
 ```

## Attribution

This Elixir library is based on the official Ruby implementation: https://github.com/magiclabs/magic-admin-ruby
