use Mix.Config

case Mix.env() do
  :test ->
    config :tesla, adapter: Tesla.MockAdapter

  _ ->
    config :tesla, adapter: Tesla.Adapter.Hackney
end

if File.exists?("config/config.secret.exs") do
  import_config "config.secret.exs"
end
