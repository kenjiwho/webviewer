const App = @This();

const Args = @import("ArgParse.zig").Args;
const WebView = @import("webview").WebView;

webview: WebView,

pub fn init(args: Args) !App {
    const webview = WebView.create(false, null);
    try webview.setTitle(args.title);

    try initKeybinds(webview);

    try webview.navigate(args.url);

    return App{ .webview = webview };
}

pub fn deinit(self: *const App) void {
    self.webview.destroy() catch {};
}

pub fn run(self: *const App) !void {
    try self.webview.run();
}

fn initKeybinds(webview: WebView) !void {
    const js =
        \\window.addEventListener('keydown', function(e) {
        \\    if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA' || e.target.isContentEditable) return;
        \\    const scrollAmount = window.innerHeight / 2;
        \\    const lineAmount = 100;
        \\    if (e.key === 'j' && !e.ctrlKey && !e.metaKey && !e.altKey && !e.shiftKey) {
        \\        window.scrollBy({top: lineAmount, behavior: 'smooth'});
        \\    } else if (e.key === 'k' && !e.ctrlKey && !e.metaKey && !e.altKey && !e.shiftKey) {
        \\        window.scrollBy({top: -lineAmount, behavior: 'smooth'});
        \\    } else if (e.key === 'd' && e.ctrlKey && !e.metaKey && !e.altKey && !e.shiftKey) {
        \\        window.scrollBy({top: scrollAmount, behavior: 'smooth'});
        \\        e.preventDefault();
        \\    } else if (e.key === 'u' && e.ctrlKey && !e.metaKey && !e.altKey && !e.shiftKey) {
        \\        window.scrollBy({top: -scrollAmount, behavior: 'smooth'});
        \\        e.preventDefault();
        \\    }
        \\});
    ;
    try webview.init(js);
}
