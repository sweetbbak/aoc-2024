//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const std = @import("std");
const mem = std.mem;
const Allocator = std.mem.Allocator;
const assert = @import("std").testing.assert;

pub fn readfile(allocator: Allocator) !void {
    const contents = try std.fs.cwd().readFileAlloc(allocator, "../input.txt", std.math.maxInt(usize));
    defer allocator.free(contents);
}

pub fn dayonep2(allocator: Allocator) !void {
    const file = try std.fs.cwd().openFile("./input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;

    // left column of numbers
    var left = std.ArrayList(usize).init(allocator);
    defer left.deinit();

    // right column of numbers
    var right = std.ArrayList(usize).init(allocator);
    defer right.deinit();

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var strings = mem.splitSequence(u8, line, "   ");

        var i: u8 = 0;
        while (strings.next()) |value| {
            const tempint = std.fmt.parseInt(usize, value, 10) catch |err| {
                std.debug.print("unable to parse int {s}: {s}", .{ value, @errorName(err) });
                return err;
            };

            // this is stupid but whatever
            if (i == 0) {
                try left.append(tempint);
            } else if (i == 1) {
                try right.append(tempint);
            } else {
                @panic("incorrect arg count for this line");
            }

            i += 1;
        }
    }

    std.mem.sort(usize, left.items, {}, comptime std.sort.asc(usize));
    std.mem.sort(usize, right.items, {}, comptime std.sort.asc(usize));

    // similarity score
    // for each number in the left column we check how many times it appears
    // and we multiply that number by the number of times it appears
    // and then we add them all together
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

        std.debug.print("{d} appears {d} times\n", .{x, c});
        total += (x * c);
    }

    std.debug.print("final similarity score: {d}\n", .{total});
    return;
}

pub fn dayone(allocator: Allocator) !void {
    const file = try std.fs.cwd().openFile("./input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;

    // left column of numbers
    var left = std.ArrayList(usize).init(allocator);
    defer left.deinit();

    // right column of numbers
    var right = std.ArrayList(usize).init(allocator);
    defer right.deinit();

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var strings = mem.splitSequence(u8, line, "   ");

        var i: u8 = 0;
        while (strings.next()) |value| {
            const tempint = std.fmt.parseInt(usize, value, 10) catch |err| {
                std.debug.print("unable to parse int {s}: {s}", .{ value, @errorName(err) });
                return err;
            };

            // this is stupid but whatever
            if (i == 0) {
                try left.append(tempint);
            } else if (i == 1) {
                try right.append(tempint);
            } else {
                @panic("incorrect arg count for this line");
            }

            i += 1;
        }
    }

    std.mem.sort(usize, left.items, {}, comptime std.sort.asc(usize));
    std.mem.sort(usize, right.items, {}, comptime std.sort.asc(usize));

    var total: u64 = 0;

    for (left.items, right.items) |x, y| {
        const value: usize = if (x > y) @abs(x - y) else @abs(y - x);
        std.debug.print("{d} : {d} = {d}\n", .{ x, y, value });
        total += value;
    }

    std.debug.print("final total of absolute difference: {d}\n", .{total});
    return;
}

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    try bw.flush();
    // try dayone(allocator);
    try dayonep2(allocator);
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // Try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "fuzz example" {
    const global = struct {
        fn testOne(input: []const u8) anyerror!void {
            // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!
            try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
        }
    };
    try std.testing.fuzz(global.testOne, .{});
}
