//
//  MergeViewController.m
//  Merge
//
//  Created by 于宙 on 2017/5/6.
//  Copyright © 2017年 devfun. All rights reserved.
//

#import "MergeViewController.h"
@import Photos;
@import MobileCoreServices;

@interface MergeViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    __weak IBOutlet UIImageView *targetImageView;
    __weak IBOutlet UIImageView *originImageView;
    
    NSURL *targetAssetURL;
    NSURL *originAssetURL;
    
    NSUInteger imageViewTag;
}
@end

@implementation MergeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [targetImageView addGestureRecognizer:tap1];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [originImageView addGestureRecognizer:tap2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tap:(UITapGestureRecognizer *)gesture {
    imageViewTag = gesture.view.tag;
    
    UIImagePickerController *pVC = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        pVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        pVC.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
//    pVC.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeLivePhoto];
    
    pVC.delegate = self;
    [self presentViewController:pVC animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSURL *assetURL = info[UIImagePickerControllerReferenceURL];
    
    switch (imageViewTag) {
        case 0:
            targetImageView.image = image;
            targetAssetURL = assetURL;
            break;
        case 1:
            originImageView.image = image;
            originAssetURL = assetURL;
            break;
        default:
            break;
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)mergeButtonAction:(id)sender {
    [self mergeAsset:targetAssetURL toAsset:originAssetURL];
}

- (void)mergeAsset:(NSURL *)assetURL toAsset:(NSURL *)toAssetURL {
    PHAsset *targetAsset = assetURL ? [PHAsset fetchAssetsWithALAssetURLs:@[assetURL] options:nil].firstObject : nil;
    PHAsset *originAsset = toAssetURL ? [PHAsset fetchAssetsWithALAssetURLs:@[toAssetURL] options:nil].firstObject : nil;
    if (!targetAsset || !originAsset) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"图片已不存在" message:@"请重新选择图片" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            targetImageView.image = originImageView.image = [UIImage imageNamed:@"add"];
            targetAssetURL = originAssetURL = nil;
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    [originAsset requestContentEditingInputWithOptions:nil completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
        PHContentEditingOutput *output = [[PHContentEditingOutput alloc] initWithContentEditingInput:contentEditingInput];
        output.adjustmentData = [[PHAdjustmentData alloc] initWithFormatIdentifier:@"com.devfun.Merge" formatVersion:@"1.0" data:[[targetAssetURL absoluteString] dataUsingEncoding:NSUTF8StringEncoding]];
        [[PHImageManager defaultManager] requestImageDataForAsset:targetAsset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            if (imageData) {
                if ([imageData writeToURL:output.renderedContentURL atomically:YES]) {
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        //Edit
                        PHAssetChangeRequest *changeRequest = [PHAssetChangeRequest changeRequestForAsset:originAsset];
                        changeRequest.contentEditingOutput = output;
                        
                        //Delete
                        [PHAssetChangeRequest deleteAssets:@[targetAsset]];
                        
                    } completionHandler:^(BOOL success, NSError * _Nullable error) {
                        if (success) {
                            NSLog(@"Merge Successfully");
                        } else {
                            NSLog(@"Merge Failed! Error:%@", error.localizedDescription);
                        }
                    }];
                } else {
                
                }
                
                
            }
        }];
    }];
}

@end
