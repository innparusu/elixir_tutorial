- Elixir には キーワードリストとマップ の2つの連想データ構造がある
- Elixir 最初の要素がアトムとなっているtupleのlistがある場合 それをキーワードリストと呼ぶ

``` elixir
iex(1)> list = [{:a, 1}, {:b, 2}]
[a: 1, b: 2]
iex(2)> list[:a]
1
iex(3)> list == [a: 1, b: 2]
true
```

- キーワードリストはリストへ行う操作がどれも可能, 性能も同じ
- 値を取るときは前にある方が取得される

- do と else の組はキーワードリスト

``` elixir
if false, do: :this, else: :that
```

- この呼出は下と同じ

``` elixir
if(false, [do: :this, else: :that])
```

- キーワードリストは関数の引数の最後に有り、角括弧はつけなくても良い(Ruby と同じ)
- キーワードリストはリストのため、線形の性能をもっている
- たくさんの要素をほじしなければならなかったり、1つのキーに対して1つの値をもつことを保証したいならmapを使う
- キーワードリストにもパターンマッチできる(しかし、ほとんど使わない)

- map は %{} で作る

``` elixir
iex(11)> map = %{:a => 1, 2 => :b}
%{2 => :b, :a => 1}
iex(12)> map[:a]
1
iex(13)> map[2]
:b
```
- mapはキーをどんな値にもできる
- mapのキーは順番通りにならない
- mapを作るときに同じキーを渡すと、最後の一つが適用される
- mapのキーが全てアトムの場合はキーワード構文が使える
- mapはパターンマッチングに使いやすい

``` elixir 
iex(14)> map = %{a: 1, b: 2}
%{a: 1, b: 2}
iex(15)> %{} = %{:a => 1, 2 => :b}
%{2 => :b, :a => 1}
iex(16)> %{:a => a} = %{:a => 1, 2 => :b}
%{2 => :b, :a => 1}
iex(17)> a
1
iex(18)> %{:c => c} = %{:a => 1, 2 => :b}
** (MatchError) no match of right hand side value: %{2 => :b, :a => 1}
```

- mapは与えられたmapのキーが有る部分にだけマッチする。そのためからのmapはすべてのmapにマッチする
- map は更新やアトムのキーにアクセスするための構文が提供されている(すでにあるキーを必要とする)

``` elixir
iex(23)> map.a
1
iex(24)> %{map | :a => 2}
%{2 => :b, :a => 2}
iex(25)> %{map | :c => 2}
** (KeyError) key :c not found in: %{2 => :b, :a => 1}
```

- elixir ではキーワードリストとマップのどちらもディクショナリと呼ばれる
- ディクショナリはinterfaceのようなもの(Elixir では behaviours とよんでいる) で、キーワードリストもマップのどちらのモジュールもこのinterfaceを実装している
- このinterfaceはAPIを提供(実際の実装は移譲)している Dict モジュールで定義している

``` elixir
iex(26)> keyword = []
[]
iex(27)> map = %{}
%{}
iex(28)> Dict.put(keyword, :a, 1)
[a: 1]
iex(29)> Dict.put(map, :a, 1)
%{a: 1}
```

- Dict モジュールは他のディクショナリ同士でも動作するような関数を提供している

``` elixir
iex(30)> Dict.equal? keyword, map
true
```
