import { equal } from "./helpers/wildcard"
import { Rules } from "./rules"

class Forward

  @make: ( rules ) ->
    Object.assign ( new @ ), { rules }

  @compile: ( rules, program, stack = []) ->
    ( @make rules ).compile program, stack

  @satisfy: ( rules, stack ) ->
    ( @make rules ).chain stack

  @chain: ( rules, program, stack = []) ->
    ( @make rules ).chain program, stack 

  compile: ( program, stack = []) -> 
    for token in program
      rule = @rules.find ({ operator }) -> 
        equal token, operator
      if rule?
        if rule.accept stack
          stack = rule.apply stack
        else returned undefined
      else stack.push token
    stack

  satisfy: ( stack ) ->
    candidates = []
    for rule in @rules
      if rule.accept stack
        candidates.push rule.operator
    @operands ?= Rules.operands @rules
    [ candidates..., @operands... ]

  chain: ( program, stack = []) -> 
    stack = @compile program, stack
    ( @satisfy stack ) if stack?

export { Forward }