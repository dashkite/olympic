import { equal } from "./wildcard"

overlap = ( target, substring ) ->
  n = target.length - substring.length
  if n >= 0
    k = target[ 0 .. n ].findIndex ( a, i ) ->
      substring.every ( b, j ) -> equal target[ i + j ], b
    if k >= 0
      [
        ( if k > 0 then target[ 0 .. ( k - 1 )] else [])
        ( target[ k .. ( k - 1 + substring.length )])
        target[( k + substring.length ) .. ]
      ]

export { overlap }