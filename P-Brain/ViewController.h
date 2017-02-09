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
#import <Speech/Speech.h>
#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import "ExampleCollectionViewCell.h"
#import "PComms.h"


@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate,AVSpeechSynthesizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *chatView;
@property (weak, nonatomic) IBOutlet UIButton *speech;
@property (weak, nonatomic) IBOutlet UITextField *input;
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

    



    

- (IBAction) start_rec:(UIButton *)sender;
    






@end

