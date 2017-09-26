//
//  FLWebController.h
//  simuyun
//
//  Created by forterli on 2017/1/22.
//  Copyright © 2017年 YTWealth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, FLWebViewHeaderShowType) {
    FLWebViewHeaderShowTypeNormal,         // 正常显示
    FLWebViewHeaderShowTypeHiddenNavBar,   // 隐藏导航栏
};

typedef NS_ENUM(NSInteger, FLWebViewFooterShowType) {
    FLWebViewFooterShowTypeNormal,         // 正常显示
    FLWebViewFooterShowTypeTabBar,         // tabbar
};

typedef NS_ENUM(NSInteger, FLWebViewRightItemType) {
    FLWebViewItemTypeNone,    // 默认
    FLWebViewItemTypeShare,   // 分享
    FLWebViewItemVerify,  // 确认
};

/// js->native
@interface FLBaseWebController : UIViewController

/*~~~~~~~~~~~~~~~~~~readonly~~~~~~~~~~~~~~~~*/
// webView
@property (nonatomic, strong, readonly) WKWebView *wkWebView;
//  标题
@property (nonatomic, strong, readonly) NSString *webTitle;
//  实际的webtitle
@property (nonatomic, strong, readonly) NSString *webRealTitle;
// 连接
@property (nonatomic, strong, readonly) NSString *webUrlStr;
// 进度条
@property (nonatomic, strong, readonly) UIView *progressView;

/*~~~~~~~~~~~~~~~~~~~~配置~~~~~~~~~~~~~~~~~~~~*/
/// 标题
@property (nonatomic, assign, readwrite) BOOL autoShowTitle;
/// 显示模式
@property (nonatomic, assign, readwrite) FLWebViewHeaderShowType showHeaderType;
/// 显示模式
@property (nonatomic, assign, readwrite) FLWebViewFooterShowType showFooterType;
/// 电池栏样式
@property (nonatomic, assign, readwrite) UIStatusBarStyle statusStyle;
/// 是否添加分享
@property (nonatomic, assign, readwrite) FLWebViewRightItemType itemType;

/// 设置滑动速率  默认5
@property (nonatomic, assign, readwrite) CGFloat decelerationRate;
/// 添加进度条
@property (nonatomic, assign, readwrite) BOOL addProgress;
/// 是否添加返回
@property (nonatomic ,assign, readwrite) BOOL addReture;

@property (nonatomic, assign, readwrite) BOOL hidenNaBar;

@property (nonatomic, assign, readwrite) BOOL hidenStatusBar;

@property (nonatomic, assign, readwrite) BOOL allowsLinkPreview;

- (instancetype)initWithURLBaseUrl:(nullable NSString *)baseUrl Str:(NSString *)urlStr title:(nullable NSString *)title;

- (instancetype)initWithURLStr:(NSString *)urlStr title:(nullable NSString *)title;

- (instancetype)initWithFileURLStr:(NSString *)fileURLStr title:(nullable NSString *)title;

/// 添加UserScrip
- (void)addUserScrip:(WKUserScript *)userScript;

- (void)removeUserScrip:(WKUserScript *)userScript;

- (void)removeUserScrips;



/// 添加加载的Scheme
- (BOOL)addLoadScheme:(NSString *)scheme;

/// 添加加载Schemes
- (BOOL)addLoadSchemes:(NSArray *)schemes;

/// 移除加载Scheme
- (BOOL)removeLoadScheme:(NSString *)scheme;

/// 移除所有加载Schemes
- (BOOL)removeLoadSchemes;

/// 添加加载的js name
- (BOOL)addScripMessageName:(NSString *)name;

/// 添加加载js name
- (BOOL)addScripMessageNames:(NSArray *)names;

/// 移除加载js name
- (BOOL)removeScripMessageNames:(NSString *)name;

/// 移除所有js name
- (BOOL)removeScripMessageNames;

// 加载Url
- (void)flWebUrlload;

// MARK: 刷新
- (void)reload;

- (void)webView:(FLBaseWebController *)webView title:(NSString *)title;

@end

@interface FLBaseWebController (WebViewPrepare)

/**
 配置
 scheme
 ScripName
 naShowTitle
 decelerationRate
 addProgress
 addReture
 */
- (void)webPrepare;
/// 配置urlStr
- (NSString *)prepareWithUrlStr:(NSString *)urlStr;
/// 配置Request
- (NSMutableURLRequest *)prepareWithUrl:(NSURL *)url;
/// 删除缓存
- (void)deleteWebCache;

@end


@interface FLBaseWebController (WebViewScriptHostMessageHandler)

// 执行js
- (void)runJS:(NSString *)js completionHandler:(void (^ _Nullable)(_Nullable id message, NSError * _Nullable error))completionHandler;

// 输入框
- (void)baseWebView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler;

// 选择框
- (void)baseWebView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler;

// 警告框
- (void)baseWebView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler;

- (void)baseWebViewURLInfo:(id)info;

- (void)baseWebViewScripUserContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message;
@end



@interface FLBaseWebController (WebViewResult)
// 页面加载完成之后调用
- (void)baseWebView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation;
// 页面加载失败时调用
- (void)baseWebView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation;
@end



@interface FLBaseWebController (WebViewRequest)

- (BOOL)baseWebView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;

// 页面开始加载时调用
- (void)baseWebView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation;

// 接收到服务器跳转请求之后调用
- (void)baseWebView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation;

// 当内容开始返回时调用
- (void)baseWebView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation;

@end


@interface  FLBaseWebController(Scroll)
/**
 *  滑动
 */
- (void)flScrollViewDidScroll:(UIScrollView *)scrollView;
/**
 *  减速
 */
- (void)flScrollViewDidEndDecelerating:(UIScrollView *)scrollView;

/**
 *  拖拽
 */
- (void)flScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

@end

@interface  FLBaseWebController(Action)
- (void)flClickActionWebView:(FLBaseWebController *)webView itemType:(FLWebViewRightItemType)itemType;
@end

NS_ASSUME_NONNULL_END
