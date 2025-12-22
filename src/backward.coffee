import { negate } from "@dashkite/joy/predicate"
import { equal, isWildcard } from "./helpers/wildcard"

class Backward

  @make: ( rules ) ->
    Object.assign ( new @ ), { rules }

  @compile: ( rules, program, stack = []) ->
    ( @make rules ).compile program, stack

  @satisfy: ( rules, stack ) ->
    ( @make rules ).satisfy stack

  @chain: ( rules, program, stack = []) ->
    ( @make rules ).chain program, stack

  compile: ( program, stack = []) ->
    stack = []
    for token in program.reverse()
      rule = @rules.find ({ operator }) ->
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

  satisfy: ( stack ) ->
    candidates = []
    for rule in @rules
      if rule.raccept stack
        candidates.push rule.operator
    [ rest..., last ] = stack
    if isWildcard last
      operands = new Set
      for rule in @rules when ( equal last, rule.product )
        operands.add rule.product
      [ candidates..., operands... ]
    else
      [ candidates..., last ]

  chain: ( program, stack ) ->
    stack = @compile program, stack
    ( @satisfy stack ) if stack?

export { Backward }