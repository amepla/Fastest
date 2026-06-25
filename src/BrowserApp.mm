#import "BrowserApp.h"
#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface BrowserWindowController : NSWindowController <WKNavigationDelegate, NSTextFieldDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSTextField *addressField;
@property (nonatomic, strong) NSButton *backButton;
@property (nonatomic, strong) NSButton *forwardButton;
@property (nonatomic, strong) NSButton *reloadButton;
@property (nonatomic, strong) NSButton *homeButton;
@end

@implementation BrowserWindowController

- (instancetype)init {
    NSRect frame = NSMakeRect(0, 0, 1280, 840);
    NSUInteger style = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable | NSWindowStyleMaskMiniaturizable;
    NSWindow *window = [[NSWindow alloc] initWithContentRect:frame styleMask:style backing:NSBackingStoreBuffered defer:NO];
    self = [super initWithWindow:window];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (NSString *)homeHTML {
    return @"<!DOCTYPE html>\n"
    "<html lang=\"en\">\n"
    "<head>\n"
    "  <meta charset=\"UTF-8\">\n"
    "  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n"
    "  <title>MacBrowser</title>\n"
    "  <style>\n"
    "    body{margin:0;background:#070707;color:#f5f0e8;font-family:-apple-system,BlinkMacSystemFont,Helvetica,Arial,sans-serif;line-height:1.6;}\n"
    "    header{min-height:100vh;display:flex;flex-direction:column;justify-content:center;padding:48px;box-sizing:border-box;background:linear-gradient(180deg,rgba(10,10,10,1) 0%,rgba(18,18,18,1) 100%);}\n"
    "    h1{font-size:clamp(3rem,7vw,5.5rem);margin:0 0 18px;letter-spacing:-0.05em;font-weight:700;color:#fff;}\n"
    "    p.lead{max-width:780px;font-size:1.15rem;color:#d9c7b3;margin:0 0 36px;}\n"
    "    ul{max-width:720px;margin:0;padding:0;list-style:none;display:grid;gap:18px;}\n"
    "    li{display:grid;gap:10px;padding:24px;border:1px solid rgba(255,255,255,0.08);border-radius:24px;background:rgba(255,255,255,0.02);backdrop-filter:blur(8px);}\n"
    "    li strong{display:block;font-size:1.05rem;color:#fff;margin-bottom:6px;}\n"
    "    li span{color:#b9ab99;}\n"
    "    footer{padding:40px 48px 48px;color:#8a7c6b;font-size:0.95rem;}\n"
    "    @media(max-width:760px){header{padding:28px;}li{padding:18px;}h1{font-size:3.5rem;}}\n"
    "  </style>\n"
    "</head>\n"
    "<body>\n"
    "  <header>\n"
    "    <h1>MacBrowser — premium browsing, designed to feel substantial.</h1>\n"
    "    <p class=\"lead\">A browser interface built with restraint, hierarchy, clear contrast, and subtle motion. Tap the address bar or use Home, Back, Forward, Reload to move with intent.</p>\n"
    "    <ul>\n"
    "      <li><strong>Point of view, not a template.</strong><span>Clean dark UI, purposeful controls, no visual clutter.</span></li>\n"
    "      <li><strong>Typography that does work.</strong><span>Large headings, readable body text, consistent spacing.</span></li>\n"
    "      <li><strong>A restrained color system.</strong><span>Black, off-white and a warm accent maintain premium tone.</span></li>\n"
    "      <li><strong>Hierarchy that breathes.</strong><span>Whitespace and contrast show where to look without effort.</span></li>\n"
    "      <li><strong>Motion that whispers.</strong><span>Buttons and page states feel crafted, not loud.</span></li>\n"
    "    </ul>\n"
    "  </header>\n"
    "  <footer>MacBrowser by user, following the $10K Checklist.</footer>\n"
    "</body>\n"
    "</html>\n";
}

- (void)setupUI {
    NSWindow *window = self.window;
    NSView *contentView = window.contentView;
    window.backgroundColor = [NSColor colorWithWhite:0.04 alpha:1.0];
    [window setTitle:@"MacBrowser"];
    [window center];

    CGFloat toolbarHeight = 60;
    NSView *toolbar = [[NSView alloc] initWithFrame:NSMakeRect(0, contentView.bounds.size.height - toolbarHeight, contentView.bounds.size.width, toolbarHeight)];
    toolbar.wantsLayer = YES;
    toolbar.layer.backgroundColor = [[NSColor colorWithWhite:0.05 alpha:0.95] CGColor];
    toolbar.autoresizingMask = NSViewWidthSizable | NSViewMinYMargin;
    [contentView addSubview:toolbar];

    CGFloat buttonWidth = 78;
    CGFloat buttonHeight = 34;
    CGFloat buttonY = 13;
    CGFloat x = 16;

    self.homeButton = [[NSButton alloc] initWithFrame:NSMakeRect(x, buttonY, buttonWidth, buttonHeight)];
    self.homeButton.title = @"Home";
    self.homeButton.bezelStyle = NSBezelStyleRounded;
    self.homeButton.font = [NSFont systemFontOfSize:13 weight:NSFontWeightSemibold];
    self.homeButton.target = self;
    self.homeButton.action = @selector(goHome:);
    [toolbar addSubview:self.homeButton];
    x += buttonWidth + 8;

    self.backButton = [[NSButton alloc] initWithFrame:NSMakeRect(x, buttonY, buttonWidth, buttonHeight)];
    self.backButton.title = @"Back";
    self.backButton.bezelStyle = NSBezelStyleRounded;
    self.backButton.font = [NSFont systemFontOfSize:13 weight:NSFontWeightSemibold];
    self.backButton.target = self;
    self.backButton.action = @selector(goBack:);
    [toolbar addSubview:self.backButton];
    x += buttonWidth + 8;

    self.forwardButton = [[NSButton alloc] initWithFrame:NSMakeRect(x, buttonY, buttonWidth, buttonHeight)];
    self.forwardButton.title = @"Forward";
    self.forwardButton.bezelStyle = NSBezelStyleRounded;
    self.forwardButton.font = [NSFont systemFontOfSize:13 weight:NSFontWeightSemibold];
    self.forwardButton.target = self;
    self.forwardButton.action = @selector(goForward:);
    [toolbar addSubview:self.forwardButton];
    x += buttonWidth + 8;

    self.reloadButton = [[NSButton alloc] initWithFrame:NSMakeRect(x, buttonY, buttonWidth, buttonHeight)];
    self.reloadButton.title = @"Reload";
    self.reloadButton.bezelStyle = NSBezelStyleRounded;
    self.reloadButton.font = [NSFont systemFontOfSize:13 weight:NSFontWeightSemibold];
    self.reloadButton.target = self;
    self.reloadButton.action = @selector(reloadPage:);
    [toolbar addSubview:self.reloadButton];
    x += buttonWidth + 12;

    CGFloat addressWidth = toolbar.bounds.size.width - x - 18;
    NSRect addressFrame = NSMakeRect(x, buttonY, addressWidth, buttonHeight);
    self.addressField = [[NSTextField alloc] initWithFrame:addressFrame];
    self.addressField.autoresizingMask = NSViewWidthSizable;
    self.addressField.placeholderString = @"Search or enter web address";
    self.addressField.font = [NSFont systemFontOfSize:14 weight:NSFontWeightRegular];
    self.addressField.drawsBackground = YES;
    self.addressField.backgroundColor = [NSColor colorWithWhite:0.11 alpha:1.0];
    self.addressField.textColor = [NSColor colorWithWhite:0.95 alpha:1.0];
    self.addressField.bezelStyle = NSTextFieldRoundedBezel;
    self.addressField.focusRingType = NSFocusRingTypeExterior;
    self.addressField.delegate = self;
    [toolbar addSubview:self.addressField];

    NSRect webFrame = NSMakeRect(0, 0, contentView.bounds.size.width, contentView.bounds.size.height - toolbarHeight);
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.preferences.javaScriptEnabled = YES;
    self.webView = [[WKWebView alloc] initWithFrame:webFrame configuration:config];
    self.webView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    self.webView.navigationDelegate = self;
    self.webView.allowsBackForwardNavigationGestures = YES;
    [contentView addSubview:self.webView];

    [self goHome:nil];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(insertNewline:)) {
        [self loadAddress:self.addressField.stringValue];
        return YES;
    }
    return NO;
}

- (void)goHome:(id)sender {
    [self.webView loadHTMLString:[self homeHTML] baseURL:nil];
    self.addressField.stringValue = @"";
    self.backButton.enabled = NO;
    self.forwardButton.enabled = NO;
}

- (void)loadAddress:(NSString *)address {
    NSString *urlString = [address stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (urlString.length == 0) {
        return;
    }

    if (![urlString containsString:@"://"]) {
        urlString = [@"https://" stringByAppendingString:urlString];
    }

    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Invalid URL";
        alert.informativeText = @"Please enter a valid web address.";
        [alert runModal];
        return;
    }

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)goBack:(id)sender {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }
}

- (void)goForward:(id)sender {
    if ([self.webView canGoForward]) {
        [self.webView goForward];
    }
}

- (void)reloadPage:(id)sender {
    [self.webView reload];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSString *currentURL = webView.URL.absoluteString ?: @"";
    self.addressField.stringValue = currentURL;
    self.backButton.enabled = webView.canGoBack;
    self.forwardButton.enabled = webView.canGoForward;
}

@end

int BrowserApp::run(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        BrowserWindowController *controller = [[BrowserWindowController alloc] init];

        [app setActivationPolicy:NSApplicationActivationPolicyRegular];
        [app activateIgnoringOtherApps:YES];
        [app run];
    }
    return 0;
}
