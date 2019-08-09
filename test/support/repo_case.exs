defmodule Drm.RepoCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Drm.Repo

      import Ecto
      import Ecto.Query
      import Drm.RepoCase

      # and any other stuff
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Drm.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Drm.Repo, {:shared, self()})
    end

    :ok
  end
end
