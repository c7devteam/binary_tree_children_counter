defmodule BinaryTreeChildrenCounter do
  def benchmark do
    Repo.start_link
    {_, a, _} = :os.timestamp
    run
    {_, b, _} = :os.timestamp
    b - a
  end

  def run do
    FindNodes.set_children_counts_to_zero
    all_nodes = build_node_cache
    root = FindNodes.find_root(all_nodes)
    run_step(root, all_nodes)
  end

  def run_step(false, _) do
    false
  end

  def run_step(nil, _) do
    false
  end

  def run_step(node, all_nodes) do
    if node.children_count_left == 0 do
      left_node = find_node_by_id(node.left_node_id, all_nodes)
      if left_node do
        run = fn -> run_step(left_node, all_nodes) end
      end
    end
    if node.children_count_right == 0 do
      right_node = find_node_by_id(node.right_node_id, all_nodes)
      if right_node do
        run = fn -> run_step(right_node, all_nodes) end
      end
    end
    if !right_node && !left_node do
      run = fn -> go_up(find_node_by_id(node.parent_id, all_nodes), node, all_nodes) end
    end
    run.()
  end

  def go_up(false, _, all_nodes) do
    FindNodes.update_all(HashDict.values(all_nodes))
    {:ok, "binary tree children counting went successfull"}
  end

  def go_up(parent, child, all_nodes) do
    cond do
      parent.left_node_id == child.id ->
        new_parent = %{parent | children_count_left: child.children_count_right + child.children_count_left + 1}
        all_nodes = HashDict.put(all_nodes, new_parent.id, new_parent)
      parent.right_node_id == child.id ->
        new_parent = %{parent | children_count_right: child.children_count_right + child.children_count_left + 1}
        all_nodes = HashDict.put(all_nodes, new_parent.id, new_parent)
    end
    run_step(new_parent, all_nodes)
  end

  def find_node_by_id(node_id, all_nodes) do
    HashDict.get(all_nodes, node_id, false)
  end

  defp build_node_cache do
    all_nodes = FindNodes.find_all 
    Enum.reduce(all_nodes, HashDict.new, fn (node, acc)->
      HashDict.put(acc, node.id, node)
    end)
  end
end
