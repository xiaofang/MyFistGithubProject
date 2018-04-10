//
//  FirstPageViewController.m
//  MyFistGithubProject
//
//  Created by 张彦芳 on 2017/9/5.
//  Copyright © 2017年 zyf. All rights reserved.
//

#import "FirstPageViewController.h"
#import "UIImageView+WebCache.h"
#import "YTImagePlaceHolderManager.h"
#import <WebKit/WebKit.h>
#import "FLBaseWebController.h"
#import "ZipArchive.h"

@interface FirstPageViewController ()<UIWebViewDelegate>
@property (nonatomic,strong)UILabel *rotateLabel;
@property (nonatomic,strong)UIButton *backButton;
@property (nonatomic,strong)NSTimer *timer;
@property (nonatomic,strong)UIImageView *imageView1;
@property (nonatomic,strong)UIImageView *imageView2;
@property (nonatomic,strong)UIButton *startButton;
@property (nonatomic,copy) NSString * urlStr;
@property (nonatomic,strong)UIWebView *webView;
@property (nonatomic,strong)WKWebView *wkWebView;
@property (nonatomic,strong)NSMutableArray *allHtmlArray;
@end

@implementation FirstPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"二级页面";
    _allHtmlArray = [[NSMutableArray alloc] init];
    _urlStr = @"https://app.simuyun.com/app6.0/biz/mine/mine-help.html";
//    _urlStr = @"https://app.simuyun.com//app6.0/biz/assesment/index.html";
//    _urlStr = @"https://app.simuyun.com/app6.0/biz/product/new_detail_toc.html?id=150611c699c14587965ca9b89a1a95b4&category=6&share=1&type=1&userid=46669bc4f1c346609186a7154ba2980b&from=singlemessage&isappinstalled=1";
//    _urlStr = @"https://app.simuyun.com/app6.0/biz/product/new_detail_toc.html?id=06a60d3cac89494e99036b3b930d23ef&category=7";
    [self initSubviews];
    _backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 500, 300, 40)];
    [_backButton setTitle:@"返回" forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    [_backButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backClick:)];
    
//    [self.view addSubview:_backButton];
//    __weak typeof(self) weakself = self;
//    self.testBlock = ^{
//
//        [weakself.backButton setTitle:@"test" forState:UIControlStateNormal];
//    };
//    self.testBlock();
    
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.f target:self selector:@selector(log) userInfo:nil repeats:YES];
//    [self.timer fire];
    

    // Do any additional setup after loading the view.
    
}
-(void)initSubviews{
    /* 测试imageViewPlaceHolder
    self.imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(40, 120, 160, 90)];
//    [self.imageView1 sd_setImageWithURL:[NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1505126654378&di=05bfb4f5104c0e2ef2e8ed53577330b5&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201502%2F08%2F20150208094220_WCJcS.thumb.700_0.jpeg"]];
    self.imageView1.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.imageView1];
   
    self.imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(10, 230, 300, 150)];
    self.imageView2.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:self.imageView2];
    
    self.startButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 80, 300, 40)];
    [self.startButton setTitle:@"开始" forState:UIControlStateNormal];
    [self.startButton addTarget:self action:@selector(startClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.startButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.view addSubview:self.startButton];
    */
    
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSLog(@"documentPath=====%@",documentPath);
    // zip 文件路径
    NSString *filePath = [documentPath stringByAppendingPathComponent:@"preload.zip"];
    
    ZipArchive *zip = [[ZipArchive alloc] init];
    BOOL zipOpenResult = [zip UnzipOpenFile:filePath];
    BOOL zipUnZipResult = [zip UnzipFileTo:documentPath overWrite:YES];
    // 删除包文件
    NSString *result = [NSString stringWithFormat:@"zip解压结果: 开始解压:%d  解压结果:%d", zipOpenResult, zipUnZipResult];
    NSLog(@"zip 解压结果====%@",result);
    [self searchAllHtmlFileWithPath:[documentPath stringByAppendingPathComponent:@"preload"]];
//    NSString *baseUrl = [documentPath stringByAppendingPathComponent:@"html"];
//    NSString *htmlPath = [baseUrl stringByAppendingPathComponent:@"jumpApp.html"];
//    NSURL *baseURL = [NSURL fileURLWithPath:baseUrl];

    
    
    UIWebView *webview = [[UIWebView alloc] initWithFrame:self.view.bounds];
   // 加载本地bundle 文件
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    NSString * htmlPath = [[NSBundle mainBundle] pathForResource:@"healthConsultation2--iOS"
                                                          ofType:@"html"];
    
    NSString * htmlCont = [NSString stringWithContentsOfFile:htmlPath
                                                    encoding:NSUTF8StringEncoding
                                                       error:nil];
//    [webview loadHTMLString:htmlCont baseURL:baseURL];
//    [self.view addSubview:webview];
//
   
    WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc]init];
    configuration.processPool = [[WKProcessPool alloc] init];
    
    WKUserContentController *userC = [[WKUserContentController alloc] init];
    configuration.userContentController = userC;
    _wkWebView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    [_wkWebView loadHTMLString:htmlCont baseURL:baseURL];
    [self.view addSubview:_wkWebView];

    //wkwebview  test
//    _wkWebView.scrollView.delegate = self;
//    _wkWebView.UIDelegate = self;
//    _wkWebView.navigationDelegate = self;
    _wkWebView.allowsBackForwardNavigationGestures = YES;
//    NSURL *url = [NSURL URLWithString:_urlStr];
//    NSURLRequest *request = [NSURLRequest requestWithURL:htmlPath];
//    [NSURLRequest requestWithURL: cachePolicy:NSURLCacheStoragePolicy timeoutInterval:<#(NSTimeInterval)#>]
//    [_wkWebView loadRequest:request];
//    [_wkWebView loadFileURL:[NSURL URLWithString:htmlPath] allowingReadAccessToURL:baseURL];
   
 

//    FLBaseWebController *webViewController = [[FLBaseWebController alloc] initWithURLStr:_urlStr title:@"test"];
//    [self.navigationController pushViewController:webViewController animated:YES];
    
    /* 测试 webview 加载html
    WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc]init];
    configuration.processPool = [[WKProcessPool alloc] init];
    
    WKUserContentController *userC = [[WKUserContentController alloc] init];
    configuration.userContentController = userC;
    _wkWebView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    [self.view addSubview:_wkWebView];
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString * path = [cachesPath stringByAppendingString:[NSString stringWithFormat:@"/Caches/health.html"]];
    NSString *htmlString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (!(htmlString ==nil || [htmlString isEqualToString:@""])) {
        [_wkWebView loadHTMLString:htmlString baseURL:[NSURL URLWithString:_urlStr]];
    }else{
        NSURL *url = [NSURL URLWithString:_urlStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [_wkWebView loadRequest:request];
        [self writeToCache];
    }
     */

}
/**
 * 网页缓存写入文件
 */
- (void)writeToCache
{
    NSString * htmlResponseStr = [NSString stringWithContentsOfURL:[NSURL URLWithString:_urlStr] encoding:NSUTF8StringEncoding error:Nil];
    //创建文件管理器
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    //获取document路径
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    [fileManager createDirectoryAtPath:[cachesPath stringByAppendingString:@"/Caches"]withIntermediateDirectories:YES attributes:nil error:nil];
    //写入路径
    NSString * path = [cachesPath stringByAppendingString:[NSString stringWithFormat:@"/Caches/health.html"]];
    [htmlResponseStr writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}
- (void)searchAllHtmlFileWithPath:(NSString *) path {
    NSFileManager * fileManger = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExist = [fileManger fileExistsAtPath:path isDirectory:&isDir];
    if (isExist) {
        if (isDir) {
            NSArray * dirArray = [fileManger contentsOfDirectoryAtPath:path error:nil];
            NSString * subPath = nil;
            for (NSString * str in dirArray) {
                subPath  = [path stringByAppendingPathComponent:str];
                BOOL issubDir = NO;
                [fileManger fileExistsAtPath:subPath isDirectory:&issubDir];
                [self searchAllHtmlFileWithPath:subPath];
            }
        }else{
            NSString *fileName = [[path componentsSeparatedByString:@"/"] lastObject];
            if ([fileName hasSuffix:@".html"]) {
                NSLog(@"path=======%@", path);
                [self.allHtmlArray addObject:path];
            }
        }
    }else{
        NSLog(@"this path is not exist!");
    }
}

-(void)log{
    NSLog(@"=====timer block");
}
-(void)backClick:(UIButton*)button{
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)startClick:(UIButton *)button{
    UIImage *imagePlaceHolder1 = [[YTImagePlaceHolderManager shareInstance] placeholderImageWithSize:self.imageView1.frame.size withInnerSize:CGSizeMake(30, 30) withInnerImage:nil withBackgroudColor:nil];
//    [self.imageView1 sd_setImageWithURL:[NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1505130857118&di=af22190455ceff7f3072924202845e48&imgtype=0&src=http%3A%2F%2Fimg3.duitang.com%2Fuploads%2Fitem%2F201502%2F16%2F20150216103557_mrXFm.thumb.700_0.jpeg"] placeholderImage:imagePlaceHolder1];
    [self.imageView1 sd_setImageWithURL:[NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1505192883615&di=31f3cd1a7fa583db1a87692b6dd93cb5&imgtype=0&src=http%3A%2F%2Fwww.chinadaily.com.cn%2Fkindle%2Fattachement%2Fjpg%2Fsite241%2F20170127%2Ff04da2db112219f4d60941.jpg"] placeholderImage:imagePlaceHolder1];
    
    UIImage * imagePlaceHolder2 = [[YTImagePlaceHolderManager shareInstance] placeholderImageWithSize:self.imageView2.frame.size withInnerSize:CGSizeZero withInnerImage:nil withBackgroudColor:nil];
    [self.imageView2 sd_setImageWithURL:[NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1505192883615&di=344072df72820790ba05a691a606c068&imgtype=0&src=http%3A%2F%2Fimg5.duitang.com%2Fuploads%2Fitem%2F201502%2F02%2F20150202141217_UfCxB.thumb.700_0.jpeg"] placeholderImage:imagePlaceHolder2];
    
    
//    UIImage *imagePlaceHolder1 = [[YTImagePlaceHolderManager shareInstance] placeholderImageWithScale:16/9.f withInnerSize:CGSizeZero withInnerImage:nil withBackgroudColor:nil];
//    //    [self.imageView1 sd_setImageWithURL:[NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1505130857118&di=af22190455ceff7f3072924202845e48&imgtype=0&src=http%3A%2F%2Fimg3.duitang.com%2Fuploads%2Fitem%2F201502%2F16%2F20150216103557_mrXFm.thumb.700_0.jpeg"] placeholderImage:imagePlaceHolder1];
//    [self.imageView1 sd_setImageWithURL:[NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1505192883614&di=80c9cf48e737bf601687ef1b41e9d16a&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimage%2Fc0%253Dshijue1%252C0%252C0%252C294%252C40%2Fsign%3D61719f2dd3f9d72a0369185ebc434241%2F6159252dd42a28344fa6cd1951b5c9ea15cebfa4.jpg"] placeholderImage:imagePlaceHolder1];
//    
//    UIImage * imagePlaceHolder2 =  [[YTImagePlaceHolderManager shareInstance] placeholderImageWithScale:2/1.f withInnerSize:CGSizeZero withInnerImage:nil withBackgroudColor:nil];
//    [self.imageView2 sd_setImageWithURL:[NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1505192883614&di=d7d8e1e0355049270a3a8498994a1409&imgtype=0&src=http%3A%2F%2Fi-7.vcimg.com%2Ftrim%2F1e1af889e6b331dbf13ba2b3e591fc2257826%2Ftrim.jpg"] placeholderImage:imagePlaceHolder2];
 
}
#pragma mark UIWebviewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    NSLog(@"webViewDidStartLoad=====");
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"webViewDidFinishLoad======");
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"webViewdidFailLoadWithError========");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    NSLog(@"FirstPageViewController dealloc");
}
//- (void)runJS:(NSString *)js completionHandler:(void (^ _Nullable)(_Nullable id message, NSError * _Nullable error))completionHandler
//{
//    [self.wkWebView evaluateJavaScript:js completionHandler:completionHandler];
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
