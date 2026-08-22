defmodule NumberF.Memory do
  @moduledoc false

  # Binary (IEC) steps, largest first. Expressed as {threshold, divisor, suffix} so a
  # new tier is one row rather than another guard clause + another magic literal.
  #
  # Previously this stopped at GB, so humanize(5_000_000_000_000) returned
  # "4656.61 GB" instead of "4.55 TB", and the `bytes < 1024` head matched negatives,
  # so humanize(-5) returned "-5 B".
  @kb 1024
  @mb 1024 * @kb
  @gb 1024 * @mb
  @tb 1024 * @gb
  @pb 1024 * @tb

  @tiers [
    {@pb, "PB"},
    {@tb, "TB"},
    {@gb, "GB"},
    {@mb, "MB"},
    {@kb, "KB"}
  ]

  def humanize(bytes) when is_number(bytes) and bytes < 0, do: "-" <> humanize(-bytes)

  def humanize(bytes) when is_number(bytes) do
    case Enum.find(@tiers, fn {threshold, _suffix} -> bytes >= threshold end) do
      nil -> "#{bytes} B"
      {divisor, suffix} -> "#{Float.round(bytes / divisor, 2)} #{suffix}"
    end
  end
end
