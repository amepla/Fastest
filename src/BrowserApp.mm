#import "BrowserApp.h"
#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

static NSColor *MBColorInk(void) {
    return [NSColor colorWithCalibratedRed:6.0 / 255.0 green:6.0 / 255.0 blue:6.0 / 255.0 alpha:1.0];
}

static NSColor *MBColorSurface(void) {
    return [NSColor colorWithCalibratedRed:18.0 / 255.0 green:18.0 / 255.0 blue:18.0 / 255.0 alpha:1.0];
}

static NSColor *MBColorCream(void) {
    return [NSColor colorWithCalibratedRed:244.0 / 255.0 green:239.0 / 255.0 blue:230.0 / 255.0 alpha:1.0];
}

static NSColor *MBColorStone(void) {
    return [NSColor colorWithCalibratedRed:154.0 / 255.0 green:143.0 / 255.0 blue:130.0 / 255.0 alpha:1.0];
}

@interface BrowserWindowController : NSWindowController <WKNavigationDelegate, NSTextFieldDelegate, NSWindowDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSTextField *addressField;
@property (nonatomic, strong) NSButton *backButton;
@property (nonatomic, strong) NSButton *forwardButton;
@property (nonatomic, strong) NSButton *reloadButton;
@property (nonatomic, strong) NSButton *homeButton;
@property (nonatomic, assign) BOOL onHomePage;
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
    [navMenu addItemWithTitle:@"Home" action:@selector(goHome:) keyEquivalent:@"h"];
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

- (NSButton *)makeToolbarButtonWithTitle:(NSString *)title action:(SEL)action x:(CGFloat)x y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height inView:(NSView *)toolbar {
    NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(x, y, width, height)];
    button.title = title;
    button.bezelStyle = NSBezelStyleRoundRect;
    button.font = [NSFont systemFontOfSize:12 weight:NSFontWeightSemibold];
    button.contentTintColor = MBColorCream();
    button.target = self;
    button.action = action;
    [toolbar addSubview:button];
    return button;
}

- (NSString *)homeHTML {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *bundlePath = [bundle pathForResource:@"home" ofType:@"html"];
    if (bundlePath) {
        NSError *error = nil;
        NSString *html = [NSString stringWithContentsOfFile:bundlePath encoding:NSUTF8StringEncoding error:&error];
        if (html) {
            return html;
        }
    }

    NSString *devPath = [[[NSFileManager defaultManager] currentDirectoryPath]
        stringByAppendingPathComponent:@"resources/home.html"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:devPath]) {
        return [NSString stringWithContentsOfFile:devPath encoding:NSUTF8StringEncoding error:nil] ?: @"";
    }

    return @"<!DOCTYPE html><html><body style='background:#060606;color:#f4efe6;font-family:serif;padding:2rem'><h1>MacBrowser</h1><p>resources/home.html not found.</p></body></html>";
}

- (NSURL *)homeBaseURL {
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"home" ofType:@"html"];
    if (bundlePath) {
        return [NSURL fileURLWithPath:[bundlePath stringByDeletingLastPathComponent] isDirectory:YES];
    }
    NSString *devPath = [[[NSFileManager defaultManager] currentDirectoryPath]
        stringByAppendingPathComponent:@"resources"];
    return [NSURL fileURLWithPath:devPath isDirectory:YES];
}

- (void)setupUI {
    NSWindow *window = self.window;
    NSView *contentView = window.contentView;
    window.backgroundColor = MBColorInk();
    window.delegate = self;
    [window setTitle:@"MacBrowser"];
    [window center];
    [window makeKeyAndOrderFront:nil];

    CGFloat toolbarHeight = 56;
    NSView *toolbar = [[NSView alloc] initWithFrame:NSMakeRect(0, contentView.bounds.size.height - toolbarHeight, contentView.bounds.size.width, toolbarHeight)];
    toolbar.wantsLayer = YES;
    toolbar.layer.backgroundColor = [MBColorSurface() CGColor];
    toolbar.autoresizingMask = NSViewWidthSizable | NSViewMinYMargin;
    [contentView addSubview:toolbar];

    CGFloat buttonWidth = 72;
    CGFloat buttonHeight = 30;
    CGFloat buttonY = 13;
    CGFloat x = 14;

    self.homeButton = [self makeToolbarButtonWithTitle:@"Home" action:@selector(goHome:) x:x y:buttonY width:buttonWidth height:buttonHeight inView:toolbar];
    x += buttonWidth + 6;

    self.backButton = [self makeToolbarButtonWithTitle:@"Back" action:@selector(goBack:) x:x y:buttonY width:buttonWidth height:buttonHeight inView:toolbar];
    x += buttonWidth + 6;

    self.forwardButton = [self makeToolbarButtonWithTitle:@"Forward" action:@selector(goForward:) x:x y:buttonY width:buttonWidth height:buttonHeight inView:toolbar];
    x += buttonWidth + 6;

    self.reloadButton = [self makeToolbarButtonWithTitle:@"Reload" action:@selector(reloadPage:) x:x y:buttonY width:buttonWidth height:buttonHeight inView:toolbar];
    x += buttonWidth + 10;

    CGFloat addressWidth = toolbar.bounds.size.width - x - 14;
    self.addressField = [[NSTextField alloc] initWithFrame:NSMakeRect(x, buttonY, addressWidth, buttonHeight)];
    self.addressField.autoresizingMask = NSViewWidthSizable;
    self.addressField.placeholderString = @"Search or enter address";
    self.addressField.placeholderAttributedString = [[NSAttributedString alloc]
        initWithString:@"Search or enter address"
            attributes:@{NSForegroundColorAttributeName: MBColorStone()}];
    self.addressField.font = [NSFont systemFontOfSize:13 weight:NSFontWeightRegular];
    self.addressField.drawsBackground = YES;
    self.addressField.backgroundColor = MBColorInk();
    self.addressField.textColor = MBColorCream();
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

    [self goHome:nil];
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
    if (self.onHomePage) {
        self.backButton.enabled = NO;
        self.forwardButton.enabled = NO;
        return;
    }
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
}

- (void)goHome:(id)sender {
    self.onHomePage = YES;
    [self.webView loadHTMLString:[self homeHTML] baseURL:[self homeBaseURL]];
    self.addressField.stringValue = @"";
    [self updateNavigationButtons];
}

- (void)loadAddress:(NSString *)address {
    NSString *urlString = [address stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (urlString.length == 0) {
        return;
    }

    if ([self looksLikeURL:urlString]) {
        if (![urlString containsString:@"://"]) {
            urlString = [@"https://" stringByAppendingString:urlString];
        }
    } else {
        NSString *encoded = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        urlString = [NSString stringWithFormat:@"https://duckduckgo.com/?q=%@", encoded ?: urlString];
    }

    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Invalid URL";
        alert.informativeText = @"Please enter a valid web address or search query.";
        [alert runModal];
        return;
    }

    self.onHomePage = NO;
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
    if (self.onHomePage) {
        [self goHome:sender];
        return;
    }
    [self.webView reload];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSString *currentURL = webView.URL.absoluteString;
    if (currentURL == nil || [currentURL isEqualToString:@"about:blank"]) {
        self.onHomePage = YES;
        self.addressField.stringValue = @"";
    } else if (!self.onHomePage) {
        self.addressField.stringValue = currentURL;
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
