defmodule License do
  @moduledoc """
  Documentation for License.
  """

  alias Encryption.{HashField, EncryptedField, PasswordField}
  alias License.Schema.License


def create(license \\ %{meta: %{email: "demo@example.com", name: "licensee name" }, policy: %{type: "free", expiration: nil, validation_type: "strict", checkin: false, checkin_interval: nil, max_fingerprints: nil, fingerprint: "umbrella-app-hash-id"}}) do

  new_license = License.create(license)

  path = Application.get_env(:license,:path)

  encoded_license = encode(new_license)

  unix_string = DateTime.utc_now |> DateTime.to_unix |> Integer.to_string

  path = path <> "/" <> unix_string <> ".key"

  File.write(path, encoded_license)
end

def encode(license) do
  encoded = Jason.encode!(license)  
  {status,key} = EncryptedField.dump(encoded)

  case status do
    :ok -> Base.encode16 key
    :error -> encoded
  end

end

def decode(license) do
 {_, bitstring} =  Base.decode16(license)
 {_,decrypted} = EncryptedField.load(bitstring)
 Jason.decode! decrypted
end

def delete(file) do
path = Application.get_env(:license,:path)
filename = path <> "/" <> file <> ".key"
File.rm(filename)
end
end
