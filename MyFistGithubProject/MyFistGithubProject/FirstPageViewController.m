//
//  FirstPageViewController.m
//  MyFistGithubProject
//
//  Created by 张彦芳 on 2017/9/5.
//  Copyright © 2017年 zyf. All rights reserved.
//

#import "FirstPageViewController.h"

@interface FirstPageViewController ()
@property (nonatomic,strong)UILabel *rotateLabel;
@property (nonatomic,strong)UIButton *backButton;
@property (nonatomic,strong)NSTimer *timer;
@end

@implementation FirstPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"二级页面";
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
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.f target:self selector:@selector(log) userInfo:nil repeats:YES];
    [self.timer fire];
    

    // Do any additional setup after loading the view.
}
-(void)log{
    NSLog(@"=====timer block");
}
-(void)backClick:(UIButton*)button{
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
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
