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

  @spec create() :: String.t()
  def create() do
    Logger.error("license cannot be empty")
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

  examples

    license =  %{hash: "license-key", meta: %{email: "demo@example.com", name: "licensee name"}, policy: %{name: "policy name", type: "free", expiration: nil, validation_type: "strict", checkin: false, checkin_interval: nil, max_fingerprints: nil, fingerprint: "main-app-name-umbrella-app-hash-id"}}
    
    License.create(license)
      
  """

  @spec create(Map.t()) :: String.t()
  def create(%{hash: hash, meta: meta, policy: policy}) do
    allow_burner_emails = Application.get_env(:drm, :allow_burner_emails)

    new_license =
      case Map.has_key?(meta, "email") do
        false ->
          LICENSE.create(%{hash: hash, meta: meta, policy: policy})

        true ->
          case allow_burner_emails do
            false ->
              burner = Burnex.is_burner?(meta.email)

              case burner do
                true -> {:error, "burner emails are not allowed"}
                false -> LICENSE.create(%{hash: hash, meta: meta, policy: policy})
              end

            true ->
              LICENSE.create(%{hash: hash, meta: meta, policy: policy})
          end
      end

    case new_license do
      {:error, error} ->
        {:error, error}

      nil ->
        {:error, "unable to create license encoding error"}

      _ ->
        KEYSERVER.import(new_license)

        # IO.inspect(new_license)

        path = Application.get_env(:drm, :path)

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
  examples
    
  license =  %{hash: "license-key", meta: %{email: "demo@example.com", name: "licensee name"}, policy: %{name: "policy name", type: "free", expiration: nil, validation_type: "strict", checkin: false, checkin_interval: nil, max_fingerprints: nil, fingerprint: "main-app-name-umbrella-app-hash-id"}}

  License.encode(license)

  """

  @spec encode(Map.t()) :: String.t()
  def encode(license) do
    encoded = Jason.encode!(license)
    {status, key} = EncryptedField.dump(encoded)

    case status do
      :ok -> Base.encode16(key)
      :error -> encoded
    end
  end

  @doc """
  Decode a license

  ## Examples
        iex> license_string = "3EAA88C336C807A756331FB3803D78E366034A2BAAE320E2530A5B0EE77DD6DE8A4913FF2D7D64FC9CB89048DDA343DE46ACD397594E260ED83597B3BCDB14EF459C0EF4B269E7088C34568D950279A3366FD30AFCCD0BF1FC299B5D390BBCF70F6D7E1C8AC0F84A4D5B5679756127D503EF1A389FB904CC4A0B8F4745DDB1CCF103065FE902A0FD6ABA01C07C8E3819924C1BD84B0D28A35E8C74282E8BAA11CFA3F5318E2401E57361B2C74B6902688E825A8718D23E1720F4BD1CC72A0B7F90259B1B32A98D2799ECA1D1C50057443F086CB542F7156DA8D50E76CB7226794D0F1B36D0ED63E168780BDD5D6170C9E4C56F3562F2C7E559049E353ABA876EE519EA11BA5D6FED0C2A644DCDA05CB217D05809E47089AC253E6F92AA31D1CABC42EF48D99378A054F3603210CD637B3B1CD64448215CF48E4179BBB1AD3A"
        iex> License.decode(license_string)
        %{"hash" => "license-key", "meta" => %{"email" => "demo@example.com", "name" => "licensee name"}, "policy" => %{"checkin" => false, "checkin_interval" => nil, "expiration" => nil, "fingerprint" => "main-app-name-umbrella-app-hash-id", "max_fingerprints" => nil, "name" => "policy name", "type" => "free", "validation_type" => "strict"}}

  """

  @spec decode(String.t()) :: Map.t()
  def decode(license) do
    status = Base.decode16(license)

    status =
      case status do
        :error ->
          :error

        _ ->
          {status, _} = status
          status
      end

    case status do
      :error ->
        {:error, "Encoding Error"}

      :ok ->
        {_, bitstring} = Base.decode16(license)
        decrypted = EncryptedField.load(bitstring)
        Jason.decode!(decrypted)
    end
  end

  @doc """
  Delete a license by filename

  ## Examples
         iex> License.delete("3454453444")
         {:error, "invalid license"}
  """

  @spec delete(String.t()) :: any()
  def delete(file) do
    path = Application.get_env(:drm, :path)

    filename = path <> "/" <> file <> ".key"

    File.rm(filename)

    value = File.read(filename)

    valid =
      case value do
        {:error, :enoent} -> false
        _ -> License.valid?(value)
      end

    case valid do
      true ->
        new_license = License.decode(value)

        KEYSERVER.remove(new_license)
        :ok

      false ->
        {:error, "invalid license"}
    end
  end

  @doc """
  Validate a license

  ## Examples
       iex> license_string = "3454453444"
       iex> License.valid?(license_string)
       false
  """

  @spec valid?(String.t()) :: any()
  def valid?(license_string) do
    base16? = is_base16?(license_string)

    case base16? do
      false ->
        false

      true ->
        {_, bitstring} = Base.decode16(license_string)
        {status, decrypted} = EncryptedField.load(bitstring)

        case status do
          :ok ->
            json = Jason.decode!(decrypted)
            expiration = json.policy.experation
            fingerprint = json.policy.fingerprint

            current_date = DateTime.utc_now()
            current_date = DateTime.to_unix(current_date)

            valid_exp =
              case expiration do
                nil -> true
                current_date when current_date > expiration -> true
                _ -> false
              end

          :error ->
            false
        end
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

  @spec valid?(String.t(), String.t()) :: any()
  def valid?(license_string, fingerprint_in_question) do
    base16? = is_base16?(license_string)

    case base16? do
      false ->
        false

      true ->
        {_, bitstring} = Base.decode16(license_string)
        {status, decrypted} = EncryptedField.load(bitstring)

        case status do
          :ok ->
            json = Jason.decode!(decrypted)
            expiration = json.policy.experation
            fingerprint = json.policy.fingerprint

            current_date = DateTime.utc_now()
            current_date = DateTime.to_unix(current_date)

            valid_exp =
              case expiration do
                nil -> true
                current_date when current_date > expiration -> true
                _ -> false
              end

            case fingerprint do
              nil ->
                true

              fingerprint_in_question
              when fingerprint_in_question == fingerprint and valid_exp == true ->
                true

              _ ->
                false
            end

          :error ->
            false
        end
    end
  end

  @doc """
  Export the license file

  ## Examples
       iex> fingerprint = "umbrella-app-id"
       iex> License.export(fingerprint)
       {:error, "fingerprint not found"}
  """

  @spec export(String.t()) :: any()
  def export(id, type \\ "list") do
    #  exported = KEYSERVER.export(id)
    exported = []

    case exported do
      [export] ->
        case type do
          "json" ->
            json_string = Jason.encode!(export)
            json_string

          _ ->
            [export]
        end

      _ ->
        Logger.info("fingerprint not found")
        {:error, "fingerprint not found"}
    end
  end

  @doc """
  Clear all licenses and delete all keys from server

  ## Examples
       iex> License.clear()
       :ok
  """
  @spec clear() :: String.t()
  def clear() do
    path = Application.get_env(:drm, :path)
    KEYSERVER.clear()
    File.rm_rf(path)
    File.mkdir(path)
  end

  @doc """
  Generate a license key based on a hash

  examples

    hash = "4424552325453453"
    
    License.generate_key(hash, 2)
    
  """
  @spec generate_key(String.t(), Integer.t(), String.t()) :: any()
  def generate_key(hash, number \\ 1, delimeter \\ "-") do
    total = String.length(hash)
    result = total / number

    hash
    |> String.codepoints()
    |> Enum.chunk(round(result))
    |> Enum.map(&Enum.join/1)
    |> Enum.join(delimeter)
  end

  @doc """
  Export license keys

  examples
    
    License.export_keys()
    
  """
  @spec clear() :: Map.t()
  def export_keys() do
    %{keys: Application.get_env(:drm, :keys), salt: Application.get_env(:drm, :salt)}
  end

  defp hash_id(number \\ 20) do
    Base.encode64(:crypto.strong_rand_bytes(number))
  end

  defp is_base16?(data) do
    status = Base.decode16(data)

    case status do
      :error -> false
      _ -> true
    end
  end

  defp is_aes?(data) do
  end
end
