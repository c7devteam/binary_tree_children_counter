defmodule FindNodes do
  require Repo
  import Ecto.Query

  def find_root do
    query = from b in BinaryTreeNode,
    where: b.id == ^1,
    select: b
    format_single_result(Repo.all(query))
  end

  def by_id(id) do
    query = from b in BinaryTreeNode,
    where: b.id == ^id,
    select: b
    format_single_result(Repo.all(query))
  end

  def find_all do
    query = from b in BinaryTreeNode,
    select: b,
    order_by: b.id
    Repo.all(query)
  end

  def update_nodes_left_child_count(node) do
    from(p in BinaryTreeNode, where: p.id == ^node.id) |>
      Repo.update_all(children_count_left: ^node.children_count_left)
  end

  def update_nodes_right_child_count(node) do
    from(p in BinaryTreeNode, where: p.id == ^node.id) |>
      Repo.update_all(children_count_right: ^node.children_count_right)
  end

  def set_children_counts_to_zero do
    Repo.update_all(BinaryTreeNode, children_count_right: 0, children_count_left: 0)
  end


  def format_single_result([]) do
    {:not_found, nil}
  end

  def format_single_result([node | _]) do
    {:success, node}
  end
end
