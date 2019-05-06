% this file is a tester app for GNU-Prolog

:- include(brain).

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
    brain(Bf, Input, Output).

read_file_to_codes(F, Codes, _) :-
    open(F, read, S),
    read_file_to_codes(Codes, S).

read_file_to_codes([], S) :-
    at_end_of_stream(S).

read_file_to_codes([C|T], S) :-
    get_code(S, C),
    read_file_to_codes(T, S).
