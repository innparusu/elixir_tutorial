- Elixir において``=``はマッチ演算子と呼ばれている
``` elixir
iex(1)> x = 1
1
iex(2)> x
1
iex(3)> 1 = x
1
iex(4)> 2 = x
** (MatchError) no match of right hand side value: 1
```
- 左側も右側も同じ時にマッチする. 両側がマッチしなかった場合, ``MatchError`` を発生させる
- 変数は``=``の左側にあるときにだけ割り当てられる
- マッチ演算子は複雑なデータ型を分類するのにも使える

``` elixir
iex(4)> {a,b,c,}={:hello, "world", 42}
{:hello, "world", 42}
iex(5)> a
:hello
iex(6)> b
"world"
iex(7)> c
42
```

- 特定の値へマッチさせることもできる
``` elixir
iex(8)> {:ok, result} = {:ok, 13}
{:ok, 13
```
- リストにもパターンマッチできる
    - head と tail というマッチングもできる

``` elixir
iex(1)> [head|tail] = [1,2,3]
[1, 2, 3]
iex(2)> head
1
iex(3)> tail
[2, 3]
```

- ピン演算子``^`` は変数の再束縛ではなく以前にマッチした値とのマッチングをしたい場合に使われる

- マッチの左側で関数を呼び出すことが出来ない

```elixir
iex(15)> length([1,2,3]) = 3
** (CompileError) iex:15: illegal pattern
```
