defmodule ApiTest do
  use ExUnit.Case
  alias Magic.API

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

  describe "get_user/2" do
    test "gets user by issuer with no wallet type" do
      Mox.expect(Tesla.MockAdapter, :call, fn env, _opts ->
        assert env.url == "https://api.magic.link/v1/admin/auth/user/get"
        assert env.headers == [{"X-Magic-Secret-Key", "some_api_key"}]
        assert env.query == [issuer: "some_issuer", wallet_type: "NONE"]
        {:ok, %{env | body: %{"status" => "ok", "data" => user_fixture()}}}
      end)

      {status, user} = API.get_user("some_issuer")
      assert status == :ok
      assert user.email == "some@email.com"
    end

    test "gets user by issuer with wallet type" do
      Mox.expect(Tesla.MockAdapter, :call, fn env, _opts ->
        assert env.url == "https://api.magic.link/v1/admin/auth/user/get"
        assert env.headers == [{"X-Magic-Secret-Key", "some_api_key"}]
        assert env.query == [issuer: "some_issuer", wallet_type: "SOLANA"]

        {:ok,
         %{
           env
           | body: %{
               "status" => "ok",
               "data" => user_with_wallet_fixture(:solana)
             }
         }}
      end)

      {status, user} = API.get_user("some_issuer", :solana)
      assert status == :ok
      assert user.email == "some@email.com"
      assert length(user.wallets) == 1
      assert Enum.at(user.wallets, 0) |> Map.get(:wallet_type) == :solana
    end

    test "gets user by issuer with a different secret key" do
      Mox.expect(Tesla.MockAdapter, :call, fn env, _opts ->
        assert env.url == "https://api.magic.link/v1/admin/auth/user/get"
        assert env.headers == [{"X-Magic-Secret-Key", "different_api_key"}]
        assert env.query == [issuer: "some_issuer", wallet_type: "NONE"]
        {:ok, %{env | body: %{"status" => "ok", "data" => user_fixture()}}}
      end)

      {status, user} = API.get_user("some_issuer", :none, secret_key: "different_api_key")
      assert status == :ok
      assert user.email == "some@email.com"
    end
  end

  describe "logout_user/2" do
    test "logs user out by issuer" do
      Mox.expect(Tesla.MockAdapter, :call, fn env, _opts ->
        assert env.url == "https://api.magic.link/v2/admin/auth/user/logout"
        {_, api_key} = List.keyfind(env.headers, "X-Magic-Secret-Key", 0)
        assert api_key == "some_api_key"
        assert env.body == Jason.encode!(%{issuer: "some_issuer"})
        {:ok, %{env | body: %{"status" => "ok", "data" => %{}}}}
        # {:ok, env}
      end)

      assert API.logout_user("some_issuer") == {:ok, %{}}
    end

    test "gets user by issuer with a different secret key" do
      Mox.expect(Tesla.MockAdapter, :call, fn env, _opts ->
        assert env.url == "https://api.magic.link/v2/admin/auth/user/logout"
        {_, api_key} = List.keyfind(env.headers, "X-Magic-Secret-Key", 0)
        assert api_key == "different_api_key"
        assert env.body == Jason.encode!(%{issuer: "some_issuer"})
        {:ok, %{env | body: %{"status" => "ok", "data" => %{}}}}
      end)

      assert API.logout_user("some_issuer", secret_key: "different_api_key") == {:ok, %{}}
    end
  end
end
