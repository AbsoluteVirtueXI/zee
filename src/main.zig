const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    //const gpa = init.gpa;

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

    try stdout.writeAll("stdout test.\n");
    try stdout.flush();

    try stderr.writeAll("stderr test.\n");
    try stderr.flush();
}
