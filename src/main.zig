const std = @import("std");
const ArgParse = @import("ArgParse.zig");
const App = @import("App.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const params =
        \\-h, --help            Display this help message.
        \\-t, --title <STR>     Title of the webview window.
        \\<URL>                 url to open in the webview.
        \\
    ;

    var arg_parser = try ArgParse.ArgParser(params).init(allocator);
    defer arg_parser.deinit();

    const args = try arg_parser.parse();

    const app = try App.init(args);
    defer app.deinit();

    try app.run();
}
