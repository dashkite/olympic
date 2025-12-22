import assert from "@dashkite/assert"
import {test, success} from "@dashkite/amen"
import print from "@dashkite/amen-console"

import { Forward, Backward } from "../src"
import { SimpleRule, rule, mixin } from "../src/rule"
import { equal } from "../src/helpers/wildcard"
import { tokens } from "../src/helpers/tokens"

do ->

  print await test "Olympic", [

    test "wildcard equality", ->
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
        rule "a b x c"
        rule "c y d"
        rule "d z e"
        rule "a d w f"
      ]

      [

        test "forward", ->

          program = tokens "a a b x y"
          forward = Forward.make rules

          assert.deepEqual ( tokens "a d" ),
            stack = forward.compile program
          assert.deepEqual ( tokens "z w a b c d e f" ),
            forward.satisfy stack
          assert.deepEqual ( tokens "z w a b c d e f" ),
            forward.chain program

        test "backward", ->

          backward = Backward.make rules
          assert.deepEqual ( tokens "x c" ),
            backward.chain tokens "y"
          assert.deepEqual ( tokens "b" ),
            backward.chain tokens "x y"
          assert.deepEqual ( tokens "a" ),
            backward.chain tokens "b x y"
          assert !( backward.chain tokens "c b x y" )?

      ]

    test "chaining, with wildcards", [

      test "forward", ->

        rules = [
          rule "a b x k.c"
          rule "*.c y d"
        ]

        program = tokens "a a b x"

        forward = Forward.make rules
        assert.deepEqual ( tokens "y a b k.c d"),
          forward.chain program

      test "backward", ->

        rules = [
          rule "a b x k.c"
          rule "*.c y d"
        ]

        backward = Backward.make rules
        assert.deepEqual ( tokens "x k.c" ),
          backward.chain tokens "y"

    ]

    test "chaining, with stack operators", do ->

      drop = ([ rest..., last ]) -> rest

      dup = ([ rest..., last ]) -> [ rest..., last, last ]

      class Dup extends mixin "* dup *"
        apply: dup
        rapply: drop

      class Drop extends mixin "* drop *"
        apply: drop
        rapply: dup

      rules = [
        rule "a a x c"
        rule "c y d"
        Dup.make()
        Drop.make()
      ]

      [

        test "forward", ->
          program = tokens "drop dup"
          stack = tokens "a b"
          forward = Forward.make rules
          assert.deepEqual ( tokens "x dup drop a c d" ),
            forward.chain program, stack

        test "backward", ->
          backward = Backward.make rules
          assert.deepEqual ( tokens "dup drop a" ),
            backward.chain tokens "x y"
      ]

  ]

  process.exit if success then 0 else 1
