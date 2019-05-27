## lifted from https://github.com/dwyl/phoenix-ecto-encryption-example
defmodule Encryption.HashField do

   @moduledoc false
   
  @behaviour Ecto.Type

  def type, do: :binary

  def cast(value) do
    {:ok, to_string(value)}
  end

  def dump(value) do
    {:ok, hash(value)}
  end

  def load(value) do
    {:ok, value}
  end

  def hash(value) do
    :crypto.hash(:sha256, value <> get_salt(value))
  end

  defp get_salt(value) do
    secret_key_base =
      Application.get_env(:drm, :salt)
    :crypto.hash(:sha256, value <> secret_key_base)
  end
end
