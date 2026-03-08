const std = @import("std");
const Allocator = std.mem.Allocator;
const WebView = @import("webview").WebView;
const clap = @import("clap");
const ArgParse = @import("ArgParse.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const params =
        \\-h, --help        Display this help message.
        \\<URL>             url to open in the webview.
        \\
    ;

    var arg_parser = try ArgParse.ArgParser(params).init(allocator);
    defer arg_parser.deinit();

    const url = try arg_parser.parse();

    const w = WebView.create(false, null);
    defer w.destroy() catch {};

    try w.setTitle("Typst Preview");
    try w.navigate(url);
    try w.run();
}
