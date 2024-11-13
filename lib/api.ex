defmodule Magic.API do
  @moduledoc false

  use Tesla

  def get_user(issuer, wallet_type \\ :none, opts \\ []) do
    client(opts)
    |> get("/v1/admin/auth/user/get",
      query: [issuer: issuer, wallet_type: wallet_type |> to_string() |> String.upcase()]
    )
    |> process_response()
  end

  def logout_user(issuer, opts \\ []) do
    client(opts)
    |> post("/v2/admin/auth/user/logout", %{issuer: issuer})
    |> process_response()
  end

  defp client(opts) do
    secret_key = Keyword.get(opts, :secret_key, Application.get_env(:magic_admin, :secret_key))

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
    map
    |> Map.new(fn {rk, rv} ->
      v =
        cond do
          rk == "wallet_type" -> rv |> String.downcase() |> String.to_atom()
          is_map(rv) -> map_keys_to_atoms(rv)
          is_list(rv) -> Enum.map(rv, &map_keys_to_atoms/1)
          true -> rv
        end

      {String.to_atom(rk), v}
    end)
  end
end
