defmodule FindNodes do
  require Repo
  import Ecto.Query
  {:ok, agent} = Agent.start_link fn -> [] end

  def find_root(agent) do
    HashDict.get(agent, 1)
  end

  def find_all do
    query = from b in BinaryTreeNode,
    select: b,
    order_by: b.id
    Repo.all(query)
  end

  def set_children_counts_to_zero do
    Repo.update_all(BinaryTreeNode, children_count_right: 0, children_count_left: 0)
  end

  def update_all(records) do
    { :ok, pid  } = Postgrex.Connection.start_link([hostname: "localhost", username: "postgres", password: "sapkaja21", database: "bonofa_main_test"])

    query = Enum.reduce(records, "", fn (r, c) -> 
      c <> "UPDATE binary_tree_nodes SET children_count_left = #{r.children_count_left}, children_count_right = #{r.children_count_right} WHERE id = #{r.id};"
    end)
    result = Postgrex.Connection.query(pid, query)
    :success
  end
  
  def receive_message(a, a) do
    :success
  end

  def format_single_result([]) do
    {:not_found, nil}
  end

  def format_single_result([node | _]) do
    {:success, node}
  end
end
