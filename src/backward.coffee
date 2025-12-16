class Backward

  @make: ( rules ) ->
    Object.assign ( new @ ), { rules }

  @compile: ( rules, program ) ->
    need = []
    while program.length > 0
      [ program..., current ] = program
      rule = do ->
        rules
          .find ([ operands..., operator, product ]) ->
            operator == current
      need = need[ ... -1 ]
      if rule?
        [ operands..., _, __ ] = rule
        need = [ need..., operands... ]
    need

  @satisfy: ( rules, need ) ->
    [ _..., target ] = need
    if target?
      rule = rules.find ([ _..., product ]) -> target == product
      if rule?
        [ _..., operator, __ ] = rule
        operator
      else target

  @chain: ( rules, program ) ->
    need = @compile rules, program
    @satisfy rules, need

  compile: ( program ) -> Backward.compile @rules, program

  satisfy: ( stack ) -> Backward.satisfy @rules, stack

  chain: ( program ) -> Backward.chain @rules, program

export { Backward }