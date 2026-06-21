#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <objc/message.h>
#import <objc/runtime.h>
#import <os/log.h>

static os_log_t WebInspectEnablerLog(void) {
    static os_log_t log;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        log = os_log_create("dev.wingchan.WebInspectEnabler", "runtime");
    });
    return log;
}

static void WILLog(NSString *format, ...) {
    va_list arguments;
    va_start(arguments, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:arguments];
    va_end(arguments);

    const char *publicMessage = [message UTF8String] ?: "";
    os_log_info(WebInspectEnablerLog(), "%{public}s", publicMessage);
    os_log_info(OS_LOG_DEFAULT, "[WebInspectEnabler] %{public}s", publicMessage);
}

static void WILError(NSString *format, ...) {
    va_list arguments;
    va_start(arguments, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:arguments];
    va_end(arguments);

    const char *publicMessage = [message UTF8String] ?: "";
    os_log_error(WebInspectEnablerLog(), "%{public}s", publicMessage);
    os_log_error(OS_LOG_DEFAULT, "[WebInspectEnabler] %{public}s", publicMessage);
}

static void WILMakeWebViewInspectable(WKWebView *webView) {
    if (webView == nil) {
        return;
    }

    SEL selector = NSSelectorFromString(@"setInspectable:");
    if (![webView respondsToSelector:selector]) {
        WILLog(@"WKWebView does not support inspectable selector");
        return;
    }

    ((void (*)(id, SEL, BOOL))objc_msgSend)(webView, selector, YES);
    WILLog(@"Enabled inspectable for WKWebView: %@", webView);
}

static id WILInitWithFrameConfiguration(id self, SEL _cmd, CGRect frame, id configuration) {
    SEL swizzledSelector = NSSelectorFromString(@"wil_initWithFrame:configuration:");
    id (*originalInit)(id, SEL, CGRect, id) = (id (*)(id, SEL, CGRect, id))objc_msgSend;
    WKWebView *webView = originalInit(self, swizzledSelector, frame, configuration);
    WILMakeWebViewInspectable(webView);
    return webView;
}

static id WILInitWithCoder(id self, SEL _cmd, id coder) {
    SEL swizzledSelector = NSSelectorFromString(@"wil_initWithCoder:");
    id (*originalInit)(id, SEL, id) = (id (*)(id, SEL, id))objc_msgSend;
    WKWebView *webView = originalInit(self, swizzledSelector, coder);
    WILMakeWebViewInspectable(webView);
    return webView;
}

static void WILSetInspectable(id self, SEL _cmd, BOOL inspectable) {
    SEL swizzledSelector = NSSelectorFromString(@"wil_setInspectable:");
    void (*originalSetInspectable)(id, SEL, BOOL) = (void (*)(id, SEL, BOOL))objc_msgSend;
    originalSetInspectable(self, swizzledSelector, YES);
    WILLog(@"Forced inspectable=YES for WKWebView: %@", self);
}

static void WILDidMoveToWindow(id self, SEL _cmd) {
    SEL swizzledSelector = NSSelectorFromString(@"wil_didMoveToWindow");
    void (*originalDidMoveToWindow)(id, SEL) = (void (*)(id, SEL))objc_msgSend;
    originalDidMoveToWindow(self, swizzledSelector);
    WILMakeWebViewInspectable((WKWebView *)self);
}

static id WILLoadRequest(id self, SEL _cmd, id request) {
    SEL swizzledSelector = NSSelectorFromString(@"wil_loadRequest:");
    id (*originalLoadRequest)(id, SEL, id) = (id (*)(id, SEL, id))objc_msgSend;
    WILMakeWebViewInspectable((WKWebView *)self);
    id navigation = originalLoadRequest(self, swizzledSelector, request);
    WILMakeWebViewInspectable((WKWebView *)self);
    return navigation;
}

static id WILLoadHTMLStringBaseURL(id self, SEL _cmd, id htmlString, id baseURL) {
    SEL swizzledSelector = NSSelectorFromString(@"wil_loadHTMLString:baseURL:");
    id (*originalLoadHTMLString)(id, SEL, id, id) = (id (*)(id, SEL, id, id))objc_msgSend;
    WILMakeWebViewInspectable((WKWebView *)self);
    id navigation = originalLoadHTMLString(self, swizzledSelector, htmlString, baseURL);
    WILMakeWebViewInspectable((WKWebView *)self);
    return navigation;
}

static id WILLoadFileURLAllowingReadAccessToURL(id self, SEL _cmd, id fileURL, id readAccessURL) {
    SEL swizzledSelector = NSSelectorFromString(@"wil_loadFileURL:allowingReadAccessToURL:");
    id (*originalLoadFileURL)(id, SEL, id, id) = (id (*)(id, SEL, id, id))objc_msgSend;
    WILMakeWebViewInspectable((WKWebView *)self);
    id navigation = originalLoadFileURL(self, swizzledSelector, fileURL, readAccessURL);
    WILMakeWebViewInspectable((WKWebView *)self);
    return navigation;
}

static void WILSwizzleInstanceMethod(Class targetClass, SEL originalSelector, SEL swizzledSelector, IMP swizzledImplementation) {
    Method originalMethod = class_getInstanceMethod(targetClass, originalSelector);
    if (originalMethod == NULL) {
        WILLog(@"Original selector not found: %@", NSStringFromSelector(originalSelector));
        return;
    }

    const char *typeEncoding = method_getTypeEncoding(originalMethod);
    BOOL added = class_addMethod(targetClass, swizzledSelector, swizzledImplementation, typeEncoding);
    if (!added) {
        WILLog(@"Swizzled selector already exists: %@", NSStringFromSelector(swizzledSelector));
    }

    Method swizzledMethod = class_getInstanceMethod(targetClass, swizzledSelector);
    if (swizzledMethod == NULL) {
        WILError(@"Swizzled selector not found after add: %@", NSStringFromSelector(swizzledSelector));
        return;
    }

    method_exchangeImplementations(originalMethod, swizzledMethod);
    WILLog(@"Swizzled selector: %@", NSStringFromSelector(originalSelector));
}

__attribute__((constructor))
static void WILInitialize(void) {
    WILLog(@"WebInspectEnabler loaded for LiveContainer guest process");

    Class webViewClass = NSClassFromString(@"WKWebView");
    if (webViewClass == Nil) {
        WILError(@"WKWebView class not found");
        return;
    }

    WILSwizzleInstanceMethod(
        webViewClass,
        @selector(initWithFrame:configuration:),
        NSSelectorFromString(@"wil_initWithFrame:configuration:"),
        (IMP)WILInitWithFrameConfiguration
    );

    WILSwizzleInstanceMethod(
        webViewClass,
        @selector(initWithCoder:),
        NSSelectorFromString(@"wil_initWithCoder:"),
        (IMP)WILInitWithCoder
    );

    WILSwizzleInstanceMethod(
        webViewClass,
        @selector(setInspectable:),
        NSSelectorFromString(@"wil_setInspectable:"),
        (IMP)WILSetInspectable
    );

    WILSwizzleInstanceMethod(
        webViewClass,
        @selector(didMoveToWindow),
        NSSelectorFromString(@"wil_didMoveToWindow"),
        (IMP)WILDidMoveToWindow
    );

    WILSwizzleInstanceMethod(
        webViewClass,
        @selector(loadRequest:),
        NSSelectorFromString(@"wil_loadRequest:"),
        (IMP)WILLoadRequest
    );

    WILSwizzleInstanceMethod(
        webViewClass,
        @selector(loadHTMLString:baseURL:),
        NSSelectorFromString(@"wil_loadHTMLString:baseURL:"),
        (IMP)WILLoadHTMLStringBaseURL
    );

    WILSwizzleInstanceMethod(
        webViewClass,
        @selector(loadFileURL:allowingReadAccessToURL:),
        NSSelectorFromString(@"wil_loadFileURL:allowingReadAccessToURL:"),
        (IMP)WILLoadFileURLAllowingReadAccessToURL
    );
}
