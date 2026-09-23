const std = @import("std");
const Reader = std.Io.Reader;
const Writer = std.Io.Writer;

const Self = @This();

const buffer_size = 1024;
const Buffer = [buffer_size]u8;

_stdin_buffer_reader: Buffer = undefined,
_stdout_buffer_writer: Buffer = undefined,
_stderr_buffer_writer: Buffer = undefined,
stdin_reader: std.Io.File.Reader,
stdout_writer: std.Io.File.Writer,
stderr_writer: std.Io.File.Writer,

pub fn init(self: *Self, io: std.Io) void {
    self.stdin_reader = .initStreaming(.stdin(), io, &self._stdin_buffer_reader);
    self.stdout_writer = .initStreaming(.stdout(), io, &self._stdout_buffer_writer);
    self.stderr_writer = .initStreaming(.stderr(), io, &self._stderr_buffer_writer);
}

pub fn stdin(self: *Self) *Reader {
    return &self.stdin_reader.interface;
}

pub fn stdout(self: *Self) *Writer {
    return &self.stdout_writer.interface;
}

pub fn stderr(self: *Self) *Writer {
    return &self.stderr_writer.interface;
}
