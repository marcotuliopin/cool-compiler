class Main inherits IO {
    -- Missing method name
    main(): Object {
        out_string("Hello, COOL!")
    }

    -- Missing colon after method name
    add(x Int, y Int) Int {
        x + y
    }

    -- Missing <- for attribute assignment
    a: Int = 42;

    -- Unmatched parantheses
    if_example(cond Bool): Bool {
        if (cond then
            true
        else
            false
        fi
    }

    -- Unmatched braces
    while_example(x: Int): Int {
        while x > 0 loop
            x <- x - 1
        pool
    }

    -- Unknown type
    let_example(cond: Bool): Int {
        let x: UnknownType <- 10 in
            if cond then
                x <- 20
            else
                x <- 30
            fi;
        x
    }
};

class IncompleteClass inherits IO {
    -- Attributes
    a: Int <- 42;

    -- Method
    main(): Object {
        out_string("Hello, COOL!")
    }

    -- This class is not properly terminated, no '}' at the end
