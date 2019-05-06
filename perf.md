## Comparisons of implemenations by inferences

To judge how fast the pure implementation is, the current implementations were dug up on the internet and compared using various brainf\*\*k programs. 

All brainf\*\*k code was sourced from http://rosettacode.org, and the files used are included for reference.

The Rosseta code implemenation was actually my own efforts some time ago, and the pure implemenation is was an attemp to improveme on that attempt.

### Implemenations

- pure BF  - This implemenation
- Joyheron - https://github.com/joyheron/brainf_prolog_interpreter
- Aswin    - https://www.aswinvanwoudenberg.com/2007/01/05/a-brainfck-interpreter-in-prolog/ 
- Rosseta  - http://rosettacode.org/wiki/Execute_Brain****#Prolog 
- danieldk - https://github.com/danieldk/brainfuck-pl 

Time is measuring the number of inferences, and includes the stripping of characters and running the interpretter. The timing does not include loading the file.
The exceptions are: 
- the Aswin implementation does not strip invalid characters.
- the danieldk implemenation strips characters while loading the file, so this part was skipped.

|           |  3dname |   quine    |  hello | alphabet |        mandlebrot |
| --------- | ------- | ---------- | ------ | -------- | ----------------- |
| danieldk  |   3,662 |    Stacked |  1,750 |    9,285 |           Stacked |
| Pure BF   |   7,088 |    446,310 |  2,422 |   11,024 | complete &lt;1 hr |
| Joyheron  |  14,385 |   Infinite |  4,031 |   18,983 |          Infinite |
| Rosseta   |  16,505 |  1,847,199 |  7,444 |   42,406 | complete &gt;1 hr |
| Aswin     |  48,678 | 71,746,677 | 42,533 |  244,942 | complete &gt;1 hr |

> <b>Stacked</b> means that the program run out of stack space.
>
> <b>Infinite</b> means that the program seemed to be caught in an infinite loop.