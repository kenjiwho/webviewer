const std = @import("std");
const clap = @import("clap");
const Allocator = std.mem.Allocator;
const ArgParse = @This();

pub const Args = struct {
    url: [:0]u8,
    title: [:0]u8,
};

pub fn ArgParser(params_str: []const u8) type {
    const params = comptime clap.parseParamsComptime(params_str);

    const parsers = comptime .{
        .URL = clap.parsers.string,
        .STR = clap.parsers.string,
    };

    return struct {
        const Self = @This();

        url: [:0]u8 = undefined,
        title: [:0]u8 = undefined,
        allocator: Allocator,
        res: clap.Result(clap.Help, &params, parsers),

        pub fn init(allocator: Allocator) !Self {
            var diag = clap.Diagnostic{};

            const res = clap.parse(clap.Help, &params, parsers, .{
                .diagnostic = &diag,
                .allocator = allocator,
                .assignment_separators = "=",
            }) catch |err| {
                diag.report(std.io.getStdErr().writer(), err) catch {};
                return err;
            };

            return Self{
                .allocator = allocator,
                .res = res,
            };
        }

        pub fn deinit(self: Self) void {
            self.res.deinit();
            self.allocator.free(self.url);
            self.allocator.free(self.title);
        }

        pub fn parse(self: *Self) !Args {
            if (self.res.args.help != 0) {
                try printHelp();
                std.process.exit(0);
            }
            if (self.res.positionals[0] == null) {
                try printHelp();
                std.process.exit(1);
            }
            self.url = try self.allocator.dupeZ(u8, self.res.positionals[0].?);
            self.title = try self.allocator.dupeZ(
                u8,
                self.res.args.title orelse "webview window",
            );

            return .{ .url = self.url, .title = self.title };
        }

        fn printHelp() !void {
            std.debug.print("Usage: webview-opener ", .{});
            try clap.usage(std.io.getStdOut().writer(), clap.Help, &params);
            std.debug.print("\n\nArguments:\n", .{});
            return clap.help(std.io.getStdOut().writer(), clap.Help, &params, .{});
        }
    };
}
