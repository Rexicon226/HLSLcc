const std = @import("std");

extern fn TranslateHLSLFromMem(shader: [*:0]const u8) i32;

pub fn main() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);
    if (args.len != 2) @panic("wrong amount of args");

    const file_path = args[1];
    const contents = try std.fs.cwd().readFileAllocOptions(
        allocator,
        file_path,
        100 * 1024 * 1024,
        null,
        @alignOf(u8),
        0,
    );
    defer allocator.free(contents);

    const result = TranslateHLSLFromMem(contents.ptr);
    std.debug.print("result: {}\n", .{result});
}
