//
//  ViewController.m
//  P-Brain
//
//  Created by Patrick Quinn on 01/02/2017.
//  Copyright © 2017 GRAMMA Music. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    BOOL isKeyboardHidden;
    BOOL isRunning;
    BOOL isProcessing;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initPB];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    [session setMode:AVAudioSessionModeMeasurement error:&error];
    
    UInt32 doChangeDefaultRoute = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
    
    [session setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    if (error) {
        NSLog(@"ERROR%@", error);
        return;
    }

    [self initSnowboy];
    [self initMic];
}

- (void) initMic {
    AudioStreamBasicDescription audioStreamBasicDescription = [EZAudioUtilities monoFloatFormatWithSampleRate:16000];
    audioStreamBasicDescription.mFormatID = kAudioFormatLinearPCM;
    audioStreamBasicDescription.mSampleRate = 16000;
    audioStreamBasicDescription.mFramesPerPacket = 1;
    audioStreamBasicDescription.mBytesPerPacket = 2; //16 bits * 1 channel
    audioStreamBasicDescription.mBytesPerFrame = 2;
    audioStreamBasicDescription.mChannelsPerFrame = 1; //1 channel
    audioStreamBasicDescription.mBitsPerChannel = 16;
    audioStreamBasicDescription.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked;
    audioStreamBasicDescription.mReserved = 0;
    
    NSArray *inputs = [EZAudioDevice inputDevices];
    [self.microphone setDevice:[inputs lastObject]];
    self.microphone = [EZMicrophone microphoneWithDelegate:self withAudioStreamBasicDescription:audioStreamBasicDescription];
    [self.microphone startFetchingAudio];
}

- (void) initSnowboy {
    _snowboyDetect = NULL;
    
    _snowboyDetect = new snowboy::SnowboyDetect(std::string([[[NSBundle mainBundle]pathForResource:@"common" ofType:@"res"] UTF8String]),
                                                std::string([[[NSBundle mainBundle]pathForResource:@"Brain" ofType:@"pmdl"] UTF8String]));
    _snowboyDetect->SetSensitivity("0.5");        // Sensitivity for each hotword
    _snowboyDetect->SetAudioGain(1.0);
}

- (void) pushFromMeResponse: (NSString*)msg withTimestamp:(NSString*)timestamp {
    NSDictionary* dict = @{@"msg":@{@"text":msg}, @"owner":@"me",@"timestamp":timestamp};
    [self.tableData addObject:dict];
    [self reloadTableWithData:self.tableData];
    [self fetchResponse:msg];
    [self.input setText:@""];
}

- (void) pushFromYouResponse: (NSString*)msg withTimestamp:(NSString*)timestamp andResp:(NSMutableDictionary*)resp {
    
    NSDictionary * dict;

    if (resp){
        [resp setValue:@"you" forKey:@"owner"];
        [resp setValue:timestamp forKey:@"timestamp"];
        dict = resp;
    } else {
         dict = @{@"msg":@{@"text":msg}, @"owner":@"you",@"timestamp":timestamp};
    }
    [self.tableData addObject:dict];
    [self reloadTableWithData:self.tableData];
    [self speak_msg:msg];
}

- (void) setRecordingButtonActive {
    [self.speech setImage:[UIImage imageNamed:@"Mic-White"] forState:UIControlStateNormal];
    self.speech.backgroundColor = [UIColor colorWithRed:(0/255) green:(122/255) blue:(255/255) alpha:1.0];
}
    
- (void) setRecordingButtonInactive {
    [self.speech setImage:[UIImage imageNamed:@"Mic"] forState:UIControlStateNormal];
    self.speech.backgroundColor = [UIColor whiteColor];

}
    
-(void)stopSpeech {
    [self.synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
}
    
- (void) reloadTableWithData: (NSMutableArray*)data {
    self.flippedTableData = [self reverse:data];
    [self.chatView reloadData];
}
    
- (NSString*) get_tod_greeting {
    NSDate *date = [NSDate date];
    NSString *tod;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [gregorian components:NSCalendarUnitHour fromDate:date];
    
    NSInteger hour = [dateComponents hour];
    if (hour > 6 && hour <= 12) {
        tod = @"Good Morning";// Morning
    } else if (hour > 12 && hour <= 16) {
        tod = @"Good Afternoon";
    } else {
        tod = @"Good Evening";// Evening
    }
    
    return tod;
}

- (void)microphone:(EZMicrophone *)microphone changedDevice:(EZAudioDevice *)device {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Changed input device: %@", device);
    });
}



-(void) microphone:(EZMicrophone *)microphone
  hasAudioReceived:(float **)buffer
    withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
    
    dispatch_async(dispatch_get_main_queue(),^{
        //        [NSThread sleepForTimeInterval:0.1];
        int result = _snowboyDetect->RunDetection(buffer[0], bufferSize);  // buffer[0] is a float array
        if (result == 1) {
            [self start_rec:self.speech];
        }
    });
}

- (NSArray*)reverse:(NSMutableArray*)data {
    NSArray * reverse = [[data reverseObjectEnumerator] allObjects];
    return reverse;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self pushFromMeResponse:textField.text withTimestamp:[self get_timestamp]];
    
    [self.input setText:@""];
    
    if (textField == self.input) {
        return NO;
    }
    return YES;
}

- (NSString*) get_timestamp {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"H:mm a"];
    NSString *formattedDate =[[formatter stringFromDate:[NSDate date]] uppercaseString];
    
    return formattedDate;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.input resignFirstResponder];
}
    
- (void) speak_msg: (NSString*) msg {
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:msg];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-UK"];
    [utterance setRate:0.45];
    [utterance setVolume:1];
    [self.synthesizer speakUtterance:utterance];
}

- (void) silence_time  {
    [self start_rec:self.speech];
    self.input.text = @"";

}

- (IBAction)start_rec:(UIButton *)sender {
    if (isRunning) {
        [self.microphone startFetchingAudio];

        [self.audioEngine stop];
        [self.audioEngine.inputNode removeTapOnBus:0];
        [self.recognitionRequest endAudio];
        isRunning = NO;
        
        [sender setSelected:NO];
        [sender setBackgroundColor:[UIColor clearColor]];
        [sender setBackgroundImage:[UIImage imageNamed:@"Mic"] forState:UIControlStateNormal];
        
        if ([self.input.text length] > 0){
            isProcessing = YES;
            
            [self pushFromMeResponse:self.input.text withTimestamp:[self get_timestamp]];
        }
        self.input.text = @"";
    } else {
        [self.microphone stopFetchingAudio];

        [sender setSelected:YES];
        [sender setBackgroundColor:[UIColor colorWithRed:41.0f/255.0f green:128.0f/255.0f blue:185.0f/255.0f alpha:1.0]];
        [sender setBackgroundImage:[UIImage imageNamed:@"Mic-White"] forState:UIControlStateSelected];
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(silence_time) userInfo:nil repeats:NO];
        [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
            if (status == SFSpeechRecognizerAuthorizationStatusAuthorized) {
                isRunning = YES;
                [self startRecognition];

            }
        }];
    }
}
    
- (void) startRecognition {
    
    self.speechRecognizer = [[SFSpeechRecognizer alloc] init];
    self.recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    
    
    if (!self.audioEngine.inputNode) {
        NSLog(@"ERROR");
        return;
    }
    
    if (self.recognitionTask != nil) {
        [self.recognitionTask cancel];
        self.recognitionTask = nil;
        self.input.text = @"";
    }
    
    [self.audioEngine.inputNode installTapOnBus:0 bufferSize:1024 format:[self.audioEngine.inputNode outputFormatForBus:0] block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        if (buffer) {
            [self.recognitionRequest appendAudioPCMBuffer:buffer];
        }
    }];
    
    self.recognitionTask = [self.speechRecognizer recognitionTaskWithRequest:self.recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        if (result && !result.isFinal) {
            if (!isProcessing){
                self.input.text = result.bestTranscription.formattedString;
            }
        }
        if (error) {
            NSLog(@"%@", error);
            [self.audioEngine stop];
        }
    }];
    
    [self.audioEngine prepare];
    [self.audioEngine startAndReturnError:nil];
}


- (void) fetchResponse:(NSString*)query {
    [[PComms getComms] makeGetReq:query withBlock:^(id response, id error) {
        [self pushFromYouResponse:[[response objectForKey:@"msg"] valueForKey:@"text"] withTimestamp:[self get_timestamp] andResp:[response mutableCopy]];
        isProcessing = NO;
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void) showServerURLBox {
    
    NSString *serverURL = [[NSUserDefaults standardUserDefaults]
                            valueForKey:@"pburl"];
    
    if (serverURL == nil){
        NSLog(@"SERVR SAID NO");
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Enter P-Brain.ai URL" message:@"Enter the local URL for your P-Brain.ai server here..." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            NSString * url = alert.textFields.firstObject.text;
            if (url){
                self.pburl = [NSString stringWithFormat:@"http://%@:4567/api/",url];
                [[NSUserDefaults standardUserDefaults] setValue:self.pburl forKey:@"pburl"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }]];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"x.x.x.x";
            textField.secureTextEntry = NO;
        }];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        self.pburl = serverURL;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.flippedTableData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSDictionary * item = [self.flippedTableData objectAtIndex:indexPath.row];
    
    if ([[item valueForKey:@"owner"] isEqualToString:@"you"]){
        MeTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MeTableViewCell"];
        
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MeTableViewCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        
        
        if ([[item valueForKey:@"type"] containsString:@"song"] && indexPath.row == 0) {
            
            UIView *videoContainerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, cell.wrapper.frame.size.width,
                                                                                 cell.wrapper.frame.size.height)];

            NSString * id = [[item objectForKey:@"msg"] valueForKey:@"id"];
            [cell.wrapper addSubview:videoContainerView];
            self.videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:id];
            [self.videoPlayerViewController presentInView:videoContainerView];
            [self.videoPlayerViewController.moviePlayer play];
        } else {
            [self.videoPlayerViewController.moviePlayer stop];
            cell.content.text = [[item objectForKey:@"msg"] valueForKey:@"text"];
        }
        
        cell.timestamp.text = [item valueForKey:@"timestamp"];
        
        return cell;
    
    } else {
        YouTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YouTableViewCell"];
        
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"YouTableViewCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        
        cell.content.text = [[item objectForKey:@"msg"] valueForKey:@"text"];
        cell.timestamp.text = [item valueForKey:@"timestamp"];
        
        if (indexPath.row == [self.tableData count] -1){
            CGRect basketTopFrame = cell.frame;
            basketTopFrame.origin.x = self.view.frame.size.width;
            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{ cell.frame = basketTopFrame; } completion:^(BOOL finished){ }];
        }
        return cell;
    }
}

- (void) keyboardWillShow: (NSNotification*) notification {
    if (isKeyboardHidden){
        [UIView beginAnimations:nil context:NULL];
        
        [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
//        [UIView setAnimationCurve:[[[notification userInfo] objectForKey: UIKeyboardAnimationCurveUserInfoKey] integerValue]];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        CGRect rect = [[self view] frame];
        
        rect.origin.y -= [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
        
        [[self view] setFrame: rect];
        
        [UIView commitAnimations];
        isKeyboardHidden = NO;
    }
}

- (void) keyboardWillHide: (NSNotification*) notification {
    if (!isKeyboardHidden){
        [UIView beginAnimations:nil context:NULL];
        
        [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
//        [UIView setAnimationCurve:[[[notification userInfo] objectForKey: UIKeyboardAnimationCurveUserInfoKey] integerValue]];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        CGRect rect = [[self view] frame];
        
        rect.origin.y += [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
        
        [[self view] setFrame: rect];
        
        [UIView commitAnimations];
        isKeyboardHidden = YES;
    }
}

- (void) hideKeyboard {
    [self.input resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.exampleData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"example";
    
    ExampleCollectionViewCell *cell;
    
    cell.tag = indexPath.row;
    
    if (cell == nil)
    {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
//        cell.exampleCommand.lineBreakMode = UILineBreakModeWordWrap;
        cell.exampleCommand.numberOfLines = 0;
    }
    
    NSString * row = [self.exampleData objectAtIndex:(int)indexPath.row];
    
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    [cell.contentView.layer setBorderColor:[UIColor colorWithRed:(0/255) green:(122/255) blue:(255/255) alpha:1.0].CGColor];
    [cell.contentView.layer setBorderWidth:0.6f];
    cell.exampleCommand.text = row;
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self stopSpeech];
    
    NSString * row = [self.exampleData objectAtIndex:(int)indexPath.row];
    NSDictionary* dict = @{@"msg":@{@"text":row}, @"owner":@"me", @"timestamp":[self get_timestamp]};
    
    [self.tableData addObject:dict];
    [self reloadTableWithData:self.tableData];
    [self fetchResponse:row];
}

- (void) initAudioListening {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:nil];
    
    isRunning = NO;
    isProcessing = NO;
    
    self.synthesizer = [AVSpeechSynthesizer new];
    self.synthesizer.delegate = self;
    self.audioEngine = [[AVAudioEngine alloc] init];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stopSpeech)];
    [self.chatView addGestureRecognizer:tap];
}

- (void) initPB {
    [self initUI];
    [self initKeyboardNotifications];
    [self initExampleData];
    [self initOrientation];
    [self initAudioListening];
    
    [self pushFromYouResponse:[self get_tod_greeting] withTimestamp:[self get_timestamp] andResp:nil];
}

- (void) initUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableData = [[NSMutableArray alloc] init];
    self.speech.layer.cornerRadius = self.speech.frame.size.width / 2;
}

- (void) initOrientation {
    self.chatView.transform = CGAffineTransformMakeRotation(-M_PI);
}

- (void) initExampleData {
    self.exampleData = @[@"What time is it?",@"What is the weather?",@"What is the tech news?",@"Tell me a joke",@"Flip a coin",@"When was Abe Lincoln born?",@"Play Englishman in New York"];
}

- (void) initKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    isKeyboardHidden = YES;
}

@end
