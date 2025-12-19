import { negate } from "@dashkite/joy/predicate"
import { equal, isWildcard } from "./helpers/wildcard"

class Backward

  @make: ( rules ) ->
    Object.assign ( new @ ), { rules }

  @compile: ( rules, program ) ->
    need = []
    while program.length > 0
      [ program..., current ] = program
      rule = rules.find ([ _..., operator, __ ]) ->
        equal operator, current
      need = need[ ... -1 ]
      if rule?
        [ operands..., _, product ] = rule
        need = if product.inverse?
          product.inverse need
        else
          [ need..., operands... ]
    need

  @satisfy: ( rules, need ) ->
    [ _..., target ] = need
    if target?
      operators = rules
        .values()
        .filter ([ _..., product ]) -> equal target, product
        .map ([ _..., operator, __ ]) -> operator
        .toArray()
      seen = new Set
      operands = rules
        .values()
        .flatMap ([ operands..., _, product ]) ->
          [( operands.filter negate isWildcard )..., product ]
        .filter ( operand ) -> 
          if !( seen.has operand )
            seen.add operand
            equal target, operand
          else false
        .toArray()
      [ operators..., operands... ]

  @chain: ( rules, program ) ->
    need = @compile rules, program
    @satisfy rules, need if need?

  compile: ( program ) -> Backward.compile @rules, program

  satisfy: ( stack ) -> Backward.satisfy @rules, stack

  chain: ( program ) -> Backward.chain @rules, program

export { Backward }