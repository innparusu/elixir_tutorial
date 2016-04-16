- Elixir は範囲(ranges) もある

``` elixir
iex(10)> Enum.map(1..3, fn x -> x * 2 end)
[2, 4, 6]
iex(11)> Enum.reduce(1..3, 0, &+/2)
6
```

- Enum モジュールの関数はすべて貪欲
- 関数は一つのenumerable をとって一つのリストを返す

``` elixir
iex(12)> odd? = &(rem(&1, 2) != 0)
#Function<6.50752066/1 in :erl_eval.expr/5>
iex(13)> Enum.filter(1..3, odd?)
[1, 3]
```

- つまり Enum で複数の操作をしたとき、結果が出るまですべての操作が中間リストを作るということになる

``` elixir
iex> 1..100_000 |> Enum.map(&(&1 * 3)) |> Enum.filter(odd?) |> Enum.sum
7500000000
```

- 上の操作はパイプラインでつなげている
    - まず範囲を指定
    - 範囲のすべての要素を3倍にする(これで100000個のリストができる)
    - すべての奇数を残す(50000個のリスト)
    - すべてを足す
- Elixir ではかわりに、遅延評価できるStream モジュールを用意している

``` elixir
iex> 1..100_000 |> Stream.map(&(&1 * 3)) |> Stream.filter(odd?) |> Enum.sum
```

- stream は大きかったり無限かもしれない集まりいを扱うのに便利
- stream は lazyで composable な enumerable
- 上記の ``Stream.map(&(&1 * 3))`` は 1.. 100000 の範囲に対して map を処理する表現であるstream というデータ型を返すので, lazy
_ さらに複数のstream処理を通せるためcomposable である

``` elixir
iex(1)> 1..100_000 |> Stream.map(&(&1 * 3))
#Stream<[enum: 1..100000, funs: [#Function<0.124112216/1 in Stream.map/2>]]>
iex(3)> 1..100_000 |> Stream.map(&(&1 * 3)) |> Stream.filter(odd?)
#Stream<[enum: 1..100000,
 funs: [#Function<0.124112216/1 in Stream.map/2>,
  #Function<49.124112216/1 in Stream.filter/2>]]>
```

- Stream モジュールは引数へすべてのenumerable でも受けつけ、結果を Stream を返す
- 無限になるかもしれないstream を作る関数も用意している
    - ``Stream.cycle/1`` は与えられたenumerable を無限に繰り返す stream をつくる

``` elixir
iex(4)> stream = Stream.cycle([1,2,3])
#Function<60.124112216/2 in Stream.unfold/2>
iex(5)> Enum.take(stream, 10)
[1, 2, 3, 1, 2, 3, 1, 2, 3, 1]
```
