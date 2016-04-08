- Elixir はモジュールの中に複数の関数を入れてグループ化する
    - String モジュール等
- モジュールを自分で作るには ``defmodule`` マクロを使う

``` elixir
iex(4)> defmodule Math do
...(4)> def sum(a, b) do
...(4)> a + b
...(4)> end
...(4)> end
{:module, Math,
 <<70, 79, 82, 49, 0, 0, 4, 240, 66, 69, 65, 77, 69, 120, 68, 99, 0, 0, 0, 157, 131, 104, 2, 100, 0, 14, 101, 108, 105, 120, 105, 114, 95, 100, 111, 99, 115, 95, 118, 49, 108, 0, 0, 0, 4, 104, 2, ...>>,
 {:sum, 2}}
iex(5)> Math.sum
sum/2
iex(5)> Math.sum(1,2)
3
```

- elixirc を使ってex はコンパイルできる
- コンパイルすると Elixir.Math.beam という名前のファイルが生成される
- iex 実行時 同じディレクトリにあるバイトコードファイルは自動的に読み込まれる
- 通常3つのディレクトリを備える
    - ebin - コンパイルされたbytecode
    - lib - コード本体
    - test - testコード(.exs)
- プロジェクトでは mix というビルドツールを使う
- ex 以外にも exs という拡張子が使える (スクリプティング用)
- Elixir は ex と exs を同等に使う
- 違いは意図のみで, ex ファイルはコンパイルされることを意図しており, exs はコンパイル不要のスクリプティングに使われる
- スクリプティングでの実行方法は ``elixir`` コマンドを使う
- ``defp/2`` はプライベート関数を定義しており, module 内でしか呼べない
- 関数宣言はガードと複数句に対応している
    - 関数に複数の句がある場合、Elixir はマッチする句があるまで順番に試す

``` elixir
defmodule Math do
  def zero?(0) do
    true
  end

  def zero?(x) when is_number(x) do
    false
  end
end
```

- `name/arity` という記法を名前付き関数の型として使える(前の&を付ける, capture syntax と呼ばれる)

``` elixir
iex(2)> fun = &Math.zero?/1
&Math.zero?/1
iex(3)> is_function fun
true
iex(4)> fun.(0)
true
iex(5)> &is_function/1
&:erlang.is_function/1
iex(6)> (&is_function/1).(fun)
true
```

- capture syntax は関数を作る時のショートカットとしても使える

``` elixir
iex(7)> fun = &(&1+1)
#Function<6.50752066/1 in :erl_eval.expr/5>
iex(8)> fun.(1)
2
```

- ``&(&1+1)`` は ``fn x -> x + 1 end`` と同じ
    - この構文は Function を短く定義するのに便利
- キャプチャ演算子 ``&`` は Kernel.SpecialForms ドキュメントを参考にする

- 名前付き関数はデフォルト引数も使える

``` elixir
defmodule Concat do
  def join(a, b, sep \\ " ") do
    a <> sep <> b
  end
end
```

- デフォルト値はどんな式も対応しているが、 関数定義の時には評価されない
- 関数が呼びだされ、その関数のデフォルト値が利用されるたび、デフォルト値の式が評価される

``` elixir 
defmodule DefaultTest do
  def dowork(x \\ IO.puts "hello") do
    x
  end
end
```

``` elixir
iex(1)> DefaultTest.dowork 123
123
iex(2)> DefaultTest.dowork
hello
:ok
```

- もしデフォルト値つきの関数に複数の句がある場合, デフォルト値を宣言するヘッダ部分を分けて作るのがおすすめ

``` elixir
defmodule Concat do
  def join(a, b \\ nil, sep \\ " ")

  def join(a, b, _sep) when is_nil(b) do
    a
  end

  def join(a, b, sep) do
    a <> sep <> b
  end
end

IO.puts Concat.join("Hello", "world") #=> Hello world
IO.puts Concat.join("Hello", "world", "_") #=> Hello_world
IO.puts Concat.join("Hello") #=> Hello
```

- デフォルト値を使うなら関数定義の上書きについては注意が必要

``` elixir
defmodule Concat do
  def join(a, b) do
    IO.puts "***First join"
    a <> b
  end

  def join(a, b, sep \\ " ") do
    IO.puts "***Second join"
    a <> sep <> b
  end
end
```

- warning がでる
- 2引数の join 関数は常に最初のjoin を呼び出し, 2番目のものは 3つの引数が渡された時しか呼び出されない

``` elixir
concat.ex:7: warning: this clause cannot match because a previous clause at line 2 always matches
Interactive Elixir (1.2.4) - press Ctrl+C to exit (type h() ENTER for help)
iex> Concat.join "Hello", "world"
***First join
"Helloworld"
iex> Concat.join "Hello", "world", "_"
***Second join
"Hello_world"
```

- 3引数を先に宣言するとコンパイルerror がはかれる

``` elixir
defmodule Concat do
  def join(a, b, sep \\ " ") do
    IO.puts "***Second join"
    a <> sep <> b
  end

  def join(a, b) do
    IO.puts "***First join"
    a <> b
  end

end
```

```
e125716 @ innparusu $ iex concat.ex                                                                                                                                                                                                                                                                                              [~/Workspace/elixir/getting-started/chap8]
Erlang/OTP 18 [erts-7.3] [source] [64-bit] [smp:8:8] [async-threads:10] [hipe] [kernel-poll:false] [dtrace]

** (CompileError) concat.ex:7: def join/2 conflicts with defaults from def join/3
    (stdlib) erl_eval.erl:670: :erl_eval.do_apply/6
```
