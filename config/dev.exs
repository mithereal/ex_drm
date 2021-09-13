# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
import Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# third-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :drm, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:drm, :key)
#
# You can also configure a third-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#

# run shell command to "source .env" to load the environment variables.

# wrap in "try do"
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
  path: Path.expand("../priv/license", __DIR__),
  refresh_interval: 50000,
  salt: System.get_env("SECRET_KEY_BASE"),
  key: System.get_env("ENCRYPTION_KEY")
