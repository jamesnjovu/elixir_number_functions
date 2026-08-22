defmodule NumberF.ApplicationTest do
  use ExUnit.Case

  test "application starts successfully" do
    # Test that the application can start
    assert {:ok, _pid} = NumberF.Application.start(:normal, [])
  end

  test "application supervision tree" do
    # Test supervision tree structure
    children =
      NumberF.Application.start(:normal, [])
      |> elem(1)
      |> Supervisor.which_children()

    assert is_list(children)
  end
end
