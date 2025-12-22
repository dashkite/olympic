import { equal } from "./helpers/wildcard"
import { tokens } from "./helpers/tokens"

class Rule

class SimpleRule extends Rule

  @parse: ( string ) ->
    [ operands..., operator, product ] = tokens string
    { operands, operator, product } 

  @make: ( string ) ->
    Object.assign ( new  @ ), @parse string
      
  accept: ( stack ) ->
    (( j = stack.length - @operands.length ) >= 0 ) &&
      @operands.every ( operand, i ) ->
        equal operand, stack[ i + j ]

  apply: ( stack ) ->
    k = @operands.length
    [
      stack[ ... -k ]...
      @product
    ]

  raccept: ([ rest..., last ]) ->
    !last? || ( equal @product, last )

  rapply: ([ rest..., _ ]) ->
    [ rest..., @operands... ]

rule = ( string ) -> SimpleRule.make string

mixin = ( string ) ->
  class extends SimpleRule
    @make: ->
      Object.assign ( new  @ ), 
        @parse string

export { Rule, SimpleRule, rule, mixin }