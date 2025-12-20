import { overlap } from "./helpers/overlap"

class Forward

  @make: ( rules ) ->
    Object.assign ( new @ ), { rules }

  @compile: ( rules, program, stack = []) ->
    while ( program.length > 0 )
      for [ conditions..., action ] in rules
        if ( match = overlap [ stack..., program... ], conditions )?
          [ prefix, _, suffix ] = match
          stack = if action.apply?
            action stack
          else
            [ prefix..., action ]
          program = suffix
          break
      break unless match
    stack if program.length == 0

  @satisfy: ( rules, stack ) ->
    candidates = []
    for [ operands..., operator, product ] in rules
      if ( match = overlap stack, operands )?
        candidates.push operator        
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