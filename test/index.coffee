import assert from "@dashkite/assert"
import {test, success} from "@dashkite/amen"
import print from "@dashkite/amen-console"

import { Forward, Backward } from "../src"
import { tokens } from "../src/helpers/tokens"
import { equal } from "../src/helpers/wildcard"

do ->

  print await test "Olympic", [

    test "wildcards", ->
      assert equal "foo", "foo"
      assert !( equal "foo", "bar" )
      assert !( equal "foo.bar", "bar" )
      assert !( equal "foo", "foo.bar" )
      assert equal "foo.bar", "foo.bar"
      assert equal "*.bar", "foo.bar"
      assert equal "foo.bar", "*.bar"
      assert equal "foo.*", "foo.bar"
      assert equal "foo.bar", "foo.*"
      assert equal "*.bar", "foo.*"
      assert !( equal "foo.bar", "*.baz" )
      assert equal "*.bar", "*.*"
      assert equal "foo.bar", "*"


    test "chaining, without wildcards", do ->

      rules = [
        tokens "a b x c"
        tokens "c y d"
        tokens "d z e"
        tokens "a d w f"
      ]      

      [

        test "forward", ->

          program = tokens "a a b x y"

          forward = Forward.make rules
          assert.deepEqual ( stack = forward.compile program ), [ "a", "d" ]
          assert.deepEqual ( forward.satisfy stack ), [ "z", "w" ]
          assert.deepEqual ( forward.chain program ), [ "z", "w" ]

        test "backward", ->

          backward = Backward.make rules
          assert.deepEqual [ "x", "c" ], backward.chain tokens "y"        
          assert.deepEqual [ "b" ], backward.chain tokens "x y"        
          assert.deepEqual [ "a" ], backward.chain tokens "b x y"
          assert !( backward.chain tokens "a b x y" )?

      ]

    test "chaining, with wildcards", [

      test "forward", ->

        rules = [
          tokens "a b x k.c"
          tokens "*.c y d"
        ]      

        program = tokens "a a b x"

        forward = Forward.make rules
        assert.deepEqual ( forward.chain program ), [ "y" ]

      test "backward", ->

        rules = [
          tokens "a b x k.c"
          tokens "*.c y d"
        ]      
      
        backward = Backward.make rules
        assert.deepEqual [ "x", "k.c" ], backward.chain tokens "y"        

    ]
 
  ]

  process.exit if success then 0 else 1
