defmodule License do
  @moduledoc """
  Documentation for License.
  license functions for creating, storing and exporting aes encrypted keys.
  """

  alias License.Key.Ring, as: KEYRING
  alias License.Key.Server, as: KEYSERVER

  alias Encryption.{HashField, EncryptedField, PasswordField}
  alias License.Schema.License, as: LICENSE

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
      "FF8CB0F6894858E1816A1E18CB44ED457A2411DDC5772DB7C53ADB5575FF4649498896ECD736C1905A315C7DDA0B04093A6EE9AED39EE85C1F780C37F96A9BAB87DB7A25A055DC3F465636980AE9C57C193BF3088F14764D96700C1C4B474A52E966E783B8A026C99534E243CDC51F89FBF4CA515DE25B68033A6F86BFF831B88BF815A2219F808D883F96298225FBB5A078D0821166D63980E83ABBB07F2C16B578C07AD6ECE0718D4EE8B2BEEC193A7CE6D9A59B019594B22B54A4E77A129E7736FB2B7DD85C745A4C895E8D9A30F9E41E47DBB7E967628997A2533FB6F188C1F79472AFACBC589537A7217788149249065267141E1403BDD96C719B0BB0F76D2A246E2558636B2EF3B856B9C336AD0823CF6764939302B1FC6CB1B3FBD976835E7081C1218B98F4CC"
      
  """

  @spec create(Map.t()) :: String.t
def create(%{meta: meta, policy: policy}) do

  allow_burner_emails = Application.get_env(:license,:allow_burner_emails)

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

  path = Application.get_env(:license,:path)

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
      - `type`: the type of policy "free | multi_fingerprint | commercial" 
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
      "0D284A75D8E38BCC1320FCB24FB3BAD013AD9F3EE8ACB746C156B932FDD41728BB38D5B399F5104DD55DE223429FBD77DB1D3E7C6A2E6D4495E5BE4C34B9E6F3282C0B6A0267F1DF1397028AE2996F866B9F76F9FD0827789E7292790E94FABDB151A9C38114AB75DCC0448274EF610FD34DCFD75FDF9E16D4C911FF0AA2081AA7EC60C3F16DEC131827660CC4E5781E1E8784D309F231875135D522EF20D1EAC7FB844D46451C8F6F0C7CFB7C9FE43F41271F3A73E0C840FB332A66B0C70F7EDB3019FE0B1DA3326A1F74516B34BF8C3E2E50A3C87DDB6CC44F8428D77162C6F743ED1DFE10EA9D568399CA683FD62527CB93E00683FF12D8F3B77BEDA41DB1162236D5BDE1AB92FF66D5FE19E444D97806A93F6C52ADE988FF6C061818E24D9F36E25F56D687D293E0"
      
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
iex> license_string = "CF79FB2CBF118F5FA2055573E079FB169E43606F4D56272CAE941A691E6FA4F18F94CF41EF457DF8AF84D3A84C2C5C1DA0A50ECF6E756E2E5F1DFB6F80E5A8A77B276374CAC2855F489E3D8690E6C243D3A38B7E77BE64FF322F1ED65CB09664B07EC883D2C706EF4ECD4BF2EC799690B54DED5ACC160326C0103320FE32BFF5E83E7BC6B5615EF1FEC40B3B68A5BAA3FB2528FA0C4FDFD56CD5CC7EDD96DE69AD30463C6CC3BF8E8A54F32D847723AF53F80095D46CEBB617185506BBFA3B87FC77449C290C482F2D2F6C72DF1B4BD78101D19EFED3E61EBCDD47A2D2D68A6F53AA5038C353A16533FC692C0C53CF1417AFA2BC1C35081B99E8FCD31738473576005D2538372511D5CD1273AF990DE13FE1B5887D134BD1F26A046E4A0280D99C20F68B90E45DE73B29"
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
  
path = Application.get_env(:license,:path)

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