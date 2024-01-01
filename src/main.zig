// Title: A computer game version of Mastermind (Zig Mastermind)
// Version: 0.1.0
// Author: Lukas Moeller
// License: MIT License
//
//
// ⚡️ZIG MASTERMIND
//
// The play of the game goes as follows:
//
// 1) The computer, the "Codemaker", generates a random 4-digit code consisting of numbers from 0 to 9.
//
// 2) The Codebreakers (the player) task is to guess this code within a limited number
// of attempts (12 attempts). To make a guess the player enters a 4-digit number using the
// keyboard.
//
// 3) The Codemaker responds by placing 0, 1, 2, 3, and/or 4 special symbols to help the Codebreaker.
// The special symbols work as follows:
// (a) An asterisk `*` indicates that a number in the duess is both correct and in the correct position.
// (b) A plus sign `+` indicates that a number in the guess is correct but in the wrong position.
//
//
// There is nothing about the placement of the special symbols to indicate which particular code
// numbers are meant. It is part of the challenge of the game for the Codebreaker to figure out
// which code numbers correspond to particular special symbols. The response when 2 of the
// same numbers appear in the secret code and/or in the Codebreaker's row can cause some
// confusion. The basic principles are that one special symbol corresponds to one code number
// and, that the asterisk `*` special symbol takes precedence over a plus `+` one.

const std = @import("std");
const stdout = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();
const RndGen = std.rand.DefaultPrng;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

pub fn main() anyerror!void {
    // create general purpose allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const gpalloc = gpa.allocator();

    // generate the code that needs to be cracked by the code breaker
    const code = sliceOfDigits(generateRandomU16());

    var counter: u8 = 0;

    // main routine
    // loop N times and get user input for the guesses
    while (true) {
        // the code breaker has twelve tries to crack the code
        if (counter == 12) {
            try stdout.print("\n🔒 {d}\n", .{code});
            try stdout.print("\ncode not cracked\n", .{});
            break;
        }

        // get user input
        const raw_input = try stdin.readUntilDelimiterOrEofAlloc(gpalloc, '\n', 8192);
        var input: []u8 = undefined;

        if (raw_input) |m| {
            if (m.len < 4) {
                gpalloc.free(m);
                continue;
            } else if (m.len > 4) {
                gpalloc.free(m);
                continue;
            }
            input = m;
        } else {
            try stdout.print("\n\nend program\n", .{});
            break;
        }
        defer gpalloc.free(input);
        counter += 1;

        const codebreaker_num = try std.fmt.parseInt(u16, input, 10);
        const codebreaker_sequence = sliceOfDigits(codebreaker_num);
        var list = ArrayList(u8).init(gpalloc);
        defer list.deinit();
        for (codebreaker_sequence) |n| {
            try list.append(n);
        }

        var results: [4]u8 = undefined;
        for (code, 0..) |n, i| {
            results[i] = '.';
            if (n == codebreaker_sequence[i]) {
                results[i] = '*';
                continue;
            } else {
                for (list.items, 0..) |n2, index| {
                    if (n == n2) {
                        results[i] = '+';
                        _ = list.orderedRemove(index);
                        break;
                    }
                }
            }
        }
        var rnd = RndGen.init(@intCast(std.time.timestamp()));
        std.rand.Random.shuffle(RndGen.random(&rnd), u8, &results);

        try stdout.print("[{c} {c} {c} {c}]\n", .{ results[0], results[1], results[2], results[3] });

        if (std.mem.eql(u8, &results, "****")) {
            try stdout.print("\n🔓 {d}\n", .{code});
            try stdout.print("\ncode cracked \n", .{});
            break;
        }
    }
}

fn generateRandomU16() u16 {
    var rnd = RndGen.init(@intCast(std.time.timestamp()));
    const some_random_num = @mod(rnd.random().int(u16), 9999);
    return some_random_num;
}

test "generateRandomU16" {
    const testCases = [_]u16{
        generateRandomU16(),
        generateRandomU16(),
        generateRandomU16(),
    };

    for (testCases) |rn| {
        try std.testing.expect(rn >= 1000 and rn <= 9999);
    }
}

fn sliceOfDigits(four_digit_number: u16) [4]u8 {
    const magic_number = four_digit_number;
    const magic_number_one = magic_number / 1000;
    const magic_number_two = magic_number / 100 - magic_number_one * 10;
    const magic_number_three = magic_number / 10 - magic_number_one * 100 - magic_number_two * 10;
    const magic_number_four = magic_number - magic_number_one * 1000 - magic_number_two * 100 - magic_number_three * 10;

    return [4]u8{
        @truncate(magic_number_one),
        @truncate(magic_number_two),
        @truncate(magic_number_three),
        @truncate(magic_number_four),
    };
}

test "sliceOfDigits" {
    const testCases = [_]SliceOfDigitsTestCases{
        .{ .actual = sliceOfDigits(1234), .expected = [4]u8{ 1, 2, 3, 4 } },
        .{ .actual = sliceOfDigits(8023), .expected = [4]u8{ 8, 0, 2, 3 } },
        .{ .actual = sliceOfDigits(71), .expected = [4]u8{ 0, 0, 7, 1 } },
    };

    for (testCases) |tc| {
        try std.testing.expectEqual(tc.expected, tc.actual);
    }
}

const SliceOfDigitsTestCases = struct {
    actual: [4]u8,
    expected: [4]u8,
};
