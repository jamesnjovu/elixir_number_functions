defmodule NumberF.MemoryTest do
  use ExUnit.Case
  doctest NumberF.Memory

  describe "humanize/1" do
    test "formats bytes correctly" do
      assert NumberF.Memory.humanize(500) == "500 B"
      assert NumberF.Memory.humanize(1023) == "1023 B"
    end

    test "formats kilobytes correctly" do
      assert NumberF.Memory.humanize(1024) == "1.0 KB"
      assert NumberF.Memory.humanize(1536) == "1.5 KB"
      assert NumberF.Memory.humanize(10240) == "10.0 KB"
    end

    test "formats megabytes correctly" do
      assert NumberF.Memory.humanize(1_048_576) == "1.0 MB"
      assert NumberF.Memory.humanize(2_097_152) == "2.0 MB"
      assert NumberF.Memory.humanize(1_572_864) == "1.5 MB"
    end

    test "formats gigabytes correctly" do
      assert NumberF.Memory.humanize(1_073_741_824) == "1.0 GB"
      assert NumberF.Memory.humanize(2_147_483_648) == "2.0 GB"
      assert NumberF.Memory.humanize(1_610_612_736) == "1.5 GB"
    end
  end
end
