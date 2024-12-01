# Advent of Code 2024 🎄🤶🎅🎄

Merry Christmas and Happy Holidays!
This is my take on the AoC for 2024, written in `Zig` mach `0.14.0-dev.1911+3bf89f55c`

My rules:

- _no_ LLMs, "AI" or otherwise
- no peeking at others answers (unless you have given it your best attempt and exhausted all options)
  if you _do_ look at others answers, cite them.
- make the process, output, and answers verbose (ie: debug printing and code comments)
- try your best!

## building and testing

cd into any of the `dayXXX` directories and run `zig build run`

### Day one

This one was easy (as the first days usually seem to be) I just opened my input, split the input by the sequence of three spaces.
I then parsed the integers into a zig `usize` and appended each integer from each line into a seperate `ArrayList` from the stdlib.
Then I sorted those lists in place using `std.mem.sort` which was comically easy to do.

This uses [this implementation](https://github.com/BonzaiThePenguin/WikiSort/blob/master/WikiSort.c) under the hood which is really
well done and very efficient. It swaps values in place in chunks of 4-8 and handles a lot of edge cases.

```zig
std.mem.sort(usize, left.items, {}, comptime std.sort.asc(usize));
std.mem.sort(usize, right.items, {}, comptime std.sort.asc(usize));
```

Then I can just iterate over both lists at the same time since they are the same length, use `@abs(x - y)` or `@abs(y - x)` depending on
what is larger (there is probably a better way to do this) and then add that to total.

For part 2, I did basically the same thing but then iterated over the left hand list once, and then for each iteration of that list, I iterated over the right
hand list entirely. I counted how many times the current number occured in the right list, and multiplied that by the current number. I then added that to
a variable in the outer scope to tally the total.

I used a fun little `labeled block` that evaluates some expression and returns that value. [info on labeled blocks](https://zig.guide/master/language-basics/labelled-blocks)
which is one of the coolest things in `Zig` in my opinion. It's a neat way to express things.

but it was as simple as doing:

```zig
    var total: u64 = 0;

    for (left.items) |x| {
        const c = blk: {
            var counter: u64 = 0;
            for (right.items) |y| {
                if (x == y) {
                    counter += 1;
                }
            }
            break :blk counter;
        };
```

where `left.items` and `right.items` are lists (or arrays, slices, etc...) of the same type.
