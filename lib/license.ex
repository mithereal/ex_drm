defmodule License do
  @moduledoc """
  Documentation for License.
  """

  alias Encryption.{HashField, EncryptedField, PasswordField}
  alias License.Schema.License

  @spec create(nil) :: String.t
 def create(nil) do
IO.Puts "license cannot be empty"
 end
 
 @doc """
Create a new license
  ## Parameters
  - `meta`: a map of meta data to enclude in the license, the fingerprints key is needed for a policy type of multi_fingerprint in order to implement seperate child policys for child apps in the umbrella
  - `policy`: a map of the main policy for the license 
      ### Parameters
      - `name` : the name of the policy
      - `type`: the type of policy "free | multi_fingerprint | commercial" 
      - `expiration`: the license experation date
      - `validation_type`: the validation type "strict | floating | concurrent"
      - `checkin`: when to checkin "true | false"
      - `checkin_interval`: when to checkin "nil | daily | weekly | monthly"
      - `max_fingerprints`: the number of max fingerprints for this license
      - `fingerprint`: the fingerprint for this license
      ### Validation Types 
       - `strict`: a license that implements the policy will be considered invalid if its machine limit is surpassed
       - `floating`: a license that implements the policy will be valid across multiple machines
       - `concurrent`: a licensing model, where you allow a set number of machines to be activated at one time, and exceeding that limit may invalidate all current sessions.
      ### Types
      - `free`: a free license 
      - `commercial`: a free license 
      - `multi_fingerprint`: implement a seperate child policy for a child app in the umbrella under the parent license scheme
  ## Examples
      iex> license =  %{meta: %{email: "demo@example.com", name: "licensee name", fingerprints: [{"main-app-name-umbrella-app-hash-id", %{policy: nil}}]}, policy: %{name: "policy name", type: "free", expiration: nil, validation_type: "strict", checkin: false, checkin_interval: nil, max_fingerprints: nil, fingerprint: "main-app-name-umbrella-app-hash-id"}}
      iex> License.create(license)
      true
      
  """

  @spec create(Map.t()) :: String.t
def create(%{meta: meta, policy: policy}) do

  new_license = License.create(%{meta: meta, policy: policy})

  path = Application.get_env(:license,:path)

  encoded_license = encode(new_license)

  hash_id = hash_id(10)

  path = path <> "/" <> hash_id <> ".key"

  File.write(path, encoded_license)

  encoded_license
end

@doc """
Encode a license
## Parameters
  - `meta`: a map of meta data to enclude in the license, the fingerprints key is needed for a policy type of multi_fingerprint in order to implement seperate child policys for child apps in the umbrella
  - `policy`: a map of the main policy for the license 
      ### Parameters
      - `name` : the name of the policy
      - `type`: the type of policy "free | multi_fingerprint | commercial" 
      - `expiration`: the license experation date
      - `validation_type`: the validation type "strict | floating | concurrent"
      - `checkin`: when to checkin "true | false"
      - `checkin_interval`: when to checkin "nil | daily | weekly | monthly"
      - `max_fingerprints`: the number of max fingerprints for this license
      - `fingerprint`: the fingerprint for this license
      ### Validation Types 
       - `strict`: a license that implements the policy will be considered invalid if its machine limit is surpassed
       - `floating`: a license that implements the policy will be valid across multiple machines
       - `concurrent`: a licensing model, where you allow a set number of machines to be activated at one time, and exceeding that limit may invalidate all current sessions.
      ### Types
      - `free`: a free license 
      - `commercial`: a free license 
      - `multi_fingerprint`: implement a seperate child policy for a child app in the umbrella under the parent license scheme
  ## Examples
      iex> license =  %{meta: %{email: "demo@example.com", name: "licensee name", fingerprints: [{"main-app-name-umbrella-app-hash-id", %{policy: nil}}]}, policy: %{name: "policy name", type: "free", expiration: nil, validation_type: "strict", checkin: false, checkin_interval: nil, max_fingerprints: nil, fingerprint: "main-app-name-umbrella-app-hash-id"}}
      iex> License.encode(license)
      true
      
  """

@spec encode(Map.t()) :: String.t
def encode(license) do
  encoded = Jason.encode!(license)  
  {status,key} = EncryptedField.dump(encoded)

  case status do
    :ok -> Base.encode16 key
    :error -> encoded
  end

end

@doc """
Decode a license
"""

@spec decode(String.t) :: Map.t()
def decode(license) do
 {_, bitstring} =  Base.decode16(license)
 {_,decrypted} = EncryptedField.load(bitstring)
 Jason.decode! decrypted
end

@spec delete(String.t) :: any()
def delete(file) do
path = Application.get_env(:license,:path)
filename = path <> "/" <> file <> ".key"
File.rm(filename)
end

defp hash_id(number \\ 20) do
  Base.encode64(:crypto.strong_rand_bytes(number))
end
end
