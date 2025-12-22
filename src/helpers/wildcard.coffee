parse = ( name ) ->
  [ first, second ] = name.split "."
  if second? then { ns: first, name: second } else { name: first }

hasNamespace = ( value ) -> value?.includes "."

isWildcard = ( value ) ->
  ( value == "*" ) ||
    (( value?.includes "*." ) || 
      ( value.includes ".*" ))

equal = ( a, b ) ->
  if ( a == b ) || ( a == "*" ) || ( b == "*" )
    true
  else if ( hasNamespace a ) && ( hasNamespace b )
    a = parse a
    b = parse b
    ( equal a.name, b.name ) && ( equal b.ns, b.ns )
  else false

export { equal, isWildcard, hasNamespace }