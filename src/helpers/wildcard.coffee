import Generic from "@dashkite/generic"

# Namespace aware comparison

parse = ( name ) ->
  [ first, second ] = name.split "."
  if second? then { ns: first, name: second } else { name: first }

equal = ( a, b ) ->
  if ( a == b ) || ( a == "*" ) || ( b == "*" )
    true
  else if ( a?.includes "." ) && ( b?.includes "." )
    a = parse a
    b = parse b
    ( equal a.name, b.name ) &&
      (( !a.ns? && !b.ns ) ||
        ( equal b.ns, b.ns ))
  else false


isWildcard = ( value ) ->
  ( value == "*" ) ||
    (( value?.includes "." ) && ( value.includes "*" ))

export { equal, isWildcard }