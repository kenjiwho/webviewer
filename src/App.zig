const App = @This();

const Args = @import("ArgParse.zig").Args;
const WebView = @import("webview").WebView;

webview: WebView,

pub fn init(args: Args) !App {
    const w = WebView.create(false, null);
    try w.setTitle(args.title);

    try initKeybinds(w);

    try w.navigate(args.url);

    return App{ .webview = w };
}

pub fn deinit(self: *const App) void {
    self.webview.destroy() catch {};
}

pub fn run(self: *const App) !void {
    try self.webview.run();
}

fn initKeybinds(w: WebView) !void {
    const js =
        \\(function() {
        \\    function performScroll(amount) {
        \\        // Try window and scrolling element
        \\        window.scrollBy({top: amount, behavior: 'smooth'});
        \\        const scroller = document.scrollingElement || document.documentElement || document.body;
        \\        if (scroller && scroller !== window) {
        \\            scroller.scrollBy({top: amount, behavior: 'smooth'});
        \\        }
        \\
        \\        // Fallback: Search for any element with overflow
        \\        const all = document.querySelectorAll('div, section, article');
        \\        for (let i = 0; i < all.length; i++) {
        \\            const el = all[i];
        \\            const style = window.getComputedStyle(el);
        \\            if ((style.overflowY === 'auto' || style.overflowY === 'scroll') && el.scrollHeight > el.clientHeight) {
        \\                el.scrollBy({top: amount, behavior: 'smooth'});
        \\            }
        \\        }
        \\    }
        \\
        \\    window.addEventListener('keydown', function(e) {
        \\        // Ignore if focused on input
        \\        if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA' || e.target.isContentEditable) return;
        \\
        \\        const key = e.key.toLowerCase();
        \\        const scrollAmount = window.innerHeight / 2;
        \\        const lineAmount = 100;
        \\
        \\        let handled = false;
        \\        if (key === 'j' && !e.ctrlKey && !e.metaKey && !e.altKey && !e.shiftKey) {
        \\            performScroll(lineAmount);
        \\            handled = true;
        \\        } else if (key === 'k' && !e.ctrlKey && !e.metaKey && !e.altKey && !e.shiftKey) {
        \\            performScroll(-lineAmount);
        \\            handled = true;
        \\        } else if (key === 'd' && e.ctrlKey && !e.metaKey && !e.altKey && !e.shiftKey) {
        \\            performScroll(scrollAmount);
        \\            handled = true;
        \\        } else if (key === 'u' && e.ctrlKey && !e.metaKey && !e.altKey && !e.shiftKey) {
        \\            performScroll(-scrollAmount);
        \\            handled = true;
        \\        }
        \\
        \\        if (handled) {
        \\            e.preventDefault();
        \\            e.stopPropagation();
        \\        }
        \\    }, true); // Use capture phase to intercept before page handlers
        \\})();
    ;
    try w.init(js);
}
