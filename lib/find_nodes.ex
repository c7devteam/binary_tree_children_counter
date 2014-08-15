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
    { :ok, pid  } = Postgrex.Connection.start_link([hostname: "localhost", username: "postgres", password: "sapkaja21", database: "bonofa_main_development"])
    create_tmp_table = Postgrex.Connection.query(pid, "CREATE TEMP TABLE tmp_binary_tree_nodes AS SELECT * FROM binary_tree_nodes LIMIT 0;")
    query = Enum.reduce(records, "INSERT INTO tmp_binary_tree_nodes (id, children_count_left, children_count_right) VALUES ", fn (r, c) ->
      c <> " (#{r.id}, #{r.children_count_left}, #{r.children_count_right}), "
    end)
    query = String.replace(query <> ";", "), ;", ");")
    Postgrex.Connection.query(pid, query)
    update_query = "
    UPDATE binary_tree_nodes AS btn 
    SET children_count_left = tbtn.children_count_left, children_count_right = tbtn.children_count_right
    FROM tmp_binary_tree_nodes AS tbtn 
    WHERE tbtn.id = btn.id"
    Postgrex.Connection.query(pid, update_query)
    Postgrex.Connection.query(pid, "DROP TABLE tmp_binary_tree_nodes")
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
