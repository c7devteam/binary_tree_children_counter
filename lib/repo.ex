defmodule Repo do
  use Ecto.Repo, adapter: Ecto.Adapters.Postgres

  def conf do
    case Mix.env do
      :dev ->
        parse_url "ecto://postgres:sapkaja21@localhost/bonofa_main_development?size=1"
      :test ->
        parse_url "ecto://postgres:sapkaja21@localhost/bonofa_main_test?size=1"
    end
  end
end
