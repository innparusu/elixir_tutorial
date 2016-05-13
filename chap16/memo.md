- プロトコルは Elixir で多態を生み出すための機構です(型クラス的な)
- どんなデータ型に対しても、そのデータ型がそのプロトコルを実装すれば処理できる
- Elixir では ``false`` と ``nil`` だけ false として扱われる
- そのため``blank?`` プロトコルを規定することが重要

``` elixir
defprotocol Blank do
  @doc "Return true if data is considered blank/empty
  def blank?(data)
end
```

- このプロトコルは``blank?``と呼ばれる一つの引数を取る関数

``` elixir
# 整数はブランクにならない
defimpl Blank?, for: Integer do
  def blank?(_), do: false
end

# 空リストのときだけブランク
defimpl Blank?, for: List do
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
```

- 元々あるすべてのデータ型について同じようにしていく
- 型はこれだけある
    - Atom
    - BitString
    - Float
    - Function
    - Integer
    - List
    - Map
    - PID
    - Port
    - Reference
    - Tuple
- プロトコルを定義、実装すると呼び出すことが可能

``` elixir
iex(1)> Blank.blank?(0)
false
iex(2)> Blank.blank?([])
true
iex(3)> Blank.blank?([1,2,3])
false
# 実装してないデータ型を渡すとエラーが発生
iex(4)> Blank.blank?("hello")
** (Protocol.UndefinedError) protocol Blank not implemented for "hello"
```

- Elixir の拡張性はプロトコルと構造体が一緒に使われた時に効果を発揮する
- 構造体はマップであるが、プロトコルの実装はmapと共有していない

``` elixir
iex(4)> defmodule User do
...(4)> defstruct name: "john", age: 27
...(4)> end
{:module, User,
 <<70, 79, 82, 49, 0, 0, 5, 52, 66, 69, 65, 77, 69, 120, 68, 99, 0, 0, 0, 133, 131, 104, 2, 100, 0, 14, 101, 108, 105, 120, 105, 114, 95, 100, 111, 99, 115, 95, 118, 49, 108, 0, 0, 0, 4, 104, 2, ...>>,
 %User{age: 27, name: "john"}}
iex(5)> Blank.blank?(%{})
true
iex(6)> Blank.blank?(%User{})
** (Protocol.UndefinedError) protocol Blank not implemented for %User{age: 27, name: "john"}
    blank.ex:1: Blank.impl_for!/1
    blank.ex:3: Blank.blank?/1
```

- 構造体は自身でプロトコルを実装する必要がある

``` elixir
defimpl Blank, for: User do
  def blank?(_), do: false
end
```
- すべての型のためのデフォルトの実装を行うにはプロトコル定義の中で``@fallback_to_any`` を ``true`` に設定することでできるようになる

``` elixir
defprotocol Blank do
  @doc "Return true if data is considered blank/empty"
  @fallback_to_any true
  def blank?(data)
end
```

- そしてこのように実装できる

``` elixir
defimpl Blank, for: Any do
  def blank?(_) do: false
end
```

- Elixir にはいくつかの組み込みプロトコルがある
    - map と reduce を定義してる色々便利な ``Enum``
    - ``to_string`` を定義している(文字のあるデータ構造をどのような文字列に変換するかを規定) ``String.Chars``
        - Elixr の埋め込み文字列も関数 ``to_string`` を読んでる
    - ``Inspect`` プロトコルの関数``inspect`` はtupleなどの複雑な構造を文字列で表示できる
    - iex で結果を表示するのにも ``Inspect``プロトコルを使っている
    - 表示された値が``#``で始まるときはElixirの構文ではない方法でデータ構造を表している
        -  つまり検査したプロトコル情報が一部失われることがあるため、その情報からは元に戻せない
