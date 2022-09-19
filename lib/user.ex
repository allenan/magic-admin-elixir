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
  @spec get_metadata_by_issuer(issuer) :: {:ok, user} | {:error, String.t()}
  def get_metadata_by_issuer(issuer, opts \\ []) do
    Magic.API.get_user(issuer, opts)
  end

  @doc """
  Retrieves information about the user by the supplied public address
  """
  @spec get_metadata_by_public_address(public_address) :: {:ok, user} | {:error, String.t()}
  def get_metadata_by_public_address(public_address, opts \\ []) do
    issuer = Token.construct_issuer_with_public_address(public_address)
    get_metadata_by_issuer(issuer, opts)
  end

  @doc """
  Retrieves information about the user by the supplied DID Token
  """
  @spec get_metadata_by_token(did_token) :: {:ok, user} | {:error, String.t()}
  def get_metadata_by_token(did_token, opts \\ []) do
    issuer = Token.get_issuer(did_token)
    get_metadata_by_issuer(issuer, opts)
  end

  @doc """
  Logs a user out of all Magic SDK sessions by the supplied issuer
  """
  @spec logout_by_issuer(issuer) :: {:ok, %{}} | {:error, String.t()}
  def logout_by_issuer(issuer, opts \\ []) do
    Magic.API.logout_user(issuer, opts)
  end

  @doc """
  Logs a user out of all Magic SDK sessions by the supplied public address
  """
  @spec logout_by_public_address(public_address) :: {:ok, %{}} | {:error, String.t()}
  def logout_by_public_address(public_address, opts \\ []) do
    issuer = Token.construct_issuer_with_public_address(public_address)
    logout_by_issuer(issuer, opts)
  end

  @doc """
  Logs a user out of all Magic SDK sessions by the supplied DID Token
  """
  @spec logout_by_token(did_token) :: {:ok, %{}} | {:error, String.t()}
  def logout_by_token(did_token, opts \\ []) do
    issuer = Token.get_issuer(did_token)
    logout_by_issuer(issuer, opts)
  end
end
