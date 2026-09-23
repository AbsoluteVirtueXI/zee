const std = @import("std");
const Allocator = std.mem.Allocator;
const Writer = std.Io.Writer;

pub const TeeConfig = struct {
    gpa: Allocator,
    append_mode: bool = false,
    file_paths: std.ArrayList([]const u8) = .empty,

    const Self = @This();

    pub fn init(gpa: Allocator) !Self {
        return .{
            .gpa = gpa,
            .append_mode = false,
            .file_paths = try .initCapacity(gpa, 5),
        };
    }

    pub fn setAppendMode(self: *Self, is_append: bool) void {
        self.append_mode = is_append;
    }

    pub fn addFilePath(self: *Self, file_path: []const u8) !void {
        try self.file_paths.append(self.gpa, file_path);
    }

    pub fn nbFiles(self: Self) usize {
        return self.file_paths.items.len;
    }

    pub fn deinit(self: *Self) void {
        self.file_paths.deinit(self.gpa);
    }
};

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
    _ = stderr;

    var args = try init.minimal.args.iterateAllocator(gpa);
    defer args.deinit();

    // Skip the 1st argument which is the program name.
    _ = args.skip();

    var tee_config: TeeConfig = try .init(gpa);
    defer tee_config.deinit();

    // NEXT: Handle "--": all subsequent arguments are file paths.
    // NEXT: Treat "-" alone as a file path.
    // NEXT: Reject unknown options before "--".
    // NEXT: If adding options that take values, allow values starting with "-".
    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "-h") or std.mem.eql(u8, arg, "--help")) {
            try showUsage(stdout);
            return;
        } else if (std.mem.eql(u8, arg, "-a") or std.mem.eql(u8, arg, "--append")) {
            tee_config.setAppendMode(true);
        } else {
            try tee_config.addFilePath(arg);
        }
    }

    try stdout.print("{any}\n", .{tee_config});
    try stdout.flush();

    for (tee_config.file_paths.items) |file_path| {
        try stdout.print("{s}\n", .{file_path});
    }
    try stdout.flush();
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
