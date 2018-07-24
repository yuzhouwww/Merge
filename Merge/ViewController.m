//
//  ViewController.m
//  Merge
//
//  Created by 于宙 on 2017/5/6.
//  Copyright © 2017年 devfun. All rights reserved.
//

#import "ViewController.h"
@import Photos;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        [self gotoMainInterface];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)authorizeButtonAction:(id)sender {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        switch (status) {
            case PHAuthorizationStatusAuthorized:
                [self gotoMainInterface];
                break;
                
            default:
                NSLog(@"%ld", (long)status);
                break;
        }
    }];
}

- (void)gotoMainInterface {
    [self performSegueWithIdentifier:@"Main" sender:self];
}

@end
