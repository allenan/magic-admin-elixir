defmodule TokenTest do
  use ExUnit.Case
  doctest Magic.Token
  alias Magic.Token
  alias Magic.DIDTokenError

  def token_fixture() do
    private_key = ETH.Utils.get_private_key()
    address = ETH.Utils.get_address(private_key)

    make_token(default_claim(address), private_key)
  end

  def token_fixture_missing_sub() do
    private_key = ETH.Utils.get_private_key()
    address = ETH.Utils.get_address(private_key)

    claim = default_claim(address) |> Map.delete("sub")

    make_token(claim, private_key)
  end

  def token_fixture_bad_sig() do
    private_key = ETH.Utils.get_private_key()
    address = ETH.Utils.get_address(private_key)
    bad_private_key = ETH.Utils.get_private_key()

    make_token(default_claim(address), bad_private_key)
  end

  def token_fixture_expired() do
    private_key = ETH.Utils.get_private_key()
    address = ETH.Utils.get_address(private_key)

    now = DateTime.utc_now() |> DateTime.to_unix()
    claim = default_claim(address) |> Map.put("ext", now - 15 * 60)

    make_token(claim, private_key)
  end

  def token_fixture_bad_nbf() do
    private_key = ETH.Utils.get_private_key()
    address = ETH.Utils.get_address(private_key)

    now = DateTime.utc_now() |> DateTime.to_unix()
    claim = default_claim(address) |> Map.put("nbf", now + 15 * 60)

    make_token(claim, private_key)
  end

  test "validates a DID token" do
    %{token: did_token} = token_fixture()
    assert Token.validate!(did_token) == true
  end

  test "decodes a DID token using decode!" do
    %{token: did_token, proof: did_proof, claim: did_claim} = token_fixture()
    %{proof: proof, claim: claim} = Token.decode!(did_token)
    assert proof == did_proof
    assert claim["add"] == "fake_add"
    assert claim["aud"] == "fake_aud"
    assert claim["ext"] == did_claim["ext"]
    assert claim["iat"] == did_claim["iat"]
    assert claim["iss"] == did_claim["iss"]
    assert claim["nbf"] == did_claim["nbf"]
    assert claim["sub"] == "fake_sub"
    assert claim["tid"] == "fake_tid"
  end

  test "decodes a DID token using decode" do
    %{token: did_token, proof: did_proof, claim: did_claim} = token_fixture()
    {:ok, %{proof: proof, claim: claim}} = Token.decode(did_token)
    assert proof == did_proof
    assert claim["add"] == "fake_add"
    assert claim["aud"] == "fake_aud"
    assert claim["ext"] == did_claim["ext"]
    assert claim["iat"] == did_claim["iat"]
    assert claim["iss"] == did_claim["iss"]
    assert claim["nbf"] == did_claim["nbf"]
    assert claim["sub"] == "fake_sub"
    assert claim["tid"] == "fake_tid"
  end

  test "constructs issuer given public address" do
    assert Token.construct_issuer_with_public_address("fake_addr") == "did:ethr:fake_addr"
  end

  test "gets the issuer from an encoded token" do
    %{token: did_token, claim: did_claim} = token_fixture()
    assert Token.get_issuer(did_token) == did_claim["iss"]
  end

  test "decode! raises an error if token is malformed" do
    assert_raise DIDTokenError, "DID Token is malformed", fn ->
      Token.decode!("malformed_token")
    end
  end

  test "decode returns an error tuple if token is malformed" do
    assert Token.decode("malformed_token") == {:error, :malformed_did_token}
  end

  test "raises an error if token is missing fields" do
    %{token: token} = token_fixture_missing_sub()

    assert_raise DIDTokenError, "DID Token missing required fields: sub", fn ->
      Token.decode!(token)
    end

    assert_raise DIDTokenError, "DID Token missing required fields: sub", fn ->
      Token.validate!(token)
    end
  end

  test "raises an error if signature does not match claimed address" do
    %{token: token} = token_fixture_bad_sig()

    assert_raise DIDTokenError, "Signature mismatch between 'proof' and 'claim'.", fn ->
      Token.validate!(token)
    end
  end

  test "raises an error if token is expired" do
    %{token: token} = token_fixture_expired()

    assert_raise DIDTokenError, "Given DID token has expired. Please generate a new one.", fn ->
      Token.validate!(token)
    end
  end

  test "raises an error if token is not yet in valid time usage window" do
    %{token: token} = token_fixture_bad_nbf()

    assert_raise DIDTokenError, "Given DID token cannot be used at this time.", fn ->
      Token.validate!(token)
    end
  end

  defp default_claim(address) do
    now = DateTime.utc_now() |> DateTime.to_unix()

    %{
      "add" => "fake_add",
      "aud" => "fake_aud",
      "ext" => now + 15 * 60,
      "iat" => now,
      "iss" => "did:ethr:#{address}",
      "nbf" => now,
      "sub" => "fake_sub",
      "tid" => "fake_tid"
    }
  end

  defp make_token(claim, private_key) do
    message = Jason.encode!(claim)
    hash = message |> Magic.Utils.prefix_message() |> ETH.Utils.keccak256()
    [signature: signature, recovery: recovery] = ETH.Utils.secp256k1_signature(hash, private_key)
    proof = <<signature::binary, recovery + 27::size(8)>> |> Magic.Utils.bin_to_hex()
    token = [proof, message] |> Jason.encode!() |> Base.encode64()

    %{token: token, proof: proof, claim: claim}
  end
end
