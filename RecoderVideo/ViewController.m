//
//  ViewController.m
//  RecoderVideo
//
//  Created by Bruce on 16/3/17.
//  Copyright © 2016年 Bruce. All rights reserved.
//
/*
 AVPlayer:视频播放器 -> AVFoundation
 AVPlayerItem:视频元素
 AVPlayerLayer:显示视频内容的图层
 AVPlayerViewController:->AVKit 不需要界面
 
 
 UIKit->UIImagePickerController
 
 区分 选择摄像头 相册sourceType
 摄像头:UIImagePickerControllerSourceTypeCamera
 相册:UIImagePickerControllerSourceTypePhotoLibrary
 相册:UIImagePickerControllerSourceTypeSavedPhotosAlbum
 
 区分 拍照 录像 cameraCaptureMode:
 录像:UIImagePickerControllerCameraCaptureModeVideo
 拍照:UIImagePickerControllerCameraCaptureModePhoto
 
 区分 前后摄像头 cameraDevice
 前摄像头:UIImagePickerControllerCameraDeviceFront
 后置摄像头:UIImagePickerControllerCameraDeviceRear
 
 设置 是否显示 控制控件
 showsCameraControls 默认显示控制控件
 
 设置拍照
 takePicture
 
 录像
 startVideoCapture
 stopVideoCapture
 
 设置视频清晰度videoQuality
 UIImagePickerControllerQualityTypeHigh
 UIImagePickerControllerQualityTypeMedium
 UIImagePickerControllerQualityTypeLow
 UIImagePickerControllerQualityType640x480
 UIImagePickerControllerQualityTypeIFrame1280x720
 
 设置视频最大的录像时间videoMaximumDuration
 默认10分钟
 
 
 设置闪光cameraFlashMode
 1、UIImagePickerControllerCameraFlashModeOff 关闭
 2、UIImagePickerControllerCameraFlashModeAuto自动 =0  默认
 3、UIImagePickerControllerCameraFlashModeOn开启
 
 设置调用摄像头视图页面的  覆盖视图 cameraOverlayView
 
 设置拍照页面的形态 cameraViewTransform
 
 代理delegate
 @property(nullable,nonatomic,weak)      id <UINavigationControllerDelegate, UIImagePickerControllerDelegate> delegate;
 ✮✮✮✮✮需要导入两个代理UINavigationControllerDelegate、UIImagePickerControllerDelegate
 
// 采集完成之后调用 不区分 拍照 摄像
 - (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
 
// 采集取消的时候调用
 - (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
 
 
 */

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100, 300, 50, 50);
    [button setTitle:@"TICK" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor brownColor];
    [button addTarget:self action:@selector(doit) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)doit{
    UIImagePickerController *vc = [[UIImagePickerController alloc] init];
    vc.sourceType = UIImagePickerControllerSourceTypeCamera;
    vc.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    vc.mediaTypes = @[(NSString *)kUTTypeMovie];
    
    vc.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
    vc.videoQuality = UIImagePickerControllerQualityTypeHigh;
//    vc.cameraCaptureMode=UIImagePickerControllerCameraCaptureModePhoto;
    vc.showsCameraControls = YES;
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSLog(@"didFinishPickingMediaWithInfo完毕");
    
    NSLog(@"%@",info[UIImagePickerControllerMediaType]);
    NSString *type = info[UIImagePickerControllerMediaType];
    if ([type isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *url=[info objectForKey:UIImagePickerControllerMediaURL];
        NSString *urlStr=[url path];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlStr)) {
            UISaveVideoAtPathToSavedPhotosAlbum(urlStr, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
    }
    if ([type isEqualToString:(NSString *)kUTTypeImage]) {        UIImage *image;

        if (picker.allowsEditing) {
            image=[info objectForKey:UIImagePickerControllerEditedImage];//获取编辑后的照片
        }else{
            image=[info objectForKey:UIImagePickerControllerOriginalImage];//获取原始照片
        }

        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);//保存到相簿
        
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSLog(@"取消");
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSLog(@"%@",videoPath);
    NSURL *url=[NSURL fileURLWithPath:videoPath];
    AVPlayer *player=[AVPlayer playerWithURL:url];
    AVPlayerLayer *playerLayer=[AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame=CGRectMake(0, 0, 150, 200);
    [self.view.layer addSublayer:playerLayer];
    [player play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
