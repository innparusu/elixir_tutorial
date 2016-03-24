- 文字列の結合は``<>``で行える
- ``==`` と ``===`` の違いは後者の方が整数と浮動小数点の比較に厳密
- Elixir では異なる型を比較することができる
```elixir
iex(17)> 1<:atom
true
```
- number < atom < reference < functions < port < pid < tuple < maps < list < bitstring
