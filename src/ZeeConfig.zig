const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const Self = @This();

gpa: Allocator,
append_mode: bool = false,
file_paths: ArrayList([]const u8) = .empty,

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
