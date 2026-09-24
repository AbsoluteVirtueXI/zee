const std = @import("std");
const Allocator = std.mem.Allocator;

const ZeeConfig = @import("ZeeConfig.zig");
const StdIo = @import("StdIo.zig");

//pub fn exec(gpa: Allocator, io: std.Io, config: ZeeConfig, stdio: StdIo) !void {
//    var readBuffer: [4096]u8 = undefined;
//
//    const bytes = try stdio.stdin().readVec(data: [][]u8)

//    const files: std.ArrayList(std.Io.File) = .empty;
//const file_buffer_writers: std.ArrayList([1024]u8) = .empty;
//    for (config.file_paths) |file_path| {
//        const file = try std.Io.Dir.cwd().createFile(io, file_path, .{ .truncate = !config.append_mode });
//        files.append(gpa, file);
//        if (config.append_mode) {}
//    }
//}
