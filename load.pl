:- ensure_loaded(brain).

% run a brainf**k file with no input, output is printed to console
run_file(F) :-
    run_file(F, []).

% run a brainf**k file with input as codes, output is printed to console
run_file(F, Input) :-
    run_file(F, Input, O),
    maplist(char_code, H, O),
    maplist(write, H), !.

% run a brainf**k file with input and output specified as codes
run_file(F, Input, Output) :-
    read_file_to_codes(F, Bf, []),
    !,
    time(brain(Bf, Input, Output)).
