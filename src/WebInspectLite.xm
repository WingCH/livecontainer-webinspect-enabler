#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <objc/message.h>
#import <objc/runtime.h>
#import <os/log.h>

static os_log_t WebInspectLiteLog(void) {
    static os_log_t log;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        log = os_log_create("dev.wingchan.WebInspectLite", "runtime");
    });
    return log;
}

static void WILMakeWebViewInspectable(WKWebView *webView) {
    if (webView == nil) {
        return;
    }

    SEL selector = NSSelectorFromString(@"setInspectable:");
    if (![webView respondsToSelector:selector]) {
        os_log_info(WebInspectLiteLog(), "WKWebView does not support inspectable selector");
        return;
    }

    ((void (*)(id, SEL, BOOL))objc_msgSend)(webView, selector, YES);
    os_log_info(WebInspectLiteLog(), "Enabled inspectable for WKWebView: %{public}@", webView);
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

static void WILSwizzleInstanceMethod(Class targetClass, SEL originalSelector, SEL swizzledSelector, IMP swizzledImplementation) {
    Method originalMethod = class_getInstanceMethod(targetClass, originalSelector);
    if (originalMethod == NULL) {
        os_log_info(WebInspectLiteLog(), "Original selector not found: %{public}@", NSStringFromSelector(originalSelector));
        return;
    }

    const char *typeEncoding = method_getTypeEncoding(originalMethod);
    BOOL added = class_addMethod(targetClass, swizzledSelector, swizzledImplementation, typeEncoding);
    if (!added) {
        os_log_info(WebInspectLiteLog(), "Swizzled selector already exists: %{public}@", NSStringFromSelector(swizzledSelector));
    }

    Method swizzledMethod = class_getInstanceMethod(targetClass, swizzledSelector);
    if (swizzledMethod == NULL) {
        os_log_error(WebInspectLiteLog(), "Swizzled selector not found after add: %{public}@", NSStringFromSelector(swizzledSelector));
        return;
    }

    method_exchangeImplementations(originalMethod, swizzledMethod);
    os_log_info(WebInspectLiteLog(), "Swizzled selector: %{public}@", NSStringFromSelector(originalSelector));
}

__attribute__((constructor))
static void WILInitialize(void) {
    os_log_info(WebInspectLiteLog(), "WebInspectLite loaded for LiveContainer guest process");

    Class webViewClass = NSClassFromString(@"WKWebView");
    if (webViewClass == Nil) {
        os_log_error(WebInspectLiteLog(), "WKWebView class not found");
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
}
