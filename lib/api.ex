defmodule Magic.API do
  @moduledoc false

  use Tesla

  def get_user(issuer, opts \\ []) do
    secret_key = Keyword.get(opts, :secret_key, Application.get_env(:magic_admin, :secret_key))

    client(secret_key)
    |> get("/v1/admin/auth/user/get", query: [issuer: issuer])
    |> process_response()
  end

  def logout_user(issuer, opts \\ []) do
    secret_key = Keyword.get(opts, :secret_key, Application.get_env(:magic_admin, :secret_key))

    client(secret_key)
    |> post("/v2/admin/auth/user/logout", %{issuer: issuer})
    |> process_response()
  end

  defp client(secret_key) do
    middleware = [
      {Tesla.Middleware.BaseUrl, "https://api.magic.link"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers,
       [
         {"X-Magic-Secret-Key", secret_key}
       ]}
    ]

    Tesla.client(middleware)
  end

  defp process_response({:ok, %Tesla.Env{body: %{"status" => "ok", "data" => data}}}) do
    {:ok, data |> map_keys_to_atoms()}
  end

  defp process_response({:ok, %Tesla.Env{body: %{"status" => "failed", "message" => message}}}) do
    {:error, message}
  end

  defp process_response(_) do
    {:error, "error constructing request"}
  end

  defp map_keys_to_atoms(map) do
    map |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
  end
end
