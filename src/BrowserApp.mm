#import "BrowserApp.h"
#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

static NSString * const kSearchHost = @"duckduckgo.com";
static NSString * const kStartPageURLString = @"https://duckduckgo.com/";

static NSColor *MBColorInk(void) {
    return [NSColor colorWithCalibratedRed:6.0 / 255.0 green:6.0 / 255.0 blue:6.0 / 255.0 alpha:1.0];
}

static NSColor *MBColorSurface(void) {
    return [NSColor colorWithCalibratedRed:14.0 / 255.0 green:14.0 / 255.0 blue:14.0 / 255.0 alpha:0.92];
}

static NSColor *MBColorCream(void) {
    return [NSColor colorWithCalibratedRed:244.0 / 255.0 green:239.0 / 255.0 blue:230.0 / 255.0 alpha:1.0];
}

static NSColor *MBColorCopper(void) {
    return [NSColor colorWithCalibratedRed:201.0 / 255.0 green:162.0 / 255.0 blue:122.0 / 255.0 alpha:1.0];
}

static NSColor *MBColorStone(void) {
    return [NSColor colorWithCalibratedRed:154.0 / 255.0 green:143.0 / 255.0 blue:130.0 / 255.0 alpha:1.0];
}

static NSURL *MBSearchURL(NSString *query) {
    NSString *encoded = [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://duckduckgo.com/?q=%@", encoded ?: @""]];
}

@interface BrowserWindowController : NSWindowController <WKNavigationDelegate, NSTextFieldDelegate, NSWindowDelegate>
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
    [navMenu addItemWithTitle:@"Start Page" action:@selector(goHome:) keyEquivalent:@"h"];
    [[navMenu itemAtIndex:0] setKeyEquivalentModifierMask:NSEventModifierFlagCommand | NSEventModifierFlagShift];
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
    NSImageSymbolConfiguration *config = [NSImageSymbolConfiguration configurationWithPointSize:size weight:NSFontWeightMedium];
    NSImage *image = [NSImage imageWithSystemSymbolName:name accessibilityDescription:nil];
    return [image imageWithSymbolConfiguration:config];
}

- (NSButton *)makeSymbolButton:(NSString *)symbol toolTip:(NSString *)toolTip action:(SEL)action frame:(NSRect)frame inView:(NSView *)view {
    NSButton *button = [[NSButton alloc] initWithFrame:frame];
    button.image = [self symbolImage:symbol pointSize:15];
    button.imagePosition = NSImageOnly;
    button.bezelStyle = NSBezelStyleTexturedRounded;
    button.bordered = NO;
    button.contentTintColor = MBColorCream();
    button.toolTip = toolTip;
    button.target = self;
    button.action = action;
    [view addSubview:button];
    return button;
}

- (BOOL)isOnStartPage {
    NSURL *url = self.webView.URL;
    if (!url) {
        return NO;
    }
    NSString *host = url.host.lowercaseString;
    if (![host isEqualToString:kSearchHost]) {
        return NO;
    }
    NSString *path = url.path.length > 0 ? url.path : @"/";
    return [path isEqualToString:@"/"] && (url.query.length == 0);
}

- (void)setupUI {
    NSWindow *window = self.window;
    NSView *contentView = window.contentView;
    window.backgroundColor = MBColorInk();
    window.titlebarAppearsTransparent = YES;
    window.styleMask |= NSWindowStyleMaskFullSizeContentView;
    window.delegate = self;
    [window setTitle:@"MacBrowser"];
    [window center];

    CGFloat toolbarHeight = 52;
    NSVisualEffectView *toolbar = [[NSVisualEffectView alloc] initWithFrame:NSMakeRect(0, contentView.bounds.size.height - toolbarHeight, contentView.bounds.size.width, toolbarHeight)];
    toolbar.material = NSVisualEffectMaterialHUDWindow;
    toolbar.blendingMode = NSVisualEffectBlendingModeWithinWindow;
    toolbar.state = NSVisualEffectStateActive;
    toolbar.wantsLayer = YES;
    toolbar.layer.backgroundColor = [MBColorSurface() CGColor];
    toolbar.autoresizingMask = NSViewWidthSizable | NSViewMinYMargin;
    [contentView addSubview:toolbar];

    NSView *accentLine = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, toolbar.bounds.size.width, 1)];
    accentLine.wantsLayer = YES;
    accentLine.layer.backgroundColor = [MBColorCopper() colorWithAlphaComponent:0.35].CGColor;
    accentLine.autoresizingMask = NSViewWidthSizable | NSViewMaxYMargin;
    [toolbar addSubview:accentLine];

    CGFloat control = 32;
    CGFloat y = (toolbarHeight - control) / 2.0;
    CGFloat x = 12;
    CGFloat gap = 4;

    self.homeButton = [self makeSymbolButton:@"house.fill" toolTip:@"Start page (DuckDuckGo)" action:@selector(goHome:) frame:NSMakeRect(x, y, control, control) inView:toolbar];
    x += control + gap;

    self.backButton = [self makeSymbolButton:@"chevron.left" toolTip:@"Back" action:@selector(goBack:) frame:NSMakeRect(x, y, control, control) inView:toolbar];
    x += control + gap;

    self.forwardButton = [self makeSymbolButton:@"chevron.right" toolTip:@"Forward" action:@selector(goForward:) frame:NSMakeRect(x, y, control, control) inView:toolbar];
    x += control + gap;

    self.reloadButton = [self makeSymbolButton:@"arrow.clockwise" toolTip:@"Reload" action:@selector(reloadPage:) frame:NSMakeRect(x, y, control, control) inView:toolbar];
    x += control + 10;

    CGFloat fieldW = toolbar.bounds.size.width - x - 12;
    self.addressField = [[NSTextField alloc] initWithFrame:NSMakeRect(x, y, fieldW, control)];
    self.addressField.autoresizingMask = NSViewWidthSizable;
    self.addressField.placeholderAttributedString = [[NSAttributedString alloc]
        initWithString:@"Search DuckDuckGo or enter address"
            attributes:@{
                NSForegroundColorAttributeName: MBColorStone(),
                NSFontAttributeName: [NSFont systemFontOfSize:13 weight:NSFontWeightRegular]
            }];
    self.addressField.font = [NSFont systemFontOfSize:13 weight:NSFontWeightRegular];
    self.addressField.drawsBackground = YES;
    self.addressField.backgroundColor = MBColorInk();
    self.addressField.textColor = MBColorCream();
    self.addressField.bezeled = YES;
    self.addressField.bezelStyle = NSTextFieldRoundedBezel;
    self.addressField.focusRingType = NSFocusRingTypeExterior;
    self.addressField.delegate = self;
    [toolbar addSubview:self.addressField];

    NSRect webFrame = NSMakeRect(0, 0, contentView.bounds.size.width, contentView.bounds.size.height - toolbarHeight);
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    WKWebpagePreferences *preferences = [[WKWebpagePreferences alloc] init];
    preferences.allowsContentJavaScript = YES;
    config.defaultWebpagePreferences = preferences;
    self.webView = [[WKWebView alloc] initWithFrame:webFrame configuration:config];
    self.webView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    self.webView.navigationDelegate = self;
    self.webView.allowsBackForwardNavigationGestures = YES;
    self.webView.underPageBackgroundColor = MBColorInk();
    [contentView addSubview:self.webView];

    [window makeKeyAndOrderFront:nil];
    [self goHome:nil];
    [self focusAddressBar:nil];
}

- (void)focusAddressBar:(id)sender {
    [self.window makeFirstResponder:self.addressField];
    [self.addressField selectText:nil];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(insertNewline:)) {
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
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
}

- (void)goHome:(id)sender {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:kStartPageURLString]];
    [self.webView loadRequest:request];
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
    [self.webView reload];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if ([self isOnStartPage]) {
        self.addressField.stringValue = @"";
    } else {
        self.addressField.stringValue = webView.URL.absoluteString ?: @"";
    }
    [self updateNavigationButtons];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if (error.code == NSURLErrorCancelled) {
        return;
    }
    [self updateNavigationButtons];
}

- (void)windowWillClose:(NSNotification *)notification {
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
