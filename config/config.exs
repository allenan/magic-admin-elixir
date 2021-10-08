use Mix.Config

config :tesla, adapter: Tesla.Adapter.Hackney

if File.exists?("config/config.secret.exs") do
  import_config "config.secret.exs"
end
