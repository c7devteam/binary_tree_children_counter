defmodule Repo do
  use Ecto.Repo, adapter: Ecto.Adapters.Postgres

  def conf do
    parse_url "ecto://postgres:sapkaja21@localhost/bonofa_main_development"
  end
end
