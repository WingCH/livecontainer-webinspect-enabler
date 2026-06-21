#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <objc/message.h>
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

%hook WKWebView

- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    WKWebView *webView = %orig(frame, configuration);
    WILMakeWebViewInspectable(webView);
    return webView;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    WKWebView *webView = %orig(coder);
    WILMakeWebViewInspectable(webView);
    return webView;
}

%end

%ctor {
    os_log_info(WebInspectLiteLog(), "WebInspectLite loaded for LiveContainer guest process");
}
