# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

if Mix.env() == :dev do
  config :mix_test_watch,
    clear: true
end

# run shell command to "source .env" to load the environment variables.

try do
  # in case .env file does not exist.
  File.stream!("./.env")
  # remove excess whitespace
  |> Stream.map(&String.trim_trailing/1)
  # loop through each line
  |> Enum.each(fn line ->
    line
    # remove "export" from line
    |> String.replace("export ", "")
    # split on *first* "=" (equals sign)
    |> String.split("=", parts: 2)
    # stackoverflow.com/q/33055834/1148249
    |> Enum.reduce(fn value, key ->
      # set each environment variable
      System.put_env(key, value)
    end)
  end)
rescue
  _ -> IO.puts("no .env file found!")
end

config :drm,
  allow_burner_emails: true,
  max_floats: 5,
  refresh_interval: 2000,
  path: Path.expand("../priv/license", __DIR__)

# options:[ ssl_options: [ciphers: :ssl.cipher_suites() ++ [{:rsa, :aes_128_cbc, :sha}]]

config :drm, Drm.Vault,
  ciphers: [
    default: {
      Cloak.Ciphers.AES.GCM,
      tag: "AES.GCM.V1", key: Base.decode64!(System.get_env("ENCRYPTION_KEY")), iv_length: 12
    }
  ]

import_config "#{Mix.env()}.exs"
