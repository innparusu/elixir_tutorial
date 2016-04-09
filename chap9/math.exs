defmodule Math do
  def sum_list([head|tail], accumulator) do
    sum_list(tail, head + accumulator)
  end

  def sum_list([], accumulator) do
    accumulator
  end

  def double_each([head|tail]) do
    [head * 2|double_each(tail)]
  end

  def double_each([]) do 
    []
  end
end

Math.sum_list([1,2,3], 0) #=> 6
Math.double_each([1,2,3]) #=> [2,4,6]
