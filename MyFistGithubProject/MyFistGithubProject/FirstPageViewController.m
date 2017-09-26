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

@interface FirstPageViewController ()<UIWebViewDelegate>
@property (nonatomic,strong)UILabel *rotateLabel;
@property (nonatomic,strong)UIButton *backButton;
@property (nonatomic,strong)NSTimer *timer;
@property (nonatomic,strong)UIImageView *imageView1;
@property (nonatomic,strong)UIImageView *imageView2;
@property (nonatomic,strong)UIButton *startButton;
@property (nonatomic,copy) NSString * urlStr;
@property (nonatomic,strong)UIWebView *webView;
@end

@implementation FirstPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"二级页面";
    _urlStr = @"https://app.simuyun.com/app6.0/biz/mine/mine-help.html";
    [self initSubviews];
    _backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 500, 300, 40)];
    [_backButton setTitle:@"返回" forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    [_backButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backClick:)];
    
//    [self.view addSubview:_backButton];
    __weak typeof(self) weakself = self;
    self.testBlock = ^{
        
        [weakself.backButton setTitle:@"test" forState:UIControlStateNormal];
    };
    self.testBlock();
    
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
    /* 测试Universal link
    UIWebView *webview = [[UIWebView alloc] initWithFrame:self.view.bounds];
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    NSString * htmlPath = [[NSBundle mainBundle] pathForResource:@"jumpApp"
                                                          ofType:@"html"];
    NSString * htmlCont = [NSString stringWithContentsOfFile:htmlPath
                                                    encoding:NSUTF8StringEncoding
                                                       error:nil];
    [webview loadHTMLString:htmlCont baseURL:baseURL];
    [self.view addSubview:webview];
    */
    
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.delegate = self;
    [self.view addSubview:_webView];
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString * path = [cachesPath stringByAppendingString:[NSString stringWithFormat:@"/Caches/healthProject.html"]];
    NSString *htmlString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (!(htmlString ==nil || [htmlString isEqualToString:@""])) {
        [_webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:_urlStr]];
    }else{
        NSURL *url = [NSURL URLWithString:_urlStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [_webView loadRequest:request];
        [self writeToCache];
    }

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
    NSString * path = [cachesPath stringByAppendingString:[NSString stringWithFormat:@"/Caches/healthProject.html"]];
    [htmlResponseStr writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
