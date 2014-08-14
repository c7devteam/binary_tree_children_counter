defmodule BinaryTreeChildrenCounter do
  def run do
    FindNodes.set_children_counts_to_zero
    {:success, root} = FindNodes.find_root
    run_step(root)
  end

  def run_step(node) do
    if node.children_count_left == 0 do
      left_node = find_node_by_id(node.left_node_id)
      if left_node do
        run = fn ->
          run_step(left_node)
        end
      end
    end
    if node.children_count_right == 0 do
      right_node = find_node_by_id(node.right_node_id)
      if right_node do
        run = fn ->
          run_step(right_node)
        end
      end
    end
    if !right_node && !left_node do
      run = fn ->
        go_up(FindNodes.by_id(node.parent_id), node)
      end
    end
    run.()
  end

  def go_up({:success, parent}, child) do
    cond do
      parent.left_node_id == child.id ->
        new_parent = %{parent | children_count_left: child.children_count_right + child.children_count_left + 1}
        FindNodes.update_nodes_left_child_count(new_parent)
      parent.right_node_id == child.id ->
        new_parent = %{parent | children_count_right: child.children_count_right + child.children_count_left + 1}
        FindNodes.update_nodes_right_child_count(new_parent)
    end
    run_step(new_parent)
  end

  def go_up({:not_found, _}, _) do
    :success
  end

  def find_node_by_id(node_id) do
    parse_result(FindNodes.by_id(node_id))
  end

  def parse_result({:success, node}) do
    node
  end

  def parse_result({:not_found, _}) do
    false
  end
end
