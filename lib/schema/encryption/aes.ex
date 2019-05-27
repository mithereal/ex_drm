## lifted from https://github.com/dwyl/phoenix-ecto-encryption-example
defmodule Encryption.AES do

   @moduledoc false

   @aad "AES256GCM" # Use AES 256 Bit Keys for Encryption.
   
  @spec encrypt(any) :: String.t
  def encrypt(plaintext) do
    iv = :crypto.strong_rand_bytes(16) # create random Initialisation Vector
    key = get_key()    # get the *latest* key in the list of encryption keys
    {ciphertext, tag} =
      :crypto.block_encrypt(:aes_gcm, key, iv, {@aad, to_string(plaintext), 16})
    iv <> tag <> ciphertext # "return" iv with the cipher tag & ciphertext
  end

  @spec encrypt(any, number) :: {String.t, number}
  def encrypt(plaintext, key_id) do
    iv = :crypto.strong_rand_bytes(16) # create random Initialisation Vector
    key = get_key(key_id) # get *specific* key (by id) from list of keys.
    {ciphertext, tag} =
      :crypto.block_encrypt(:aes_gcm, key, iv, {@aad, to_string(plaintext), 16})
    iv <> tag <> ciphertext # "return" iv with the cipher tag & ciphertext
  end

  @doc """
  Decrypt a binary using GCM.
  ## Parameters
  - `ciphertext`: a binary to decrypt, assuming that the first 16 bytes of the
    binary are the IV to use for decryption.
  - `key_id`: the index of the AES encryption key used to encrypt the ciphertext
  ## Example
      iex> Encryption.AES.encrypt("test") |> Encryption.AES.decrypt(1)
      "test"
  """
  @spec decrypt(String.t, number) :: {String.t, number}
  def decrypt(ciphertext, key_id) do # patern match on binary to split parts:
    <<iv::binary-16, tag::binary-16, ciphertext::binary>> = ciphertext
    key = get_key(key_id) # get encrytion/decryption key based on key_id
    :crypto.block_decrypt(:aes_gcm, key, iv, {@aad, ciphertext, tag})
  end

  # as above but *asumes* `default` (latest) encryption key is used.
  @spec decrypt(any) :: String.t
  def decrypt(ciphertext) do
    case ciphertext do
      <<iv::binary-16, tag::binary-16, ciphertext::binary>> -> :crypto.block_decrypt(:aes_gcm, get_key(), iv, {@aad, ciphertext, tag})
      _ -> {:error, "invalid cipher"}
    end
    
  end

  # @doc """
  # get_key - Get encryption key from list of keys.
  # if `key_id` is *not* supplied as argument,
  # then the default *latest* encryption key will be returned.
  # ## Parameters
  # - `key_id`: the index of AES encryption key used to encrypt the ciphertext
  # ## Example
  #     iex> Encryption.AES.get_key
  #     <<13, 217, 61, 143, 87, 215, 35, 162, 183, 151, 179, 205, 37, 148>>
  # """ # doc commented out because https://stackoverflow.com/q/45171024/1148249
  @spec get_key() :: String
  def get_key do
    keys = Application.get_env(:drm, :keys)
  
    count = Enum.count(keys) - 1
    get_key(count)
  end

  @spec get_key(number) :: String
  defp get_key(key_id) do
    keys = Application.get_env(:drm, :keys)
   key =  Enum.at(keys, key_id)
   key
  end
end
