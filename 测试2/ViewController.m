//
//  ViewController.m
//  测试2
//
//  Created by linxun on 15/12/11.
//  Copyright © 2015年 linxun. All rights reserved.
//

// http://codego.net/381654/
#import "ViewController.h"
#import "MoveTableViewController.h"
#import "MoveViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

#import <MediaPlayer/MediaPlayer.h>

@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
   
}
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
// 包含ALAsset的数组
@property (nonatomic, strong) NSMutableArray *libraryPhotos;
@property (nonatomic, strong) NSMutableArray *images; // 存放图片的数组

// 拍照相关
@property (assign,nonatomic) int isVideo;//是否录制视频，如果为1表示录制视频，0代表拍照
@property (strong,nonatomic) UIImagePickerController *imagePicker;
@property (weak, nonatomic) UIImageView *photo;//照片展示视图
@property (strong ,nonatomic) AVPlayer *player;//播放器，用于录制完视频后播放视频

// 视频录制路径
@property (nonatomic, copy) NSString *urlString;

@property (nonatomic,strong) MPMoviePlayerController *moviePlayer;//视频播放控制器


// 小视频
@property (nonatomic, strong) AVCaptureSession *captureSession; //设置拍摄分辨率
//@property (nonatomic, strong) AVCaptureMovieFileOutput *captureMovieFileOutput;
@property (nonatomic, strong) AVCaptureMovieFileOutput *captureMovieFileOutput;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput; // 如摄像头和麦克风

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 获取相册中的所有的照片
//    [self getAllPhotos];
    
    // 播放小视频
//    [self playMove];
    
    // 录制小视频
//    [self move];
    
    // 播放原始视频
//    [self playOriginMove];
    
    // 录制视频
//    [self moveLittle];
    
    
    
    
}

-(void)dealloc{
    //移除所有通知监控
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(MPMoviePlayerController *)moviePlayer{
    if (!_moviePlayer) {
        NSURL *url=[NSURL fileURLWithPath:self.urlString];
        _moviePlayer=[[MPMoviePlayerController alloc]initWithContentURL:url];
        _moviePlayer.view.frame=self.view.bounds;
        _moviePlayer.view.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:_moviePlayer.view];
    }
    return _moviePlayer;
}
/**
 *  添加通知监控媒体播放控制器状态
 */
-(void)addNotification{
    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(mediaPlayerPlaybackStateChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.moviePlayer];
    [notificationCenter addObserver:self selector:@selector(mediaPlayerPlaybackFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
    
}

/**
 *  播放状态改变，注意播放完成时的状态是暂停
 *
 *  @param notification 通知对象
 */
-(void)mediaPlayerPlaybackStateChange:(NSNotification *)notification{
    switch (self.moviePlayer.playbackState) {
        case MPMoviePlaybackStatePlaying:
            NSLog(@"正在播放...");
            break;
        case MPMoviePlaybackStatePaused:
            NSLog(@"暂停播放.");
            break;
        case MPMoviePlaybackStateStopped:
            NSLog(@"停止播放.");
            break;
        default:
            NSLog(@"播放状态:%li",self.moviePlayer.playbackState);
            break;
    }
}

/**
 *  播放完成
 *
 *  @param notification 通知对象
 */
-(void)mediaPlayerPlaybackFinished:(NSNotification *)notification{
    [self.moviePlayer.view removeFromSuperview];
    self.moviePlayer = nil;
//    NSLog(@"播放完成.%li",self.moviePlayer.playbackState);
}


#pragma mark 播放原始视频
- (void)playOriginMove
{
    [self.moviePlayer play];
    
    //添加通知
    [self addNotification];
}

#pragma mark 录制小视频
- (void)move
{
    // 通过这里设置当前程序是拍摄
    _isVideo = YES;
    //
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerController代理方法
//完成以后走的代理方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {//如果是拍照
        UIImage *image;
        //如果允许编辑则获得编辑后的照片，否则获取原始照片
        if (self.imagePicker.allowsEditing) {
            image=[info objectForKey:UIImagePickerControllerEditedImage];//获取编辑后的照片
        }else{
            image=[info objectForKey:UIImagePickerControllerOriginalImage];//获取原始照片
        }
        [self.photo setImage:image];//显示照片
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);//保存到相簿
    }else if([mediaType isEqualToString:(NSString *)kUTTypeMovie]){//如果是录制视频
        NSLog(@"video...");
        NSURL *url=[info objectForKey:UIImagePickerControllerMediaURL];//视频路径
        NSString *urlStr=[url path];
        self.urlString = [NSString stringWithString:urlStr];
//        [self convertVideoToLowQuailtyAndFixRotationWithInputURL:[NSURL fileURLWithPath:urlStr] handler:^(NSURL *outURL) {
//            self.urlString = [NSString string];
//        }];
        
        
//        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlStr)) {
//            //保存视频到相簿，注意也可以使用ALAssetsLibrary来保存
//            UISaveVideoAtPathToSavedPhotosAlbum(urlStr, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);//保存视频到相簿
//        }
        
    }
    [self performSelector:@selector(playMove) withObject:nil afterDelay:2.0];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSLog(@"取消");
    [_imagePicker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 私有方法  录视频
-(UIImagePickerController *)imagePicker{
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc]init];
        _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;//设置image picker的来源，这里设置为摄像头
        _imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;//设置使用哪个摄像头，这里设置为后置摄像头
        if (self.isVideo) {
            _imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
//            _imagePicker.videoQuality=UIImagePickerControllerQualityTypeIFrame1280x720;
            // UIImagePickerControllerQualityTypeMedium 360 * 480
            _imagePicker.videoQuality = UIImagePickerControllerQualityType640x480; // 480 * 640
            _imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;//设置摄像头模式（拍照，录制视频）
        }else{
            _imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        }
        _imagePicker.allowsEditing = YES;//允许编辑
        _imagePicker.delegate = self;//设置代理，检测操作
    }
    return _imagePicker;
}

//视频保存后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        NSLog(@"保存视频过程中发生错误，错误信息:%@",error.localizedDescription);
    }else{
        NSLog(@"视频保存成功.");
        //录制完之后自动播放
        NSURL *url = [NSURL fileURLWithPath:videoPath];
        _player=[AVPlayer playerWithURL:url];
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        playerLayer.frame = self.photo.frame;
        [self.photo.layer addSublayer:playerLayer];
        [_player play];
        
    }
}

#pragma mark 获取所有的图片
- (void)getAllPhotos
{
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group == nil) {
            return ;
        }
        self.libraryPhotos = [NSMutableArray array];
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result == nil) {
                return ;
            }
            //
            NSString *type = [result valueForProperty:ALAssetPropertyType];
            if (![type isEqualToString:ALAssetTypePhoto]) {
                return;
            }
            // 保存照片
//            [[result defaultRepresentation] fullScreenImage]; // 大图
//            [result thumbnail]; // 小图
            [self.libraryPhotos addObject:result];
        }];
        NSLog(@"+++++图片的张数%lu", (unsigned long)self.libraryPhotos.count);
    } failureBlock:^(NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 开始按钮点击事件
- (IBAction)startBUttonClick:(id)sender {
    // 录制视频
    [self move];
    // 添加alert
//    [self addAlertView];
    // 添加actionsheet
//    [self addActionSheet];
//
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"test.txt" ofType:nil];
////    NSData *data = [NSData dataWithContentsOfFile:path];
////    NSString *testString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//
////    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithContentsOfFile:path];
//    NSError *err;
//     NSString *testString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
//    NSString *string = [self JSHash:testString];
//    NSLog(@"++++%@", testString);
}

#pragma mark 开始播放
- (IBAction)startToPaly:(id)sender {
    [self playOriginMove];
//    MoveTableViewController *controler = [[MoveTableViewController alloc] init];
//    [self.navigationController pushViewController:controler animated:YES];
//    [self presentViewController:[[MoveViewController alloc] init] animated:YES completion:nil];
}

#pragma mark 添加alert // 取消永远在左边
- (void)addAlertView{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"这个是alertView" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@" 取消按钮点击事件 ");
    }];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@" 确定按钮点击事件 ");
    }];
    
    
    [alert addAction:cancle];
    [alert addAction:sure];
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark 添加actionSheet  顺序  取消永远在最底下  其他的按照从上往下排列
- (void)addActionSheet
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"这个是actionSheet" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@" 取消按钮点击事件 ");
    }];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@" 确定按钮点击事件 ");
    }];
    UIAlertAction *delete = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@" 删除按钮点击事件 ");
    }];
    [alert addAction:cancle];
    [alert addAction:delete];
    [alert addAction:sure];
    
    [self presentViewController:alert animated:YES completion:nil];
}

//hash算法
- (NSString *) JSHash:(NSString *)str{
    int hash = 20150615;
    NSTimeInterval time1 = [[NSDate date] timeIntervalSince1970];
    for(int i = 0; i < str.length; i++){
        hash ^= ((hash << 5) + [str characterAtIndex:i] + (hash >> 2));
    }
    int a=hash & 0x7FFFFFFF;
    NSTimeInterval time2 = [[NSDate date] timeIntervalSince1970];
    NSString *title = [NSString stringWithFormat:@"长度--%lu 耗时---%f", str.length, time2 - time1];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
    return [NSString stringWithFormat:@"%i",a];
}

#pragma mark 播放小视频
- (void)playMove
{
    self.images = [NSMutableArray array];
    // 获取媒体文件路径的 URL，必须用 fileURLWithPath: 来获取文件 URL
    NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"IMG_3628" ofType:@"m4v"];
    NSURL *fileUrl = [NSURL fileURLWithPath:self.urlString];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:fileUrl options:nil];
    NSError *error = nil;
    // 创建一个读取媒体数据的阅读器AVAssetReader
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    // 获取视频的轨迹AVAssetTrack其实就是我们的视频来源
    NSArray *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *videoTrack =[videoTracks objectAtIndex:0];
    //
    int m_pixelFormatType;
    //     视频播放时，
    m_pixelFormatType = kCVPixelFormatType_32BGRA;
    // 其他用途，如视频压缩
//        m_pixelFormatType = kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange;
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    [options setObject:@(m_pixelFormatType) forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    AVAssetReaderTrackOutput *videoReaderOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack outputSettings:options];
    
    [reader addOutput:videoReaderOutput];
    [reader startReading];
    
    // 要确保nominalFrameRate>0，之前出现过android拍的0帧视频
    while ([reader status] == AVAssetReaderStatusReading && videoTrack.nominalFrameRate > 0) {
        // 读取 video sample
        CMSampleBufferRef videoBuffer = [videoReaderOutput copyNextSampleBuffer];
//        [self.delegate mMoveDecoder:self onNewVideoFrameReady:videoBuffer];
        // 处理获取到的轨迹
        [self mMoveDecoderOnNewVideoFrameReady:videoBuffer];
        CGFloat sampleInternal = 0.001;
        // 根据需要休眠一段时间；比如上层播放视频时每帧之间是有间隔的,这里的 sampleInternal 我设置为0.001秒
        [NSThread sleepForTimeInterval:sampleInternal];
    }
    
    // 视频解码结束
//    [self.delegate mMoveDecoderOnDecoderFinished:self];
    // 播放
    [self playWithoutSound];
}

#pragma mark 播放
- (void)playWithoutSound
{
    NSLog(@"图片一共有的张数%lu", (unsigned long)self.images.count);
    NSLog(@"已经完成");
    // 得到媒体的资源
    NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"IMG_3628.m4v" ofType:@""];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:self.urlString] options:nil];
    // 通过动画来播放我们的图片
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    // asset.duration.value/asset.duration.timescale 得到视频的真实时间
    animation.duration = asset.duration.value/asset.duration.timescale;
    animation.values = self.images;
    animation.repeatCount = MAXFLOAT;
//    animation.repeatCount = 1;
    [self.preview.layer addAnimation:animation forKey:nil];
    // 确保内存能及时释放掉
    [self.images enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj) {
            obj = nil;
        }
    }];
    
}

#pragma mark 处理获取到的轨迹
- (void)mMoveDecoderOnNewVideoFrameReady:(CMSampleBufferRef)videoBuffer
{
    CGImageRef cgimage = [self imageFromSampleBufferRef:videoBuffer];
    if (!(__bridge id)(cgimage)) { return; }
    [self.images addObject:((__bridge id)(cgimage))];
    CGImageRelease(cgimage);
}

// 得到轨迹的图片
// AVFoundation 捕捉视频帧，很多时候都需要把某一帧转换成 image
- (CGImageRef)imageFromSampleBufferRef:(CMSampleBufferRef)sampleBufferRef
{
    // 为媒体数据设置一个CMSampleBufferRef
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBufferRef);
    // 锁定 pixel buffer 的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    // 得到 pixel buffer 的基地址
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // 得到 pixel buffer 的行字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // 得到 pixel buffer 的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // 创建一个依赖于设备的 RGB 颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphic context）对象
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    //根据这个位图 context 中的像素创建一个 Quartz image 对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // 解锁 pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    // 释放 context 和颜色空间
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    // 用 Quzetz image 创建一个 UIImage 对象
    // UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // 释放 Quartz image 对象
    //    CGImageRelease(quartzImage);
    
    return quartzImage;
    
}


#pragma mark 转化视频
- (void)convertVideoToLowQuailtyAndFixRotationWithInputURL:(NSURL*)inputURL handler:(void (^)(NSURL *outURL))handler
{
    if ([[inputURL pathExtension] isEqualToString:@"MOV"])
    {
        NSURL *outputURL = [inputURL URLByDeletingPathExtension];
        outputURL = [outputURL URLByAppendingPathExtension:@"mp4"];
        
        AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
        
        AVAssetTrack *sourceVideoTrack = [[avAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        AVAssetTrack *sourceAudioTrack = [[avAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        
        AVMutableComposition* composition = [AVMutableComposition composition];
        
        AVMutableCompositionTrack *compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                    preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, avAsset.duration)
                                       ofTrack:sourceVideoTrack
                                        atTime:kCMTimeZero error:nil];
        [compositionVideoTrack setPreferredTransform:sourceVideoTrack.preferredTransform];
        
        AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                    preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, avAsset.duration)
                                       ofTrack:sourceAudioTrack
                                        atTime:kCMTimeZero error:nil];
        
        AVMutableVideoComposition *videoComposition = [self getVideoComposition:avAsset];
        
        NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
        if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality])
        {
            AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:composition presetName:AVAssetExportPresetMediumQuality];
            exportSession.outputURL = outputURL;
            exportSession.outputFileType = AVFileTypeMPEG4;
            exportSession.shouldOptimizeForNetworkUse = YES;
            exportSession.videoComposition = videoComposition;
            [exportSession exportAsynchronouslyWithCompletionHandler:^{
                
                switch ([exportSession status])
                {
                    case AVAssetExportSessionStatusFailed:
                        NSLog(@"Export failed: %@ : %@", [[exportSession error] localizedDescription], [exportSession error]);
                        handler(nil);
                        
                        break;
                    case AVAssetExportSessionStatusCancelled:
                        
                        NSLog(@"Export canceled");
                        handler(nil);
                        
                        break;
                    default:
                        
                        handler(outputURL);
                        
                        break;
                        
                }
            }];
        }
        
    } else {
        handler(inputURL);
    }
}

- (AVMutableVideoComposition *)getVideoComposition:(AVAsset *)asset
{
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    CGSize videoSize = videoTrack.naturalSize;
//    BOOL isPortrait_ = [self isVideoPortrait:asset];
    BOOL isPortrait_ = YES;
    if(isPortrait_) {
        //        NSLog(@"video is portrait ");
        videoSize = CGSizeMake(videoSize.height, videoSize.width);
    }
    composition.naturalSize     = videoSize;
    videoComposition.renderSize = videoSize;
    videoComposition.frameDuration = CMTimeMakeWithSeconds( 1 / videoTrack.nominalFrameRate, 600);
    
    AVMutableCompositionTrack *compositionVideoTrack;
    compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    AVMutableVideoCompositionLayerInstruction *layerInst;
    layerInst = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    [layerInst setTransform:videoTrack.preferredTransform atTime:kCMTimeZero];
    AVMutableVideoCompositionInstruction *inst = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    inst.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
    inst.layerInstructions = [NSArray arrayWithObject:layerInst];
    videoComposition.instructions = [NSArray arrayWithObject:inst];
    return videoComposition;
}

#pragma mark 录制小视频
- (void)moveLittle
{
    self.captureSession = [[AVCaptureSession alloc] init];
     self.captureSession.sessionPreset = AVCaptureSessionPreset640x480;
    //CONFIGURE VIDEO RECORING
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if(self.videoInput){
        [self.captureSession addInput:self.videoInput];
    }
    else{
        NSLog(@"Input Error:%@", error);
    }
    
    //CONFIGURE AUDIO RECORDING
//    kCVPixelFormatType_32BGRA
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
    if(captureDeviceInput){
        [self.captureSession addInput:captureDeviceInput];
    }
    
    //CONFIGURE DISPLAY OUTPUT 为用户提供拍摄预览界面
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    previewLayer.frame = self.view.frame;
    [self.view.layer addSublayer:previewLayer];
    
    //CONFIGURE FILE OUTPUT
    //HANDLE EVENT IN RECORD START/STOP ACTION AND ALSO IN AVCaptureMovieFileOutput DELEGATE
    self.captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    
//    AVCaptureConnection *connection = [self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
//    [connection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
    
//    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecH264,AVVideoCodecKey, @(320), AVVideoWidthKey, @(240), AVVideoHeightKey, AVVideoProfileLevelH264Main30, AVVideoAllowFrameReorderingKey, nil];
//////// AVCaptureVideoDataOutput相关
//    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
//    [output setVideoSettings:outputSettings];
//    output.sampleBufferDelegate = self;
//    if ([self.captureSession canAddOutput:output]) {
//        [self.captureSession addOutput:output];
//    }
////////
    
//    Float64 TotalSeconds = 60;            //Total seconds
//    int32_t preferredTimeScale = 30;    //Frames per second
//    CMTime maxDuration = CMTimeMakeWithSeconds(TotalSeconds, preferredTimeScale);    //<<SET MAX DURATION
//    movieOutput.maxRecordedDuration = maxDuration;
//    
//    movieOutput.minFreeDiskSpaceLimit = 1024 * 1024;
    if([self.captureSession canAddOutput:self.captureMovieFileOutput]){
        [self.captureSession addOutput:self.captureMovieFileOutput];
    }
}

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    BOOL isSuccess = YES;
    NSLog(@"error:%@", error);
    if(error.code != noErr)
    {
        id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
        if(value)
        {
            isSuccess = [value boolValue];
        }
    }
    
    if(isSuccess)
    {
        NSData *data = [NSData dataWithContentsOfURL:outputFileURL];
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *docDir = [paths objectAtIndex:0];
//        [data writeToFile:[docDir stringByAppendingPathComponent:@"123.mp4"] atomically:YES];
        NSString *urlString = [outputFileURL path];
        self.urlString = urlString;
        
        for (CALayer *layer in [self.view.layer sublayers]) {
            if ([layer isKindOfClass:[AVCaptureVideoPreviewLayer class]]) {
                [layer removeFromSuperlayer];
            }
        }
        [self resizeVideo];
//        [self resizeVideo:urlString];
//        [self playMove];
//        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
//        if([assetsLibrary videoAtPathIsCompatibleWithSavedPhotosAlbum:outputFileURL])
//        {
//            [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
//                if(error){
//                    NSLog(@"Error:%@", error);
//                }
//                
//                //delete temporary file
//                NSError *aError = nil;
//                [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:&aError];
//            }];
//            
//        }
//        else{
//            NSLog(@"could not saved to photos album.");
//        }
    }
    
}

#pragma mark - 左上角record 按钮
- (IBAction)d:(UIButton *)sender {
    NSString *title = [sender titleForState:UIControlStateNormal];
    if([title isEqualToString:@"Record"]){
        [self.preview.layer removeAllAnimations];
        //
        [self moveLittle];
        
        NSError *error = nil;
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        [[AVAudioSession sharedInstance] setDelegate:self];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:&error];
        NSLog(@"audioSessionError:%@", error);
        [[AVAudioSession sharedInstance] setActive:YES error: nil];
        self.captureSession.usesApplicationAudioSession = YES;
        self.captureSession.automaticallyConfiguresApplicationAudioSession = YES;
        [sender setTitle:@"Stop" forState:UIControlStateNormal];
        [self.captureSession startRunning];
        
        //CREATE FILE
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
        
        // 获取路径docu
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [paths objectAtIndex:0];
        
        NSLog(@"+++++++%@", docDir);
        //        NSString *outputFileName = [[kAppDocDirPath stringByAppendingPathComponent:[dateFormatter stringFromDate:[NSDate date]]] stringByAppendingPathExtension:@"mp4"];
        NSString *outputFileName = [[docDir stringByAppendingPathComponent:[dateFormatter stringFromDate:[NSDate date]]] stringByAppendingPathExtension:@"m4v"];
        NSURL *outputFileURL = [[NSURL alloc] initFileURLWithPath:outputFileName];
        
        [self.captureMovieFileOutput startRecordingToOutputFileURL:outputFileURL recordingDelegate:self];
    }
    else{ // 停止 录制
        [self.captureSession stopRunning];
        [self.captureMovieFileOutput stopRecording];
        [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
        [[AVAudioSession sharedInstance] setDelegate:nil];
        [[AVAudioSession sharedInstance] setActive:NO error: nil];
        [sender setTitle:@"Record" forState:UIControlStateNormal];
    }
}

#pragma mark 压缩视频
-(void)resizeVideo:(NSString*)pathy{
//    NSString *newName = [pathy stringByAppendingString:@".down.mov"];
    NSString *newName = [NSString stringWithString:pathy];
    NSURL *fullPath = [NSURL fileURLWithPath:newName];
    NSURL *path = [NSURL fileURLWithPath:pathy];
    
    NSLog(@"Write Started");
    NSError *error = nil;
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:fullPath fileType:AVFileTypeQuickTimeMovie error:&error];
    NSParameterAssert(videoWriter);
    AVAsset *avAsset = [[AVURLAsset alloc] initWithURL:path options:nil];
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:320], AVVideoWidthKey,
                                   [NSNumber numberWithInt:240], AVVideoHeightKey,
                                   nil];
    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput
                                             assetWriterInputWithMediaType:AVMediaTypeVideo
                                             outputSettings:videoSettings];
    NSParameterAssert(videoWriterInput);
    NSParameterAssert([videoWriter canAddInput:videoWriterInput]);
    videoWriterInput.expectsMediaDataInRealTime = YES;
    [videoWriter addInput:videoWriterInput];
    NSError *aerror = nil;
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:avAsset error:&aerror];
    AVAssetTrack *videoTrack = [[avAsset tracksWithMediaType:AVMediaTypeVideo]objectAtIndex:0];
    videoWriterInput.transform = videoTrack.preferredTransform;
    NSDictionary *videoOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    AVAssetReaderTrackOutput *asset_reader_output = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack outputSettings:videoOptions];
    [reader addOutput:asset_reader_output];
    //audio setup
    AVAssetWriterInput* audioWriterInput = [AVAssetWriterInput
                                             assetWriterInputWithMediaType:AVMediaTypeAudio
                                             outputSettings:nil];
    AVAssetReader *audioReader = [AVAssetReader assetReaderWithAsset:avAsset error:&error];
    AVAssetTrack* audioTrack = [[avAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    AVAssetReaderOutput *readerOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:nil];
    [audioReader addOutput:readerOutput];
    NSParameterAssert(audioWriterInput);
    NSParameterAssert([videoWriter canAddInput:audioWriterInput]);
    audioWriterInput.expectsMediaDataInRealTime = NO;
    [videoWriter addInput:audioWriterInput];
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    [reader startReading];
    dispatch_queue_t _processingQueue = dispatch_queue_create("assetAudioWriterQueue", NULL);
    [videoWriterInput requestMediaDataWhenReadyOnQueue:_processingQueue usingBlock:
     ^{
//         [self retain];
         while ([videoWriterInput isReadyForMoreMediaData]) {
             CMSampleBufferRef sampleBuffer;
             if ([reader status] == AVAssetReaderStatusReading &&
                 (sampleBuffer = [asset_reader_output copyNextSampleBuffer])) {
                 BOOL result = [videoWriterInput appendSampleBuffer:sampleBuffer];
                 CFRelease(sampleBuffer);
                 if (!result) {
                     [reader cancelReading];
                     break;
                 }
             } else {
                 [videoWriterInput markAsFinished];
                 switch ([reader status]) {
                     case AVAssetReaderStatusReading:
                         // the reader has more for other tracks, even if this one is done
                         break;
                     case AVAssetReaderStatusCompleted:
                     {
                         // your method for when the conversion is done
                         // should call finishWriting on the writer
                         //hook up audio track
                         [audioReader startReading];
                         [videoWriter startSessionAtSourceTime:kCMTimeZero];
                         dispatch_queue_t mediaInputQueue = dispatch_queue_create("mediaInputQueue", NULL);
                         [audioWriterInput requestMediaDataWhenReadyOnQueue:mediaInputQueue usingBlock:^
                          {
                              NSLog(@"Request");
                              NSLog(@"Asset Writer ready :%d",audioWriterInput.readyForMoreMediaData);
                              while (audioWriterInput.readyForMoreMediaData) {
                                  CMSampleBufferRef nextBuffer;
                                  if ([audioReader status] == AVAssetReaderStatusReading &&
                                      (nextBuffer = [readerOutput copyNextSampleBuffer])) {
                                      NSLog(@"Ready");
                                      if (nextBuffer) {
                                          NSLog(@"NextBuffer");
                                          [audioWriterInput appendSampleBuffer:nextBuffer];
                                      }
                                  }else{
                                      [audioWriterInput markAsFinished];
                                      switch ([audioReader status]) {
                                          case AVAssetReaderStatusCompleted:
                                              [videoWriter finishWriting];
                                              [self hookUpVideo:newName];
                                              break;
                                      }
                                  }
                              }
                          }
                          ];
                 }
                         break;
                     case AVAssetReaderStatusFailed:
                         [videoWriter cancelWriting];
                         break;
                 }
                 break;
             }
         }
     }
     ];
    NSLog(@"Write Ended");
}

#pragma mark 文件压缩2 好像好
- (void)resizeVideo
{
    NSURL *sourceURL = [NSURL fileURLWithPath:self.urlString];
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:sourceURL options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];//用时间给文件全名，以免重复，在测试的时候其实可以判断文件是否存在若存在，则删除，重新生成文件即可
        [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
        NSString * resultPath = [NSString string];
        resultPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/output-%@.mp4", [formater stringFromDate:[NSDate date]]];
        exportSession.outputURL = [NSURL fileURLWithPath:resultPath];
        exportSession.outputFileType = AVFileTypeMPEG4;
        [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
         {
             switch (exportSession.status) {
                 case AVAssetExportSessionStatusUnknown:
                     NSLog(@"AVAssetExportSessionStatusUnknown");
                     break;
                 case AVAssetExportSessionStatusWaiting:
                     NSLog(@"AVAssetExportSessionStatusWaiting");
                     break;
                 case AVAssetExportSessionStatusExporting:
                     NSLog(@"AVAssetExportSessionStatusExporting");
                     break;
                 case AVAssetExportSessionStatusCompleted:
                     NSLog(@"AVAssetExportSessionStatusCompleted");
                     break;
                 case AVAssetExportSessionStatusFailed:
                     NSLog(@"AVAssetExportSessionStatusFailed");
                     break;
             }
         }];
    }
}


#pragma mark 保存视频
- (void)hookUpVideo:(NSString *)path
{
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSLog(@"++++++++++++++%lu", (unsigned long)[data length]);
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *docDir = [paths objectAtIndex:0];
//    
//        [data writeToFile:[docDir stringByAppendingPathComponent:@"123.mp4"] atomically:YES];
}
@end
