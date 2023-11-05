class A {
};

Class B inherits A { -- test heritage
};

Class C {
    var : Int <- 0; -- test attribute declaration

    main(): SELF_TYPE { -- test method declaration
        out_string("Hello, World.\n")
    };

    method0(num1 : Int, num2 : Int) : B {  -- test let, plus, assign and dispatch
        (let x : Int in
        {
            x <- num1 + num2;
            (new B).set_var(x);
        }
        )
    };

    method1(num : Int) : E {  -- test loop, new
        (let x : Int <- 1 in
        {
            (let y : Int <- 1 in
                while y <= num loop
                    {
                        x <- x * y;
                        y <- y + 1;
                    }
            pool
            );
            (new E).set_var(x);
        }
        )
    };

    method2(num : Int) : Bool {  -- test conditional, negation
        (let x : Int <- num in
            if x < 0 then method7(~x) else
            if 0 = x then true else
            if 1 = x then false else
            if 2 = x then false else
                method7(x - 3)
            fi fi fi fi
        )
    };

    x : Int;

    method3() : Object { -- test case, 
        {
            case x of
                dummy : Int => out_string("- is Int -\n");
                dummy : Bool => out_string("- is Bool -\n");
            esac;
        }
    };
};