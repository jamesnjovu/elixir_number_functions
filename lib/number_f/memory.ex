defmodule NumberF.Memory do
  @moduledoc false

  def humanize(bytes) when bytes < 1024, do: "#{bytes} B"
  def humanize(bytes) when bytes < 1_048_576, do: "#{Float.round(bytes / 1024, 2)} KB"
  def humanize(bytes) when bytes < 1_073_741_824, do: "#{Float.round(bytes / 1_048_576, 2)} MB"
  def humanize(bytes), do: "#{Float.round(bytes / 1_073_741_824, 2)} GB"
end
