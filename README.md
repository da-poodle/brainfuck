# brainf\*\*k
A brainfuck interpreter written in prolog using only horn clauses. 

This interpreter uses no inbuilt libraries or cuts, and if run on SWI-Prolog will be able to run any legitimate brainf\*\*k program. 

## How to run a file

To run, open the file in swipl and use the run_file/1 predicate with a valid brainf\*\*k file. 

To run a file that has no input (output to stdout).
<code prolog>
run_file('test_programs/hello.bf').
</code>

To run a file that has input (input is represented as codes).
<code prolog>
run_file('...', [23,34,etc..]).
</code>

To run a file and capture the input and output (Both represented as codes).
<code prolog>
run_file('...', [23,34,etc..], [23, 43, 34, etc..]).
</code>

The <code prolog>brain/3</code> predicate can be called directly with a program that is represented as codes. 

## Special rules
The intepretter is unforgiving in its interpretation of the brainf\*\*k language and there are a few rules that you should be aware of. 

- Programs can only end in . or ]
- the < operation cannot be used unless the > operation has already created memory to go back to.
- All input must be consumed, an empty list is expected at the end. 