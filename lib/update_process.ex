defmodule UpdateProcess do
  def receive_message do
    receive do
      {node, pid} ->
        Repo.update(node)
        send(pid, :success)
    end
  end
end
