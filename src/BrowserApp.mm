#import "BrowserApp.h"
#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <QuartzCore/QuartzCore.h>

static NSString * const kNewTabScheme = @"macbrowser";

static NSColor *MBColorInk(void) {
    return [NSColor colorWithCalibratedRed:6.0 / 255.0 green:6.0 / 255.0 blue:6.0 / 255.0 alpha:1.0];
}

static NSColor *MBColorCream(void) {
    return [NSColor colorWithCalibratedRed:244.0 / 255.0 green:239.0 / 255.0 blue:230.0 / 255.0 alpha:1.0];
}

static NSColor *MBColorCopper(void) {
    return [NSColor colorWithCalibratedRed:201.0 / 255.0 green:162.0 / 255.0 blue:122.0 / 255.0 alpha:1.0];
}

static NSURL *MBSearchURL(NSString *query) {
    NSString *encoded = [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://duckduckgo.com/?q=%@", encoded ?: @""]];
}

@interface MBToolbarButton : NSButton
@end

@implementation MBToolbarButton

- (void)mouseEntered:(NSEvent *)event {
    [super mouseEntered:event];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.12;
        self.animator.alphaValue = 1.0;
        self.animator.contentTintColor = MBColorCopper();
    } completionHandler:nil];
}

- (void)mouseExited:(NSEvent *)event {
    [super mouseExited:event];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.12;
        self.animator.alphaValue = 0.82;
        self.animator.contentTintColor = MBColorCream();
    } completionHandler:nil];
}

- (void)viewDidMoveToWindow {
    [super viewDidMoveToWindow];
    if (self.window) {
        NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                            options:NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow | NSTrackingInVisibleRect
                                                              owner:self
                                                           userInfo:nil];
        [self addTrackingArea:area];
    }
}

@end

@interface BrowserWindowController : NSWindowController <WKNavigationDelegate, WKScriptMessageHandler, NSSearchFieldDelegate, NSWindowDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSSearchField *addressField;
@property (nonatomic, strong) MBToolbarButton *backButton;
@property (nonatomic, strong) MBToolbarButton *forwardButton;
@property (nonatomic, strong) MBToolbarButton *reloadButton;
@property (nonatomic, strong) MBToolbarButton *homeButton;
@property (nonatomic, assign) BOOL onNewTabPage;
@property (nonatomic, strong) NSString *startPageMarkup;
@end

@implementation BrowserWindowController

- (instancetype)init {
    NSRect frame = NSMakeRect(0, 0, 1280, 840);
    NSUInteger style = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable | NSWindowStyleMaskMiniaturizable;
    NSWindow *window = [[NSWindow alloc] initWithContentRect:frame styleMask:style backing:NSBackingStoreBuffered defer:NO];
    self = [super initWithWindow:window];
    if (self) {
        [self setupMenu];
        [self setupUI];
    }
    return self;
}

- (void)setupMenu {
    NSMenu *mainMenu = [[NSMenu alloc] init];

    NSMenuItem *appMenuItem = [[NSMenuItem alloc] init];
    NSMenu *appMenu = [[NSMenu alloc] initWithTitle:@"MacBrowser"];
    [appMenu addItemWithTitle:@"Quit MacBrowser" action:@selector(terminate:) keyEquivalent:@"q"];
    appMenuItem.submenu = appMenu;
    [mainMenu addItem:appMenuItem];

    NSMenuItem *navMenuItem = [[NSMenuItem alloc] init];
    NSMenu *navMenu = [[NSMenu alloc] initWithTitle:@"Navigate"];
    [navMenu addItemWithTitle:@"New Tab" action:@selector(goHome:) keyEquivalent:@"t"];
    [[navMenu itemAtIndex:0] setKeyEquivalentModifierMask:NSEventModifierFlagCommand];
    [navMenu addItemWithTitle:@"Back" action:@selector(goBack:) keyEquivalent:@"["];
    [navMenu addItemWithTitle:@"Forward" action:@selector(goForward:) keyEquivalent:@"]"];
    [navMenu addItemWithTitle:@"Reload" action:@selector(reloadPage:) keyEquivalent:@"r"];
    [navMenu addItem:[NSMenuItem separatorItem]];
    [navMenu addItemWithTitle:@"Focus Address Bar" action:@selector(focusAddressBar:) keyEquivalent:@"l"];
    navMenuItem.submenu = navMenu;
    [mainMenu addItem:navMenuItem];

    [NSApp setMainMenu:mainMenu];
}

- (NSImage *)symbolImage:(NSString *)name pointSize:(CGFloat)size {
    NSImageSymbolConfiguration *config = [NSImageSymbolConfiguration configurationWithPointSize:size weight:NSFontWeightSemibold];
    NSImage *image = [NSImage imageWithSystemSymbolName:name accessibilityDescription:nil];
    return [image imageWithSymbolConfiguration:config];
}

- (MBToolbarButton *)makeToolbarButton:(NSString *)symbol toolTip:(NSString *)toolTip action:(SEL)action frame:(NSRect)frame inView:(NSView *)view {
    MBToolbarButton *button = [[MBToolbarButton alloc] initWithFrame:frame];
    button.image = [self symbolImage:symbol pointSize:14];
    button.imagePosition = NSImageOnly;
    button.bezelStyle = NSBezelStyleRegularSquare;
    button.bordered = NO;
    button.alphaValue = 0.82;
    button.contentTintColor = MBColorCream();
    button.toolTip = toolTip;
    button.target = self;
    button.action = action;
    [view addSubview:button];
    return button;
}

- (NSString *)loadNewTabHTML {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"newtab" ofType:@"html"];
    if (path) {
        NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        if (html.length > 0) {
            return html;
        }
    }

    NSString *devPath = [[[NSFileManager defaultManager] currentDirectoryPath] stringByAppendingPathComponent:@"resources/newtab.html"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:devPath]) {
        return [NSString stringWithContentsOfFile:devPath encoding:NSUTF8StringEncoding error:nil] ?: @"";
    }

    return @"<!DOCTYPE html><html><body style='background:#060606;color:#f4efe6;font:16px -apple-system,sans-serif;display:flex;align-items:center;justify-content:center;height:100vh'><form id=f><input id=q style='width:320px;padding:12px;border-radius:10px;border:1px solid #333;background:#111;color:#fff' placeholder='Search'/></form><script>f.onsubmit=e=>{e.preventDefault();const v=q.value.trim();if(v)webkit.messageHandlers.search.postMessage(v)}</script></body></html>";
}

- (void)setupUI {
    NSWindow *window = self.window;
    NSView *contentView = window.contentView;
    window.backgroundColor = MBColorInk();
    window.delegate = self;
    window.title = @"MacBrowser";
    window.movableByWindowBackground = NO;
    [window center];

    self.startPageMarkup = [self loadNewTabHTML];

    CGFloat toolbarHeight = 52;
    NSView *toolbar = [[NSView alloc] initWithFrame:NSMakeRect(0, contentView.bounds.size.height - toolbarHeight, contentView.bounds.size.width, toolbarHeight)];
    toolbar.wantsLayer = YES;
    toolbar.layer.backgroundColor = [NSColor colorWithCalibratedWhite:0.08 alpha:1.0].CGColor;
    toolbar.autoresizingMask = NSViewWidthSizable | NSViewMinYMargin;
    [contentView addSubview:toolbar];

    NSBox *separator = [[NSBox alloc] initWithFrame:NSMakeRect(0, 0, toolbar.bounds.size.width, 1)];
    separator.boxType = NSBoxSeparator;
    separator.borderColor = [MBColorCopper() colorWithAlphaComponent:0.2];
    separator.autoresizingMask = NSViewWidthSizable | NSViewMaxYMargin;
    [toolbar addSubview:separator];

    CGFloat control = 36;
    CGFloat y = (toolbarHeight - control) / 2.0;
    CGFloat x = 10;

    self.homeButton = [self makeToolbarButton:@"house.fill" toolTip:@"New tab" action:@selector(goHome:) frame:NSMakeRect(x, y, control, control) inView:toolbar];
    x += control + 2;
    self.backButton = [self makeToolbarButton:@"chevron.left" toolTip:@"Back" action:@selector(goBack:) frame:NSMakeRect(x, y, control, control) inView:toolbar];
    x += control + 2;
    self.forwardButton = [self makeToolbarButton:@"chevron.right" toolTip:@"Forward" action:@selector(goForward:) frame:NSMakeRect(x, y, control, control) inView:toolbar];
    x += control + 2;
    self.reloadButton = [self makeToolbarButton:@"arrow.clockwise" toolTip:@"Reload" action:@selector(reloadPage:) frame:NSMakeRect(x, y, control, control) inView:toolbar];
    x += control + 8;

    self.addressField = [[NSSearchField alloc] initWithFrame:NSMakeRect(x, y, toolbar.bounds.size.width - x - 10, control)];
    self.addressField.autoresizingMask = NSViewWidthSizable;
    self.addressField.placeholderString = @"Search or enter address";
    self.addressField.font = [NSFont systemFontOfSize:15 weight:NSFontWeightRegular];
    self.addressField.bezelStyle = NSTextFieldRoundedBezel;
    self.addressField.delegate = self;
    self.addressField.sendsSearchStringImmediately = NO;
    self.addressField.sendsWholeSearchString = YES;
    self.addressField.target = self;
    self.addressField.action = @selector(addressBarAction:);
    self.addressField.focusRingType = NSFocusRingTypeExterior;
    [toolbar addSubview:self.addressField];

    NSRect webFrame = NSMakeRect(0, 0, contentView.bounds.size.width, contentView.bounds.size.height - toolbarHeight);
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    WKWebpagePreferences *preferences = [[WKWebpagePreferences alloc] init];
    preferences.allowsContentJavaScript = YES;
    config.defaultWebpagePreferences = preferences;
    config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeAll;
    [config.userContentController addScriptMessageHandler:self name:@"search"];

    self.webView = [[WKWebView alloc] initWithFrame:webFrame configuration:config];
    self.webView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    self.webView.navigationDelegate = self;
    self.webView.allowsBackForwardNavigationGestures = YES;
    self.webView.allowsLinkPreview = YES;
    self.webView.underPageBackgroundColor = MBColorInk();
    [contentView addSubview:self.webView];

    [window makeKeyAndOrderFront:nil];
    [self goHome:nil];
}

- (void)addressBarAction:(id)sender {
    [self loadAddress:self.addressField.stringValue];
}

- (void)focusAddressBar:(id)sender {
    [self.window makeFirstResponder:self.addressField];
    [self.addressField selectText:nil];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (control == self.addressField && commandSelector == @selector(insertNewline:)) {
        [self loadAddress:self.addressField.stringValue];
        return YES;
    }
    return NO;
}

- (BOOL)looksLikeURL:(NSString *)input {
    if ([input containsString:@"://"]) {
        return YES;
    }
    if ([input rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]].location != NSNotFound) {
        return NO;
    }
    if ([input containsString:@"."] && ![input hasPrefix:@"."]) {
        return YES;
    }
    return NO;
}

- (void)updateNavigationButtons {
    if (self.onNewTabPage) {
        self.backButton.enabled = NO;
        self.forwardButton.enabled = NO;
        return;
    }
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
}

- (void)showNewTabPage {
    self.onNewTabPage = YES;
    NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://newtab/", kNewTabScheme]];
    [self.webView loadHTMLString:self.startPageMarkup baseURL:baseURL];
    self.addressField.stringValue = @"";
    [self updateNavigationButtons];
}

- (void)goHome:(id)sender {
    [self showNewTabPage];
}

- (void)loadAddress:(NSString *)address {
    NSString *trimmed = [address stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmed.length == 0) {
        return;
    }

    NSURL *url = nil;
    if ([self looksLikeURL:trimmed]) {
        NSString *urlString = trimmed;
        if (![urlString containsString:@"://"]) {
            urlString = [@"https://" stringByAppendingString:urlString];
        }
        url = [NSURL URLWithString:urlString];
    } else {
        url = MBSearchURL(trimmed);
    }

    if (!url) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Invalid address";
        alert.informativeText = @"Enter a URL or search query.";
        [alert runModal];
        return;
    }

    self.onNewTabPage = NO;
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)goBack:(id)sender {
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }
}

- (void)goForward:(id)sender {
    if (self.webView.canGoForward) {
        [self.webView goForward];
    }
}

- (void)reloadPage:(id)sender {
    if (self.onNewTabPage) {
        [self showNewTabPage];
        return;
    }
    [self.webView reload];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"search"] && [message.body isKindOfClass:[NSString class]]) {
        [self loadAddress:(NSString *)message.body];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSURL *url = webView.URL;
    if (self.onNewTabPage || [url.scheme isEqualToString:kNewTabScheme]) {
        self.onNewTabPage = YES;
        self.addressField.stringValue = @"";
    } else {
        self.onNewTabPage = NO;
        self.addressField.stringValue = url.absoluteString ?: @"";
    }
    [self updateNavigationButtons];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if (error.code == NSURLErrorCancelled) {
        return;
    }
    [self updateNavigationButtons];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = navigationAction.request.URL;
    if ([url.scheme isEqualToString:kNewTabScheme]) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)windowWillClose:(NSNotification *)notification {
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"search"];
    [NSApp terminate:nil];
}

@end

int BrowserApp::run(int /*argc*/, const char * /*argv*/[]) {
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        static __strong BrowserWindowController *windowController = nil;
        windowController = [[BrowserWindowController alloc] init];
        (void)windowController;

        [app setActivationPolicy:NSApplicationActivationPolicyRegular];
        [app activateIgnoringOtherApps:YES];
        [app run];
    }
    return 0;
}
