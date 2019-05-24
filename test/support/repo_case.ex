defmodule License.RepoCase do
    use ExUnit.CaseTemplate
  
    using do
      quote do
        alias License.Repo
  
        import Ecto
        import Ecto.Query
        import License.RepoCase
  
        # and any other stuff
      end
    end
  
    setup tags do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(MyApp.Repo)
  
      unless tags[:async] do
        Ecto.Adapters.SQL.Sandbox.mode(MyApp.Repo, {:shared, self()})
      end
  
      :ok
    end
  end