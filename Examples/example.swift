// @{Maths
//  @description This module contains maths related functions
//  It is still a work in progress, but you can expect to have the
//  following features when it is done:
//    - simple maths.
//    - geometry.

/**
  @{add
    @summary Adds two integers together.
    
    @[params
      @a Int
      @b Int
    @]

    @^return int The sum of the two numbers a and b.
  @}
*/
func add(_ a: Int, _ b: Int) -> Int {
  return a + b;
}

/**
  @{mul
    @summary Multiply two integers together
    
    @[params
      @^firstNumber a Int
      @^secondNumber b Int
    @]

    @^return int The result of the multiplication between a and b.
  @}
*/
func mul(firstNumber a: Int, withSecondNumber b: Int) -> Int {
  return a * b;
}
//@}Maths