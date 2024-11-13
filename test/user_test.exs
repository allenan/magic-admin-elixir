defmodule UserTest do
  use ExUnit.Case
  alias Magic.User
  import TestHelper

  setup do
    Application.put_env(:magic_admin, :secret_key, "some_api_key")
  end

  def user_fixture do
    %{
      "issuer" => "some_issuer",
      "email" => "some@email.com",
      "phoneNumber" => "some_phone_number",
      "publicAddress" => "some_public_address"
    }
  end

  def user_with_wallet_fixture(wallet_type) do
    user_fixture()
    |> Map.put("wallets", [
      %{
        "wallet_type" => wallet_type |> to_string() |> String.upcase(),
        "public_address" => "public_address"
      }
    ])
  end

  describe "get_metadata_by_issuer/2" do
    test "gets user given issuer with no wallet type" do
      Mox.expect(Tesla.MockAdapter, :call, fn env, _opts ->
        assert env.headers == [{"X-Magic-Secret-Key", "some_api_key"}]
        {:ok, %{env | body: %{"status" => "ok", "data" => user_fixture()}}}
      end)

      {status, user} = User.get_metadata_by_issuer("some_issuer")
      assert status == :ok
      assert user.email == "some@email.com"
    end

    test "gets user given issuer with wallet type" do
      Mox.expect(Tesla.MockAdapter, :call, fn env, _opts ->
        assert env.headers == [{"X-Magic-Secret-Key", "some_api_key"}]
        {:ok, %{env | body: %{"status" => "ok", "data" => user_with_wallet_fixture(:solana)}}}
      end)

      {status, user} = User.get_metadata_by_issuer("some_issuer", :solana)
      assert status == :ok
      assert user.email == "some@email.com"
      assert length(user.wallets) == 1
      assert Enum.at(user.wallets, 0) |> Map.get(:wallet_type) == :solana
    end

    test "gets user given issuer with different secret key" do
      Mox.expect(Tesla.MockAdapter, :call, fn env, _opts ->
        assert env.headers == [{"X-Magic-Secret-Key", "different_api_key"}]
        {:ok, %{env | body: %{"status" => "ok", "data" => user_fixture()}}}
      end)

      {status, user} =
        User.get_metadata_by_issuer("some_issuer", :none, secret_key: "different_api_key")

      assert status == :ok
      assert user.email == "some@email.com"
    end
  end

  describe "get_metadata_by_public_address/2" do
    test "gets user given public address with no wallet type" do
      Mox.expect(Tesla.MockAdapter, :call, fn env, _opts ->
        assert env.headers == [{"X-Magic-Secret-Key", "some_api_key"}]
        {:ok, %{env | body: %{"status" => "ok", "data" => user_fixture()}}}
      end)

      {status, user} = User.get_metadata_by_public_address("some_public_address")
      assert status == :ok
      assert user.email == "some@email.com"
    end

    test "gets user given public address with wallet type" do
      Mox.expect(Tesla.MockAdapter, :call, fn env, _opts ->
        assert env.headers == [{"X-Magic-Secret-Key", "some_api_key"}]
        {:ok, %{env | body: %{"status" => "ok", "data" => user_with_wallet_fixture(:solana)}}}
      end)

      {status, user} = User.get_metadata_by_public_address("some_public_address", :solana)
      assert status == :ok
      assert user.email == "some@email.com"
      assert length(user.wallets) == 1
      assert Enum.at(user.wallets, 0) |> Map.get(:wallet_type) == :solana
    end

    test "gets user given public address with different secret key" do
      Mox.expect(Tesla.MockAdapter, :call, fn env, _opts ->
        assert env.headers == [{"X-Magic-Secret-Key", "different_api_key"}]
        {:ok, %{env | body: %{"status" => "ok", "data" => user_fixture()}}}
      end)

      {status, user} =
        User.get_metadata_by_public_address("some_public_address", :none,
          secret_key: "different_api_key"
        )

      assert status == :ok
      assert user.email == "some@email.com"
    end
  end

  describe "get_metadata_by_token/2" do
    test "gets user given token with no wallet type" do
      Mox.expect(Tesla.MockAdapter, :call, fn env, _opts ->
        assert env.headers == [{"X-Magic-Secret-Key", "some_api_key"}]
        {:ok, %{env | body: %{"status" => "ok", "data" => user_fixture()}}}
      end)

      %{token: did_token} = token_fixture()
      {status, user} = User.get_metadata_by_token(did_token)
      assert status == :ok
      assert user.email == "some@email.com"
    end

    test "gets user given token with wallet type" do
      Mox.expect(Tesla.MockAdapter, :call, fn env, _opts ->
        assert env.headers == [{"X-Magic-Secret-Key", "some_api_key"}]
        {:ok, %{env | body: %{"status" => "ok", "data" => user_with_wallet_fixture(:solana)}}}
      end)

      %{token: did_token} = token_fixture()
      {status, user} = User.get_metadata_by_token(did_token, :solana)
      assert status == :ok
      assert user.email == "some@email.com"
      assert length(user.wallets) == 1
      assert Enum.at(user.wallets, 0) |> Map.get(:wallet_type) == :solana
    end

    test "gets user given token with different secret key" do
      Mox.expect(Tesla.MockAdapter, :call, fn env, _opts ->
        assert env.headers == [{"X-Magic-Secret-Key", "different_api_key"}]
        {:ok, %{env | body: %{"status" => "ok", "data" => user_fixture()}}}
      end)

      %{token: did_token} = token_fixture()

      {status, user} =
        User.get_metadata_by_token(did_token, :none, secret_key: "different_api_key")

      assert status == :ok
      assert user.email == "some@email.com"
    end
  end

  describe "logout_by_issuer/2" do
    test "logs out user given issuer" do
      Mox.expect(Tesla.MockAdapter, :call, fn env, _opts ->
        {_, api_key} = List.keyfind(env.headers, "X-Magic-Secret-Key", 0)
        assert api_key == "some_api_key"
        {:ok, %{env | body: %{"status" => "ok", "data" => %{}}}}
      end)

      assert User.logout_by_issuer("some_issuer") == {:ok, %{}}
    end

    test "logs out user given issuer with different secret key" do
      Mox.expect(Tesla.MockAdapter, :call, fn env, _opts ->
        {_, api_key} = List.keyfind(env.headers, "X-Magic-Secret-Key", 0)
        assert api_key == "different_api_key"
        {:ok, %{env | body: %{"status" => "ok", "data" => %{}}}}
      end)

      assert User.logout_by_issuer("some_issuer", secret_key: "different_api_key") == {:ok, %{}}
    end
  end

  describe "logout_by_public_address/2" do
    test "logs out user given public address" do
      Mox.expect(Tesla.MockAdapter, :call, fn env, _opts ->
        {_, api_key} = List.keyfind(env.headers, "X-Magic-Secret-Key", 0)
        assert api_key == "some_api_key"
        {:ok, %{env | body: %{"status" => "ok", "data" => %{}}}}
      end)

      assert User.logout_by_public_address("some_public_address") == {:ok, %{}}
    end

    test "logs out user given public address with different secret key" do
      Mox.expect(Tesla.MockAdapter, :call, fn env, _opts ->
        {_, api_key} = List.keyfind(env.headers, "X-Magic-Secret-Key", 0)
        assert api_key == "different_api_key"
        {:ok, %{env | body: %{"status" => "ok", "data" => %{}}}}
      end)

      assert User.logout_by_public_address("some_public_address", secret_key: "different_api_key") ==
               {:ok, %{}}
    end
  end

  describe "logout_by_token/2" do
    test "logs out user given token" do
      Mox.expect(Tesla.MockAdapter, :call, fn env, _opts ->
        {_, api_key} = List.keyfind(env.headers, "X-Magic-Secret-Key", 0)
        assert api_key == "some_api_key"
        {:ok, %{env | body: %{"status" => "ok", "data" => %{}}}}
      end)

      %{token: did_token} = token_fixture()
      assert User.logout_by_token(did_token) == {:ok, %{}}
    end

    test "logs out user given public address with different secret key" do
      Mox.expect(Tesla.MockAdapter, :call, fn env, _opts ->
        {_, api_key} = List.keyfind(env.headers, "X-Magic-Secret-Key", 0)
        assert api_key == "different_api_key"
        {:ok, %{env | body: %{"status" => "ok", "data" => %{}}}}
      end)

      %{token: did_token} = token_fixture()

      assert User.logout_by_token(did_token, secret_key: "different_api_key") ==
               {:ok, %{}}
    end
  end
end
