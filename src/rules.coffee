import { equal, isWildcard } from "./helpers/wildcard"

Rules =

  operands: ( rules ) ->
    operands = new Set
    for rule in rules
      for operand in [ rule.operands..., rule.product ]
        if isWildcard operand
          for matched in ( Rules.expand rules, operand )
            operands.add matched
        else
          operands.add operand
    Array.from operands

  expand: ( rules, target ) ->
    operands = new Set
    for rule in rules
      for operand in [ rule.operands..., rule.product ]
        if !( isWildcard operand ) && ( equal target, operand )
          operands.add operand
    Array.from operands

export { Rules }