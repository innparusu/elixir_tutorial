defprotocol Blank do
  @doc "Return true if data is considered blank/empty"
  @fallback_to_any true
  def blank?(data)
end

defimpl Blank, for: Any do
  def blank?(_) do: false
end

# 整数はブランクにならない
defimpl Blank, for: Integer do
  def blank?(_), do: false
end

# 空リストのときだけブランク
defimpl Blank, for: List do
  def blank?([]), do: true
  def blank?(_),  do: false
end

# 空のmapの時だけブランクになる
defimpl Blank, for: Map do
  def blank?(map), do: map_size(map) == 0
end

# アトムが false と nil の時だけブランクになる
defimpl Blank, for: Atom do
  def blank?(false), do: true
  def blank?(nil),   do: true
  def blank?(_),     do: false
end

defimpl Blank, for: User do
    def blank?(_), do: false
end
