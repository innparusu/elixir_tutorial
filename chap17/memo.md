- アトムへ数を足そうとすると、エラーの例をみることができる

``` elixir
iex(14)> :foo+1
** (ArithmeticError) bad argument in arithmetic expression
    :erlang.+(:foo, 1)
```

- runtime errorは``raise/1`` マクロを使うことで何時でも起こせる

``` elixir
Interactive Elixir (1.2.6) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> raise "oops"
** (RuntimeError) oops
```

- 他のエラーは``raise/2``にエラーの名前とキーワード引数のリストを渡すことで起こせる

``` elixir
iex(3)> raise ArgumentError, message: "invalid argument foo"
** (ArgumentError) invalid argument foo
```

- モジュールをつくり、その中で``defexception/1``マクロを使うと自分でエラーを定義できる

``` elixir
iex(3)> defmodule MyError do
...(3)> defexception message: "default message"
...(3)> end
{:module, MyError,
 <<70, 79, 82, 49, 0, 0, 8, 56, 66, 69, 65, 77, 69, 120, 68, 99, 0, 0, 0, 243, 131, 104, 2, 100, 0, 14, 101, 108, 105, 120, 105, 114, 95, 100, 111, 99, 115, 95, 118, 49, 108, 0, 0, 0, 4, 104, 2, ...>>,
 :ok}
iex(4)> raise MyError
** (MyError) default message

iex(4)> raise MyError, message: "custom message"
** (MyError) custom message
```

- 例外は ``try/resuce`` 構造で拾うことができる

``` elixir
iex(4)> try do
...(4)> raise "oops"
...(4)> rescue
...(4)> e in RuntimeError -> e
...(4)> end
%RuntimeError{message: "oops"}
```

- 実際の所 Elixir では``try/rescue`` 構造を使うことはほとんどない
- 例 ファイルを開けなかった時のエラー
    - 多くの言語はファイルを開けなかった時はエラーになる
    - Elixir での関数``File.read/1``はファイルを開くのに成功した/失敗した情報を含んだtupleを返す

``` elixir
iex(5)> File.read "hello"
{:error, :enoent}
iex(6)> File.write "hello", "world"
:ok
iex(7)> File.read "hello"
{:ok, "world"}
```

- ファイルを開くときに起こる複数の結果に対応したい場合、``case``を使ってパターンマッチングする

``` elixir
iex(8)> case File.read "hello" do
...(8)>  {:ok, body} -> IO.puts "got ok"
...(8)> {:error, body} -> IO.puts "got error"
...(8)> end
```

- 最終的にファイルを開いた時に例外にするかどうかは自分で決める
    - なぜならElixir では多くの関数が例外を出さないため
- ``File.read!/1``はエラーを吐く

``` elixir
iex(9)> File.read! "unknown"
** (File.Error) could not read file unknown: no such file or directory
    (elixir) lib/file.ex:244: File.read!/1
```

- ``try/rescue`` を避けるのはフロー制御のためにエラーを利用しないため
- Elixir ではエラーを期待していない、あるいは例外的な状況のために用意している
- フロー制御が必要な場合、throwが使われなければならない

- Elixir では後で取れるように値を投げることができる
- ``throw`` と ``catch`` がないと値が取れないような状況のために ``throw``と``catch``は予約されている
- 例 13の倍数になるような最初の数を見つけたい時

``` elixir
iex(9)> try do
...(9)> Enum.each -50..50, fn(x) ->
...(9)> if rem(x, 13) == 0, do: throw(x)
...(9)> end
...(9)> "Got nothing"
...(9)> catch
...(9)> x -> "Got #{x}"
...(9)> end
"Got -39"
```

- 実際には``Enum.find/2``を使ったほうがシンプル

``` elixir
iex(10)> Enum.find -50..50, &(rem(&1,13)==0)
-39
```

- Elixir はプロセスが死んだ時``exit``を送る
- プロセスは明示的にexit を送ることで殺せる
- 例 リンクしていたプロセスを``exit``信号と1という値を送って殺す
    - Elixir のシェルはそのメッセージを自動的に受け取って端末に表示

``` elixir
iex(11)> spawn_link fn -> exit(1) end
** (EXIT from #PID<0.57.0>) 1
```

- ``exit`` は ``try/catch`` を使うことでキャッチされる

``` elixir
iex(1)> try do
...(1)> exit "I am exiting"
...(1)> catch
...(1)> :exit, _ -> "not really"
...(1)> end
"not really"
```

- 特定の動作をした後に色々したい場合は ``try/after`` が利用される
- 例 ファイルを開いた時、必ず閉じることを``try/after``で保証する

``` elixir
iex(3)> try do
...(3)> IO.write file, "ola"
...(3)> raise "oops, something went wrong"
...(3)> after
...(3)> File.close(file)
...(3)> end
** (RuntimeError) oops, something went wrong
```
 
- ``try/catch/rescue/after`` ブロックの中で定義した変数は外では見えない
- これは``try``ブロックが失敗するかもしれず、その時変数が最初の場所で絶対に束縛されない事がありうるため

``` elixir
iex(3)> try do
...(3)> from_try = true
...(3)> after
...(3)> from_after = true
...(3)> end
true
iex(4)> from_try
** (CompileError) iex:4: undefined function from_try/0
iex(4)> from_after
** (CompileError) iex:4: undefined function from_after/0
```
