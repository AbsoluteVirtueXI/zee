const std = @import("std");
const Allocator = std.mem.Allocator;
const Writer = std.Io.Writer;

const ZeeConfig = @import("ZeeConfig.zig");
const StdIo = @import("StdIo.zig");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const gpa = init.gpa;

    var stdio: StdIo = undefined;
    stdio.init(io);
    const stdin = stdio.stdin();
    _ = stdin;
    const stdout = stdio.stdout();
    const stderr = stdio.stderr();
    _ = stderr;

    var args = try init.minimal.args.iterateAllocator(gpa);
    defer args.deinit();

    // Skip the 1st argument which is the program name.
    _ = args.skip();

    var zee_config: ZeeConfig = try .init(gpa);
    defer zee_config.deinit();

    // NEXT: Handle "--": all subsequent arguments are file paths.
    // NEXT: Treat "-" alone as a file path.
    // NEXT: Reject unknown options before "--".
    // NEXT: If adding options that take values, allow values starting with "-".
    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "-h") or std.mem.eql(u8, arg, "--help")) {
            try showUsage(stdout);
            return;
        } else if (std.mem.eql(u8, arg, "-a") or std.mem.eql(u8, arg, "--append")) {
            zee_config.setAppendMode(true);
        } else {
            try zee_config.addFilePath(arg);
        }
    }

    try stdout.print("{any}\n", .{zee_config});
    try stdout.flush();

    for (zee_config.file_paths.items) |file_path| {
        try stdout.print("{s}\n", .{file_path});
    }
    try stdout.flush();
}

const help_text =
    \\Usage: zee [OPTION]... [FILE]...
    \\Copy standard input to each FILE, and also to starnard output.
    \\
    \\-a, --append      append to the given FILEs, do not overwirte.
    \\-h, --help        display this help and exit
    \\
;
pub fn showUsage(writer: *Writer) !void {
    try writer.print("{s}", .{help_text});
    try writer.flush();
    return;
}
