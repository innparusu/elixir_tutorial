- モジュールのattributeには3つの目的がある
    - 注釈をモジュールへ付ける. ユーザーやvmが利用できるような情報のことが多い
    - 定数として利用
    - コンパイルの際にモジュールの一時的な保管場所として利用する

- Elixir はモジュールattributeのコンセプトをErlang から持ってきている
- 下記の例ではモジュールのversion attribute を明示的に設定している
- ``@vsn`` はモジュールがアップデートされたかをErlangVMでのコード再読み込みの仕組みでチェックするのに使っている

``` elixir
defmodule MyServer do
  @vsn 2
end
```

- Elixir には 予約済みのattributeが少しだけある(結構頻繁に使われる)
    - ``@moduledoc`` このモジュールのドキュメントを提供
    - ``@doc`` この印の次にある関数やマクロのドキュメントを提供する
- Elixir には 予約済みのattributeが少しだけある
   (結構頻繁に使われる)
    - ``@moduledoc`` このモジュールのドキュメントを提供
    - ``@doc`` この印の次にある関数やマクロのドキュメントを提供する
    - ``@behaviour``  ユーザーが定義した振る舞いなのかOTPが定義した振る舞いなのか区別する
    - ``@before_compile`` モジュールがコンパイルされる前に実行されるフックを提供
- この中でも ``@moduledoc`` と ``@doc`` はよく使われているattribute

``` elixir
# Math にドキュメントを追加する
defmodule Math do
  @moduledoc """
  Provides math-related functions.

  ## Examples

      iex> Math.sum(1, 2)
      3

  """

  @doc """
  Calculates the sum of two numbers.
  """
  def sum(a, b), do: a + b
end
```

- Elixir は読みやすいドキュメントを書くためにヒアドキュメントでマークダウンを使える
- ヒアドキュメントは 最初と最後を3つのダブルクォートでくくること
- コンパイルされたモジュール IEx から直接ドキュメントへアクセスすることができる

``` elixir
$ elixirc math.ex
$ iex
Erlang/OTP 18 [erts-7.3] [source] [64-bit] [smp:8:8] [async-threads:10] [hipe] [kernel-poll:false] [dtrace]

Interactive Elixir (1.2.5) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> h Math

                                      Math

Provides math-related functions.

Examples

┃ iex> Math.sum(1, 2)
┃ 3

iex(2)> h Math.sum

                                 def sum(a, b)

Calculates the sum of two numbers.
```

- ExDoc と呼ばれるドキュメントからHTMLページを生成するためのツールも提供している

- Elixir 開発者はモジュールのattributeを定数として使う

``` elixir
defmodule MyServer do
  @initial_state %{host: "147.0.0.1", port: 3456}
  IO.inspect @initial_state
end
```

- Erlang とちがい、ユーザーが定義したattributeはデフォルトではモジュールに保存されない
- 値はコンパイル時のみ存在する
- 定義されていないattributeへアクセスすると warning が表示される 
- attributeは関数の中で読める

``` elixir
defmodule MyServer do
  @my_data 14
  def first_data, do: @my_data
  @my_data 13
  def second_data, do: @my_data
end

MyServer.first_data #=> 14
MyServer.second_data #=> 13
```

- 関数の内部でattributeを読むときは現在のスナップショットの値を取る
- つまり値は動かす時ではなくコンパイルするときに読み込まれる
