defmodule Magic.Utils do
  @v_base 27

  def prefix_message(message) do
    "\x19Ethereum Signed Message:\n#{String.length(message)}#{message}"
  end

  def recover_pubkey(message, signature) do
    <<bin_signature::binary-size(64), version::size(8)>> = hex_to_bin(signature)
    hash = ExKeccak.hash_256(Magic.Utils.prefix_message(message))

    # Version of signature should be 27 or 28, but 0 and 1 are also possible versions
    # which can show up in Ledger hardwallet signings
    if version < 27 do
      version = version + 27
    end

    {:ok, pubkey} = ExSecp256k1.recover_compact(hash, bin_signature, version - @v_base)
    pubkey
  end

  def pubkey_to_address(pubkey) do
    ETH.Utils.get_address(pubkey)
  end

  def hex_to_bin(string) do
    Base.decode16!(remove_hex_prefix(string), case: :mixed)
  end

  def bin_to_hex(bin) do
    bin |> Base.encode16() |> add_hex_prefix()
  end

  def remove_hex_prefix(s) do
    if String.starts_with?(s, "0x") do
      String.slice(s, 2..-1)
    else
      s
    end
  end

  def add_hex_prefix(s) do
    "0x" <> s
  end
end
