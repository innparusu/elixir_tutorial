- Elixir ではすべてのコードはプロセスの内部で動く
- プロセス同士は独立、平行して動き、メッセージパッシングでやり取りする
- プロセスはElixirにおける並行の基本となるばかりではなく、分散や高可用なプログラムの構築にも役立つ
- Elixir のプロセスは OSのプロセスとは別物
- プロセスは他のプログラミング言語ににおけるスレッドとは異なりメモリやCPUにとって非常に軽量
- 同時に動作する数千のプロセスを保持することは珍しいことではない

- 新しいプロセスを生み出すためには関数``spawan/1``を使う
- ``spawan/1``はPIDを返す
- ここで生み出したプロセスは与えられた関数を実行し、終わったら終了する

``` elixir
iex> pid = spawn fn -> 1 + 2 end
#PID<0.44.0>
iex> Process.alive?(pid)
false
```

- ``self/0`` を呼ぶことで今動いているPIDを入手できる

``` elixir
iex(9)> self()
#PID<0.57.0>
iex(10)> Process.alive?(self())
true
```

- ``send/2`` を使ってプロセスへメッセージを送り、``receive/1``を使って受け取ることができる
- メッセージがプロセスから送られてくると、メッセージはプロセスのメールボックスへ保存される
- ``receive/1``ブロックは与えられたパターンにマッチするいずれかのメッセージの現在のプロセスのメールボックスから探す
- ``receive/1`` はパターンマッチ可能

``` elixir
iex(1)> send self(), {:hello, "world"}
{:hello, "world"}
iex(2)> receive do
...(2)> {:hello, msg} -> msg
...(2)> {:world, msg} -> "won't match"
...(2)> end
```

- パターンにマッチするメッセージがメールボックスになければ、現在のプロセスはマッチするメッセージが来るまで待ち続ける
- タイムアウトを指定することもできる

``` elixir
iex(1)> receive do
...(1)> {:hello, msg} -> msg
...(1)> after
...(1)> 1_000 -> "nothing after 1s"
...(1)> end
"nothing after 1s"
```

``` elixir
iex(2)> parent = self()
#PID<0.57.0>
iex(3)> spawn fn -> send(parent, {:hello, self()}) end
#PID<0.65.0>
iex(4)> receive do
...(4)> {:hello, pid} -> "Got hello from #{inspect pid}"
...(4)> end
"Got hello from #PID<0.65.0>"
```

- ``flush/0`` はメールボックスにあるすべてのメッセージを表示し、空にする

``` elixir
iex(8)> send self(), :hello
:hello
iex(9)> flush()
:hello
:ok
```

- Elixir でspawan するときに一番良く使われるのは``spawan_link/1``を経由するもの
- プロセスが失敗した時、単にエラーを表示するだけで生み出した方のプロセスが依然動いている
- なぜならプロセス同士は独立しているため
- あるプロセスでの失敗を他のプロセスへ伝搬させたければ``spawn_link/1``を使うべき

``` elixir
iex(12)> spawn fn -> raise "oops" end
#PID<0.78.0>

00:53:15.458 [error] Process #PID<0.78.0> raised an exception
** (RuntimeError) oops
    :erlang.apply/2
```

- span_link を使用した場合、リンクしているので親プロセスも落ちる

``` elixir
# spawn.exs
spawn_link fn -> raise "oops" end

receive do
  :hello -> "let's wait until the process fails"
end
```

-  プロセスとリンクは可用性の高いシステム(フォールドトレラント)を構築するのに大事な役割をになっている
- Elixir のアプリケーションはプロセスが死んでしまった際に検知し、同じ場所で新しいプロセスを動かすために、作るプロセスとスーパーバイザー(監視役)をリンクさせる
    - これができるのはプロセスがデフォルトでは何も共有しないため
- プロセスが独立しているなら、プロセス内での失敗が他のプロセスに影響を及ぼさない
- 他の言語では例外を受け取ったり操作することが求められるが、Elixir ではスーパーバイザーがシステムを再起動してくれるであろうという形式のため、プロセスは失敗したままでも良い

- 状態を保存するにはプロセスを使う

``` elixir
defmodule KV do
  def start_link do
    {:ok, spawn_link(fn -> loop(%{}) end)}
  end

  defp loop(map) do
    receive do
      {:get, key, caller} ->
        send caller, Map.get(map, key)
        loop(map)
      {:put, key, value} ->
        loop(Map.put(map, key, value))
    end
  end
end
```

``` elixir
iex> {:ok, pid} = KV.start_link
#PID<0.62.0>
iex> send pid, {:get, :hello, self()}
{:get, :hello, #PID<0.41.0>}
iex> flush
nil
iex> send pid, {:put, :hello, :world}
#PID<0.62.0>
iex> send pid, {:get, :hello, self()}
{:get, :hello, #PID<0.41.0>}
iex> flush
:world
```

- 上記の通り, pid を知っているどんなプロセスにも、メッセージを送ることができ、状態を操作することができる 
- 名前を与えてpidを登録することもできる
- 状態をもたせ、名前を登録することはよく行われているが、殆どの場合、手で実装することはなく、Elixirが提供している物のどれかを使う
    - 例えば、Elixir は状態を利用する``agents`` という単純な抽象物を提供している

``` elixir
iex(5)> {:ok, pid} = Agent.start_link(fn -> %{} end)
{:ok, #PID<0.68.0>}
iex(6)> Agent.update(pid, fn map -> Map.put(map, :hello, :world) end)
:ok
iex(7)> Agent.get(pid, fn map -> Map.get(map, :hello) end)
:world
```

- ``Agent.start_link/2`` は ``:name`` オプションを渡すことができる
- Elixir は(GenServerと呼ばれる)一般的なサーバー、(GenEventと呼ばれる)一般的なイベント管理と一般的なイベント処理, タスクなど, agent と同じようにプロセスによって実現されているAPIを提供する
