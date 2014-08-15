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
    create_tmp_table_for_binary_nodes 
    insert_binary_tree_calculation_result_to_tmp_table(records)
    update_real_table_with_tmp_table_results
    drop_tmp_table
    :success
  end

  def create_tmp_table_for_binary_nodes do
    Ecto.Adapters.Postgres.query(Repo, "CREATE TABLE tmp_binary_tree_nodes AS SELECT * FROM binary_tree_nodes LIMIT 0;", [])
  end

  def insert_binary_tree_calculation_result_to_tmp_table(records) do
    query = Enum.reduce(records, "INSERT INTO \"tmp_binary_tree_nodes\" (id, children_count_left, children_count_right) VALUES ", fn (r, c) ->
      c <> " (#{r.id}, #{r.children_count_left}, #{r.children_count_right}), "
    end)
    query = String.replace(query <> ";", "), ;", ");")
    Ecto.Adapters.Postgres.query(Repo, query, [])
  end

  def update_real_table_with_tmp_table_results do
    update_query = "
    UPDATE binary_tree_nodes AS btn 
    SET children_count_left = tbtn.children_count_left, children_count_right = tbtn.children_count_right
    FROM tmp_binary_tree_nodes AS tbtn 
    WHERE tbtn.id = btn.id"
    Ecto.Adapters.Postgres.query(Repo, update_query, [])
  end

  def drop_tmp_table do
    drop_query= "DROP TABLE tmp_binary_tree_nodes"
    Ecto.Adapters.Postgres.query(Repo, drop_query, [])
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
