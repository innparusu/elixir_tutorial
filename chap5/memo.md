- case は値がいずれか一つにマッチするまで複数のパターンと比較することができる

``` elixir
iex(1)> case {1,2,3} do
...(1)> {4,5,6} ->
...(1)> "this clause won't match"
...(1)> {1,x,3} ->
...(1)> "this clause will match and bind x to 2 in this clause"
...(1)> _ ->
...(1)> "this clause would match any value"
...(1)> end
"this clause will match and bind x to 2 in this clause"
```

- 変数とパターンマッチさせたい場合、^ を使う必要がある

``` elixir
iex(2)> x = 1
1
iex(3)> case 10 do
...(3)> ^x -> "Won't match"
...(3)> _ -> "Will match"
...(3)> end
"will match"
```

- ガードを指定することで条件を拡張することができる

``` elixir
iex(1)> case {1,2,3} do
...(1)> {1,x,3} when x > 0 ->
...(1)> "Will match"
...(1)> _ ->
...(1)> "Won't match"
...(1)> end
"Will match"
```

- ガードの中で起きたエラーは単純にガードの失敗とみなされれてガードの外には影響しない

``` elixir
iex(3)> hd(1)
** (ArgumentError) argument error
    :erlang.hd(1)
iex(3)> case 1 do
...(3)> x when hd(x) -> "Won't match"
...(3)> x -> "Got: #{x}"
...(3)> end
"Got: 1"
```

- どの句にもマッチしなければ、エラーが発生

``` elixir
iex(4)> case :ok do
...(4)> :error -> "Won't match"
...(4)> end
```

- 匿名関数でも句やカードを複数持つことができる

``` elixir
iex(4)> f = fn
...(4)> x,y when x > 0 -> x+y
...(4)> x,y -> x*y
...(4)> end
```

- case は異なる値に対して(1つの値を)マッチさせようとするときにはうまく使える。
- 場合によっては最初に評価した式がtrueになるまで複数の条件をチェックしたい場合がある。 その場合は cond を使う

``` elixir
iex(1)> cond do
...(1)>  2+2 == 5 ->
...(1)> "this will not be true"
...(1)> 2*2 == 3 ->
...(1)> "nor this"
...(1)> 1+1 == 2 ->
...(1)> "but this will"
...(1)> end
"but this will"
```

- cond は true になる条件がなければエラーになる
- そのため条件にtrueになるものを加えて常にマッチさせることが必要かも

``` elixir
iex(2)> cond do
...(2)> 2+2 == 5 ->
...(2)> "this is never true"
...(2)> 2+2 == 3 ->
...(2)> "nor this"
...(2)> true ->
...(2)> "this is always true(equivalent to else)"
...(2)> end
"this is always true(equivalent to else)"
```

- 一つだけ条件をチェックしたい場合は if/2 や unless/2 といったマクロを使う
- else も使える

``` elixir
iex(1)> if nil do
...(1)> "This won't be seen"
...(1)> else
...(1)> "This will"
...(1)> end
"This will"
```

- if は以下の様にも書ける

``` elixir
iex(2)> if true, do: 1 + 2
3
```

- Elixir では do/end ブロックは式のまとまりを簡単にdo:へわたすためのもの
- この構文はキーワードリストを使っていると言える. else も同じ構文で渡せる

``` elixir
iex(4)> if false, do: :this, else: :that
:that
```

- ブロックは常に一番遠くの関数呼び出しに束縛される

``` elixir
iex(5)> is_number if true do
...(5)> 1+2
...(5)> end
```

は 

``` elixir
iex(5)> is_number(if true) do
...(5)> 1+2
...(5)> end
```

と解釈される

- 曖昧さを解消するためには明示的に括弧を追加する

``` elixir
iex(5)> is_number(if true do
...(5)>  1+2
...(5)> end)
true
```
