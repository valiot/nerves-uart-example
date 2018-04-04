defmodule NervesUartExampleTest do
  use ExUnit.Case
  doctest NervesUartExample

  test "greets the world" do
    assert NervesUartExample.hello() == :world
  end
end
