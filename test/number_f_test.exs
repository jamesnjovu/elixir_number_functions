defmodule NumberFTest do
  use ExUnit.Case
  doctest NumberF

  test "greets the world" do
    assert NumberF.hello() == :world
  end
end
