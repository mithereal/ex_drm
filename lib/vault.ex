defmodule Drm.Vault do
  @moduledoc false

use Cloak.Vault, otp_app: :drm

@impl GenServer
  def init(config) do
    config =
      Keyword.put(config, :ciphers, [
        default: {
          Cloak.Ciphers.AES.GCM,
          tag: "AES.GCM.V1",
          key: decode_env!("ENCRYPTION_KEY"),
          iv_length: 12
        }
      ])

    {:ok, config}
  end

  defp decode_env!(var) do
    var
    |> System.get_env()
    |> Base.decode64!()
  end

    def dump(value) do
   {_,data} = Drm.Vault.encrypt(value)
     Base.encode64(data)
  end

    def load(value) do
 Drm.Vault.decrypt(value)
  end


end