defmodule Drm do
  @moduledoc """
  Documentation for Drm.
  license functions for creating, storing and exporting aes encrypted keys.
  """

  alias Drm, as: License

  alias Drm.License.Supervisor, as: LICENSESUPERVISOR

  alias Encryption.{HashField, EncryptedField, PasswordField}
  alias Drm.Schema.License, as: LICENSE

  require Logger

  @default_path Path.expand("../../priv/license", __DIR__)

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

    license =  %{hash: "license-key12", meta: %{email: "demo@example.com", name: "licensee name"}, policy: %{name: "policy name", type: "free", expiration: nil, validation_type: "strict", checkin: false, checkin_interval: nil, max_fingerprints: nil, fingerprint: "main-app-name-umbrella-app-hash-id"}}
    
    License.create(license)
      
  """

  @spec create(Map.t()) :: String.t()
  def create(%{hash: hash, meta: meta, policy: policy}) do
    allow_burner_emails = Application.get_env(:drm, :allow_burner_emails, false)

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

        path = Application.get_env(:drm, :path, @default_path)

        encoded_license = encode(new_license)

        hash_id = hash_id(10)

        filename = hash_id <> ".key"

        path = path <> "/" <> filename

        status = File.write(path, encoded_license)

        new_license =
          case status do
            :ok -> Map.put(new_license, :filename, filename)
            _ -> Map.put(new_license, :filename, "")
          end

        LICENSESUPERVISOR.start_child(new_license)

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
    
    license =  %{hash: "license-key", meta: %{email: "demo@example.com", name: "licensee name"}, policy: %{name: "policy name", type: "free", expiration: 55, validation_type: "strict", checkin: false, checkin_interval: nil, max_fingerprints: nil, fingerprint: "main-app-name-umbrella-app-hash-id"}}
    License.encode(license)
  """

  @spec encode(Map.t()) :: String.t()
  def encode(license) do
    {_, encoded} = Jason.encode(license)
    {status, key} = EncryptedField.dump(encoded)

    case status do
      :ok -> key
      :error -> :error
    end
  end

  @doc """
  Decode a license

  examples

    license_string = "1ASHD7P87VKlA1iC8Q3tdPFCthdeHxSOWS6BQfUv8gsC8yzNg6OeccIErfuKGvRWzzsRyZ7n/0RwE7ZuQCBL4eHPL5zhGCW5JunAKlsorpKdbMWACiv64q/JO3TOCBJSasd0grljX8z2OzKDeEyk7f0xfIleeL0jXfe+rF9/JC4o7vRHTwJS5va6r19fcWWB5u4AxQUw5tsJmcWBVX5TDwTH8WSJr8HK9xto8V6M1DNzNUKf3dLHBr32dVUjM+uNW2W2uy5Cl3LKIPxv+rmwZmTBZ/1kX8VrqE1BXCM7HttiwzmBEmbQJrvcnY5CAiO562HJTAM6C7RFsHGOtrwWINRzCkMxOffAeuHYy6G9S+ngasJBR/0a39HcA2Ic4mz5"
    License.decode(license_string)
  """

  @spec decode(String.t()) :: Map.t()
  def decode(license) do
    base64? = is_base64?(license)

    case base64? do
      false ->
        {:error, "Encoding Error"}

      true ->
        {status, decrypted} =
          case EncryptedField.load(license) do
            {status, decrypted} -> {status, decrypted}
            v -> {:ok, v}
          end

        case status == :ok do
          true ->
            decoded = Jason.decode!(decrypted)
            struct = LICENSE.from_json(decoded)
            {:ok, struct}

          false ->
            {:error, "Encoding Error"}
        end
    end
  end

  @doc """
  Delete a license by filename

  ## Examples
        iex> License.delete("3454453444")
        {:error, :enoent}

  """

  @spec delete(String.t()) :: any()
  def delete(file) do
    path = Application.get_env(:drm, :path, @default_path)

    filename = path <> "/" <> file <> ".key"

    File.rm(filename)
  end

  @doc """
  Validate that a license struct is valid

  examples
    license =  %{hash: "license-key", meta: %{email: "demo@example.com", name: "licensee name"}, policy: %{name: "policy name", type: "free", expiration: 55, validation_type: "strict", checkin: false, checkin_interval: nil, max_fingerprints: nil, fingerprint: "main-app-name-umbrella-app-hash-id"}}
    License.is_valid?(license)
  """
  def is_valid?(license) do
    expiration = license.policy.expiration

    current_date = DateTime.to_unix(DateTime.utc_now())

    valid_exp =
      case expiration do
        nil ->
          true

        _ ->
          current_date < expiration
      end
  end

  @doc """
  Validate that a license struct is valid and matches the fingerprint 

  examples
    license =  %{hash: "license-key", meta: %{email: "demo@example.com", name: "licensee name"}, policy: %{name: "policy name", type: "free", expiration: 55, validation_type: "strict", checkin: false, checkin_interval: nil, max_fingerprints: nil, fingerprint: "main-app-name-umbrella-app-hash-id"}}
    fingerprint = "main-app-name-umbrella-app-hash-id"
    License.is_valid?(license, fingerprint)
  """
  def is_valid?(license, fingerprint_in_question) do
    expiration = license.policy.expiration
    fingerprint = license.policy.fingerprint

    current_date = DateTime.to_unix(DateTime.utc_now())

    valid_exp =
      case expiration do
        nil ->
          true

        _ ->
          current_date < expiration
      end

    case fingerprint do
      nil ->
        true

      _ ->
        valid_exp
    end
  end

  @doc """
  Validate an encrypted license string

  ## Examples
       iex> license_string = "3454453444"
       iex> License.valid?(license_string)
       false
  """

  @spec valid?(String.t()) :: any()
  def valid?(license_string) do
    base64? = is_base64?(license_string)

    case base64? do
      false ->
        false

      true ->
        {status, decrypted} = EncryptedField.load(license_string)

        case status do
          :ok ->
            json = Jason.decode!(decrypted)
            struct = Drm.Schema.License.from_json(json)
            expiration = struct.policy.experation

            current_date = DateTime.to_unix(DateTime.utc_now())

            valid_exp =
              case expiration do
                nil ->
                  true

                _ ->
                  current_date > expiration
              end

          :error ->
            false
        end
    end
  end

  @doc """
  Validate that an encrypted license is valid and matches the fingerprint 

  ## Examples
      iex> license_string = "3454453444"
      iex> fingerprint = "umbrella-app-id"
      iex> License.valid?(license_string, fingerprint)
      false
  """

  @spec valid?(String.t(), String.t()) :: any()
  def valid?(license_string, fingerprint_in_question) do
    base64? = is_base64?(license_string)

    case base64? do
      false ->
        false

      true ->
        {status, decrypted} = EncryptedField.load(license_string)

        case status do
          :ok ->
            json = Jason.decode!(decrypted)
            struct = Drm.Schema.License.from_json(json)
            expiration = struct.policy.experation
            fingerprint = struct.policy.fingerprint

            current_date = DateTime.to_unix(DateTime.utc_now())

            valid_exp =
              case expiration do
                nil ->
                  true

                _ ->
                  current_date > expiration
              end

            case fingerprint do
              nil ->
                true

              :error ->
                false

              _ ->
                valid_exp
            end
        end
    end
  end

  @doc """
  check if the appid "fingerprint" exists

  Examples
       iex> fingerprint = "umbrella-app-id"
       iex> License.fingerprint_valid?(fingerprint)
       false
  """
  def fingerprint_valid?(f) do
    licenses = Drm.License.Supervisor.get_licenses_by_fingerprint(f)

    Enum.count(licenses) > 0
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
    exported = Drm.License.Supervisor.get_licenses_by_fingerprint(id)

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
        # Logger.info("License: Fingerprint Not Found.")
        {:error, "fingerprint not found"}
    end
  end

  @doc """
  Remove all licenses

  ## Examples
       iex> License.clear()
       :ok
  """
  @spec clear() :: String.t()
  def clear() do
    path = Application.get_env(:drm, :path, @default_path)
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
    |> Enum.chunk_every(round(result))
    |> Enum.map(&Enum.join/1)
    |> Enum.join(delimeter)
  end

  @doc """
  Export license keys

  examples
    
    License.export_keys()
    
  """
  @spec export_keys() :: Map.t()
  def export_keys() do
    %{keys: Application.get_env(:drm, :keys), salt: Application.get_env(:drm, :salt)}
  end

  @spec hash_id(Integer.t()) :: String.t()
  defp hash_id(number \\ 20) do
    Base.encode64(:crypto.strong_rand_bytes(number))
  end

  @spec is_base64?(String.t()) :: any()
  defp is_base64?(data) do
    status = Base.decode64(data)

    case status do
      :error -> false
      _ -> true
    end
  end
end
