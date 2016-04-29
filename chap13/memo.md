- alias によって与えられたモジュールの名前へ別名をつけることができる

``` elixir
defmodule Math do
  alias Math.List, as: List
end
```

- どんな``List``の参照でも自動的に``Math.List``へと展開される
- Originalにアクセスしたい場合はElixir からモジュールへとaccessできる

``` elixir
List.flatten             #=> uses Math.List.flatten
Elixir.List.flatten      #=> uses List.flatten
Elixir.Math.List.flatten #=> uses Math.List.flatten
```

- Elixir の中で定義されているすべてのモジュールはElixir名前空間の中に定義されている
- Elixir を省略することができる

- Alias はショートカットを定義するのによく使われる

``` elixir
# alias Math.List, as: List と同じ
alias Math.List
```
- alias はレキシカルスコープ
- 特定の関数の中で別名をセットすることができる[;w

``` elixir
defmodule Math do
  def plus(a, b) do
    alias Math.List
    # ...
  end

  def minus(a, b) do
    # ...
  end
end
```

- alias を関数plus/2 の中で呼び出しても, plus/2 の内部でのみ有効で minus/2 には影響しない

- Elixir はメタプログラミングのためにマクロを用意している
- マクロはコンパイル時に実行して展開されるコードのこと
    - マクロを使うために、 コンパイル時にそのモジュールと実装が用意されている保証が必要になる
    - ``require`` ディレクティブを使うとそのようにできる

``` elixir
iex(3)> Integer.is_odd(3)
** (CompileError) iex:3: you must require Integer before invoking the macro Integer.is_odd/1
    (elixir) src/elixir_dispatch.erl:98: :elixir_dispatch.dispatch_require/6
iex(3)> require Integer
nil
iex(4)> Integer.is_odd(3)
true
```

- Elixir では ``Integer.is_odd?/1`` はマクロとして定義されているのでガードとして利用できる
    - つまり Integer モジュールが必要
- ロードされていないマクロを呼びだそうとするとエラーになる
- alias と同じように require もレキシカルスコープ

- 他のモジュールの関数かマクロへ修飾名を付けず簡単にaccessしたいときにimport を使う

``` elixir
# List.duplicate/2だけをインポート
iex(1)> import List, only: [duplicate: 2]
nil
iex(2)> duplicate :ok, 3
[:ok, :ok, :ok]
```

- :only は省略可能, しかし、付けることが推奨
- :except もある
- import では :only へ :macros と :functions を渡すことができる

``` elixir
# すべてのマクロをインポート
import Integer, only: :macros
# すべての関数をインポート
import Integer, only: :functions
```

- import もレキシカルスコープ
- つまり特定の関数の中で特定の物をインポートできる

``` elixir
# List.dublicate/2 は特定の関数内からしか見えない
defmodule Math do
  def some_function do
    import List, only: [duplicate: 2]
    # call duplicate
  end
end
```

- Elixir の alias は String, Keyword のような大文字で始まり、識別子でコンパイル時にatomへ変換される
    - String alias はデフォルトで atom :"Elixir.String" へ変換される

``` elixir
iex(3)> is_atom(String)
true
iex(4)> to_string(String)
"Elixir.String"
iex(5)> :"Elixir.String"
String
```

- alias/2 を使うことで単に alias を何へ変換するかだけを変えている
    - Erlang VM (つまり elixirでも)の中ではモジュールがatomで表現されているため alias が動く

``` elixir
iex(7)> to_string(List)
"Elixir.List"
iex(8)> :lists.flatten([1,[2],3])
[1, 2, 3]
iex(9)> :"Elixir.List".flatten([1,[2],3])
[1, 2, 3]
```

- これがモジュール内部で与えられた関数を動的に呼び出す事ができるメカニズム

``` elixir
iex> mod = :lists
:lists
iex> mod.flatten([1,[2],3])
[1,2,3]
```

- 下の例は Foo と Foo.Bar という2つのモジュールを定義している
- Foo の中の Bar は 同じレキシカルスコープにいる
- Bar を他のファイルに移動した場合、参照するにはフルネーム(Foo.Bar)か alias を使ってセットすることが必要

``` elixir
defmodule Foo do
  defmodule Bar do
  end
end
# 上のコードと同じ
defmodule Elixir.Foo do
  defmodule Elixir.Foo.Bar do
  end
  alias Elixir.Foo.Bar, as: Bar
end
```

