defmodule Encryption.AES do
  @moduledoc false

  @iv "2840234823308290"

  @spec encrypt(any) :: {String.t(), number}
  def encrypt(data) do
    key = get_key()
    # {:ok, iv} = ExCrypto.rand_bytes(16)

    case ExCrypto.encrypt(key, data, %{initialization_vector: @iv}) do
      {:ok, {_iv, cipher_text}} -> encode(cipher_text)
      x -> {:error, x}
    end
  end

  @spec encrypt(any, number) :: {String.t(), number}
  def encrypt(data, key_id) do
    key = get_key(key_id)
    # {:ok, iv} = ExCrypto.rand_bytes(16)

    case ExCrypto.encrypt(key, data, %{initialization_vector: @iv}) do
      {:ok, {_iv, cipher_text}} -> encode(cipher_text)
      x -> {:error, x}
    end
  end

  @spec decrypt(any) :: String.t()
  def decrypt(data) do
    key = get_key()

    {:ok, cipher_text} = decode(data)

    # <<iv::binary-16, ciphertext::binary>> = cipher_text

    with {:ok, string} <- ExCrypto.decrypt(key, @iv, cipher_text), do: string
  end

  @spec decrypt(String.t(), number) :: {String.t(), number}
  def decrypt(data, key_id) do
    key = get_key(key_id)

    {:ok, cipher_text} = decode(data)

    # <<iv::binary-16, ciphertext::binary>> = cipher_text

    with {:ok, string} <- ExCrypto.decrypt(key, @iv, cipher_text), do: string
  end

  @doc """
  get_key - Get encryption key from list of keys.
  if `key_id` is *not* supplied as argument,
  then the default *latest* encryption key will be returned.
  ## Parameters
  - `key_id`: the index of AES encryption key used to encrypt the ciphertext

  example

    Encryption.AES.get_key
     
  """
  @spec get_key() :: String
  def get_key do
    keys = Application.get_env(:drm, :keys)

    List.last(keys)
  end

  @spec get_key(number) :: String
  defp get_key(key_id) do
    keys = Application.get_env(:drm, :keys)
    key = Enum.at(keys, key_id)
    key
  end

  defp encode(data, type \\ :base64) do
    case type do
      :base32 -> Base.encode32(data)
      _ -> Base.encode64(data)
    end
  end

  defp decode(data, type \\ :base64) do
    case type do
      :base32 -> Base.decode32(data)
      _ -> Base.decode64(data)
    end
  end
end
