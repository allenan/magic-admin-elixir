ExUnit.start()
Mox.defmock(Tesla.MockAdapter, for: Tesla.Adapter)

defmodule TestHelper do
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
