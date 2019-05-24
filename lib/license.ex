defmodule License do
  @moduledoc """
  Documentation for License.
  """

  alias Encryption.{HashField, EncryptedField, PasswordField}
  alias License.Schema.License

  require Logger


  @doc false

  @spec create() :: String.t
 def create() do
  Logger.error "license cannot be empty"
 end
 
 @doc """
Create a new license
  ## Parameters
  - `meta`: a map of meta data to enclude in the license
  - `policy`: a map of the main policy for the license 
      ### Parameters
      - `name` : the name of the policy
      - `type`: the type of policy "free  | commercial" 
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
  ## Examples
      iex> license =  %{meta: %{email: "demo@example.com", name: "licensee name"}, policy: %{name: "policy name", type: "free", expiration: nil, validation_type: "strict", checkin: false, checkin_interval: nil, max_fingerprints: nil, fingerprint: "main-app-name-umbrella-app-hash-id"}}
      iex> License.create(license)
      CF79FB2CBF118F5FA2055573E079FB169E43606F4D56272CAE941A691E6FA4F18F94CF41EF457DF8AF84D3A84C2C5C1DA0A50ECF6E756E2E5F1DFB6F80E5A8A77B276374CAC2855F489E3D8690E6C243D3A38B7E77BE64FF322F1ED65CB09664B07EC883D2C706EF4ECD4BF2EC799690B54DED5ACC160326C0103320FE32BFF5E83E7BC6B5615EF1FEC40B3B68A5BAA3FB2528FA0C4FDFD56CD5CC7EDD96DE69AD30463C6CC3BF8E8A54F32D847723AF53F80095D46CEBB617185506BBFA3B87FC77449C290C482F2D2F6C72DF1B4BD78101D19EFED3E61EBCDD47A2D2D68A6F53AA5038C353A16533FC692C0C53CF1417AFA2BC1C35081B99E8FCD31738473576005D2538372511D5CD1273AF990DE13FE1B5887D134BD1F26A046E4A0280D99C20F68B90E45DE73B29
      
  """

  @spec create(Map.t()) :: String.t
def create(%{meta: meta, policy: policy}) do

  new_license = License.create(%{meta: meta, policy: policy})

  ## add to the keyring
  #Keyring.add new_license

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
  - `meta`: a map of meta data to enclude in the license
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
  ## Examples
      iex> license =  %{meta: %{email: "demo@example.com", name: "licensee name"}, policy: %{name: "policy name", type: "free", expiration: nil, validation_type: "strict", checkin: false, checkin_interval: nil, max_fingerprints: nil, fingerprint: "main-app-name-umbrella-app-hash-id"}}
      iex> License.encode(license)
      CF79FB2CBF118F5FA2055573E079FB169E43606F4D56272CAE941A691E6FA4F18F94CF41EF457DF8AF84D3A84C2C5C1DA0A50ECF6E756E2E5F1DFB6F80E5A8A77B276374CAC2855F489E3D8690E6C243D3A38B7E77BE64FF322F1ED65CB09664B07EC883D2C706EF4ECD4BF2EC799690B54DED5ACC160326C0103320FE32BFF5E83E7BC6B5615EF1FEC40B3B68A5BAA3FB2528FA0C4FDFD56CD5CC7EDD96DE69AD30463C6CC3BF8E8A54F32D847723AF53F80095D46CEBB617185506BBFA3B87FC77449C290C482F2D2F6C72DF1B4BD78101D19EFED3E61EBCDD47A2D2D68A6F53AA5038C353A16533FC692C0C53CF1417AFA2BC1C35081B99E8FCD31738473576005D2538372511D5CD1273AF990DE13FE1B5887D134BD1F26A046E4A0280D99C20F68B90E45DE73B29
      
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

 ## Examples
iex> license = "CF79FB2CBF118F5FA2055573E079FB169E43606F4D56272CAE941A691E6FA4F18F94CF41EF457DF8AF84D3A84C2C5C1DA0A50ECF6E756E2E5F1DFB6F80E5A8A77B276374CAC2855F489E3D8690E6C243D3A38B7E77BE64FF322F1ED65CB09664B07EC883D2C706EF4ECD4BF2EC799690B54DED5ACC160326C0103320FE32BFF5E83E7BC6B5615EF1FEC40B3B68A5BAA3FB2528FA0C4FDFD56CD5CC7EDD96DE69AD30463C6CC3BF8E8A54F32D847723AF53F80095D46CEBB617185506BBFA3B87FC77449C290C482F2D2F6C72DF1B4BD78101D19EFED3E61EBCDD47A2D2D68A6F53AA5038C353A16533FC692C0C53CF1417AFA2BC1C35081B99E8FCD31738473576005D2538372511D5CD1273AF990DE13FE1B5887D134BD1F26A046E4A0280D99C20F68B90E45DE73B29"
iex> License.encode(license_string)
%{
  "meta" => %{"email" => "demo@example.com", "name" => "licensee name"},
  "policy" => %{
    "checkin" => false,
    "checkin_interval" => nil,
    "expiration" => nil,
    "fingerprint" => "main-app-name-umbrella-app-hash-id",
    "max_fingerprints" => nil,
    "name" => "policy name",
    "type" => "free",
    "validation_type" => "strict"
  }
}

"""

@spec decode(String.t) :: Map.t()
def decode(license) do
 {_, bitstring} =  Base.decode16(license)
 {_,decrypted} = EncryptedField.load(bitstring)
 Jason.decode! decrypted
end

@doc """
Delete a license
 will return :ok or {:error, :eperm}

 ## Examples

 iex> license_id = "3454453444"
iex> License.delete(license_id)
{:error, :eperm}

"""

@spec delete(String.t) :: any()
def delete(file) do
path = Application.get_env(:license,:path)
filename = path <> "/" <> file <> ".key"
File.rm(filename)
end

@doc """
Check if the license string is valid

 ## Examples

 iex> license_string = "3454453444"
iex> License.valid?(license_string)
false

"""
def valid?(license_string) do
  {_, bitstring} =  Base.decode16(license_string)
 {status,_} = EncryptedField.load(bitstring)
 
 case status do
   :ok -> true
   :error -> false
 end
end

defp hash_id(number \\ 20) do
  Base.encode64(:crypto.strong_rand_bytes(number))
end
end