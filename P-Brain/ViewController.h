//
//  ViewController.h
//  P-Brain
//
//  Created by Patrick Quinn on 01/02/2017.
//  Copyright © 2017 GRAMMA Music. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YouTableViewCell.h"
#import "MeTableViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Speech/Speech.h>
#import <XCDYouTubeKit/XCDYouTubeKit.h>
#include <EZAudio/EZAudio.h>
#import "ExampleCollectionViewCell.h"
#import "PComms.h"
#import "snowboy-detect.h"






@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate,AVSpeechSynthesizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource,EZMicrophoneDelegate> {
        snowboy::SnowboyDetect* _snowboyDetect;
}

@property (strong, nonatomic) IBOutlet UITableView *chatView;
@property (strong, nonatomic) IBOutlet UIButton *speech;
@property (strong, nonatomic) IBOutlet UITextField *input;
@property (strong, nonatomic) IBOutlet UICollectionView *exampleCollection;


@property (strong, nonatomic) NSMutableArray *tableData;
@property (strong, nonatomic) NSArray *flippedTableData;
@property (strong, nonatomic) NSArray *exampleData;

@property (strong, nonatomic) AVSpeechSynthesizer *synthesizer;
    
@property (strong, nonatomic) SFSpeechRecognizer *speechRecognizer;
@property (strong, nonatomic) AVAudioEngine *audioEngine;
@property (strong, nonatomic) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
@property (strong, nonatomic) SFSpeechRecognitionTask *recognitionTask;
@property (strong, nonatomic) NSString *pburl;
@property (strong, nonatomic) XCDYouTubeVideoPlayerViewController *videoPlayerViewController;
@property (nonatomic, strong) EZMicrophone *microphone;


    



    

- (IBAction) start_rec:(UIButton *)sender;
    






@end

