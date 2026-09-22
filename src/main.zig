const std = @import("std");
const Writer = std.Io.Writer;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const gpa = init.gpa;

    var stdout_buffer_writer: [1024]u8 = undefined;
    var stdout_writer: std.Io.File.Writer = .initStreaming(.stdout(), io, &stdout_buffer_writer);
    const stdout = &stdout_writer.interface;

    var stdin_buffer_reader: [1024]u8 = undefined;
    var stdin_reader: std.Io.File.Reader = .initStreaming(.stdin(), io, &stdin_buffer_reader);
    const stdin = &stdin_reader.interface;
    _ = stdin;

    var stderr_buffer_writer: [1024]u8 = undefined;
    var stderr_writer: std.Io.File.Writer = .initStreaming(.stderr(), io, &stderr_buffer_writer);
    const stderr = &stderr_writer.interface;

    var args = try init.minimal.args.iterateAllocator(gpa);
    defer args.deinit();

    const prog_name = args.next() orelse "zee";
    _ = prog_name;

    const next_arg = args.next() orelse {
        try showUsage(stderr);
        return;
    };

    if (std.mem.eql(u8, next_arg, "-h") or std.mem.eql(u8, next_arg, "--help")) {
        try showUsage(stdout);
        return;
    }
}

const help_text =
    \\Usage: tee [OPTION]... [FILE]...
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
