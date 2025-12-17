import assert from "@dashkite/assert"
import {test, success} from "@dashkite/amen"
import print from "@dashkite/amen-console"

import { Forward, Backward } from "../src"
import { tokens } from "../src/helpers/tokens"

do ->

  print await test "Olympic", do ->

    rules = [
      tokens "a b x c"
      tokens "c y d"
      tokens "d z e"
      tokens "a d w f"
    ]      
  
    [

      test "forward chaining", ->

        program = tokens "a a b x y"

        forward = Forward.make rules
        assert.deepEqual ( stack = forward.compile program ), [ "a", "d" ]
        assert.deepEqual ( forward.satisfy stack ), [ "z", "w" ]
        assert.deepEqual ( forward.chain program ), [ "z", "w" ]


      test "backward chaining", ->

        backward = Backward.make rules
        assert.deepEqual [ "x", "c" ], backward.chain tokens "y"        
        assert.deepEqual [ "b" ], backward.chain tokens "x y"        
        assert.deepEqual [ "a" ], backward.chain tokens "b x y"
        assert !( backward.chain tokens "a b x y" )?

    ]

  process.exit if success then 0 else 1
