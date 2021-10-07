defmodule Magic.API do
  @moduledoc false

  use HTTPoison.Base

  def process_request_url(url) do
    "https://api.magic.link" <> url
  end

  def process_request_headers(_headers) do
    secret_key = Application.get_env(:magic, :secret_key)

    [
      "content-type": "application/json",
      "X-Magic-Secret-Key": secret_key
    ]
  end

  def process_response_body(body) do
    body
    |> Poison.decode!()
  end
end
