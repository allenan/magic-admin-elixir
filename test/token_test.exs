defmodule TokenTest do
  use ExUnit.Case
  doctest Magic.Token
  alias Magic.Token
  alias Magic.DIDTokenError
  import TestHelper

  describe "validate!/1" do
    test "validates a DID token" do
      %{token: did_token} = token_fixture()
      assert Token.validate!(did_token) == true
    end

    test "raises an error if token is missing fields" do
      %{token: token} = token_fixture_missing_sub()

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
  end

  describe "validate/1" do
    test "validates a DID token" do
      %{token: did_token} = token_fixture()
      assert Token.validate(did_token) == :ok
    end

    test "returns an error if token is missing fields" do
      %{token: token} = token_fixture_missing_sub()

      assert Token.validate(token) ==
               {:error, {:did_token_error, "DID Token missing required fields: sub"}}
    end

    test "returns an error if signature does not match claimed address" do
      %{token: token} = token_fixture_bad_sig()

      assert Token.validate(token) ==
               {:error, {:did_token_error, "Signature mismatch between 'proof' and 'claim'."}}
    end

    test "raises an error if token is expired" do
      %{token: token} = token_fixture_expired()

      assert Token.validate(token) ==
               {:error,
                {:did_token_error, "Given DID token has expired. Please generate a new one."}}
    end

    test "raises an error if token is not yet in valid time usage window" do
      %{token: token} = token_fixture_bad_nbf()

      assert Token.validate(token) ==
               {:error, {:did_token_error, "Given DID token cannot be used at this time."}}
    end
  end

  describe "decode!/1" do
    test "decodes a DID token" do
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

    test "raises an error if token is malformed" do
      assert_raise DIDTokenError, "DID Token is malformed", fn ->
        Token.decode!("malformed_token")
      end
    end

    test "raises an error if token is missing fields" do
      %{token: token} = token_fixture_missing_sub()

      assert_raise DIDTokenError, "DID Token missing required fields: sub", fn ->
        Token.decode!(token)
      end
    end
  end

  describe "decode/1" do
    test "decodes a DID token" do
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

    test "returns an error tuple if token is malformed" do
      assert Token.decode("malformed_token") ==
               {:error, {:did_token_error, "DID Token is malformed"}}
    end
  end

  describe "construct_issuer_with_public_address/1" do
    test "constructs issuer given public address" do
      assert Token.construct_issuer_with_public_address("fake_addr") == "did:ethr:fake_addr"
    end
  end

  describe "get_issuer/1" do
    test "gets the issuer from an encoded token" do
      %{token: did_token, claim: did_claim} = token_fixture()
      assert Token.get_issuer(did_token) == did_claim["iss"]
    end
  end
end
