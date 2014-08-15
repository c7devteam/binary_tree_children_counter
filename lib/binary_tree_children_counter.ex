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
    all_nodes = FindNodes.find_all
    agent = Enum.reduce(all_nodes, HashDict.new, fn (node, acc)->
      acc = HashDict.put(acc, node.id, node)
    end)
    root = FindNodes.find_root(agent)
    run_step(root, agent)
  end

  def run_step(node, agent) do
    if node.children_count_left == 0 do
      left_node = find_node_by_id(node.left_node_id, agent)
      if left_node do
        run = fn ->
          run_step(left_node, agent)
        end
      end
    end
    if node.children_count_right == 0 do
      right_node = find_node_by_id(node.right_node_id, agent)
      if right_node do
        run = fn ->
          run_step(right_node, agent)
        end
      end
    end
    if !right_node && !left_node do
      run = fn ->
        go_up(find_node_by_id(node.parent_id, agent), node, agent)
      end
    end
    run.()
  end

  def go_up(false, _, agent) do
    FindNodes.update_all(HashDict.values(agent))
    :success
  end

  def go_up(parent, child, agent) do
    cond do
      parent.left_node_id == child.id ->
        new_parent = %{parent | children_count_left: child.children_count_right + child.children_count_left + 1}
        agent = HashDict.put(agent, new_parent.id, new_parent)
      parent.right_node_id == child.id ->
        new_parent = %{parent | children_count_right: child.children_count_right + child.children_count_left + 1}
        agent = HashDict.put(agent, new_parent.id, new_parent)
    end
    run_step(new_parent, agent)
  end

  def find_node_by_id(0, _) do
    false
  end

  def find_node_by_id(node_id, agent) do
    HashDict.get(agent, node_id)
  end

  def parse_result({:success, node}) do
    node
  end

  def parse_result({:not_found, _}) do
    false
  end
end
