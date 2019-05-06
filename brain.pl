/*
 * brain/3
 *
 * Call brain/3 with the brainf**k code as codes.
 * the input as codes is the second parameter.
 * the output as codes is the third parameter.
 *
 * No errors are produced, only a true or false answer with
 * any generated output.
 *
 * Restrictions/Features:
 * - The brainf**k program must only end with ] or .
 * - The input must all be read
 * - The memory will only be generated using >
 * - using < to generate memory will fail.
 */
brain(Code, Input, Output) :-
    strip_non_bf(Code, Stripped),
    brain(Stripped, Input, Output, [], [0], []).


% strip all the non brainf**k characters from the code
strip_non_bf([], []).
strip_non_bf([C|T], R) :-
    map_code(C, _, _, Valid),
    include_if_bf(Valid, [C|T], R).

include_if_bf(bf, [C|T], [C|R]) :- strip_non_bf(T, R).
include_if_bf(nonbf, [_|T], R) :- strip_non_bf(T, R).


/*
 * Code = remainder of the code after processing
 * I = input data
 * O = current output data
 * Ms = the memory stack
 * M/Mt = current memory address
 * S = the loop stack
 * R = the resulting output
 *
 * brain/6 is used for operations that can logically be at the end of a
 * program, for others brain/7 is called.
 */
brain([], [], [], _, _, []).
brain([C|Code], I, O, Ms, M, S) :-
    brain(C, Code, I, O, Ms, M, S).

/*
 * Uncomment this for some debugging info
 *
brain([C|Code], I, O, Ms, M, S) :-
    format('Failed on code ~w~n', C),
    maplist(write, Code), nl,
    write('Ms: '), maplist(format('~p '), Ms), nl,
    write('M : '), maplist(format('~p '), M), nl,
    nl,
    write('Stack: '),
    print(S), nl.

print_stack_entry(S) :-
    maplist(write, S), nl.
*/

% the following three just force indexing
% SWI-Prolog will index when there are more than 10 options
brain(0, Code, I, O, Ms, M, S) :- brain(Code, I, O, Ms, M, S).
brain(1, Code, I, O, Ms, M, S) :- brain(Code, I, O, Ms, M, S).
brain(2, Code, I, O, Ms, M, S) :- brain(Code, I, O, Ms, M, S).

% [
brain(91, Code, I, O, Ms, [M|Mt], S) :-
    map_code(M, _, Z, _),
    loop_start(Z, Code, I, O, Ms, [M|Mt], S).

% ]
brain(93, Code, I, O, Ms, [M|Mt], S) :-
    map_code(M, _, Z, _),
    loop_end(Z, Code, I, O, Ms, [M|Mt], S).

% ,
brain(44, [C|Code], [I|It], O, Ms, [_|Mt], S) :-
    brain(C, Code, It, O, Ms, [I|Mt], S).

% .
brain(46, Code, I, [M|O], Ms, [M|Mt], S) :-
    brain(Code, I, O, Ms, [M|Mt], S).

% >
brain(62, Code, I, O, Ms, [M|Mt], S) :-
    mem_shift_right(Mt, Code, I, O, Ms, [M|Mt], S).

% <
brain(60, [C|Code], I, O, [M|Ms], Mt, S) :-
    brain(C, Code, I, O, Ms, [M|Mt], S).

% -
brain(45, [C|Code], I, O, Ms, [M|Mt], S) :-
    map_code(M1, M, _, _),
    brain(C, Code, I, O, Ms, [M1|Mt], S).

% +
brain(43, [C|Code], I, O, Ms, [M|Mt], S) :-
    map_code(M, M1, _, _),
    brain(C, Code, I, O, Ms, [M1|Mt], S).

mem_shift_right([], [C|Code], I, O, Ms, [M], S) :-
    brain(C, Code, I, O, [M|Ms], [0], S).
mem_shift_right([_|_], [C|Code], I, O, Ms, [M|Mt], S) :-
    brain(C, Code, I, O, [M|Ms], Mt, S).

loop_start(nonzero, [C|Code], I, O, Ms, M, S) :-
    % a start of a loop is never the last code so call straight switch
    brain(C, Code, I, O, Ms, M, [[C|Code]|S]).
loop_start(zero, [C|Code], I, O, Ms, [0|Mt], S) :-
    find_matching_bracket(C, Code, NewCode),
    brain(NewCode, I, O, Ms, [0|Mt], S). % skip the loop altogether

loop_end(nonzero, _, I, O, Ms, M, [[C|Code]|St]) :-
    % a start of a loop is never the last code so call straight switch
    brain(C, Code, I, O, Ms, M, [[C|Code]|St]). % peek the loop stack
loop_end(zero, Code, I, O, Ms, M, [_|St]) :-
    brain(Code, I, O, Ms, M, St). % pop the loop stack


% indexing hack
find_matching_bracket(0,   [C|Co], M) :- find_matching_bracket(C, Co, M).
find_matching_bracket(1,   [C|Co], M) :- find_matching_bracket(C, Co, M).
find_matching_bracket(2,   [C|Co], M) :- find_matching_bracket(C, Co, M).

% skipping non bracket codes
find_matching_bracket(45,   [C|Co], M) :- find_matching_bracket(C, Co, M).
find_matching_bracket(43,   [C|Co], M) :- find_matching_bracket(C, Co, M).
find_matching_bracket(62,   [C|Co], M) :- find_matching_bracket(C, Co, M).
find_matching_bracket(60,   [C|Co], M) :- find_matching_bracket(C, Co, M).
find_matching_bracket(46, [C|Co], M) :- find_matching_bracket(C, Co, M).
find_matching_bracket(44, [C|Co], M) :- find_matching_bracket(C, Co, M).

% if there is an inner loop, then skip it
find_matching_bracket(91, [C|Co], M) :-
   find_matching_bracket(C, Co, [C1|Ct]),
   find_matching_bracket(C1, Ct, M).
% return the code after the matching bracket
find_matching_bracket(93, C,      C).




/*
 * pure succ predicate with a couple of differences
 * 1. there is an identifier to indicate if a number is zero or not
 * 2. 255 doesn't go to 266 but rather wraps to 0 again
 *
 * includes a map to determine if a code is zero or not
 * include a map to determine if a code is a brainf**k code or not
 */
map_code(0,1,zero, nonbf).
map_code(1,2,nonzero, nonbf).
map_code(2,3,nonzero, nonbf).
map_code(3,4,nonzero, nonbf).
map_code(4,5,nonzero, nonbf).
map_code(5,6,nonzero, nonbf).
map_code(6,7,nonzero, nonbf).
map_code(7,8,nonzero, nonbf).
map_code(8,9,nonzero, nonbf).
map_code(9,10,nonzero, nonbf).
map_code(10,11,nonzero, nonbf).
map_code(11,12,nonzero, nonbf).
map_code(12,13,nonzero, nonbf).
map_code(13,14,nonzero, nonbf).
map_code(14,15,nonzero, nonbf).
map_code(15,16,nonzero, nonbf).
map_code(16,17,nonzero, nonbf).
map_code(17,18,nonzero, nonbf).
map_code(18,19,nonzero, nonbf).
map_code(19,20,nonzero, nonbf).
map_code(20,21,nonzero, nonbf).
map_code(21,22,nonzero, nonbf).
map_code(22,23,nonzero, nonbf).
map_code(23,24,nonzero, nonbf).
map_code(24,25,nonzero, nonbf).
map_code(25,26,nonzero, nonbf).
map_code(26,27,nonzero, nonbf).
map_code(27,28,nonzero, nonbf).
map_code(28,29,nonzero, nonbf).
map_code(29,30,nonzero, nonbf).
map_code(30,31,nonzero, nonbf).
map_code(31,32,nonzero, nonbf).
map_code(32,33,nonzero, nonbf).
map_code(33,34,nonzero, nonbf).
map_code(34,35,nonzero, nonbf).
map_code(35,36,nonzero, nonbf).
map_code(36,37,nonzero, nonbf).
map_code(37,38,nonzero, nonbf).
map_code(38,39,nonzero, nonbf).
map_code(39,40,nonzero, nonbf).
map_code(40,41,nonzero, nonbf).
map_code(41,42,nonzero, nonbf).
map_code(42,43,nonzero, nonbf).
map_code(43,44,nonzero, bf). % + (add 1)
map_code(44,45,nonzero, bf). % , (read)
map_code(45,46,nonzero, bf). % - (subtract 1)
map_code(46,47,nonzero, bf). % . (print)
map_code(47,48,nonzero, nonbf).
map_code(48,49,nonzero, nonbf).
map_code(49,50,nonzero, nonbf).
map_code(50,51,nonzero, nonbf).
map_code(51,52,nonzero, nonbf).
map_code(52,53,nonzero, nonbf).
map_code(53,54,nonzero, nonbf).
map_code(54,55,nonzero, nonbf).
map_code(55,56,nonzero, nonbf).
map_code(56,57,nonzero, nonbf).
map_code(57,58,nonzero, nonbf).
map_code(58,59,nonzero, nonbf).
map_code(59,60,nonzero, nonbf).
map_code(60,61,nonzero, bf). % < (shift mem left)
map_code(61,62,nonzero, nonbf).
map_code(62,63,nonzero, bf). % > (shift mem right)
map_code(63,64,nonzero, nonbf).
map_code(64,65,nonzero, nonbf).
map_code(65,66,nonzero, nonbf).
map_code(66,67,nonzero, nonbf).
map_code(67,68,nonzero, nonbf).
map_code(68,69,nonzero, nonbf).
map_code(69,70,nonzero, nonbf).
map_code(70,71,nonzero, nonbf).
map_code(71,72,nonzero, nonbf).
map_code(72,73,nonzero, nonbf).
map_code(73,74,nonzero, nonbf).
map_code(74,75,nonzero, nonbf).
map_code(75,76,nonzero, nonbf).
map_code(76,77,nonzero, nonbf).
map_code(77,78,nonzero, nonbf).
map_code(78,79,nonzero, nonbf).
map_code(79,80,nonzero, nonbf).
map_code(80,81,nonzero, nonbf).
map_code(81,82,nonzero, nonbf).
map_code(82,83,nonzero, nonbf).
map_code(83,84,nonzero, nonbf).
map_code(84,85,nonzero, nonbf).
map_code(85,86,nonzero, nonbf).
map_code(86,87,nonzero, nonbf).
map_code(87,88,nonzero, nonbf).
map_code(88,89,nonzero, nonbf).
map_code(89,90,nonzero, nonbf).
map_code(90,91,nonzero, nonbf).
map_code(91,92,nonzero, bf). % '[' (start loop)
map_code(92,93,nonzero, nonbf).
map_code(93,94,nonzero, bf). % ']' (end loop)
map_code(94,95,nonzero, nonbf).
map_code(95,96,nonzero, nonbf).
map_code(96,97,nonzero, nonbf).
map_code(97,98,nonzero, nonbf).
map_code(98,99,nonzero, nonbf).
map_code(99,100,nonzero, nonbf).
map_code(100,101,nonzero, nonbf).
map_code(101,102,nonzero, nonbf).
map_code(102,103,nonzero, nonbf).
map_code(103,104,nonzero, nonbf).
map_code(104,105,nonzero, nonbf).
map_code(105,106,nonzero, nonbf).
map_code(106,107,nonzero, nonbf).
map_code(107,108,nonzero, nonbf).
map_code(108,109,nonzero, nonbf).
map_code(109,110,nonzero, nonbf).
map_code(110,111,nonzero, nonbf).
map_code(111,112,nonzero, nonbf).
map_code(112,113,nonzero, nonbf).
map_code(113,114,nonzero, nonbf).
map_code(114,115,nonzero, nonbf).
map_code(115,116,nonzero, nonbf).
map_code(116,117,nonzero, nonbf).
map_code(117,118,nonzero, nonbf).
map_code(118,119,nonzero, nonbf).
map_code(119,120,nonzero, nonbf).
map_code(120,121,nonzero, nonbf).
map_code(121,122,nonzero, nonbf).
map_code(122,123,nonzero, nonbf).
map_code(123,124,nonzero, nonbf).
map_code(124,125,nonzero, nonbf).
map_code(125,126,nonzero, nonbf).
map_code(126,127,nonzero, nonbf).
map_code(127,128,nonzero, nonbf).
map_code(128,129,nonzero, nonbf).
map_code(129,130,nonzero, nonbf).
map_code(130,131,nonzero, nonbf).
map_code(131,132,nonzero, nonbf).
map_code(132,133,nonzero, nonbf).
map_code(133,134,nonzero, nonbf).
map_code(134,135,nonzero, nonbf).
map_code(135,136,nonzero, nonbf).
map_code(136,137,nonzero, nonbf).
map_code(137,138,nonzero, nonbf).
map_code(138,139,nonzero, nonbf).
map_code(139,140,nonzero, nonbf).
map_code(140,141,nonzero, nonbf).
map_code(141,142,nonzero, nonbf).
map_code(142,143,nonzero, nonbf).
map_code(143,144,nonzero, nonbf).
map_code(144,145,nonzero, nonbf).
map_code(145,146,nonzero, nonbf).
map_code(146,147,nonzero, nonbf).
map_code(147,148,nonzero, nonbf).
map_code(148,149,nonzero, nonbf).
map_code(149,150,nonzero, nonbf).
map_code(150,151,nonzero, nonbf).
map_code(151,152,nonzero, nonbf).
map_code(152,153,nonzero, nonbf).
map_code(153,154,nonzero, nonbf).
map_code(154,155,nonzero, nonbf).
map_code(155,156,nonzero, nonbf).
map_code(156,157,nonzero, nonbf).
map_code(157,158,nonzero, nonbf).
map_code(158,159,nonzero, nonbf).
map_code(159,160,nonzero, nonbf).
map_code(160,161,nonzero, nonbf).
map_code(161,162,nonzero, nonbf).
map_code(162,163,nonzero, nonbf).
map_code(163,164,nonzero, nonbf).
map_code(164,165,nonzero, nonbf).
map_code(165,166,nonzero, nonbf).
map_code(166,167,nonzero, nonbf).
map_code(167,168,nonzero, nonbf).
map_code(168,169,nonzero, nonbf).
map_code(169,170,nonzero, nonbf).
map_code(170,171,nonzero, nonbf).
map_code(171,172,nonzero, nonbf).
map_code(172,173,nonzero, nonbf).
map_code(173,174,nonzero, nonbf).
map_code(174,175,nonzero, nonbf).
map_code(175,176,nonzero, nonbf).
map_code(176,177,nonzero, nonbf).
map_code(177,178,nonzero, nonbf).
map_code(178,179,nonzero, nonbf).
map_code(179,180,nonzero, nonbf).
map_code(180,181,nonzero, nonbf).
map_code(181,182,nonzero, nonbf).
map_code(182,183,nonzero, nonbf).
map_code(183,184,nonzero, nonbf).
map_code(184,185,nonzero, nonbf).
map_code(185,186,nonzero, nonbf).
map_code(186,187,nonzero, nonbf).
map_code(187,188,nonzero, nonbf).
map_code(188,189,nonzero, nonbf).
map_code(189,190,nonzero, nonbf).
map_code(190,191,nonzero, nonbf).
map_code(191,192,nonzero, nonbf).
map_code(192,193,nonzero, nonbf).
map_code(193,194,nonzero, nonbf).
map_code(194,195,nonzero, nonbf).
map_code(195,196,nonzero, nonbf).
map_code(196,197,nonzero, nonbf).
map_code(197,198,nonzero, nonbf).
map_code(198,199,nonzero, nonbf).
map_code(199,200,nonzero, nonbf).
map_code(200,201,nonzero, nonbf).
map_code(201,202,nonzero, nonbf).
map_code(202,203,nonzero, nonbf).
map_code(203,204,nonzero, nonbf).
map_code(204,205,nonzero, nonbf).
map_code(205,206,nonzero, nonbf).
map_code(206,207,nonzero, nonbf).
map_code(207,208,nonzero, nonbf).
map_code(208,209,nonzero, nonbf).
map_code(209,210,nonzero, nonbf).
map_code(210,211,nonzero, nonbf).
map_code(211,212,nonzero, nonbf).
map_code(212,213,nonzero, nonbf).
map_code(213,214,nonzero, nonbf).
map_code(214,215,nonzero, nonbf).
map_code(215,216,nonzero, nonbf).
map_code(216,217,nonzero, nonbf).
map_code(217,218,nonzero, nonbf).
map_code(218,219,nonzero, nonbf).
map_code(219,220,nonzero, nonbf).
map_code(220,221,nonzero, nonbf).
map_code(221,222,nonzero, nonbf).
map_code(222,223,nonzero, nonbf).
map_code(223,224,nonzero, nonbf).
map_code(224,225,nonzero, nonbf).
map_code(225,226,nonzero, nonbf).
map_code(226,227,nonzero, nonbf).
map_code(227,228,nonzero, nonbf).
map_code(228,229,nonzero, nonbf).
map_code(229,230,nonzero, nonbf).
map_code(230,231,nonzero, nonbf).
map_code(231,232,nonzero, nonbf).
map_code(232,233,nonzero, nonbf).
map_code(233,234,nonzero, nonbf).
map_code(234,235,nonzero, nonbf).
map_code(235,236,nonzero, nonbf).
map_code(236,237,nonzero, nonbf).
map_code(237,238,nonzero, nonbf).
map_code(238,239,nonzero, nonbf).
map_code(239,240,nonzero, nonbf).
map_code(240,241,nonzero, nonbf).
map_code(241,242,nonzero, nonbf).
map_code(242,243,nonzero, nonbf).
map_code(243,244,nonzero, nonbf).
map_code(244,245,nonzero, nonbf).
map_code(245,246,nonzero, nonbf).
map_code(246,247,nonzero, nonbf).
map_code(247,248,nonzero, nonbf).
map_code(248,249,nonzero, nonbf).
map_code(249,250,nonzero, nonbf).
map_code(250,251,nonzero, nonbf).
map_code(251,252,nonzero, nonbf).
map_code(252,253,nonzero, nonbf).
map_code(253,254,nonzero, nonbf).
map_code(254,255,nonzero, nonbf).
map_code(255,0,nonzero, nonbf).
