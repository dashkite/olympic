class Backward

  @make: ( rules ) ->
    Object.assign ( new @ ), { rules }

  @compile: ( rules, program ) ->
    need = []
    while program.length > 0
      [ program..., current ] = program
      rule = rules.find ([ _..., operator, __ ]) ->
        operator == current
      need = need[ ... -1 ]
      if rule?
        [ operands..., _, __ ] = rule
        need = [ need..., operands... ]
    need

  @satisfy: ( rules, need ) ->
    [ _..., target ] = need
    if target?
      result = rules
        .values()
        .filter ([ _..., product ]) -> target == product
        .map ([ _..., operator, __ ]) -> operator
        .toArray()
      result.push target
      result

  @chain: ( rules, program ) ->
    need = @compile rules, program
    @satisfy rules, need if need?

  compile: ( program ) -> Backward.compile @rules, program

  satisfy: ( stack ) -> Backward.satisfy @rules, stack

  chain: ( program ) -> Backward.chain @rules, program

export { Backward }