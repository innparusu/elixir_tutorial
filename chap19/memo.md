- Sigil は ``~`` 文字から始まり、次に文字、その次にseparatorと続く
- Elixir でよく使われるsigils は 正規表現のための ``~r``

``` elixir
iex(1)> regex = ~r/foo|bar/
~r/foo|bar/
iex(2)> "foo" =~ regex
true
iex(3)> "bar" =~ regex
true
iex(4)> "bat" =~ regex
false
```

- Elixir は PCRE ライブラリで実装されている Perl 互換正規表現を提供している
- ``i`` modifier を使うと正規表現の大小文字を区別しない

``` elixir
iex(5)> "HELLO" =~ ~r/hello/
false
iex(6)> "HELLO" =~ ~r/hello/i
true
```

- Sigil では ``/`` を含んだ8つのseparateをサポートしている

``` elixir
~r/hello/
~r|hello|
~r"hello"
~r'hello'
~r(hello)
~r[hello]
~r{hello}
~r<hello>
```

- 正規表現以外にも3つのSigil を提供している
- ``~s`` は文字列を生成するのに使われる
- ``~c`` は文字リストを生成するのに使われる
- ``~w`` スペースで区切られた語句からリストを生成する

``` elixir
iex(7)> ~s(this is a string with "quotes")
"this is a string with \"quotes\""
iex(9)> ~c(this is a string with "quotes")
'this is a string with "quotes"'
iex(10)> ~w(foo bar bat)
["foo", "bar", "bat"]
```

- ``~w`` は結果のフォーマットを選ぶのに``c``, ``s``, や``a`` modefier を指定できる
    - c は char list
    - s は 文字列
    - a は アトム

``` elixir
iex(11)> ~w(foo bar bat)a
[:foo, :bar, :bat]
iex(12)> ~w(foo bar bat)c
['foo', 'bar', 'bat']
iex(13)> ~w(foo bar bat)s
["foo", "bar", "bat"]
```

- 小文字でのSigil 以外にも大文字のSigilに対応している
- ``~s``はエスケープし、``~S``はエスケープしない

``` elixir
iex(14)> ~s(String with escape codes \x26 interpolation)
"String with escape codes & interpolation"
iex(15)> ~S(String without escape codes and without #{interpolation})
"String without escape codes and without \#{interpolation}"
```

- Sigilは3つ連続した``'``, ``"`` で区切られたヒアドキュメントにも対応している

``` elixir
iex(16)> ~s"""
...(16)> this is
...(16)> a hoge
...(16)> """
"this is\na hoge\n"
```

- ドキュメントを書くときにSigilによるヒアドキュメントがよく使われる
    - エスケープ文字を書きたい場合、幾つかの文字で二重にエスケープが必要になるため、ミスしやすいため、ヒアドキュメントを使う
- Elixr のSigil は拡張が可能
    - 実際 ``~r/foo/i`` は関数 ``sigil_r`` を2つの引数で呼び出しているのと同じこと

``` elixir
iex(20)> sigil_r(<<"foo">>, 'i')
~r/foo/i
```

- つまり ``~r`` についてのドキュメントは ``sigil_r`` を通じてアクセスする
- Sigil は特定の関数を実装することで用意できる
 
``` elixir
iex(23)> defmodule MySigils do
...(23)> def sigil_i(string, []), do: String.to_integer(string)
...(23)> end
{:module, MySigils,
 <<70, 79, 82, 49, 0, 0, 5, 44, 66, 69, 65, 77, 69, 120, 68, 99, 0, 0, 0, 172, 131, 104, 2, 100, 0, 14, 101, 108, 105, 120, 105, 114, 95, 100, 111, 99, 115, 95, 118, 49, 108, 0, 0, 0, 4, 104, 2, ...>>,
 {:sigil_i, 2}}
iex(24)> import MySigils
nil
iex(25)> ~i(13)
13
iex(26)> ~i(30)
30
```

- Sigil はマクロの助けを借りてコンパイル時に使われることもできる
- 例えば Elixir の正規表現はソースコードのコンパイル時に効率のよい形へとコンパイルされる
    - そうすると、動作時にそのステップを省略できる
