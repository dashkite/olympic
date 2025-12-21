import { equal } from "./helpers/wildcard"

class Forward

  @make: ( rules ) ->
    Object.assign ( new @ ), { rules }

  @compile: ( rules, program, stack = []) ->
    for token in program
      rule = rules.find ({ operator }) -> 
        equal token, operator
      if rule?
        if rule.accept stack
          stack = rule.apply stack
        else returned undefined
      else stack.push token
    stack

  @satisfy: ( rules, stack ) ->
    candidates = []
    for rule in rules
      if rule.accept stack
        candidates.push rule.operator
    candidates

  @chain: ( rules, program, stack = []) ->
    stack = @compile rules, program, stack
    ( @satisfy rules, stack ) if stack?

  compile: ( program, stack = []) -> 
    Forward.compile @rules, program, stack

  satisfy: ( stack ) -> Forward.satisfy @rules, stack

  chain: ( program, stack = []) -> 
    Forward.chain @rules, program, stack

export { Forward }