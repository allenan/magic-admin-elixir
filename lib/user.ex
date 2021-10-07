defmodule Magic.User do
  @moduledoc """
  Provides methods to interact with the User via the Magic API
  """
  alias Magic.Token

  @type issuer :: Token.issuer()
  @type public_address :: Token.public_address()
  @type did_token :: Token.did_token()
  @type user :: %{email: String.t(), issuer: issuer, public_address: public_address}

  @doc """
  Retrieves information about the user by the supplied issuer
  """
  @spec get_metadata_by_issuer!(issuer) :: user
  def get_metadata_by_issuer!(issuer) do
    %HTTPoison.Response{body: body} =
      Magic.API.get!("/v1/admin/auth/user/get", nil, params: [issuer: issuer])

    body["data"]
    |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
  end

  @doc """
  Retrieves information about the user by the supplied public address
  """
  @spec get_metadata_by_public_address!(public_address) :: user
  def get_metadata_by_public_address!(public_address) do
    issuer = Token.construct_issuer_with_public_address(public_address)
    get_metadata_by_issuer!(issuer)
  end

  @doc """
  Retrieves information about the user by the supplied DID Token
  """
  @spec get_metadata_by_token!(did_token) :: user
  def get_metadata_by_token!(did_token) do
    issuer = Token.get_issuer(did_token)
    get_metadata_by_issuer!(issuer)
  end

  @doc """
  Logs a user out of all Magic SDK sessions by the supplied issuer
  """
  @spec logout_by_issuer!(issuer) :: HTTPoison.Response.t()
  def logout_by_issuer!(issuer) do
    Magic.API.post!("/v2/admin/auth/user/logout", nil, params: [issuer: issuer])
  end

  @doc """
  Logs a user out of all Magic SDK sessions by the supplied public address
  """
  @spec logout_by_public_address!(public_address) :: HTTPoison.Response.t()
  def logout_by_public_address!(public_address) do
    issuer = Token.construct_issuer_with_public_address(public_address)
    logout_by_issuer!(issuer)
  end

  @doc """
  Logs a user out of all Magic SDK sessions by the supplied DID Token
  """
  @spec logout_by_token!(did_token) :: HTTPoison.Response.t()
  def logout_by_token!(did_token) do
    issuer = Token.get_issuer(did_token)
    logout_by_issuer!(issuer)
  end
end
