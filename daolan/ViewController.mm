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
#import "Record.h"
#import "Play.h"
@interface ViewController ()<MyServerDelegete, RecordDelegate>
{
    
}
@property (nonatomic, strong) Record *recorder;
@property (strong, nonatomic) Play *play;
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
    self.recorder = [[Record alloc] init];
    self.recorder.delegate = self;
    _play = [[Play alloc] init];
    // Do any additional setup after loading the view, typically from a nib.
}

//- (void)record:(Record *)record AudioBuffer:(const void *)buffer withQueue:(AudioQueueRef)queue {
//    [self.myServer sendData:buffer];
//}

- (void)record:(Record *)record AudioBuffer:(NSData *)buffer withQueue:(AudioQueueRef)queue {
    [self.myServer sendData:buffer];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.textView resignFirstResponder];
}
- (IBAction)record:(UIButton *)sender {
    [self.recorder start];
}
- (IBAction)play:(UIButton *)sender {
    [self.play Play:self.recorder.getBytes Length:9999999];
}

- (IBAction)startServer:(UIButton *)sender {
    [self.myServer startListenAndNewThread];
}

- (IBAction)stopServer:(UIButton *)sender {
    [self.myServer closeServer];
}
- (IBAction)sendMsg:(UIButton *)sender {
//    [self.myServer sendData:[self.textView.text UTF8String]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
