defmodule Drm do
  @moduledoc """
  Documentation for License.
  license functions for creating, storing and exporting aes encrypted keys.
  """

  alias Drm, as: License

  alias Drm.Key.Ring, as: KEYRING
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
      iex> license =  %{meta: %{email: "demo@example.com", name: "licensee name"}, policy: %{name: "policy name", type: "free", expiration: nil, validation_type: "strict", checkin: false, checkin_interval: nil, max_fingerprints: nil, fingerprint: "main-app-name-umbrella-app-hash-id"}}
      iex> License.create(license)
     "B75FE9CCF260E7E7BAC9606174E525D28EE52E07907F53D8B7E4E30C32FEC6C67CBA0C7F7FEC36AE4152F296FC08E4EEE892A70A71E549F5A2296BC96C6365CD9666B9C4712C8BB3BCAEE8A6B5DA3CC716D91970F8C9EE14712660B2D004A7FB5BE77C0BDDF1827E2EF73345E0F223986FBF8D0DBFBDF7A43FC836C82229D3FC6E7E8316C2E8B9AA0A2A9F73C1D52ACB479DAD6433A9137FC7D3409C5E81ED04A6F3C0289B9E44DA46DB63B633BBF0BAC73529E181AE2F93D3E78208801D8EB1D54C00E3E5C50BD9B84CFA2E51784F20E36761FE95381FD5AC667F2F39A46CDE78F404403748905665A088A17B7D2FBE348767313A24EA3E954A76CA68F98C5D2817E9DE1C7D6ED78E7577E03EB31562295ACA1CB26983B51758D35246E72A316E844A71531852E380D8"
      
  """

  @spec create(Map.t()) :: String.t
def create(%{meta: meta, policy: policy}) do

  allow_burner_emails = Application.get_env(:drm,:allow_burner_emails)

  new_license = case Map.has_key?(meta, "email") do
    false -> LICENSE.create(%{meta: meta, policy: policy})
    true -> case allow_burner_emails do
      false -> burner = Burnex.is_burner?(meta.email)
          case burner do
             true -> {:error , "burner emails are not allowed"}
             false -> LICENSE.create(%{meta: meta, policy: policy})
          end
      true ->  LICENSE.create(%{meta: meta, policy: policy})
    end
  end

    
  case new_license do
    {:error , error} -> {:error , error}
    nil -> {:error , "unable to create license encoding error"}
     _->

      KEYSERVER.import new_license

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
      iex> license =  %{meta: %{email: "demo@example.com", name: "licensee name"}, policy: %{name: "policy name", type: "free", expiration: nil, validation_type: "strict", checkin: false, checkin_interval: nil, max_fingerprints: nil, fingerprint: "main-app-name-umbrella-app-hash-id"}}
      iex> License.encode(license)
     "7DDF63C83E7A274EC1D02F4DB896D07A57A4B7B1F096CD1E545A99C5E702FA37B9372D12A3866312462E93C96C645B033A93A0FF28DFDC4F1F2A609A833EABAED3C98242AD139BA41C477E3FBB7A186584BE9B4D48A88F3E6EB80E0A5B1A075C290FCB29EADD7FA81EF9D91AC0DECB79AA23F71ADA1E18D397B8A7D70749D014EC8D4E12E6A738508CA6F3852573EDDFEA78E601E6B99DAD6ECC55700DDDACFAF051C06BA0DADE97E9CB4CA0B6E6048C2C00354C5FBC2BC9FB82EFC32D26B829405C1452F2132D8185B58CD3567B908A7A99664757E9FC66F03E8EF1C3A2459042C2B658BD37AFD985114FF9804F431FE4436418511B6E19DB83030C083AAB5624C5ED8F482824BFB650388083DD2867668288247B1687F8F5494719DA9D2016860ACF92F0EADEC32EFC"
      
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
iex> license_string = "7DDF63C83E7A274EC1D02F4DB896D07A57A4B7B1F096CD1E545A99C5E702FA37B9372D12A3866312462E93C96C645B033A93A0FF28DFDC4F1F2A609A833EABAED3C98242AD139BA41C477E3FBB7A186584BE9B4D48A88F3E6EB80E0A5B1A075C290FCB29EADD7FA81EF9D91AC0DECB79AA23F71ADA1E18D397B8A7D70749D014EC8D4E12E6A738508CA6F3852573EDDFEA78E601E6B99DAD6ECC55700DDDACFAF051C06BA0DADE97E9CB4CA0B6E6048C2C00354C5FBC2BC9FB82EFC32D26B829405C1452F2132D8185B58CD3567B908A7A99664757E9FC66F03E8EF1C3A2459042C2B658BD37AFD985114FF9804F431FE4436418511B6E19DB83030C083AAB5624C5ED8F482824BFB650388083DD2867668288247B1687F8F5494719DA9D2016860ACF92F0EADEC32EFC"
iex> License.decode(license_string)
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

  case decrypted do
   :error -> nil
   _-> Jason.decode! decrypted
 end

end


@doc """
Delete a license
 will return :ok or :error

 ## Examples

 iex> license_id = "3454453444"
iex> License.delete(license_id)
{:error, "invalid license"}

"""

@spec delete(String.t) :: any()
def delete(file) do
  
path = Application.get_env(:drm,:path)

filename = path <> "/" <> file <> ".key"

File.rm(filename)

value = File.read filename

value = case value do
  {:error, :enoent} -> false
  _-> value
end


valid = License.valid?(value)


case valid do
  true ->   new_license = License.decode(value)

  KEYSERVER.remove new_license
   :ok
    
  false -> {:error, "invalid license"}
end

end

@doc """
Check if the license string is valid

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
Check if the license string is valid

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
{:error, "fingerprint not found"}

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