
class Cons inherits List {

car : Int;   -- The element in this list cell

cdr : List;  -- The rest of the list

isNil() : Bool { false };

head()  : Int { car };

tail()  : List { cdr };

init(i : Int, rest : List) : List {
    {
    car <- i;
    cdr <- rest;
    self;
    }
};

};

(*
*  The Main class shows how to use the List class. It creates a small
*  list and then repeatedly prints out its elements and takes off the
*  first element of the list.
*)

class Main inherits IO {

mylist : List;

-- Print all elements of the list. Calls itself recursively with
-- the tail of the list, until the end of the list is reached.

print_list(l : List) : Object {
    if l.isNil() then out_string("\n")
                else {
            out_int(l.head());
            out_string(" ");
            print_list(l.tail());
                }
    fi
};


main() : Object {
    {
    mylist <- new List.cons(1).cons(2).cons(3).cons(4).cons(5);
    while (not mylist.isNil()) loop
        {
        print_list(mylist);
        mylist <- mylist.tail();
        }
    pool;
    }
};

};
