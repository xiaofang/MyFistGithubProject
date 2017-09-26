//
//  ViewController.m
//  MyFistGithubProject
//
//  Created by zyf on 17/7/21.
//  Copyright © 2017年 zyf. All rights reserved.
//

#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import  <AVFoundation/AVFoundation.h>
#import "CustomView.h"
#import "CustomView+test.h"
#import <objc/runtime.h>
#import "FirstPageViewController.h"

#define __MainScreenFrame   [[UIScreen mainScreen] bounds]
#define __MainScreen_Width  ((__MainScreenFrame.size.width)<(__MainScreenFrame.size.height)?(__MainScreenFrame.size.width):(__MainScreenFrame.size.height))
#define __MainScreen_Height ((__MainScreenFrame.size.height)>(__MainScreenFrame.size.width)?(__MainScreenFrame.size.height):(__MainScreenFrame.size.width))
#define DOWNLOAD_ANIMATIONENDX (__MainScreen_Width-96)
#define kColor249 [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0]
@interface ViewController (){
    NSObject * _object;
}
@property(nonatomic,retain)NSObject *object;
@property (nonatomic,copy) NSArray * array;
@property(nonatomic,copy)NSString *now;
@property(nonatomic,strong)UIButton *startRecordButton;
@property(nonatomic,strong)UIButton *startPlayButton;
@property (nonatomic,strong)NSURL *recordedFile;
@property (nonatomic,strong)AVAudioPlayer *player;
@property (nonatomic,strong)AVAudioRecorder *recorder;
@property (nonatomic,strong)NSString *recoderName;
@property (nonatomic,strong)NSManagedObjectContext *managedContext;
@property (nonatomic,strong)UIImageView *loadingView;
@property (nonatomic,strong)UIView *rotateView;
@property (nonatomic,strong)UILabel *rotateLabel;
@property(nonatomic,strong)UIButton *universalLinkButton;
@property(nonatomic,strong)UIButton *loadHtmlButton;



@end

@implementation ViewController

__weak NSString *string_weak_ = nil;

//+(void)load{
//    NSLog(@"==load ViewController");
//}

-(void)initCoreData{
NSMutableString *a = [NSMutableString stringWithString:@"Tom"];
NSLog(@"\\n 定以前：------------------------------------\\n\\
a指向的堆中地址：%p；a在栈中的指针地址：%p", a, &a);               //a在栈区
void (^foo)(void) = ^{
a.string = @"Jerry";
NSLog(@"\\n block内部：------------------------------------\\n\\
a指向的堆中地址：%p；a在栈中的指针地址：%p", a, &a);               //a在栈区
//                    a = [NSMutableString stringWithString:@"William"];
};
foo();
NSLog(@"\\n 定以后：------------------------------------\\n\\
  a指向的堆中地址：%p；a在栈中的指针地址：%p", a, &a);
  }
  -(void)setUpButtons{
      _startRecordButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 500, 300, 40)];
      [_startRecordButton setTitle:@"按住讲话" forState:UIControlStateNormal];
      [_startRecordButton setTitle:@"松开结束" forState:UIControlStateSelected];
      [_startRecordButton addTarget:self action:@selector(startPlayCord:) forControlEvents:UIControlEventTouchDown];
      [_startRecordButton addTarget:self action:@selector(stopRecord:) forControlEvents:UIControlEventTouchUpInside];
      [_startRecordButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
      _startRecordButton.layer.cornerRadius = 5;
      _startRecordButton.layer.borderWidth = 0.5;
      _startRecordButton.layer.borderColor = [UIColor colorWithRed:231/255.0 green:231/255.0 blue:231/255.0 alpha:1.0].CGColor;
//      [self.view addSubview:self.startRecordButton];
      
      _startPlayButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 400, 300, 40)];
      [_startPlayButton setTitle:@"播放录音" forState:UIControlStateNormal];
      [_startPlayButton addTarget:self action:@selector(startPlay:) forControlEvents:UIControlEventTouchUpInside];
      //    [_startPlayButton addTarget:self action:@selector(stopPlay:) forControlEvents:UIControlEventTouchUpInside];
      [_startPlayButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
      _startPlayButton.layer.cornerRadius = 5;
      _startPlayButton.layer.borderWidth = 0.5;
      _startPlayButton.layer.borderColor = [UIColor colorWithRed:231/255.0 green:231/255.0 blue:231/255.0 alpha:1.0].CGColor;
//      [self.view addSubview:self.startPlayButton];
      
      _universalLinkButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 100, 300, 40)];
      [_universalLinkButton setTitle:@"test universal Links" forState:UIControlStateNormal];
      [_universalLinkButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
      _universalLinkButton.tag = 1000;
      [_universalLinkButton addTarget:self action:@selector(handButtonClick:) forControlEvents:UIControlEventTouchUpInside];
      [self.view addSubview:self.universalLinkButton];
      
      _loadHtmlButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 170, 300, 40)];
      [_loadHtmlButton setTitle:@"test cache html" forState:UIControlStateNormal];
      [_loadHtmlButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
      _loadHtmlButton.tag = 1001;
      [_loadHtmlButton addTarget:self action:@selector(handButtonClick:) forControlEvents:UIControlEventTouchUpInside];
      [self.view addSubview:self.loadHtmlButton];
      
  }
  - (void)startPlayCord:(UIButton*)button{
      button.selected = YES;
      self.startRecordButton.backgroundColor = kColor249;
      NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc]init];
      //设置录音格式
      [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
      //设置录音采样率
      [recordSetting setValue:[NSNumber numberWithFloat:8000] forKey:AVSampleRateKey];
      //录音的质量
      [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
      //线性采样位数  8、16、24、32
      [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
      //录音通道数  1 或 2
      [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
      _recorder = [[AVAudioRecorder alloc] initWithURL:self.recordedFile settings:recordSetting error:nil];
      //缓冲录音
      [_recorder prepareToRecord];
      //开始录音
      [_recorder record];
      //如果是反复录制需要置空
      _player = nil;
      
      FirstPageViewController *viewController = [[FirstPageViewController alloc] init];
      [self.navigationController pushViewController:viewController animated:YES];
      
  }
  - (void)stopRecord:(UIButton*)button{
      button.selected = NO;
      self.startRecordButton.backgroundColor = [UIColor whiteColor];
      [_recorder stop];
      _recorder = nil;
      NSError *playerError;
      _player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recordedFile error:&playerError];
  }
  -(void)setupRecordFilePath{
      NSDateFormatter *formater = [[NSDateFormatter alloc] init];
      [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
      NSString * dateStr = [formater stringFromDate:[NSDate date]];
      NSString * path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, true) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.aac",dateStr]];
      _recoderName = [NSString stringWithFormat:@"%@.aac",dateStr];
      _recordedFile = [NSURL fileURLWithPath:path];
  }
  -(void)setupSession{
      AVAudioSession *session = [AVAudioSession sharedInstance];
      NSError *sessionError;
      [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
      if(session == nil)
      {
      }
      else
      {
          [session setActive:YES error:nil];
      }
  }
  
  - (void)startPlay:(UIButton*)button{
      
      //初始化播放器的时候如下设置
      UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
      AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                              sizeof(sessionCategory),
                              &sessionCategory);
      UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
      AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                               sizeof (audioRouteOverride),
                               &audioRouteOverride);
      AVAudioSession *audioSession = [AVAudioSession sharedInstance];
      //默认情况下扬声器播放
      [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
      [audioSession setActive:YES error:nil];
      //建议播放之前设置yes，播放结束设置no，这个功能是开启红外感应
      //    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
      //    //添加监听
      //    [[NSNotificationCenter defaultCenter] addObserver:self
      //                                             selector:@selector(sensorStateChange:)
      //                                                 name:@"UIDeviceProximityStateDidChangeNotification"
      //                                               object:nil];
      //开始播放
      [_player play];
      
      
  }
-(void)handButtonClick:(UIButton *)button{
//    NSURL *url = [NSURL URLWithString:@"https://app.simuyun.com/app6.0/biz/mine/mine_active_list.html"];
//    [[UIApplication sharedApplication] openURL:url  options:[NSDictionary dictionary] completionHandler:^(BOOL success) {
//        
//    }];
    switch(button.tag){
        case 1000:{
            FirstPageViewController *viewController = [[FirstPageViewController alloc] init];
            [self.navigationController pushViewController:viewController animated:YES];
        }
        break;
        case 1001:{
            FirstPageViewController *viewController = [[FirstPageViewController alloc] init];
            [self.navigationController pushViewController:viewController animated:YES];
        }
        break;
        
        default:{
            FirstPageViewController *viewController = [[FirstPageViewController alloc] init];
            [self.navigationController pushViewController:viewController animated:YES];
        }
        break;
            
    }
    
}
  
  
  
  - (void)viewDidLoad {
      
      [super viewDidLoad];
      
      _loadingView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 154, 154)];
      [_loadingView setImage:[UIImage imageNamed:@"icon_me"]];
      
      _rotateView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 300, 154, 154)];
      _rotateView.layer.cornerRadius = 77;
      _rotateView.backgroundColor = [UIColor redColor];
      
      self.rotateLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 30, 50, 50)];
      self.rotateLabel.text = @"rotate";
      [_rotateView addSubview:self.rotateLabel];
      
      
      [self.view addSubview:_loadingView];
      [self.view addSubview:_rotateView];
      
      [self setUpButtons];
      [self setupRecordFilePath];
      [self setupSession];
      [self initCoreData];
      [self testCategoryMethod];
      
      
//      [self testRotate];
//      self.testBlock = ^{
//          
//          self.rotateLabel.text = @"test leak";
//      };
//      
//      self.testBlock();
//      self.timer = [NSTimer scheduledTimerWithTimeInterval:2.f repeats:YES block:^(NSTimer * _Nonnull timer) {
//          NSLog(@"=====timer block");
//      }];
//      [self.timer fire];
      
      
      //    for(int i= 0;i< 100000;i++){
      //        @autoreleasepool {
      //            NSString *str = @"aBc";
      //            str = [str lowercaseString];
      //            str = [str stringByAppendingString:@"cde"];
      //            NSLog(@"string: %@", str);
      //        }
      ////    }
      //    NSArray *dataArray = [_array mutableCopy];
      //
      //    dispatch_async(dispatch_get_main_queue(), ^(void){
      //        NSLog(@"这里死锁了");
      //    });
      
      //    NSObject *firstObject = [NSObject new];
      //    __attribute__((objc_precise_lifetime)) NSObject *object = [NSObject new];
      //    __weak NSObject *secondObject = object;
      //    NSObject *thirdObject = [NSObject new];
      //
      //    __unused void (^block)() = ^{
      //        __unused NSObject *first = firstObject;
      //        __unused NSObject *second = secondObject;
      //        __unused NSObject *third = thirdObject;
      //    };
      
      //    [self addObserver:self forKeyPath:@"now" options:NSKeyValueObservingOptionNew context:nil];
      //    NSLog(@"1");
      //    [self willChangeValueForKey:@"now"]; // “手动触发self.now的KVO”，必写。
      //    NSLog(@"2");
      //    [self didChangeValueForKey:@"now"]; // “手动触发self.now的KVO”，必写。
      //    NSLog(@"4");
      
      
      
      NSLog(@"log=====A");
      [self performSelector:@selector(logB) withObject:nil];
      NSLog(@"log=====C");
      //    dispatch_queue_t queue1 = dispatch_queue_create("queue1", DISPATCH_QUEUE_CONCURRENT);
      
      //    dispatch_async(queue1, ^{
      //        NSLog(@"====1%@",[NSThread currentThread]);
      //    });
      //    dispatch_async(queue1, ^{
      //        NSLog(@"====2%@",[NSThread currentThread]);
      //    });
      //    dispatch_barrier_async(queue1, ^{
      //        NSLog(@"====3%@",[NSThread currentThread]);
      //    });
      //    dispatch_async(queue1, ^{
      //        NSLog(@"====4%@",[NSThread currentThread]);
      //    });
      //    [self test6];
      
      //    NSLog(@"%@",[NSThread currentThread]);
      //    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      //        NSLog(@"sync----%@",[NSThread currentThread]);
      //    });
      //    NSLog(@"%@",[NSThread currentThread]);
      
      
      //    dispatch_queue_t concurrentQueue = dispatch_queue_create("my.concurrent.queue", DISPATCH_QUEUE_CONCURRENT);
      //    dispatch_async(concurrentQueue, ^(){
      //        NSLog(@"dispatch-1");
      //    });
      //    dispatch_async(concurrentQueue, ^(){
      //        NSLog(@"dispatch-2");
      //    });
      //    dispatch_barrier_async(concurrentQueue, ^(){
      //        NSLog(@"dispatch-barrier");
      //    });
      //    dispatch_async(concurrentQueue, ^(){
      //        NSLog(@"dispatch-3");
      //    });
      //    dispatch_async(concurrentQueue, ^(){
      //        NSLog(@"dispatch-4");
      //    });
      //    dispatch_barrier_async 作用是在并行队列中，等待前面两个操作并行操作完成，这里是并行输出
      //    dispatch-1，dispatch-2
      //    然后执行
      //    dispatch_barrier_async中的操作，(现在就只会执行这一个操作)执行完成后，即输出
      //    "dispatch-barrier，
      //    最后该并行队列恢复原有执行状态，继续并行执行
      //    dispatch-3,dispatch-4
      
  }
  -(void)testCategoryMethod{
      CustomView *customView = [[CustomView alloc] init];
      [customView logSelf];
  }
  -(void)testOperation{
      NSOperation *operation1 = [[NSOperation alloc] init];
      NSOperationQueue *opearationQueue = [[NSOperationQueue alloc] init];
      [opearationQueue addOperation:operation1];
      [opearationQueue setSuspended:YES];
      dispatch_queue_t queue = dispatch_queue_create("com.download", DISPATCH_QUEUE_CONCURRENT);
      dispatch_async(queue, ^{
          NSURLConnection *connection = [[NSURLConnection alloc] init];
          
      });
      
  }
  -(void)testRotate{
      CABasicAnimation* rotationAnimation;
      rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
      rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI*2.0];
      rotationAnimation.duration = 2.f;
      rotationAnimation.cumulative = YES;
      rotationAnimation.repeatCount = 100;
      //    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
      [_loadingView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
      
      CGRect rect = _loadingView.frame;
      CGMutablePathRef downloadPath = CGPathCreateMutable();
      CGPathMoveToPoint(downloadPath, NULL, 0,0);
      CGPathAddQuadCurveToPoint(downloadPath, NULL, 200, 400, 400,(__MainScreen_Height - 30));
      CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
      pathAnimation.path = downloadPath;
      pathAnimation.duration = 2;
      pathAnimation.repeatCount = MAXFLOAT;
      pathAnimation.autoreverses = NO;
      
      
      CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
      animationGroup.animations = [NSArray arrayWithObjects:pathAnimation, /*scaleAnimation,*/ rotationAnimation, nil];
      animationGroup.duration = 2;
      animationGroup.repeatCount = 100;
      
      [_loadingView.layer addAnimation:animationGroup forKey:nil];
      CFRelease(downloadPath);
      
      
      CABasicAnimation* rotationAnimation1;
      rotationAnimation1 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
      rotationAnimation1.toValue = [NSNumber numberWithFloat: M_PI*2.0];
      rotationAnimation1.duration = 2.f;
      rotationAnimation1.cumulative = YES;
      rotationAnimation1.repeatCount = 100;
      //    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
      [_rotateView.layer addAnimation:rotationAnimation1 forKey:@"rotationAnimation"];
  }
  
  -(void)test{
      dispatch_queue_t q = dispatch_queue_create("fs", DISPATCH_QUEUE_SERIAL);
      NSLog(@"start--%@",[NSThread currentThread]);
      for (int i=0; i<10; i++) {
          dispatch_async(q, ^{
              NSLog(@"async--%@",[NSThread currentThread]);
          });
      }
      NSLog(@"end--%@",[NSThread currentThread]);
  }
  -(void)test2{
      dispatch_queue_t q = dispatch_queue_create("fs", DISPATCH_QUEUE_SERIAL);
      NSLog(@"start--%@",[NSThread currentThread]);
      for (int i=0; i<10; i++) {
          dispatch_sync(q, ^{
              NSLog(@"sync--%@---%d",[NSThread currentThread],i);
          });
      }
      NSLog(@"end--%@",[NSThread currentThread]);
  }
  -(void)test3{
      dispatch_queue_t q = dispatch_queue_create("fs", DISPATCH_QUEUE_CONCURRENT);
      NSLog(@"start--%@",[NSThread currentThread]);
      for (int i=0; i<10; i++) {
          dispatch_async(q, ^{
              NSLog(@"async--%@---%d",[NSThread currentThread],i);
          });
      }
      NSLog(@"end--%@",[NSThread currentThread]);
  }
  -(void)test4{
      dispatch_queue_t q = dispatch_queue_create("fs", DISPATCH_QUEUE_CONCURRENT);
      NSLog(@"start--%@",[NSThread currentThread]);
      for (int i=0; i<10; i++) {
          dispatch_sync(q, ^{
              NSLog(@"sync--%@---%d",[NSThread currentThread],i);
          });
      }
      NSLog(@"end--%@",[NSThread currentThread]);
  }
  -(void)test5{
      dispatch_queue_t q = dispatch_queue_create("fs", DISPATCH_QUEUE_SERIAL);
      NSLog(@"start--%@",[NSThread currentThread]);
      for (int i=0; i<10; i++) {
          dispatch_async(q, ^{
              NSLog(@"async--%@---%d",[NSThread currentThread],i);
          });
      }
      NSLog(@"end1--%@",[NSThread currentThread]);
      for (int i=0; i<10; i++) {
          dispatch_sync(q, ^{
              NSLog(@"sync--%@---%d",[NSThread currentThread],i);
          });
      }
      NSLog(@"end2--%@",[NSThread currentThread]);
  }
  -(void)test6{
      dispatch_queue_t q = dispatch_queue_create("fs", DISPATCH_QUEUE_SERIAL);
      NSLog(@"start--%@",[NSThread currentThread]);
      for (int i=0; i<10; i++) {
          dispatch_sync(q, ^{
              NSLog(@"sync--%@---%d",[NSThread currentThread],i);
          });
      }
      NSLog(@"end1--%@",[NSThread currentThread]);
      for (int i=0; i<10; i++) {
          dispatch_async(q, ^{
              NSLog(@"async--%@---%d",[NSThread currentThread],i);
          });
      }
      NSLog(@"end2--%@",[NSThread currentThread]);
  }
  -(void)test7{
      dispatch_queue_t q = dispatch_queue_create("fs", DISPATCH_QUEUE_CONCURRENT);
      NSLog(@"start--%@",[NSThread currentThread]);
      for (int i=0; i<10; i++) {
          dispatch_async(q, ^{
              NSLog(@"async--%@---%d",[NSThread currentThread],i);
          });
      }
      NSLog(@"end1--%@",[NSThread currentThread]);
      for (int i=0; i<10; i++) {
          dispatch_sync(q, ^{
              NSLog(@"sync--%@---%d",[NSThread currentThread],i);
          });
      }
      NSLog(@"end2--%@",[NSThread currentThread]);
  }
  -(void)test8{
      dispatch_queue_t q = dispatch_queue_create("fs", DISPATCH_QUEUE_CONCURRENT);
      NSLog(@"start--%@",[NSThread currentThread]);
      for (int i=0; i<10; i++) {
          dispatch_sync(q, ^{
              NSLog(@"sync--%@---%d",[NSThread currentThread],i);
          });
      }
      NSLog(@"end1--%@",[NSThread currentThread]);
      for (int i=0; i<10; i++) {
          dispatch_async(q, ^{
              NSLog(@"async--%@---%d",[NSThread currentThread],i);
          });
      }
      NSLog(@"end2--%@",[NSThread currentThread]);
  }
  
  -(void)logB{
      NSLog(@"log=====B");
  }
  
  - (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
      NSLog(@"3");
  }
  - (void)viewWillAppear:(BOOL)animated {
      
      [super viewWillAppear:animated];
      
  }
  - (void)viewDidAppear:(BOOL)animated {
      
      [super viewDidAppear:animated];
      
  }
- (void)viewDidDisappear:(BOOL)animated{
  
  [super viewDidDisappear:animated];
  
}

  
  - (void)didReceiveMemoryWarning {
      [super didReceiveMemoryWarning];
      // Dispose of any resources that can be recreated.
  }
-(void)dealloc{

  NSLog(@"====self dealloc");
}
  
  @end

