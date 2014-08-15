defmodule BinaryTreeChildrenCounterTest do
  use ExUnit.Case, async: false

  test "worker" do
    repo = Repo.start_link
    { :ok, pid  } = Postgrex.Connection.start_link([hostname: "localhost", username: "postgres", password: "sapkaja21", database: "bonofa_main_test"])
    Postgrex.Connection.query(pid, "ALTER SEQUENCE binary_tree_nodes_id_seq RESTART")

    Repo.transaction(fn ->
      level_widths = calculate_level_width(3)
        data = Enum.map(level_widths, fn (width)->
          Enum.map(1..width, fn (width_item) ->
            build_tree_element_map(width, width_item)
          end)
        end)
        assert(data == [
          [
            %BinaryTreeNode{parent_id: 0, left_node_id: 2, right_node_id: 3}
          ],
          [
            %BinaryTreeNode{parent_id: 1, left_node_id: 4, right_node_id: 5},
            %BinaryTreeNode{parent_id: 1, left_node_id: 6, right_node_id: 7}
          ],
          [
            %BinaryTreeNode{parent_id: 2, left_node_id: 8, right_node_id: 9},
            %BinaryTreeNode{parent_id: 2, left_node_id: 10, right_node_id: 11},
            %BinaryTreeNode{parent_id: 3, left_node_id: 12, right_node_id: 13},
            %BinaryTreeNode{parent_id: 3, left_node_id: 14, right_node_id: 15}
          ]
        ])

        Enum.each(data, fn (level)->
          Enum.each(level, fn (e)->
            Repo.insert(e)
          end)
        end)
        BinaryTreeChildrenCounter.run
        assert(
            FindNodes.find_all == [
              %BinaryTreeNode{id: 1, parent_id: 0, left_node_id: 2, right_node_id: 3, children_count_left: 3, children_count_right: 3},
              %BinaryTreeNode{id: 2, parent_id: 1, left_node_id: 4, right_node_id: 5, children_count_left: 1, children_count_right: 1},
              %BinaryTreeNode{id: 3, parent_id: 1, left_node_id: 6, right_node_id: 7, children_count_left: 1, children_count_right: 1},
              %BinaryTreeNode{id: 4, parent_id: 2, left_node_id: 8, right_node_id: 9, children_count_left: 0, children_count_right: 0},
              %BinaryTreeNode{id: 5, parent_id: 2, left_node_id: 10, right_node_id: 11, children_count_left: 0, children_count_right: 0},
              %BinaryTreeNode{id: 6, parent_id: 3, left_node_id: 12, right_node_id: 13, children_count_left: 0, children_count_right: 0},
              %BinaryTreeNode{id: 7, parent_id: 3, left_node_id: 14, right_node_id: 15, children_count_left: 0, children_count_right: 0}
            ]
          )
        Repo.rollback
      end)
  end

  def calculate_level_width(levels) do
    Enum.scan(1..levels, fn (_,b) -> b * 2 end)
  end

  def build_tree_element_map(1, 1) do
    %BinaryTreeNode{parent_id: 0, left_node_id: 2, right_node_id: 3}
  end


  def build_tree_element_map(width_item, width) do
    e = (width + width_item) - 1
    %BinaryTreeNode{parent_id: trunc(e/2), left_node_id: e*2, right_node_id: e * 2 + 1}
  end
end
