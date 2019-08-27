defmodule Drm.Repo do

   @moduledoc false

  use Ecto.Repo, 
    otp_app: :drm,
    adapter: Ecto.Adapters.Postgres

  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  end
end
