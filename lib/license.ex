defmodule Drm do
  @moduledoc """
  Documentation for Drm.
  license functions for creating, storing and exporting aes encrypted keys.
  """

  alias Drm, as: License

  alias Drm.Key.Server, as: KEYSERVER

  alias Encryption.{HashField, EncryptedField, PasswordField}
  alias Drm.Schema.License, as: LICENSE

  require Logger


  @doc false

  @spec create() :: String.t
 def create() do
  Logger.error "license cannot be empty"
 end
 
 @doc """
Create a new license
  ## Parameters
  - `hash`: the license key string
  - `meta`: a map of meta data to enclude in the license
  - `policy`: a map of the main policy for the license 
      ### Parameters
      - `name` : the name of the policy
      - `type`: the type of policy "free  | commercial" 
      - `expiration`: the license experation date this is a Datetime.t -> int ie. DateTime.utc_now() |> to_unix
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
      iex> license =  %{hash: "license-key", meta: %{email: "demo@example.com", name: "licensee name"}, policy: %{name: "policy name", type: "free", expiration: nil, validation_type: "strict", checkin: false, checkin_interval: nil, max_fingerprints: nil, fingerprint: "main-app-name-umbrella-app-hash-id"}}
      iex> License.create(license)
      
      
  """

  @spec create(Map.t()) :: String.t
def create(%{hash: hash, meta: meta, policy: policy}) do

  allow_burner_emails = Application.get_env(:drm,:allow_burner_emails)

  new_license = case Map.has_key?(meta, "email") do
    false -> LICENSE.create(%{hash: hash, meta: meta, policy: policy})
    true -> case allow_burner_emails do
      false -> burner = Burnex.is_burner?(meta.email)
          case burner do
             true -> {:error , "burner emails are not allowed"}
             false -> LICENSE.create(%{hash: hash, meta: meta, policy: policy})
          end
      true ->  LICENSE.create(%{hash: hash, meta: meta, policy: policy})
    end
  end

    
  case new_license do
    {:error , error} -> {:error , error}
    nil -> {:error , "unable to create license encoding error"}
     _->

   KEYSERVER.import new_license

   IO.inspect new_license

  path = Application.get_env(:drm,:path)

  encoded_license = encode(new_license)

  hash_id = hash_id(10)

  path = path <> "/" <> hash_id <> ".key"

  File.write(path, encoded_license)

  encoded_license
  end
end

@doc """
Encode a license
## Parameters
  - `hash`: the license key string
  - `meta`: a map of meta data to enclude in the license
  - `policy`: a map of the main policy for the license 
      ### Parameters
      - `name` : the name of the policy
      - `type`: the type of policy "free | commercial" 
      - `expiration`: the license experation date this is a Datetime.t -> int ie. DateTime.utc_now() |> to_unix
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
      iex> license =  %{hash: "license-key", meta: %{email: "demo@example.com", name: "licensee name"}, policy: %{name: "policy name", type: "free", expiration: nil, validation_type: "strict", checkin: false, checkin_interval: nil, max_fingerprints: nil, fingerprint: "main-app-name-umbrella-app-hash-id"}}
      iex> License.encode(license)
      
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
     iex> license_string = ""
     iex> License.decode(license_string)
     
"""

@spec decode(String.t) :: Map.t()
def decode(license) do
 {_, bitstring} =  Base.decode16(license)
 {_,decrypted} = EncryptedField.load(bitstring)

  case decrypted do
   :error -> nil
   _-> Jason.decode! decrypted
 end

end


@doc """
Delete a license

## Examples
       iex> License.delete("3454453444")
       :error
"""

@spec delete(String.t) :: any()
def delete(file) do
  
path = Application.get_env(:drm,:path)

filename = path <> "/" <> file <> ".key"

File.rm(filename)

value = File.read filename

valid = case value do
  {:error, :enoent} -> false
  _-> License.valid?(value)
end

case valid do
  true ->   new_license = License.decode(value)

  KEYSERVER.remove new_license
   :ok
    
  false -> {:error, "invalid license"}
end

end

@doc """
Validate a license

## Examples
     iex> license_string = "3454453444"
     iex> License.valid?(license_string)
     false
"""

@spec valid?(String.t) :: any()
def valid?(license_string) do
  {_, bitstring} =  Base.decode16(license_string)
 {status,decrypted} = EncryptedField.load(bitstring)
 
 case status do
   :ok -> json = Jason.decode! decrypted
   expiration = json.policy.experation

   current_date = DateTime.utc_now()

   case expiration do
     nil -> true
     current_date when current_date > expiration -> true
    _ -> false
   end
   
   :error -> false
 end
end

@doc """
Validate a license

## Examples
    iex> license_string = "3454453444"
    iex> fingerprint = "umbrella-app-id"
    iex> License.valid?(license_string, fingerprint)
    false
"""

@spec valid?(String.t,String.t) :: any()
def valid?(license_string, fingerprint_in_question) do
  {_, bitstring} =  Base.decode16(license_string)
 {status,decrypted} = EncryptedField.load(bitstring)
 
 case status do
   :ok -> json = Jason.decode! decrypted
   expiration = json.policy.experation
   fingerprint = json.policy.fingerprint

   current_date = DateTime.utc_now()
   current_date = DateTime.to_unix(current_date)

   valid_exp = case expiration do
     nil -> true
     current_date when current_date > expiration -> true
    _ -> false
   end

   case fingerprint do
    nil -> true
    fingerprint_in_question when fingerprint_in_question == fingerprint and valid_exp == true -> true
   _ -> false

  end

   :error -> false
 end
end

@doc """
Export the license file

## Examples
     iex> fingerprint = "umbrella-app-id"
     iex> License.export(fingerprint)
     :error
"""

@spec export(String.t) :: any()
def export(id, type \\ "list") do

  exported = KEYSERVER.export id

   case exported do
    [export] -> case type do
                "json" -> json_string = Jason.encode!(export)
                json_string
                _-> [export]
    _ -> Logger.info "fingerprint not found" 
    {:error, "fingerprint not found"}
   end
end
end

def generate_key(hash, number, delimeter \\ "-") do
  key = String.chunk(hash, number)
  Enum.join(key, delimeter)
end

defp hash_id(number \\ 20) do
  Base.encode64(:crypto.strong_rand_bytes(number))
end

end