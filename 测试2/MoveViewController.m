//
//  MoveViewController.m
//  测试2
//
//  Created by linxun on 15/12/26.
//  Copyright © 2015年 linxun. All rights reserved.
//

#import "MoveViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface MoveViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>
{
    AVCaptureSession *session;
    AVCaptureVideoDataOutput *videoOutput;
    AVCaptureAudioDataOutput *audioOutput;
    AVAssetWriter *videoWriter;
    AVAssetWriterInput *videoWriterInput;
    AVAssetWriterInput *audioWriterInput;
    AVAssetWriterInputPixelBufferAdaptor *adaptor;
}


@end

@implementation MoveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 录制视频
    [self move];
}

// 录制视频
- (void)move
{
    NSError * error;
    
    session = [[AVCaptureSession alloc] init];
    
    [session beginConfiguration];
    
    [session setSessionPreset:AVCaptureSessionPreset640x480];
    
    [self initVideoAudioWriter];
    
    AVCaptureDevice * videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    
    
    
    AVCaptureDevice * audioDevice1 = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    
    AVCaptureDeviceInput *audioInput1 = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice1 error:&error];
    
    videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    [videoOutput setAlwaysDiscardsLateVideoFrames:YES];
    
    [videoOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    
    [videoOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    
    
    audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    
//numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
//    audioOutput.audioSettings =
//    
//    [NSDictionary dictionaryWithObject:
//
//     [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
//     
//                                forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    [audioOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    [session addInput:videoInput];
    
    [session addInput:audioInput1];
    
    [session addOutput:videoOutput];
    
    [session addOutput:audioOutput];
    
    
    
    [session commitConfiguration];
    
    [session startRunning];
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    
    
    //CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    
    
    
//    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    
    
    static int frame = 0;
    
    CMTime lastSampleTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    
    if( frame == 0 && videoWriter.status != AVAssetWriterStatusWriting  )
        
    {
        
        [videoWriter startWriting];
        
        [videoWriter startSessionAtSourceTime:lastSampleTime];
        
    }
    
    if (captureOutput == videoOutput)
        
    {
        
        
        
    if( videoWriter.status > AVAssetWriterStatusWriting )
            
        {
            
            NSLog(@"Warning: writer status is %d", videoWriter.status);
            
            if( videoWriter.status == AVAssetWriterStatusFailed )
                
                NSLog(@"Error: %@", videoWriter.error);
            
            return;
            
        }
        
        if ([videoWriterInput isReadyForMoreMediaData])
            
            if( ![videoWriterInput appendSampleBuffer:sampleBuffer] )
                
                NSLog(@"Unable to write to video input");
        
            else
                
                NSLog(@"already write vidio");
        
    }else if (captureOutput == audioOutput)

        {
            
            if( videoWriter.status > AVAssetWriterStatusWriting )
                
            {
                
                NSLog(@"Warning: writer status is %d", videoWriter.status);
                
                if( videoWriter.status == AVAssetWriterStatusFailed )
                    
                    NSLog(@"Error: %@", videoWriter.error);
                
                return;
                
            }
            
            if ([audioWriterInput isReadyForMoreMediaData])
                
                if( ![audioWriterInput appendSampleBuffer:sampleBuffer] )
                    
                    NSLog(@"Unable to write to audio input");
            
                else
                    
                    NSLog(@"already write audio");
            
        }
    


if (frame == 150)

{
    
    [self closeVideoWriter];
    
}
//
frame++;

//[pool drain]; 

}

- (void)closeVideoWriter
{
    [session stopRunning];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [[AVAudioSession sharedInstance] setDelegate:nil];
    [[AVAudioSession sharedInstance] setActive:NO error: nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) initVideoAudioWriter

{
    
    CGSize size = CGSizeMake(480, 320);
    
    
    
    
    
    NSString *betaCompressionDirectory = [NSHomeDirectory()stringByAppendingPathComponent:@"Documents/Movie.mp4"];
    
    
    
    NSError *error = nil;
    
    
    
    unlink([betaCompressionDirectory UTF8String]);
    
    
    
    //----initialize compression engine
    
    videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:betaCompressionDirectory]
                        
                                                 fileType:AVFileTypeQuickTimeMovie
                        
                                                    error:&error];
    
    NSParameterAssert(videoWriter);
    
    if(error)
        
        NSLog(@"error = %@", [error localizedDescription]);
    
    NSDictionary *videoCompressionProps = [NSDictionary dictionaryWithObjectsAndKeys:
                                           
                                           [NSNumber numberWithDouble:128.0*1024.0],AVVideoAverageBitRateKey,
                                           
                                           nil ];
    
    
    
//    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey,
//                                   
//                                   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
//                                   
//                                   [NSNumber numberWithInt:size.height],AVVideoHeightKey,videoCompressionProps, AVVideoCompressionPropertiesKey, nil];
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey,
                                   
                                   [NSNumber numberWithInt:320], AVVideoWidthKey,
                                   
                                   [NSNumber numberWithInt:240],AVVideoHeightKey,videoCompressionProps, AVVideoCompressionPropertiesKey, nil];
    videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    
    
    
    NSParameterAssert(videoWriterInput);
    
    
    
    videoWriterInput.expectsMediaDataInRealTime = YES;
    
    
    
    NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                           
                                                           [NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil];
    
    
    
    adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput
                    
                                                                                   sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    
    NSParameterAssert(videoWriterInput);
    
    NSParameterAssert([videoWriter canAddInput:videoWriterInput]);
    
    
    
    if ([videoWriter canAddInput:videoWriterInput])
        
        NSLog(@"I can add this input");
    
    else
        
        NSLog(@"i can't add this input");
    
    
    
    // Add the audio input
    
    AudioChannelLayout acl;
    
    bzero( &acl, sizeof(acl));
    
    acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
    
    
    
    NSDictionary* audioOutputSettings = nil;
    
    //    audioOutputSettings = [ NSDictionary dictionaryWithObjectsAndKeys:
    
    //                           [ NSNumber numberWithInt: kAudioFormatAppleLossless ], AVFormatIDKey,
    
    //                           [ NSNumber numberWithInt: 16 ], AVEncoderBitDepthHintKey,
    
    //                           [ NSNumber numberWithFloat: 44100.0 ], AVSampleRateKey,
    
    //                           [ NSNumber numberWithInt: 1 ], AVNumberOfChannelsKey,
    
    //                           [ NSData dataWithBytes: &acl length: sizeof( acl ) ], AVChannelLayoutKey,
    
    //                           nil ];
    
    audioOutputSettings = [ NSDictionary dictionaryWithObjectsAndKeys:
                           
                           [ NSNumber numberWithInt: kAudioFormatMPEG4AAC ], AVFormatIDKey,
                           
                           [ NSNumber numberWithInt:64000], AVEncoderBitRateKey,
                           
                           [ NSNumber numberWithFloat: 44100.0 ], AVSampleRateKey,
                           
                           [ NSNumber numberWithInt: 1 ], AVNumberOfChannelsKey,                                      
                           
                           [ NSData dataWithBytes: &acl length: sizeof( acl ) ], AVChannelLayoutKey,
                           
                           nil ];
    
    
    
    audioWriterInput = [AVAssetWriterInput
                         
                         assetWriterInputWithMediaType: AVMediaTypeAudio 
                         
                         outputSettings: audioOutputSettings ];
    
    
    
    audioWriterInput.expectsMediaDataInRealTime = YES;
    
    // add input
    
    [videoWriter addInput:audioWriterInput];
    
    [videoWriter addInput:videoWriterInput];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
