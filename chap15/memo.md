- 構造体は初期値、コンパイル時の保証及び多態をElixir へもたらす、mapを利用した拡張
- 構造体を定義するにはモジュールの中で ``defstruct/1`` を呼ぶ

``` elixir
iex(1)> defmodule User do
...(1)> defstruct name: "john", age: 27
...(1)> end
{:module, User,
 <<70, 79, 82, 49, 0, 0, 5, 52, 66, 69, 65, 77, 69, 120, 68, 99, 0, 0, 0, 133, 131, 104, 2, 100, 0, 14, 101, 108, 105, 120, 105, 114, 95, 100, 111, 99, 115, 95, 118, 49, 108, 0, 0, 0, 4, 104, 2, ...>>,
 %User{age: 27, name: "john"}}
```

- ``%User{}`` 構文を使って構造体のインスタンスが作れるようになる

``` elixir
iex(2)> %User{}
%User{age: 27, name: "john"}
iex(3)> %User{name: "meg"}
%User{age: 27, name: "meg"}
iex(4)> is_map(%User{})
true
```

- 構造体は用意しているフィールドが存在することをコンパイル時に保証する

``` elixir
iex(5)> %User{oops: :field}
** (CompileError) iex:5: unknown key :oops for struct User
```

- mapのようにすでにあるフィールドに対してアクセスやアップデートできる

``` elixir
iex(5)> john = %User{}
%User{age: 27, name: "john"}
iex(6)> john.name
"john"
iex(7)> john.msg
** (KeyError) key :msg not found in: %User{age: 27, name: "john"}

iex(7)> meg = %{john | name: "meg"}
%User{age: 27, name: "meg"}
iex(8)> %{meg | oops: :field}
** (KeyError) key :oops not found in: %User{age: 27, name: "meg"}
```

- アップデート構文を使うと、 VM はmap/構造体へ新しいキーがなにも追加されないことを認識し、mapがメモリ内で構造を共有できるようにする
- 構造体はパターンマッチングでよく使われ、構造体の型が同じことを保証する

``` elixir
iex(11)> %User{name: name} = john
%User{age: 27, name: "john"}
iex(12)> name
"john"
iex(13)> %User{} = %{}
** (MatchError) no match of right hand side value: %{}
```

- マッチングが動作するのは構造体がマップの中の``__struct__`` というフィールドを保存しているから

``` elixir
iex(13)> john.__struct__
User
```

- 構造体は単にデフォルトのフィールドがあるだけの剥き出しのmap
    - mapは構造体のために何のプロトコルも実装していない
    - 例えば構造体を列挙するようなアクセスはできない

``` elixir
iex(15)> user = %User{}
%User{age: 27, name: "john"}
iex(16)> user[:name]
** (UndefinedFunctionError) undefined function User.fetch/2 (User does not implement the Access behaviour)
             User.fetch(%User{age: 27, name: "john"}, :name)
```

- 構造体はディクショナリでもないので、 ``Dict`` モジュールからも使えない

``` elixir
iex(17)> Dict.get(%User{}, :name)
** (UndefinedFunctionError) undefined function User.get/3
    User.get(%User{age: 27, name: "john"}, :name, nil)
```

- 構造体は map なので ``Map`` モジュールは使える

``` elixir
iex(17)> Map.put(%User{}, :name, "kurt")
%User{age: 27, name: "kurt"}
iex(18)> Map.merge(%User{age: 27}, %User{name: "takashi"})
%User{age: 27, name: "takashi"}
```
