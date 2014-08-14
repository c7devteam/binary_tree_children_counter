defmodule BinaryTreeNode do
  use Ecto.Model

  schema "binary_tree_nodes" do
    field :left_node_id, :integer
    field :right_node_id, :integer
    field :parent_id, :integer
    field :children_count_left, :integer, default: 0
    field :children_count_right, :integer, default: 0
    field :children_count_active_left, :integer
    field :children_count_active_right, :integer
    field :level, :integer, default: 0
  end
end
