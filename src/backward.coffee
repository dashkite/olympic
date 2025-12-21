import { negate } from "@dashkite/joy/predicate"
import { equal, isWildcard } from "./helpers/wildcard"

class Backward

  @make: ( rules ) ->
    Object.assign ( new @ ), { rules }

  @compile: ( rules, program ) ->
    stack = []
    for token in program.reverse()
      rule = rules.find ({ operator }) ->
        equal token, operator
      if rule?
        if rule.raccept stack
          stack = rule.rapply stack
        else return undefined
      else
        [ rest..., last ] = stack
        if equal token, last
          stack = rest
        else return undefined
    stack

  @satisfy: ( rules, stack ) ->
    candidates = []
    for rule in rules
      if rule.raccept stack
        candidates.push rule.operator
    [ rest..., last ] = stack
    if isWildcard last
      operands = new Set
      for rule in rules when ( equal last, rule.product )
        operands.add rule.product
      [ candidates..., operands... ]
    else
      [ candidates..., last ]

  @chain: ( rules, program ) ->
    need = @compile rules, program
    @satisfy rules, need if need?

  compile: ( program ) -> Backward.compile @rules, program

  satisfy: ( stack ) -> Backward.satisfy @rules, stack

  chain: ( program ) -> Backward.chain @rules, program

export { Backward }