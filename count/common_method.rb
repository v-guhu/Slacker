
def prefix_zero integer

  if integer < 10
    '0' + integer.to_s
  else
    integer.to_s
  end

end