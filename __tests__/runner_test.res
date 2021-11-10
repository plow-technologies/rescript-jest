include Jest.Runner({
  type t<_> = bool
  let affirm = ok => assert ok
})

let () = {
  test("test", () => true)

  Skip.test("test - expect fail", () => false)

  testAsync("testAsync", finish => finish(true))

  Skip.testAsync("testAsync - no done", _ => ())

  Skip.testAsync("testAsync - expect fail", finish => finish(false))

  testAsync("testAsync - timeout ok", ~timeout=1, finish => finish(true))

  Skip.testAsync("testAsync - timeout fail", ~timeout=1, _ => ())

  testPromise("testPromise", () => Js.Promise.resolve(true))

  Skip.testPromise("testPromise - reject", () => Js.Promise.reject(Failure("")))

  Skip.testPromise("testPromise - expect fail", () => Js.Promise.resolve(false))

  testPromise("testPromise - timeout ok", ~timeout=1, () => Js.Promise.resolve(true))

  Skip.testPromise("testPromise - timeout fail", ~timeout=1, () =>
    Js.Promise.make((~resolve as _, ~reject as _) => ())
  )

  testAll("testAll", list{"foo", "bar", "baz"}, input => Js.String.length(input) === 3)
  testAll("testAll - tuples", list{("foo", 3), ("barbaz", 6), ("bananas!", 8)}, ((input, output)) =>
    Js.String.length(input) === output
  )

  describe("describe", () => test("some aspect", () => true))

  describe("beforeAll", () => {
    let x = ref(0)

    beforeAll(() => x := x.contents + 4)

    test("x is 4", () => x.contents === 4)
    test("x is still 4", () => x.contents === 4)
  })

  describe("beforeAllAsync", () => {
    describe("without timeout", () => {
      let x = ref(0)

      beforeAllAsync(finish => {
        x := x.contents + 4
        finish()
      })

      test("x is 4", () => x.contents === 4)
      test("x is still 4", () => x.contents === 4)
    })

    describe("with 100ms timeout", () => {
      let x = ref(0)

      beforeAllAsync(~timeout=100, finish => {
        x := x.contents + 4
        finish()
      })

      test("x is 4", () => x.contents === 4)
      test("x is still 4", () => x.contents === 4)
    })

    Skip.describe("timeout should fail suite", () =>
      /* This apparently runs even if the suite is skipped */
      /* beforeAllAsync ~timeout:1 (fun _ ->()); */

      test("", () => true) /* runner will crash if there's no tests */
    )
  })

  describe("beforeAllPromise", () => {
    describe("without timeout", () => {
      let x = ref(0)

      beforeAllPromise(() => {
        x := x.contents + 4
        Js.Promise.resolve()
      })

      test("x is 4", () => x.contents === 4)
      test("x is still 4", () => x.contents === 4)
    })

    describe("with 100ms timeout", () => {
      let x = ref(0)

      beforeAllPromise(~timeout=100, () => {
        x := x.contents + 4
        Js.Promise.resolve()
      })

      test("x is 4", () => x.contents === 4)
      test("x is still 4", () => x.contents === 4)
    })

    Skip.describe("timeout should fail suite", () =>
      /* This apparently runs even if the suite is skipped */
      /* beforeAllPromise ~timeout:1 (fun () -> Js.Promise.make (fun ~resolve:_ ~reject:_ -> ())); */

      test("", () => true) /* runner will crash if there's no tests */
    )
  })

  describe("beforeEach", () => {
    let x = ref(0)

    beforeEach(() => x := x.contents + 4)

    test("x is 4", () => x.contents === 4)
    test("x is suddenly 8", () => x.contents === 8)
  })

  describe("beforeEachAsync", () => {
    describe("without timeout", () => {
      let x = ref(0)

      beforeEachAsync(finish => {
        x := x.contents + 4
        finish()
      })

      test("x is 4", () => x.contents === 4)
      test("x is suddenly 8", () => x.contents === 8)
    })

    describe("with 100ms timeout", () => {
      let x = ref(0)

      beforeEachAsync(~timeout=100, finish => {
        x := x.contents + 4
        finish()
      })

      test("x is 4", () => x.contents === 4)
      test("x is suddenly 8", () => x.contents === 8)
    })

    Skip.describe("timeout should fail suite", () => {
      beforeEachAsync(~timeout=1, _ => ())

      test("", () => true) /* runner will crash if there's no tests */
    })
  })

  describe("beforeEachPromise", () => {
    describe("without timeout", () => {
      let x = ref(0)

      beforeEachPromise(() => {
        x := x.contents + 4
        Js.Promise.resolve(true)
      })

      test("x is 4", () => x.contents === 4)
      test("x is suddenly 8", () => x.contents === 8)
    })

    describe("with 100ms timeout", () => {
      let x = ref(0)

      beforeEachPromise(~timeout=100, () => {
        x := x.contents + 4
        Js.Promise.resolve(true)
      })

      test("x is 4", () => x.contents === 4)
      test("x is suddenly 8", () => x.contents === 8)
    })

    Skip.describe("timeout should fail suite", () => {
      beforeEachPromise(~timeout=1, () => Js.Promise.make((~resolve as _, ~reject as _) => ()))

      test("", () => true) /* runner will crash if there's no tests */
    })
  })
  
  describe("afterAll", () => {
    let x = ref(0)

    describe("phase 1", () => {
      afterAll(() => x := x.contents + 4)

      test("x is 0", () => x.contents === 0)
      test("x is still 0", () => x.contents === 0)
    })

    describe("phase 2", () => test("x is suddenly 4", () => x.contents === 4))
  })
  
  describe("afterAllAsync", () => {
    describe("without timeout", () => {
      let x = ref(0)

      describe("phase 1", () => {
        afterAllAsync(finish => {
          x := x.contents + 4
          finish()
        })

        test("x is 0", () => x.contents === 0)
        test("x is still 0", () => x.contents === 0)
      })

      describe("phase 2", () => test("x is suddenly 4", () => x.contents === 4))
    })
    
    describe("with 100ms timeout", () => {
      let x = ref(0)
      
      describe("phase 1", () => {
        afterAllAsync(~timeout=100, finish => {
          x := x.contents + 4
          finish()
        })

        test("x is 0", () => x.contents === 0)
        test("x is still 0", () => x.contents === 0)
      })

      describe("phase 2", () => test("x is suddenly 4", () => x.contents === 4))
    })
    
    describe("timeout should not fail suite", () => {
      Jest.Jest.useFakeTimers(())
      let x = ref(0)
      describe("x is 0", () => {
        afterAllAsync(~timeout=1, finish => {
          x.contents = 5
          finish()
        })
        test("before afterAllAsync x was 0", () => x.contents === 0 )
      })
      Jest.Jest.runAllTimers()
      test("afterAllAsync x is now 5", () => x.contents === 5 )
    })
  })
  
  describe("afterAllPromise", () => {
    describe("without timeout", () => {
      let x = ref(0)

      describe("phase 1", () => {
        afterAllPromise(() => {
          x := x.contents + 4
          Js.Promise.resolve(true)
        })

        test("x is 0", () => x.contents === 0)
        test("x is still 0", () => x.contents === 0)
      })

      describe("phase 2", () => test("x is suddenly 4", () => x.contents === 4))
    })

    describe("with 100ms timeout", () => {
      let x = ref(0)

      describe("phase 1", () => {
        afterAllPromise(~timeout=100, () => {
          x := x.contents + 4
          Js.Promise.resolve(true)
        })

        test("x is 0", () => x.contents === 0)
        test("x is still 0", () => x.contents === 0)
      })

      describe("phase 2", () => test("x is suddenly 4", () => x.contents === 4))
    })

    describe("afterAllPromise timeout should not fail suite", () => {
      Jest.Jest.useFakeTimers(())
      let x = ref(0)
      describe("x is 0", () => {
        afterAllPromise(~timeout=1, () => {
          Js.Promise.make((~resolve, ~reject) => {
            resolve(. "Promise")
            reject(. Js.Exn.raiseError("Failure"))
          })
          -> Js.Promise.then_(_ => {
            x.contents = 5
            Js.Promise.resolve(`${string_of_int(x.contents)}`)
          }, _)
          -> Js.Promise.catch(_ => {
            Js.Promise.reject(Js.Exn.raiseError(`Failure: x is ${string_of_int(x.contents)}`))
          }, _)
        })
        Jest.Jest.runAllTimers()
        test("before afterAllPromise x was 0", () => x.contents === 0)
      })
      test("afterAllPromise x is now 5", () => x.contents === 5)

    })
  })

  describe("afterEach", () => {
    let x = ref(0)

    afterEach(() => x := x.contents + 4)

    test("x is 0", () => x.contents === 0)
    test("x is suddenly 4", () => x.contents === 4)
  })

  describe("afterEachAsync", () => {
    describe("without timeout", () => {
      let x = ref(0)

      afterEachAsync(finish => {
        x := x.contents + 4
        finish()
      })

      test("x is 0", () => x.contents === 0)
      test("x is suddenly 4", () => x.contents === 4)
    })

    describe("with 100ms timeout", () => {
      let x = ref(0)

      afterEachAsync(~timeout=100, finish => {
        x := x.contents + 4
        finish()
      })

      test("x is 0", () => x.contents === 0)
      test("x is suddenly 4", () => x.contents === 4)
    })

    describe("timeout should not fail suite", () => {
      Jest.Jest.useFakeTimers(())
      afterEachAsync(~timeout=1, finish => {
        finish()
        -> ignore
      })
      Jest.Jest.runAllTimers()
      test("timeout did not fail suite", () => true)
    })
  })

  describe("afterEachPromise", () => {
    describe("without timeout", () => {
      let x = ref(0)

      afterEachPromise(() => {
        x := x.contents + 4
        Js.Promise.resolve(true)
      })

      test("x is 0", () => x.contents === 0)
      test("x is suddenly 4", () => x.contents === 4)
    })

    describe("with 100ms timeout", () => {
      let x = ref(0)

      afterEachPromise(~timeout=100, () => {
        x := x.contents + 4
        Js.Promise.resolve(true)
      })

      test("x is 0", () => x.contents === 0)
      test("x is suddenly 4", () => x.contents === 4)
    })

    describe("timeout should not fail suite", () => {
      Jest.Jest.useFakeTimers(())
      afterEachPromise(~timeout=1, () => {
        Js.Promise.make((~resolve, ~reject) => {
          resolve(. "Resolved")
          reject(. Js.Exn.raiseError("Failure"))
        })
      })
      Jest.Jest.runAllTimers()
      test("timeout did not fail suite", () => true)
    })
  })

  describe("Only", () =>
    /* See runner_only_test.ml */
    ()
  )

  describe("Skip", () => {
    Skip.test("Skip.test", () => false)

    Skip.testAsync("Skip.testAsync", finish => finish(false))
    Skip.testAsync("Skip.testAsync - timeout", ~timeout=1, _ => ())

    Skip.testPromise("Skip.testPromise", () => Js.Promise.resolve(false))
    Skip.testPromise("testPromise - timeout", ~timeout=1, () =>
      Js.Promise.make((~resolve, ~reject as _) => resolve(. false))
    )

    Skip.testAll("testAll", list{"foo", "bar", "baz"}, _ => false)
    Skip.testAll("testAll - tuples", list{("foo", 3), ("barbaz", 6), ("bananas!", 8)}, ((_, _)) =>
      false
    )

    Skip.describe("Skip.describe", () => test("some aspect", () => false))
  })
}
