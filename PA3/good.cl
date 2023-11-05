class Main inherits IO {
    -- Attributes
    a: Int <- 42;

    -- Methods
    main(): Object {
        let b: Int <- 17;
        let result: Int;
        result <- self.add(a, b);
        out_string("Result is: ");
        out_int(result);
    };

    add(x: Int, y: Int): Int {
        x + y
    };

    if_example(cond: Bool): Bool {
        if cond then
            true
        else
            false
        fi
    };

    while_example(x: Int): Int {
        while x > 0 loop
            x <- x - 1
        pool;
        x
    };

    case_example(obj: Object): String {
        case obj of
            String => "It's a string"
            Int => "It's an integer"
            Bool => "It's a boolean"
            Object => "It's an object"
        esac
    };

    let_example(cond: Bool): Int {
        let x: Int <- new Int in
            if cond then
                x <- 10
            else
                x <- 20
            fi;
        x
    };
};
