- Elixir は以下をよく行う
    - 列挙を繰り返す
    - 結果をフィルタリングする
    - 別の値のリストへとマッピングする
- 内包表記はそうした構造のsyntax sugar になっている
    - ``for`` でそれらの一般的なタスクをまとめている

``` elixir
iex(1)> for n <- [1,2,3,4], do: n*n
[1, 4, 9, 16]
```

- リスト内表記は Generators, Filters, collectables で、できている

- 上の式での ``n<-[1,2,3,4]`` が Generators
    - これはリスト内包表記で使われる値を生成する
    - 列挙可能なのもなら何でも渡せる

``` elixir
iex(2)> for n <- 1..4, do: n*n
[1, 4, 9, 16]
```

- Generator はパターンマッチングにも対応している
- マッチしなかった全てのパターンを無視できる


``` elixir
iex(4)> values = [good: 1, good: 2, bad: 3, good: 4]
[good: 1, good: 2, bad: 3, good: 4]
iex(5)> for {:good, n} <- values, do: n * n
[1, 4, 16]
```

- 幾つかの目的になった要素だけを通すのには Filter を利用することもできる
- filter は nil, false 以外を通す

``` elixir
iex(7)> for n <- 1..4, Integer.is_odd(n), do: n * n
[1, 9]
```

- 内包表記には複数のGenerator と filter を与えることができる
- リスト内表記の中の変数はリスト内表記の外側には影響を及ぼさない

``` elixir
# ディレクトリのリストを受け取って、それらのディレクトリにあるすべてのファイルを削除する例
for dir <- dirs,
    file <- File.ls!(dir),
    path = Path.join(dir, file),
    File.regular?(path) do
 File.rm!(path)
end
```

- bitstring の stream を用意したい時でも Generator は使える

``` elixir
iex(1)> pixels = <<213, 45, 132, 64, 76, 32, 76, 0, 0, 234, 32, 15>>
<<213, 45, 132, 64, 76, 32, 76, 0, 0, 234, 32, 15>>
iex(2)>  for <<r::8, g::8, b::8 <- pixels>>, do: {r, g, b}
[{213, 45, 132}, {64, 76, 32}, {76, 0, 0}, {234, 32, 15}]
```
- 内部表記は結果としてリストを返す
- ``:into`` オプションを渡すことで、内包表記の結果を異なるデータ型へと挿入することができる

``` elixir
iex(3)> for << c <- " hello world">>, c != ?\s, into: "", do: <<c>>
"helloworld"
```

- set,map 他のディクショナリにも``:into`` オプションを渡せる
- 大抵の場合は ``:into`` は ``Collecatble`` プロトコルを実装してさえいればどんなものでも受け付ける
- 例えばIOモジュールはストリームを提供し、streamはEnumerableでかつCollectable
- そのため、内包表記を使って何でもタイプしたものを大文字にして返すエコー端末を実装することができる

``` elixir
iex(5)> for line <- stream, into: stream do
...(5)>  String.upcase(line) <> "\n"
...(5)> end
hoge
HOGE

huga
HUGA
```

