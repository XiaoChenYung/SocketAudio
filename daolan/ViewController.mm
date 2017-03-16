//
//  ViewController.m
//  daolan
//
//  Created by tm on 2017/3/15.
//  Copyright © 2017年 tm. All rights reserved.
//

#import "ViewController.h"
#import "MyServer.h"
#include <OpenAL/OpenAL.h>
#import <AVFoundation/AVFoundation.h>
#import "AQRecorder.h"

@interface ViewController ()<MyServerDelegete>
{
    AQRecorder*					recorder;
}

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (strong, nonatomic) MyServer *myServer;

@end

@implementation ViewController

- (void)showtitle:(NSString *)title {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.textView.text = title;
    });
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myServer = [MyServer new];
    self.myServer.delegate = self;
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)startServer:(UIButton *)sender {
    [self.myServer startListenAndNewThread];
}

- (IBAction)stopServer:(UIButton *)sender {
    [self.myServer closeServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
