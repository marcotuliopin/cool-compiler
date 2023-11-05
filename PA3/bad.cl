
(*
 *  execute "coolc bad.cl" to see the error messages that the coolc parser
 *  generates
 *
 *  execute "myparser bad.cl" to see the error messages that your parser
 *  generates
 *)
class Main inherits IO {
    a: Int <- 42;
    
    main(): Object {
        let b: Int <- 17;
        let result: Int
        result <- self.add(a, b)
        out_string("Result is: ")
        out_int(result)
    }
    
    add(x: Int, y: Int): Int {
        x + y
    }
    
    if_example(cond: Bool): Bool {
        if cond then
            true
        else
            false
        fi
    }
    
    while_example(x: Int): Int {
        while x > 0 loop
            x <- x - 1
        pool
    }
    
    case_example(obj: Object): String {
        case obj of
            String => "It's a string"
            Int => "It's an integer"
            Bool => "It's a boolean"
            Object => "It's an object"
        esac
    }
    
    let_example(cond: Bool): Int {
        let x: Int in
            if cond then
                x <- 10
            else
                x <- 20
            fi
        x
    }
};

class ClassWithParseError inherits Object {
    // Class contents here, but intentionally omit the terminating ;
    methodWithError(): String {
        "This is a method in the first class."
    }
    // No ; here, which will cause a parsing error

class SecondClass inherits Object {
    secondMethod(): String {
        "This is a method in the second class."
    };
};


