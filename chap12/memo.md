``` elixir
iex(1)> IO.puts "hello world"
hello world
:ok
iex(2)> IO.gets"yer or no?"
yer or no?yes
"yes\n"
iex(7)> IO.puts :stderr, "hello world"
hello world
:ok
```

- ファイルを開くにはFileモジュールを使う
- デフォルトではファイルはbinaryモードで開かれる

``` elixir
iex(3)> {:ok, file} = File.open "hello", [:write]
{:ok, #PID<0.61.0>}
iex(4)> IO.binwrite file, "world"
:ok
iex(5)> File.close file
:ok
iex(6)> File.read "hello"
{:ok, "world"}
```

- ファイルを:utf8エンコーディングで開くことができる
- エンコーディングの指定はIOモジュールの他の関数でも使える

``` elixir
iex(8)> {:ok, file} = File.open "hello", [:write, :utf8]
{:ok, #PID<0.67.0>}
```

- ファイルを開いたり、読み書きする関数についてはFileモジュールがファイルシステム条で動く関数をたくさん持っている
- File.rm/1 はファイルを削除する
- File.mkdir/1 はディレクトリを作る
- ``File.mkdir_p/1`` は mkdir -p 的な奴
- ``File.cp_r/2``, ``File.rm_rf/2`` は cp -r , rm -rf 的な奴
- Fileモジュールの関数は2種類の習慣がある
    - !(バンと読む) つきのもの
    - つかないもの

``` elixir
iex(4)> File.read "hello"
{:ok, "world"}
iex(5)> File.read! "hello"
"world"
iex(6)> File.read "unknown"
{:error, :enoent}
iex(7)> File.read! "unknown"
** (File.Error) could not read file unknown: no such file or directory
    (elixir) lib/file.ex:244: File.read!/1
```

- ! が付いたversionはファイルがない場合エラーが発生する
- つまり!のつかないversionはパターンマッチングを利用して異なる形式の結果を取り扱おうとするときに選ぶ

``` elixir
# こうは書かない
{:ok, file} = File.read("hoge")

# こう書くべき
case  File.read ("hoge") do
    {:ok, body} -> # handle ok
    {:error, r} -> # handle error
end
# または
File.read! ("hoge")
```

- Path はバイナリーであり、Pathモジュールで操作できる

``` elixir
iex(1)> Path.join("foo", "bar")
"foo/bar"
iex(2)> Path.expand("~/hello")
"/Users/e125716/hello"
```

- File.open/2 が PIDを含んだtupleを返すのは、 入出力モジュールがプロセス内で実際に動いている為
- ``IO.write(pid, binary)`` とかくと、 入出力モジュールはメッセージをやりたい操作と共にプロセスへ送る

- 自身のプロセスを使った場合
``` elixir
iex(4)> pid = spawn fn ->
...(4)> receive do: (msg -> IO.inspect msg)
...(4)> end
#PID<0.68.0>
iex(5)> IO.write(pid, "hello")
{:io_request, #PID<0.57.0>, #Reference<0.0.8.102>,
 {:put_chars, :unicode, "hello"}}
** (ErlangError) erlang error: :terminated
    (stdlib) :io.put_chars(#PID<0.68.0>, :unicode, "hello")
```

- ``IO.write/2`` のあと、 入出力モジュールへ表示したい内容が送られている
- 次に入出力モジュールが何か結果を期待した時点で失敗している(入出力デバイスを供給していないため)
- ``StringIO`` モジュールは文字列で入出力デバイスのメッセージを実装したものを提供する

``` elixir
iex(5)> {:ok, pid} = StringIO.open("hello")
{:ok, #PID<0.71.0>}
iex(6)> IO.read(pid, 2)
"he"
```

- 入出力デバイス とプロセスをモデル化することで, Erlang VM は同じネットワークの異なるノード間でファイルプロセスを交換し，どちらのノードであってもファイルの読み書きができる
- すべての入力デバイスで、どのプロセスにも一つだけグループリーダーと呼ばれる特別なものがある
- ``:stdio`` と書いた場合、実際にはメッセージをグループリーダーへ送っている。 グループリーダーはSTDIO ファイルディスクリプタに書き込む
- グループリーダーはプロセス毎に設定でき、 異なる状況で利用される
- ファイルがエンコーディングなしで開かれたら、ファイルはrawモードを期待しており, IO モジュールの関数は必ず ``bin*`` で始まるものが使われる
- それらの関数は引数として ``iodata`` を期待する。つまりバイト及びbinaryからなるリストが渡されることを期待している
- 一方で ``:stdio`` と ``:utf8`` のエンコーディングを指定して開いたファイルはIOモジュールの残りの関数で動き，引数として ``char_data`` を期待している. つまり文字と文字列からなるリストが渡されることを期待している.
