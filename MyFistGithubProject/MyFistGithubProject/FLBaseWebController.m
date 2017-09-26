//
//  FLWebController.m
//  simuyun
//
//  Created by forterli on 2017/1/22.
//  Copyright © 2017年 YTWealth. All rights reserved.
//

#import "FLBaseWebController.h"

@protocol  FLBaseScriptMessageHandlerDelegate<NSObject>
- (void)baseScripUserContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message;
@end
@interface  FLBaseScriptMessageHandler:NSObject <WKScriptMessageHandler>
@property (nonatomic, assign) id<FLBaseScriptMessageHandlerDelegate>scriptMessageHandlerDelegate;
@end
@implementation FLBaseScriptMessageHandler
+ (FLBaseScriptMessageHandler *)sharedScriptMessageHandler
{
    FLBaseScriptMessageHandler *sharedScriptMessageHandler;
    sharedScriptMessageHandler = [[FLBaseScriptMessageHandler alloc] init];
    return sharedScriptMessageHandler;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if (_scriptMessageHandlerDelegate && [_scriptMessageHandlerDelegate respondsToSelector:@selector(baseWebViewScripUserContentController:didReceiveScriptMessage:)]) {
        [_scriptMessageHandlerDelegate baseScripUserContentController:userContentController didReceiveScriptMessage:message];
    }
}
@end

typedef NS_ENUM(NSInteger, FLLoadType){
    FLLoadTypeURL = 0,
    FLLoadTypeFile,
};

@interface FLBaseWebController ()<UIScrollViewDelegate,WKUIDelegate,WKNavigationDelegate,FLBaseScriptMessageHandlerDelegate,UIGestureRecognizerDelegate>
@property (nonatomic, strong, readwrite) NSString *webUrlStr;
@property (nonatomic, strong, readwrite) NSString *webFileUrlStr;
@property (nonatomic, strong, readwrite) WKWebView *wkWebView;
@property (nonatomic, strong, readwrite) NSString *webTitle;
@property (nonatomic, strong, readwrite) NSString *webRealTitle;
@property (nonatomic, strong, readwrite) NSMutableArray *backarray;
@property (nonatomic, strong, readwrite) UIView *progressView;
@property (nonatomic, assign, readwrite) FLLoadType loadType;
@property (nonatomic, strong, readwrite) NSMutableSet *scripNames;
@property (nonatomic, strong, readwrite) NSMutableSet *loadSchemes;
@property (nonatomic, strong, readwrite) NSMutableSet *userScrip;
//@property (nonatomic, strong) MBProgressHUD *proagessView;

@property (nonatomic, strong) FLBaseScriptMessageHandler *scriptMessageHandler;


@end

@implementation FLBaseWebController

#pragma mark - life cycle

- (instancetype)initWithURLBaseUrl:(NSString *)baseUrl Str:(NSString *)urlStr title:(NSString *)title
{
    NSString *url = [urlStr copy];
    if (baseUrl && (![url hasPrefix:@"http:"] && ![url hasPrefix:@"https:"])) {
        url = [NSString stringWithFormat:@"%@%@",baseUrl,urlStr];
    }
    if (self = [self initWithURLStr:url title:title]) {
    }
    return self;
}

- (instancetype)initWithURLStr:(NSString *)urlStr title:(NSString *)title
{
    if (self = [self init]) {
        _webTitle = title;
        _webUrlStr = urlStr;
        if ([self includeChinese:urlStr]) {
            _webUrlStr = [_webUrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        _webFileUrlStr = nil;
        _loadType = FLLoadTypeURL;
        if ([self respondsToSelector:@selector(prepareWithUrlStr:)]) {
            _webUrlStr = [self prepareWithUrlStr:_webUrlStr];
        }
        [self webPrepare];
    }
    return self;
}

- (instancetype)initWithFileURLStr:(NSString *)fileURLStr title:(NSString *)title
{
    if (self = [self init]) {
        _webTitle = title;
        _webFileUrlStr = fileURLStr;
        _webUrlStr = nil;
        _loadType = FLLoadTypeFile;
        [self webPrepare];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _autoShowTitle = NO;
        _addReture = NO;
        _addProgress = NO;
        _decelerationRate = 5;
        _allowsLinkPreview = NO;
        _statusStyle = UIStatusBarStyleDefault;
        _showHeaderType = FLWebViewHeaderShowTypeNormal;
        _showFooterType = FLWebViewFooterShowTypeNormal;
        _scriptMessageHandler = [FLBaseScriptMessageHandler sharedScriptMessageHandler];
        _scriptMessageHandler.scriptMessageHandlerDelegate = self;
        [self addLoadSchemes:@[@"http",@"https",@"file"]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    /// config view
    if (self.navigationController) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    [self.view addSubview:self.wkWebView];
    
    [self flAddProgress];
    [self flConfigItem];
    /// add observer
//    [self addObserver:self forKeyPath:kKeypath(self.wkWebView.title) options:NSKeyValueObservingOptionNew context:nil];
//    [self addObserver:self forKeyPath:kKeypath(self.wkWebView.loading) options:NSKeyValueObservingOptionNew context:nil];
//    [self addObserver:self forKeyPath:kKeypath(self.wkWebView.estimatedProgress) options:NSKeyValueObservingOptionNew context:nil];
    
    [self loadScripMessageNames];
    
    [self loadUserScrip];
    
    if (_webTitle && !_autoShowTitle) {
        self.navigationItem.title = _webTitle;
    }

    switch (_itemType) {
        case FLWebViewItemTypeNone:
        {
            
            break;
        }
        case FLWebViewItemTypeShare:
        {
            [self configShare];
            break;
        }
        case FLWebViewItemVerify:
        {
            [self configSave];
            break;
        }
        default:
            break;
    }
    /// load web
    [self flWebUrlload];
}


- (BOOL)prefersStatusBarHidden
{
    return self.hidenStatusBar;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return self.statusStyle;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.hidenNaBar) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.hidenNaBar) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    if (_wkWebView) {
        [self removeLoadScripMessageNames];
//        [self removeObserver:self forKeyPath:kKeypath(self.wkWebView.estimatedProgress)];
//        [self removeObserver:self forKeyPath:kKeypath(self.wkWebView.title)];
//        [self removeObserver:self forKeyPath:kKeypath(self.wkWebView.loading)];
        
        self.wkWebView.UIDelegate = nil;
        self.wkWebView.navigationDelegate = nil;
        self.wkWebView.scrollView.delegate = nil;
        self.wkWebView = nil;
    }
}

#pragma mark - event reponse
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
//{
//    /// 进度条
//    if ([keyPath isEqualToString:kKeypath(self.wkWebView.estimatedProgress)]) {
//        [self progressNum:[change[NSKeyValueChangeNewKey] floatValue]];
//    }
//    /// 标题
//    if ([keyPath isEqualToString:kKeypath(self.wkWebView.title)]) {
//        self.webRealTitle = change[NSKeyValueChangeNewKey];
//        if (self.autoShowTitle) {
//            self.navigationItem.title = self.webRealTitle;
//        }
//    }
//    /// 加载
//    if ([keyPath isEqualToString:kKeypath(self.wkWebView.loading)]) {
//        BOOL loading = [change[NSKeyValueChangeNewKey] boolValue];
//        if (loading) {
//            if (_proagessView == nil) {
//                _proagessView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//            }
//        }else{
//            [self webView:self title:self.wkWebView.title];
//            if (_proagessView) {
//                [_proagessView hideAnimated:YES];
//            }
//        }
//    }
//}

/// 返回
- (void)retureBack:(UIBarButtonItem *)sender
{
    [self flRetureAction];
}
/// 关闭
- (void)closeAction:(UIBarButtonItem *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

/// 分享
- (void)clickAction
{
    if ([self respondsToSelector:@selector(flClickActionWebView:itemType:)]) {
        [self flClickActionWebView:self itemType:_itemType];
    }
}


- (void)baseWebViewURLInfo:(id)info{}
- (void)baseWebViewScripUserContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{}

#pragma mark - Delegate
#pragma mark - Delegate - FLBaseScriptMessageHandlerDelegate
- (void)baseScripUserContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([self respondsToSelector:@selector(baseWebViewScripUserContentController:didReceiveScriptMessage:)]) {
        [self baseWebViewScripUserContentController:userContentController didReceiveScriptMessage:message];
    }
}

#pragma mark - Delegate - WebView
#pragma mark - WKNavigationDelegate

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    NSLog(@"~~~~~~~~~~~~~~~~~~网页加载内容进程终止");
}

// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSString *lowUrlStr = navigationAction.request.URL.absoluteString;
    if ([lowUrlStr hasPrefix:@"sms:"] || [lowUrlStr hasPrefix:@"tel:"] || [lowUrlStr hasPrefix:@"mailto:"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        UIApplication *app = [UIApplication sharedApplication];
        if ([app canOpenURL:[NSURL URLWithString:lowUrlStr]]) {
            [app openURL:[NSURL URLWithString:lowUrlStr]];
        }
        return;
    }
    BOOL transaction = NO;
    if ([self respondsToSelector:@selector(baseWebView:decidePolicyForNavigationAction:decisionHandler:)]) {
        transaction = [self baseWebView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
    }
    if (!transaction) {
        if (self.loadSchemes.count && _loadType == FLLoadTypeURL) {
            for (NSString *scheme  in self.loadSchemes) {
                if ([navigationAction.request.URL.scheme isEqualToString:scheme]) {
                    decisionHandler(WKNavigationActionPolicyAllow);
                    return;
                }
            }
        }else if (_loadType == FLLoadTypeFile){
            /// 加载文件允许跳转
            decisionHandler(WKNavigationActionPolicyAllow);
            return;
        }
        // 取消跳转
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    if ([self respondsToSelector:@selector(baseWebViewURLInfo:)]) {
        [self baseWebViewURLInfo:navigationAction.request.URL.absoluteString];
    }
}

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"~~~~~~~~~~~~~~~~~~开始加载");
    if ([self respondsToSelector:@selector(baseWebView:didStartProvisionalNavigation:)]) {
        [self baseWebView:webView didStartProvisionalNavigation:navigation];
    }
}

// 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"~~~~~~~~~~~~~~~~~~跳转到其他的服务器");
    
    if ([self respondsToSelector:@selector(baseWebView:didReceiveServerRedirectForProvisionalNavigation:)]) {
        [self baseWebView:webView didReceiveServerRedirectForProvisionalNavigation:navigation];
    }
}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    
    if ([self respondsToSelector:@selector(baseWebView:didCommitNavigation:)]) {
        [self baseWebView:webView didCommitNavigation:navigation];
    }
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~~网页导航加载完毕");
    
    [self.wkWebView evaluateJavaScript:@"document.documentElement.style.webkitUserSelect='none'" completionHandler:nil];
    [self.wkWebView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none'" completionHandler:nil];
    if ([self respondsToSelector:@selector(baseWebView:didFinishNavigation:)]) {
        [self baseWebView:webView didFinishNavigation:navigation];
    }
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    
    NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~~网页导航加载失败");
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~~网页加载失败");
    
    if ([self respondsToSelector:@selector(baseWebView:didFailProvisionalNavigation:)]) {
        [self baseWebView:webView didFailProvisionalNavigation:navigation];
    }
}


#pragma mark - WKUIDelegate
// 创建一个新的WebView
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    WKFrameInfo *frameInfo = navigationAction.targetFrame;
    if (![frameInfo isMainFrame]) {
        self.autoShowTitle = YES;
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}
//
//- (void)webViewDidClose:(WKWebView *)webView
//{
//
//}
//
// 输入框
//- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler{
//    if ([self respondsToSelector:@selector(baseWebView:runJavaScriptTextInputPanelWithPrompt:defaultText:initiatedByFrame:completionHandler:)]) {
//        [self baseWebView:webView runJavaScriptTextInputPanelWithPrompt:prompt defaultText:defaultText initiatedByFrame:frame completionHandler:completionHandler];
//    }
//}
//// 选择框
//- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
//    if ([self respondsToSelector:@selector(baseWebView:runJavaScriptConfirmPanelWithMessage:initiatedByFrame:completionHandler:)]) {
//        [self baseWebView:webView runJavaScriptConfirmPanelWithMessage:message initiatedByFrame:frame completionHandler:completionHandler];
//    }
//}
//// 警告框
//- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
//    if ([self respondsToSelector:@selector(baseWebView:runJavaScriptAlertPanelWithMessage:initiatedByFrame:completionHandler:)]) {
//        [self baseWebView:webView runJavaScriptAlertPanelWithMessage:message initiatedByFrame:frame completionHandler:completionHandler];
//    }else{
//        completionHandler();
//    }
//}


#pragma mark - Delegate - ScrollView
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    scrollView.decelerationRate = _decelerationRate;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self respondsToSelector:@selector(flScrollViewDidScroll:)]) {
        [self flScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([self respondsToSelector:@selector(flScrollViewDidEndDecelerating:)]) {
        [self flScrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([self respondsToSelector:@selector(flScrollViewDidEndDragging:willDecelerate:)]) {
        [self flScrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}


#pragma mark - methods

// MARK: 刷新
- (void)reload
{
    [self.wkWebView reload];
}

- (BOOL)includeChinese:(NSString *)string
{
    for(int i=0; i< [string length];i++)
    {
        int a =[string characterAtIndex:i];
        if( a >0x4e00&& a <0x9fff){
            return YES;
        }
    }
    return NO;
}

// 中文编码
- (NSString *)getChineseStringWithString:(NSString *)string{
    //(unicode中文编码范围是0x4e00~0x9fa5)
    for (int i = 0; i < string.length; i++) {
        int utfCode = 0;
        void *buffer = &utfCode;
        NSRange range = NSMakeRange(i, 1);
        BOOL b = [string getBytes:buffer maxLength:2 usedLength:NULL encoding:NSUTF16LittleEndianStringEncoding options:NSStringEncodingConversionExternalRepresentation range:range remainingRange:NULL];
        if (b && (utfCode >= 0x4e00 && utfCode <= 0x9fa5)) {
            return [string substringFromIndex:i];
        }
    }
    return nil;
}

// 执行js
- (void)runJS:(NSString *)js completionHandler:(void (^ _Nullable)(_Nullable id message, NSError * _Nullable error))completionHandler
{
    [self.wkWebView evaluateJavaScript:js completionHandler:completionHandler];
}

/**
 配置
 */
- (void)webPrepare{}
- (void)webView:(FLBaseWebController *)webView title:(NSString *)title{};

/// 添加加载的UserScrip
- (void)addUserScrip:(WKUserScript *)userScript
{
    [self.userScrip addObject:userScript];
}

- (void)removeUserScrip:(WKUserScript *)userScript
{
    [self.userScrip removeObject:userScript];
    [self.wkWebView.configuration.userContentController removeAllUserScripts];
    [self loadUserScrip];
}

- (void)removeUserScrips
{
    [self.userScrip removeAllObjects];
    [self.wkWebView.configuration.userContentController removeAllUserScripts];
}

/// 添加加载的Scheme
- (BOOL)addLoadScheme:(NSString *)scheme
{
    if ([scheme isKindOfClass:[NSString class]]) {
        [self.loadSchemes addObject:scheme];
        return YES;
    }
    return NO;
}
/// 添加加载Schemes
- (BOOL)addLoadSchemes:(NSArray *)schemes
{
    for (id scheme  in schemes) {
        if (![scheme isKindOfClass:[NSString class]]) {
            return NO;
        }
    }
    [self.loadSchemes addObjectsFromArray:schemes];
    return YES;
}

/// 移除加载Scheme
- (BOOL)removeLoadScheme:(NSString *)scheme
{
    if ([scheme isKindOfClass:[NSString class]]) {
        [self.loadSchemes removeObject:scheme];
        return YES;
    }
    return NO;
}

/// 移除所有加载Schemes
- (BOOL)removeLoadSchemes
{
    [self.loadSchemes removeAllObjects];
    if (self.loadSchemes.count) {
        return YES;
    }else{
        return NO;
    }
}


/// 添加加载的js name
- (BOOL)addScripMessageName:(NSString *)name
{
    if ([name isKindOfClass:[NSString class]]) {
        [self.scripNames addObject:name];
        return YES;
    }
    return NO;
}
/// 添加加载js name
- (BOOL)addScripMessageNames:(NSArray *)names
{
    for (id name  in names) {
        if (![name isKindOfClass:[NSString class]]) {
            return NO;
        }
    }
    [self.scripNames addObjectsFromArray:names];
    return YES;
}

/// 移除加载js name
- (BOOL)removeScripMessageNames:(NSString *)name
{
    if ([name isKindOfClass:[NSString class]]) {
        [self.scripNames removeObject:name];
        [self.wkWebView.configuration.userContentController removeScriptMessageHandlerForName:name];
        return YES;
    }
    return NO;
}

/// 移除所有js name
- (BOOL)removeScripMessageNames
{
    [self.scripNames removeAllObjects];
    if (self.scripNames.count) {
        return YES;
    }else{
        return NO;
    }
}



#pragma mark - provate methods

/// 加载js 方法
- (void)loadUserScrip
{
    for (WKUserScript *userScrip  in self.userScrip) {
        [self.wkWebView.configuration.userContentController addUserScript:userScrip];
    }
}


/// 加载所有 js name
- (void)loadScripMessageNames
{
    for (NSString *name  in self.scripNames) {
        [self.wkWebView.configuration.userContentController addScriptMessageHandler:_scriptMessageHandler name:name];
    }
}

/// 移除所有 js name
- (void)removeLoadScripMessageNames
{
    for (NSString *name  in self.scripNames) {
        [self.wkWebView.configuration.userContentController removeScriptMessageHandlerForName:name];
    }
    [self removeScripMessageNames];
}

/// 进度条
- (void)progressNum:(CGFloat)progress
{
    if (progress >= 1) {
        self.progressView.hidden = YES;
    }else{
        self.progressView.hidden = NO;
        self.progressView.frame = CGRectMake(0, self.wkWebView.frame.origin.y, self.wkWebView.frame.size.width * progress, 1.5);
    }
}
/// 加载URL
- (void)loadURLWebViewWithStr:(NSString *)urlStr
{
    self.loadType = FLLoadTypeURL;
    self.webUrlStr = urlStr;
}
/// 加载文件
- (void)loadFileWebViewWithStr:(NSString *)filePath
{
    self.loadType = FLLoadTypeFile;
    self.webFileUrlStr = filePath;
}


- (NSURLRequest *)stringToRequest:(NSString *)urlStr
{
    NSMutableURLRequest *urlRequest = nil;
    NSURL *url = [NSURL URLWithString:urlStr];
    if ([self respondsToSelector:@selector(prepareWithUrl:)]) {
        urlRequest = [self prepareWithUrl:url];
    }else{
        urlRequest = [NSMutableURLRequest requestWithURL:url];
    }
    
    return  urlRequest;
}

- (NSURLRequest *)filePathToRequest:(NSString *)path
{
    NSMutableURLRequest *urlRequest = nil;
    NSURL *url = [NSURL fileURLWithPath:path];
    if ([self respondsToSelector:@selector(prepareWithUrl:)]) {
        urlRequest = [self prepareWithUrl:url];
    }else{
        urlRequest = [NSMutableURLRequest requestWithURL:url];
    }
    
    return  urlRequest;
}

/// 返回
- (void)flRetureAction
{
    BOOL canBack = [self.wkWebView canGoBack];
    if (canBack == YES && _addReture) {
        [self.wkWebView goBack];
        self.navigationItem.leftBarButtonItems = self.backarray;
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark 刷新
/// 添加进度条
- (void)flAddProgress
{
    if (_addProgress) {
        [self.view addSubview:self.progressView];
    }else{
        if (_progressView) {
            [_progressView removeFromSuperview];
            _progressView = nil;
        }
    }
}

// 加载Url
- (void)flWebUrlload
{
    switch (_loadType) {
        case FLLoadTypeURL:
        {
            [self loadURLWebViewWithStr:self.webUrlStr];
            break;
        }
        case FLLoadTypeFile:{
            [self loadFileWebViewWithStr:self.webFileUrlStr];
            break;
        }
        default:
            break;
    }
}

/// 添加返回按钮
- (void)flConfigItem
{
    if (_addReture) {
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"return_nor.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(retureBack:)];
        UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceItem.width = - 10;
        self.navigationItem.leftBarButtonItems = @[spaceItem,backItem];
    }else{
        self.navigationItem.leftBarButtonItems = nil;
    }
}

/// 添加分享按钮
- (void)configShare
{
    UIButton *shareBtn = [[UIButton alloc] init];
    [shareBtn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    shareBtn.frame = CGRectMake(0, 0, 57, 17);
    [shareBtn addTarget:self action:@selector(clickAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:shareBtn];
}

/// 添加保存
- (void)configSave
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(clickAction)];
}

- (void)deleteWebCache {
#ifdef __IPHONE_9_0
    if([[UIDevice currentDevice].systemVersion floatValue] >=9.0) {
        NSSet*websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        NSDate*dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
        }];
    }
#endif
}


#pragma mark - getters and setters
- (void)setWebUrlStr:(NSString *)webUrlStr
{
    if (self.isViewLoaded && [_webUrlStr isEqualToString:webUrlStr] && webUrlStr) {
        [_wkWebView loadRequest:[self stringToRequest:webUrlStr]];
    }
    _webUrlStr = webUrlStr;
}

- (void)setWebFileUrlStr:(NSString *)webFileUrlStr
{
    if (self.isViewLoaded && [_webFileUrlStr isEqualToString:webFileUrlStr] && webFileUrlStr) {
        [_wkWebView loadRequest:[self filePathToRequest:webFileUrlStr]];
    }
    _webFileUrlStr = webFileUrlStr;
}

- (void)setAddProgress:(BOOL)addProgress
{
    if (self.isViewLoaded) {
        [self flAddProgress];
    }
    _addProgress = addProgress;
}

- (void)setAddReture:(BOOL)addReture
{
    if (self.isViewLoaded) {
        [self flConfigItem];
    }
    _addReture = addReture;
}

- (WKWebView *)wkWebView
{
    if (_wkWebView == nil) {
        // 配置frame
        CGFloat topSpaceY= 0.f;
        CGFloat bottomSpaceY = 0.f;
        CGRect webFrame = CGRectZero;
        CGFloat headerHeight = 0.0, footerHeight = 0.0;
        switch (_showHeaderType) {
            case FLWebViewHeaderShowTypeNormal:{
                headerHeight = 0.0;
                if (self.navigationController.navigationBar.translucent) {
                    headerHeight += 64 + topSpaceY;
                    footerHeight = -64 - topSpaceY;
                }
                break;
            }
            case FLWebViewHeaderShowTypeHiddenNavBar:{
                headerHeight = 0.0;
                footerHeight = 0.0;
                break;
            }
        }
        
        switch (self.showFooterType) {
            case FLWebViewFooterShowTypeNormal:
            {
                footerHeight -= bottomSpaceY;
                break;
            }
                
            case FLWebViewFooterShowTypeTabBar:
            {
                footerHeight -= (49.+ bottomSpaceY);
                break;
            }
            default:
                break;
        }
        //配置环境
        webFrame = CGRectMake(0, headerHeight, 375, 674);
        WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc]init];
        configuration.processPool = [[WKProcessPool alloc] init];
        
        WKUserContentController *userC = [[WKUserContentController alloc] init];
        configuration.userContentController = userC;
        
        _wkWebView = [[WKWebView alloc] initWithFrame:webFrame configuration:configuration];
        _wkWebView.scrollView.delegate = self;
        _wkWebView.UIDelegate = self;
//        _wkWebView.allowsLinkPreview = _allowsLinkPreview;
        _wkWebView.navigationDelegate = self;
        _wkWebView.allowsBackForwardNavigationGestures = YES;
    }
    return _wkWebView;
}

- (NSMutableArray *)backarray
{
    if (_backarray == nil){
        _backarray = [[NSMutableArray alloc] init];
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"return_nor.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(retureBack:)];
        UIBarButtonItem *spaceItemOne = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceItemOne.width = - 10;
        UIBarButtonItem *two = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(closeAction:)];
        
        UIBarButtonItem *spaceItemTwo = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceItemTwo.width = - 30;
        [_backarray addObject:spaceItemOne];
        [_backarray addObject:backItem];
        
        [_backarray addObject:spaceItemTwo];
        [_backarray addObject:two];
    }
    return _backarray;
    
}


- (UIView *)progressView
{
    if (_progressView == nil) {
        _progressView = [[UIView alloc] initWithFrame:CGRectMake(0, self.wkWebView.frame.origin.y, 0, 1.5)];
        _progressView.backgroundColor = [UIColor redColor];
    }
    return _progressView;
}

- (NSMutableSet *)loadSchemes
{
    if (_loadSchemes == nil) {
        _loadSchemes = [[NSMutableSet alloc] initWithCapacity:10];
    }
    return _loadSchemes;
}

- (NSMutableSet *)scripNames
{
    if (_scripNames == nil) {
        _scripNames = [[NSMutableSet alloc] initWithCapacity:10];
    }
    return _scripNames;
}

- (NSMutableSet *)userScrip
{
    if (_userScrip == nil) {
        _userScrip = [[NSMutableSet alloc] initWithCapacity:10];
    }
    return _userScrip;
}


@end
