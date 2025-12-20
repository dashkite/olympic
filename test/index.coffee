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

    test "chaining with function products", [
      
      test "forward", ->

        drop = ( stack ) -> stack[ ...-1 ]
        dup = ([ rest..., last ]) -> [ rest..., last, last ]

        rules = [
          tokens "a b x c"
          tokens "c y d"
          tokens "d d z e"
          [ ( tokens "* drop" )..., drop ]
          [ ( tokens "* dup" )..., dup ]
        ]

        program = tokens "a b x y dup"
        forward = Forward.make rules
        assert.deepEqual ( stack = forward.compile program ), [ "d", "d" ]
        assert.deepEqual ( forward.satisfy stack ), [ "z", "drop", "dup" ]

      test "backward", ->

        drop = ( stack ) -> stack[ ...-1 ]
        dup = ([ rest..., last ]) -> [ rest..., last, last ]

        drop.inverse = dup
        dup.inverse = drop

        rules = [
          tokens "a b x c"
          tokens "c y d"
          tokens "d d z e"
          [ ( tokens "* drop" )..., drop ]
          [ ( tokens "* dup" )..., dup ]
        ]

        backward = Backward.make rules
        assert.deepEqual [ "x", "c" ], backward.chain tokens "y"        
        assert.deepEqual [ "b" ], backward.chain tokens "x y"        
        # console.log backward.compile tokens "dup z"
        # assert.deepEqual ( tokens "y dup d" ), backward.chain tokens "z"
        # assert !( backward.chain tokens "a b x y" )?
    ]

    test "backward as reverse of forward", ->

      rules = [
        tokens "a b x c"
        tokens "c y d"
        tokens "e w b"
      ]      

      selur = rules
        .map ([ operands..., operator, product ]) ->
          [ _..., last ] = operands
          [ product, operator, last ]
      # console.log JSON.stringify ( selur.map ( tokens ) -> tokens.join " " ), null, 2
      # forward = Forward.make rules
      # console.log forward.chain tokens "a b x"
      drawrof = Forward.make selur
      # console.log drawrof.compile tokens "d y"
      # console.log drawrof.chain tokens "y"
      backward = Backward.make selur
      stack = backward.compile tokens "y"
      assert.deepEqual [ "x" ], drawrof.chain ( tokens "y" ), stack
      stack = backward.compile tokens "y x"
      assert.deepEqual [ "w" ], drawrof.chain ( tokens "y x" ), stack

      rules = [
        tokens "a b x k.c"
        tokens "*.c y d"
      ]      
    
      selur = rules
        .map ([ operands..., operator, product ]) ->
          [ _..., last ] = operands
          [ product, operator, last ]
      # console.log JSON.stringify ( selur.map ( tokens ) -> tokens.join " " ), null, 2
      # forward = Forward.make rules
      # console.log forward.chain tokens "a b x"
      drawrof = Forward.make selur
      backward = Backward.make selur
      stack = backward.compile tokens "y"  
      # console.log drawrof.chain (tokens "y" ), stack  
      assert.deepEqual [ "x" ], 
        drawrof.chain (tokens "y" ), stack

      drop = ( stack ) -> stack[ ...-1 ]
      dup = ([ rest..., last ]) -> [ rest..., last, last ]

      drop.inverse = dup
      dup.inverse = drop

      rules = [
        tokens "a b x c"
        tokens "c y d"
        [ ( tokens "* drop" )..., drop ]
        [ ( tokens "* dup" )..., dup ]
      ]

      selur = rules
        .map ([ operands..., operator, product ]) ->
          [ _..., last ] = operands
          [( product.inverse ? product ), operator, last ]

      drawrof = Forward.make selur
      backward = Backward.make selur
      stack = backward.compile tokens "y"  
      console.log drawrof.chain tokens "y", stack
      assert.deepEqual [ "x" ], drawrof.chain tokens "y", stack
      # assert.deepEqual [ "b" ], backward.chain tokens "x y"      
 
  ]

  process.exit if success then 0 else 1
