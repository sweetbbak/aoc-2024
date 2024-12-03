const std = @import("std");
const assert = std.debug.assert;
const mem = @import("std").mem;
const sort = @import("std").sort;
const Allocator = @import("std").mem.Allocator;

fn parse_numbers(list: []u8) !bool {
    // check that it is sorted asc or desc...
    // check that the difference between each number is between 1 and 3
    const is_asc = sort.isSorted(u8, list, {}, sort.asc(u8));
    const is_desc = sort.isSorted(u8, list, {}, sort.desc(u8));
    std.log.debug("list: {any} : sorted {any}", .{ list, (is_asc or is_desc) });

    // not a good list
    if (!is_asc and !is_desc) {
        return false;
    }

    var first = list[0];

    var i: u16 = 1;
    while (i < list.len) : (i += 1) {
        const cur = list[i];
        var diff: u8 = 0;

        diff = if (first > cur) first - cur else cur - first;

        if (diff < 1 or diff > 3) {
            return false;
        }

        first = cur;
    }

    return true;
}

fn part2(list: []u8) !bool {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    
    for (list, 0..) |_, i| {
        var newlist = std.ArrayList(u8).init(allocator);
        defer newlist.deinit();

        for (list, 0..) |val, x| {
            if (x == i) continue;
            try newlist.append(val);
        }

        const _list = try newlist.toOwnedSlice();
        defer allocator.free(_list);

        const good = try parse_numbers(_list);
        if (good) return true;
    }
    return false;
}

pub fn daytwo(allocator: Allocator) !void {
    const file = try std.fs.cwd().openFile("./input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var counter: usize = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var list = std.ArrayList(u8).init(allocator);
        defer list.deinit();

        var strings = mem.splitScalar(u8, line, ' ');

        while (strings.next()) |value| {
            const tempint = std.fmt.parseInt(u8, value, 10) catch |err| {
                std.debug.print("unable to parse int {s}: {s}", .{ value, @errorName(err) });
                return err;
            };

            try list.append(tempint);
        }

        const output = try list.toOwnedSlice();
        defer allocator.free(output);

        const is_good = part2(output) catch |err| {
            std.log.err("error: {s}", .{@errorName(err)});
            @panic(@errorName(err));
        };

        if (is_good) counter += 1;
    }

    std.debug.print("final count: {d}\n", .{counter});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    try daytwo(allocator);
}
