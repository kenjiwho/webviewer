const App = @This();

const Args = @import("ArgParse.zig").Args;
const WebView = @import("webview").WebView;

url: [:0]u8,
title: [:0]u8,

pub fn init(args: Args) App {
    return App{
        .url = args.url,
        .title = args.title,
    };
}

pub fn run(self: *const App) !void {
    const w = WebView.create(false, null);
    defer w.destroy() catch {};

    try w.setTitle(self.title);
    try w.navigate(self.url);
    try w.run();
}
