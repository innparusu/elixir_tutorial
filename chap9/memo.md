- Elixir も他の関数型言語と変わらずにループは再帰で書く
- case と似たように, 関数は複数の句をもつことができる

``` elixir
defmodule Recursion do
  def print_multiple_times(msg, n) when n <= 1 do
    IO.puts msg
  end

  def print_multiple_times(msg, n) do
    IO.puts msg
    print_multiple_times(msg, n - 1)
  end
end

Recursion.print_multiple_times("Hello", 3)
# Hello!
# Hello!
# Hello!
```

- ``print_multiple_times/2`` は引数の2番目へどんな数が渡されても、 1番目の定義("ベースケース"と呼ばれる), あるいはベースケースへ確実に近づくような2番目の定義のどちらかを呼ぶ

``` elixir
defmodule Math do
  def sum_list([head|tail], accumulator) do
    sum_list(tail, head + accumulator)
  end

  def sum_list([], accumulator) do
    accumulator
  end
end

Math.sum_list([1,2,3], 0) #=> 6
```

``` elixir
defmodule Math do
  def double_each([head|tail]) do
    [head * 2|double_each(tail)]
  end

  def double_each([]) do 
    []
  end
end

Math.double_each([1, 2, 3]) #=> [2, 4, 6]
```

- Enumモジュールはリストを扱う様々な関数を提供している

``` elixir
# sum_list
iex> Enum.reduce([1, 2, 3], 0, fn(x, acc) -> x + acc end)
6
# dobule_each
iex> Enum.map([1, 2, 3], fn(x) -> x * 2 end)
[2, 4, 6]
```

- キャプチャー構文も使える

``` elixir
# sum_list
iex> Enum.reduce([1, 2, 3], 0, &+/2)
6
# dobule_each
iex> Enum.map([1, 2, 3], &(&1 * 2))
[2, 4, 6]
```
