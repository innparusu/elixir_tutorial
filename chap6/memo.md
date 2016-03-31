- Elixirは?を使うとコードポイントの値を得る

``` elixir
iex(13)> ?a
97
iex(14)> ?ほ
12411
iex(15)> ?b
98
iex(16)> ?c
99
iex(17)> ?d
100
```

- binaryを<<>> を使って定義することができる

``` elixir
iex(21)> <<0,1,2,3>>
<<0, 1, 2, 3>>
iex(22)> byte_size <<0,1,2,3>>
4
```

- 文字列の結合操作はbinaryの結合操作
- nullバイト<<0>> を結合させて文字列のバイナリ表現を見る

``` elixir
iex(25)> <<0, 1>> <> <<2, 3>>
<<0, 1, 2, 3>>
iex(26)> "hello" <> <<0>>
<<104, 101, 108, 108, 111, 0>>
```

- (複数の)バイナリは255より大きい数を保持したり，コードポイントからUTF8表現へ変換したりできる

``` elixir
iex(29)> <<255>>
<<255>>
iex(30)> <<256>>
<<0>>
iex(31)> <<256 :: size(16)>>
<<1, 0>>
iex(32)> <<256 :: size(32)>>
<<0, 0, 1, 0>>
iex(33)> <<256 :: utf8>>
"Ā"
iex(34)> <<256 :: utf8, 0>>
<<196, 128, 0>>
```

- もしバイトが8ビットなら1ビットを渡した場合、binaryではないが、ビット列になる
- つまりbinaryとは8で割り切れるビット列のこと

``` elixir
iex(35)> <<1 :: size(1)>>
<<1::size(1)>>
iex(36)> <<2 :: size(1)>>
<<0::size(1)>>
iex(37)> is_binary(<<1 :: size(1)>>)
false
iex(38)> is_bitstring(<<1 :: size(1)>>)
true
iex(39)> bit_size(<<1 :: size(1)>>)
1
```

- binary/ビット列にもパターンマッチできる

``` elixir
iex(46)> <<0, 1, x>> = <<0, 1, 2>>
<<0, 1, 2>>
iex(47)> x
2
iex(48)> <<0, 1, x>> = <<0, 1, 2,3>>
** (MatchError) no match of right hand side value: <<0, 1, 2, 3>>
```

- binary 修飾子を使うことで残りへマッチさせることができる

``` elixir
iex(64)> <<0,1,x::binary>> = <<0,1,2,3>>
<<0, 1, 2, 3>>
iex(65)> x
<<2, 3>>
```

- 上記のパターンは<>の結果に似ている

``` elixir
iex(66)> "he"<>rest = "hello"
"hello"
iex(67)> rest
"llo"
```

- 文字リストは文字のリストでしかない
- シングルクォートで囲まれた文字列はバイト列の代わりにコードポイントのリストを含んでいる(iexではASCIIの範囲より外にある文字を含んでいるとコードポイントの数字しか表示しない)
- ダブルクォートで囲まれたものは文字列(binary)で、シングルクォートで囲まれたものは文字のリスト

``` elixir
iex(1)> 'hełło'
[104, 101, 322, 322, 111]
iex(2)> is_list 'hełło'
true
iex(4)> 'hello'
'hello'
```

- 文字リストははとんどErlang とのinterface , 特にbinaryを引数に取れない古いLibraryに使われる
- to_string/ や to_char_list/1 を使うと文字リストを文字列に変換したり逆のことができる

``` elixir
iex(5)> to_char_list "hello"
'hello'
iex(6)> to_char_list "hełło"
[104, 101, 322, 322, 111]
iex(7)> to_string 'hełło'
"hełło"
iex(8)> to_string :hello
"hello"
iex(9)> to_string 1
"1"
```
