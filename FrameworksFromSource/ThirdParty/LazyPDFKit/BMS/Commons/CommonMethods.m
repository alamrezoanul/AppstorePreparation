//
//  CommonMethods.m
//  Boardmaestro
//
//  Created by InfoSapex on 10/17/16.
//  Copyright © 2016 InfoSapex Limited. All rights reserved.
//

#import "CommonMethods.h"
#import "LazyPDFViewController.h"

//Linked
@implementation CommonMethods
{
    
}
- (id)init
{
    self = [super init];
    if(self)
    {
        NSLog(@"Methods initialized: %@", self);
        
        self.serverIpOrDomain = [[NSUserDefaults standardUserDefaults] stringForKey:@"serverIpOrDomain"];
        self.Token = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
    }
    return self;
}
-(id)initWithParent : (UIViewController *) __parent
{
    self = [self init];
    self.persistentParent = __parent; //Do not update this anywere else
    
    if(self.persistentParent)
    {
        
        NSLog(@"CommonMethods initialized for Class: `%@`", NSStringFromClass([self.persistentParent class]));
        _showNotification = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveBMSNotification:) name:BMSNotificationName object:nil];
        
    }
    return self;
}
-(void) toggleObserver: (BOOL) _value
{
    _showNotification = _value;
    
}

- (void) receiveBMSNotification:(NSNotification *) notification
{
    
    if( !_showNotification ) { return; }
    
    NSNotification* notificationToPost = nil;
    
    UIViewController *parent1 = self.persistentParent;
    
    
    NSLog(@"parent1: %@", [parent1 description]);
    NSDictionary* userInfo = notification.userInfo;
    
    NSLog (@"Successfully received the notification! %@", userInfo[@"aps"]);
    NSString *messagecontainer1 = userInfo[@"aps"];
    
    NSString *messagecontainter = [NSString stringWithFormat:@"%@", messagecontainer1];
    if( [messagecontainter containsString:@"Type: APP"] )
    {
        if( [messagecontainter containsString:@"Action: Refresh"] )
        {
            notificationToPost = [NSNotification notificationWithName:HandleRemoteWipe object:self userInfo:notification.userInfo];
            [[NSNotificationCenter defaultCenter] postNotification:notificationToPost];
        }
        return;
    }
    
    if( [parent1 isKindOfClass:[LazyPDFViewController class]] )
    {
        @try
        {
            //Start : Parse and show notificatoins
            
            //messagecontainter = @"alert = \"Title: The Meeting # 168 is started\nAction: Started\nType: Meeting\";\n			sound = \"bingbong.aiff\";"; -For Debug
            //messagecontainter = @"alert = \"Title: The Poll No. 175 of Meeting No. 173\nhas been deleted\nAction: Deleted\nType: Poll\";	sound = \"bingbong.aiff\";";
            //messagecontainter = @"alert = \"Title: The Agenda # ibtcam-agenda-4 of Meeting No. 241\nhas been created\nAction: Created\nType: Agenda\";	sound = \"bingbong.aiff\";";
            if( [messagecontainter containsString:@"Type: Poll"] )
            {
                NSArray* listItems = [messagecontainter componentsSeparatedByString: @"="];
                
                NSLog(@"listitems: %@", listItems);
                
                NSArray* listItems1 = [listItems[1] componentsSeparatedByString: @"\n"];
                NSString *titles1_ = listItems1[0];
                NSArray *titles11 = [titles1_ componentsSeparatedByString:@"\\n"];
                
                NSArray *titles2_ = [titles11[0] componentsSeparatedByString:@": "];
                NSString *titles1 = titles2_[1];
                NSString *titles2 = titles11[1];
                NSString *msgTitle = [NSString stringWithFormat:@"%@ %@",titles1, titles2];
                NSString *action = titles11[2];
                
                [self.persistentParent.view makeToast:msgTitle duration:ToastDuration position:CSToastPositionCenter];
                
            }
            else if( [messagecontainter containsString:@"Type: Meeting"] || [messagecontainter containsString:@"Type: Correspondence"])
            {
                // Show toast message
                NSArray* listItems = [messagecontainter componentsSeparatedByString: @"="];
                
                NSLog(@"listitems: %@", listItems);
                
                
                //NSString *fromStr = [listItems2 objectAtIndex:1];
                if( [messagecontainter containsString:@"Type: Meeting"])
                {
                    
                    if( [messagecontainter containsString:@"Action: CastingVote"] )
                    {
                        
                        NSString *message1 = [listItems objectAtIndex:1];
                        
                        //TODO: Parse special characters here
                        NSArray* listItems2 = [message1 componentsSeparatedByString: @"\\n"];
                        NSLog(@"listItems2: %@", listItems2);
                        NSString *messageStr = [listItems2 objectAtIndex:1];
                        NSArray *messages = [messageStr componentsSeparatedByString:@":"];
                        NSString *messsage = [messages objectAtIndex:1];
                        NSLog(@"message: %@", messsage);
                        
                        NSInteger intPollId = [messsage integerValue];
                        if( intPollId > 0 )
                        {
                            NSString *_pollIdLocal = [NSString stringWithFormat:@"%ld", intPollId];
                            
                            NSDictionary *aDict = @{ @"pollId":_pollIdLocal };
                            [self handleCastingVotePrivBase:aDict];
                        }
                    }
                    else //Published, Started, Finished
                    {
                        NSString *message1 = [listItems objectAtIndex:1];
                        NSArray* listItems2 = [message1 componentsSeparatedByString: @"\\n"];
                        NSLog(@"listItems2: %@", listItems2);
                        NSString *messageStr = [listItems2 objectAtIndex:0];
                        NSArray *messages = [messageStr componentsSeparatedByString:@":"];
                        NSString *messsage = [messages objectAtIndex:1];
                        NSLog(@"message: %@", messsage);
                        NSArray *listItems3 = [messsage componentsSeparatedByString:@" "];
                        NSLog(@"listItems3: %@", listItems3);
                        if( [messagecontainter containsString:@"Action: Published"] )
                        {
                            [self showToast:self.persistentParent title:@"Alert" message:@"You have a new Meeting"];
                            
                        }
                        else //Started, Finished
                        {
                            
                            if( [listItems3 count] >= 5 )
                            {
                                
                                //Refresh the meeting here
                                NSString *_meetingId = [listItems3 objectAtIndex:4];
                                NSInteger _intMeetingId = [_meetingId intValue];
                                if( _intMeetingId > 0 )
                                {
                                    _meetingId = [NSString stringWithFormat:@"%li", _intMeetingId];
                                    
                                    NSDictionary *aDict = @{ @"meetingId":_meetingId, @"messagecontainer":messagecontainter };
                                    
                                    NSString *messagecontainer = [aDict objectForKey:@"messagecontainer"];
                                    NSString *meetingStatus = @"";
                                    if( [messagecontainer containsString:@"Action: Started"] )
                                    {
                                        meetingStatus = [NSString stringWithFormat:@"Meeting (%@) has been Started!", _meetingId ];
                                    }
                                    else if( [messagecontainer containsString:@"Action: Finished"] )
                                    {
                                        meetingStatus = [NSString stringWithFormat:@"Meeting (%@) has been Finished!", _meetingId ];
                                    }
                                    [self showToast:self.persistentParent title:@"Alert" message:meetingStatus];
                                }
                                
                                //Text ...
                                //Title: the meeting # 588 is started\n
                                //Action: \n
                                //Type:
                            }
                        }
                    }
                }
                else
                {
                    
                    [self showToast:self.persistentParent title:@"Alert" message:@"You have a new Notice!"];
                    
                }
            }
            else if( [messagecontainter containsString:@"Type: AgendaFile"] )
            {
                // Show toast message
                NSArray* listItems = [messagecontainter componentsSeparatedByString: @"="];
                
                NSLog(@"listitems: %@", listItems);
                
                NSString *message1 = [listItems objectAtIndex:1];
                
                //TODO: Parse special characters here
                NSArray* listItems2 = [message1 componentsSeparatedByString: @"\\n"];
                NSLog(@"listItems2: %@", listItems2);
                NSString *messageStr = [listItems2 objectAtIndex:0];
                NSArray *messages = [messageStr componentsSeparatedByString:@":"];
                NSString *messsage = [messages objectAtIndex:1];
                NSLog(@"message: %@", messsage);
                messsage = [NSString stringWithFormat:@"%@ has been updated!",messsage];
                
                [self showToast:self.persistentParent title:@"Alert!" message:messsage];
                
            }
            else if( [messagecontainter containsString:@"Type: Agenda"] )
            {
                NSArray* listItems = [messagecontainter componentsSeparatedByString: @"="];
                
                NSLog(@"listitems: %@", listItems);
                
                NSArray* listItems1 = [listItems[1] componentsSeparatedByString: @"\n"];
                NSString *titles1_ = listItems1[0];
                NSArray *titles11 = [titles1_ componentsSeparatedByString:@"\\n"];
                
                NSArray *titles2_ = [titles11[0] componentsSeparatedByString:@": "];
                NSString *titles1 = titles2_[1];
                NSString *titles2 = titles11[1];
                NSString *msgTitle = [NSString stringWithFormat:@"%@ %@",titles1, titles2];
                NSString *action = titles11[2];
                
                [self.persistentParent.view makeToast:msgTitle duration:ToastDuration position:CSToastPositionCenter];
            }
            
        }
        @catch (NSException *exception)
        {
            
        }
        //End : Parse and show notifications
    }
    else
    {
        notificationToPost = [NSNotification notificationWithName:HandleMeetingNotificationName object:self userInfo:notification.userInfo];
        [[NSNotificationCenter defaultCenter] postNotification:notificationToPost];
    }
}

- (NSDictionary *) getPollDictFromServer : (NSString *) __pollId
{
    self.serverIpOrDomain = [[NSUserDefaults standardUserDefaults] stringForKey:@"serverIpOrDomain"];
    self.Token = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
    
    NSString *strPollURL = [NSString stringWithFormat:@"%@/api/poll/get_everything/%@?token=%@",self.serverIpOrDomain, __pollId, self.Token];
    NSLog(@"strPollURL: %@", strPollURL);
    
    NSString *messageString = [self getData:strPollURL];
    
    NSMutableDictionary *dict=[NSJSONSerialization JSONObjectWithData:[messageString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    
#ifdef SHOWLOG
    NSLog(@"dict data: %@", dict);
#endif
    
    NSDictionary *dataArr=[dict valueForKey:@"data"];
    
    NSLog(@"dataArr: %@", dataArr);
    
    NSDictionary *apoll = dataArr;
    
    NSLog(@"apoll: %@", apoll) ;
    
    BOOL nullYES = [self isNULL:apoll];
    if( nullYES )
    {
        return nil;
    }
    
    return apoll;
}

///*
// Start : Casting Vote
#pragma mark -
#pragma mark Casting Votes

- (void) handleCastingVotePrivBase: (NSDictionary *) aDict
{
    //NSDictionary *aDict = notification.userInfo;
    NSString *_pollId = [aDict objectForKey:@"pollId"];
    [[NSUserDefaults standardUserDefaults] setValue:_pollId forKey:@"_pollId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self showCastingVoteBase : @"Casting Vote Required on Poll" message:@"Casting Vote"];
}

- (void) sendCastingVoteBase : (NSString *) __postData
{
    self.serverIpOrDomain = [[NSUserDefaults standardUserDefaults] stringForKey:@"serverIpOrDomain"];
    self.Token = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
    
    NSString *_pollId = [[NSUserDefaults standardUserDefaults] stringForKey:@"_pollId"];
    NSString *strUrl = [NSString stringWithFormat:@"%@/api/poll/vote/%@?token=%@",self.serverIpOrDomain, _pollId, self.Token];
    
    NSString *messageString = [self postData:strUrl data:__postData];
    
    [self hideCustomProgress];
    
    [self.persistentParent.view makeToast:@"Casting Vote Success!" duration:ToastDuration position:CSToastPositionCenter];
    
}
- (void) showCastingVoteBase : (NSString *)title message:(NSString *)msg
{
    
    //Start : Prepare options here ...
    NSString *_pollId = [[NSUserDefaults standardUserDefaults] stringForKey:@"_pollId"];
    NSDictionary *aPollDict = [self getPollDictFromServer:_pollId];
    NSLog(@"aPollDict: %@", [aPollDict description]);
    
    NSMutableArray* allresults = [aPollDict objectForKey:@"result"];
    NSDictionary *aresult1 = nil;
    NSDictionary *aresult2 = nil;
    NSDictionary *aresult3 = nil;
    if( [allresults count] == 0 )
    {
        
        allresults = [[NSMutableArray alloc] init];
        NSMutableArray *options = [aPollDict objectForKey:@"options"];
        for(NSUInteger index = 0; index < [options count]; ++index)
        {
            NSDictionary *aoption = options[index];
            
            NSDictionary *aresult = @{
                                      @"poll_option_id" : [NSString stringWithFormat:@"%i", [[aoption objectForKey:@"id"] intValue]],
                                      @"option_label" : [aoption objectForKey:@"option_label"],
                                      @"totalcount" : @"0"
                                      };
            
            //            aresult = [[NSDictionary alloc] init];
            //            [aresult setValue:[NSString stringWithFormat:@"%i", [[aoption objectForKey:@"id"] intValue]] forKey:@"poll_option_id"];
            //            [aresult setValue:[aoption objectForKey:@"option_label"] forKey:@"option_label"];
            //            [aresult setValue:@"0" forKey:@"totalcount"];
            
            [allresults	insertObject:aresult atIndex:index];
            
        }
        
    }
    
    NSString *pollTitle = [aPollDict objectForKey:@"title"];
    if( [allresults count] == 3 )
    {
        aresult1 = allresults[0];
        aresult2 = allresults[1];
        aresult3 = allresults[2];
        
        
        if( ( [[aresult1 objectForKey:@"totalcount"] intValue] == [[aresult2 objectForKey:@"totalcount"] intValue] ) == [[aresult3 objectForKey:@"totalcount"] intValue] )
        {
            [self _showCastingVoteBase:title withMessage:pollTitle withResult1:aresult1 withResult2:aresult2 withResult3:aresult3];
        }
        else if( [[aresult1 objectForKey:@"totalcount"] intValue] == [[aresult2 objectForKey:@"totalcount"] intValue] )
        {
            [self _showCastingVoteBase:title withMessage:pollTitle withResult1:aresult1 withResult2:aresult2 withResult3:nil];
        }
        else if( [[aresult1 objectForKey:@"totalcount"] intValue] == [[aresult3 objectForKey:@"totalcount"] intValue] )
        {
            [self _showCastingVoteBase:title withMessage:pollTitle withResult1:aresult1 withResult2:aresult3 withResult3:nil];
        }
        else if( [[aresult2 objectForKey:@"totalcount"] intValue] == [[aresult3 objectForKey:@"totalcount"] intValue] )
        {
            [self _showCastingVoteBase:title withMessage:pollTitle withResult1:aresult2 withResult2:aresult3 withResult3:nil];
        }
    }
    else if( [allresults count] == 2 )
    {
        for( int i =0; i < [allresults count]-1; ++i)
        {
            aresult1 = allresults[i];
            
            for(int j=i+1; j<[allresults count]; ++j)
            {
                aresult2 = allresults[j];
                if( [[aresult1 objectForKey:@"totalcount"] intValue] == [[aresult2 objectForKey:@"totalcount"] intValue] )
                {
                    break;
                }
                else
                {
                    aresult2 = nil;
                }
            }
            
            if( aresult1 && aresult2 )
            {
                break;
            }
        }
        
        
        if( aresult1 && aresult2 )
        {
            [self _showCastingVoteBase:title withMessage:pollTitle withResult1:aresult1 withResult2:aresult2 withResult3:nil];
            
        }
    }
    
}
- (void) _showCastingVoteBase : (NSString *)title withMessage:(NSString *)msg withResult1: (NSDictionary *) aresult1 withResult2:(NSDictionary *)aresult2 withResult3:(NSDictionary *)aresult3
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:msg
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* optionButton1 = [UIAlertAction actionWithTitle:[aresult1 objectForKey:@"option_label"] style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              //Do Some action here
                                                              [alert dismissViewControllerAnimated:YES completion:nil];
                                                              NSString *strComment = [[[alert textFields] objectAtIndex:0] text];
                                                              if( [strComment length] == 0 )
                                                              {
                                                                  [self showToast:self.persistentParent title:@"" message:@"Comment is required"];
                                                                  [self _showCastingVoteBase:title withMessage:msg withResult1:aresult1 withResult2:aresult2 withResult3:aresult3];
                                                                  
                                                                  return;
                                                              }
                                                              
                                                              [self showCustomProgress];
                                                              
                                                              NSString *postData = [NSString stringWithFormat:@"type=casting&option_id=%i&option_comment=%@", [[aresult1 objectForKey:@"poll_option_id"] intValue], strComment];
                                                              NSLog(@"post value: %@", postData);
                                                              
                                                              [self performSelector:@selector(sendCastingVoteBase:) withObject:postData afterDelay:0.2];
                                                              
                                                          }];
    UIAlertAction* optionButton2 = [UIAlertAction actionWithTitle:[aresult2 objectForKey:@"option_label"] style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              //Do Some action here
                                                              [alert dismissViewControllerAnimated:YES completion:nil];
                                                              NSString *strComment = [[[alert textFields] objectAtIndex:0] text];
                                                              if( [strComment length] == 0 )
                                                              {
                                                                  [self showToast:self.persistentParent title:@"" message:@"Comment is required"];
                                                                  [self _showCastingVoteBase:title withMessage:msg withResult1:aresult1 withResult2:aresult2 withResult3:aresult3];
                                                                  return ;
                                                              }
                                                              
                                                              [self showCustomProgress];
                                                              
                                                              NSString *postData = [NSString stringWithFormat:@"type=casting&option_id=%i&option_comment=%@",[[aresult2 objectForKey:@"poll_option_id" ] intValue], strComment];
                                                              NSLog(@"post value: %@", postData);
                                                              [self performSelector:@selector(sendCastingVoteBase:) withObject:postData afterDelay:0.2];
                                                              
                                                          }];
    [alert addAction:optionButton1];
    [alert addAction:optionButton2];
    
    
    if( aresult3 )
    {
        UIAlertAction* optionButton3 = [UIAlertAction actionWithTitle:[aresult3 objectForKey:@"option_label"] style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  //Do Some action here
                                                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                                                  NSString *strComment = [[[alert textFields] objectAtIndex:0] text];
                                                                  if( [strComment length] == 0 )
                                                                  {
                                                                      [self showToast:self.persistentParent title:@"" message:@"Comment is required"];
                                                                      [self _showCastingVoteBase:title withMessage:msg withResult1:aresult1 withResult2:aresult2 withResult3:aresult3];
                                                                      return ;
                                                                  }
                                                                  
                                                                  [self showCustomProgress];
                                                                  
                                                                  NSString *postData = [NSString stringWithFormat:@"type=casting&option_id=%i&option_comment=%@",[[aresult3 objectForKey:@"poll_option_id"] intValue], strComment];
                                                                  NSLog(@"post value: %@", postData);
                                                                  [self performSelector:@selector(sendCastingVoteBase:) withObject:postData afterDelay:0.2];
                                                                  
                                                              }];
        [alert addAction:optionButton3];
    }
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Comment is required";
    }];
    
    [self.persistentParent presentViewController:alert animated:YES completion:nil];
}
// End : Casting Vote
//*/

- (BOOL) isNULL: (id) value
{
    BOOL result = FALSE;
    if( value == nil )
    {
        result = TRUE;
    }
    else if( [value isKindOfClass:[NSNull class]] )
    {
        result = TRUE;
    }
    else if( [value isKindOfClass:[NSDictionary class]] )
    {
        if( value == [NSNull null] )
        {
            result = TRUE;
        }
    }
    else if( [value isKindOfClass:[NSArray class]] )
    {
        if( value == [NSNull null] )
        {
            result = TRUE;
        }
    }
    else if( [value isKindOfClass:[NSString class]] )
    {
        result = [value isEqualToString:@"<null>"] || [value isEqualToString:@"(null)"];
    }
    
    return  result;
}

- (NSString *) replaceString : (NSString *)originalString replaceString: (NSString *)replaceString
{
    //NSString *str =
    return @"";
}

-(NSDictionary* )prepareBasicAuthenticationForLicenseServer
{
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", kLicenseServerUserName, kLicenseServerPassword];
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
    
    NSDictionary* aDict = @{
                            @"key" : @"Authorization",
                            @"value" : authValue
                            };
    
    return aDict;
}
-(NSString* ) getData : (NSString *)url
{
    [self showCustomProgress];
    
    __block NSMutableString *messageString = nil;
    __block BOOL gotResponse = FALSE;
    
    dispatch_sync(_networkQueue, ^{
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setTimeoutInterval:10.0];
        [request setURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"GET"];
        
        
        NSDictionary* aDict = [self prepareBasicAuthenticationForLicenseServer];
        [request setValue:[aDict objectForKey:@"value"] forHTTPHeaderField:[aDict objectForKey:@"key"]];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            NSLog(@"requestReply: %@", requestReply);
            
            messageString = [[NSMutableString alloc] initWithString:@""];
            [messageString appendString:[NSString stringWithFormat:@"%@",requestReply]];
            
            NSLog(@"in getData, _messageString: %@", messageString);
            
            gotResponse = TRUE;
            
            [self hideCustomProgress];
        }] resume];
    });
    
    while( !gotResponse );
    
    [self hideCustomProgress];
    return messageString;
}

-(void) getData : (NSString *)url withCompletion: (void (^)(NSString *))completion
{
    
    __block NSMutableString *messageString = nil;
    __block BOOL gotResponse = FALSE;
    
    dispatch_sync(_networkQueue, ^{
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        
        [request setTimeoutInterval:15.0];
        [request setURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"GET"];
        NSURLSessionConfiguration *sessConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        [sessConfiguration setTimeoutIntervalForRequest:15.0];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessConfiguration];
        [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            NSLog(@"requestReply: %@", requestReply);
            
            messageString = [[NSMutableString alloc] initWithString:@""];
            [messageString appendString:[NSString stringWithFormat:@"%@",requestReply]];
            
            NSLog(@"in getData, messageString: %@", messageString);
            
            gotResponse = TRUE;
            if(completion)
            {
                completion(messageString);
            }
            
        }] resume];
    });
    
    while( !gotResponse ) ;
}

-(NSMutableString *) postData : (NSString *) posturl data: (NSString *) postdata
{
    if( postdata == nil )
    {
        return @"";
    }
    
    __block NSMutableString *messageString = @"";
    __block BOOL gotResponse = FALSE;
    
    NSData *postData_ = nil;
    NSString *postLength = nil;
    @try{
        NSLog(@"postData: %@", postdata);
        postData_ = [postdata dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData_ length]];
    }
    @catch(NSException *ex) {
        NSLog(@"Error is here");
    }
    
    //[self.persistentParent.view makeToastActivity:CSToastPositionCenter];
    [self showCustomProgress];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:posturl]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"iPad" forHTTPHeaderField:@"User-Agent"];
    
    NSDictionary* aDict = [self prepareBasicAuthenticationForLicenseServer];
    [request setValue:[aDict objectForKey:@"value"] forHTTPHeaderField:[aDict objectForKey:@"key"]];
    
    [request setHTTPBody:postData_];
    NSTimeInterval timeOutSecs = 15;
    [request setTimeoutInterval:timeOutSecs];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSLog(@"requestReply: %@", requestReply);
        
        messageString = [[NSMutableString alloc] initWithString:@""];
        [messageString appendString:[NSString stringWithFormat:@"%@",requestReply]];
        
        NSLog(@"messageString: %@", messageString);
        
        gotResponse = TRUE;
        
        //		dispatch_async(dispatch_get_main_queue(), ^{
        //			if( self.parent != nil )
        //			{
        //				[self.parent.view hideToastActivity];
        //			}
        //			[self.persistentParent.view hideToastActivity];
        //		});
        
        [self hideCustomProgress];
        
    }] resume];
    
    while( !gotResponse );
    
    //	dispatch_async(dispatch_get_main_queue(), ^{
    //		if( self.parent != nil )
    //		{
    //			[self.parent.view hideToastActivity];
    //		}
    //		[self.persistentParent.view hideToastActivity];
    //	});
    
    [self hideCustomProgress];
    
    return messageString;
    
}
- (NSDictionary* ) getJSONFromServerReturnArray: (NSString *)fullUrl
{
    
    [self showCustomProgress];
    
    NSMutableArray* retArray = [[NSMutableArray alloc] init];
    
    __block NSInteger totalItems = 0;
    __block BOOL gotResponse = FALSE;
    NSString* apiURL;
    if( [fullUrl containsString:@"token="] )
    {
        apiURL = fullUrl;
    }
    else
    {
        apiURL = [NSString stringWithFormat:@"%@?token=%@", fullUrl, self.Token];
    }
    NSLog(@"apiURL: %@", apiURL);
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithURL:[NSURL URLWithString:apiURL]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                
                if (!error)
                {
                    
                    NSError *jsonError = nil;
                    NSMutableDictionary *jsonObject = (NSMutableDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                    
                    [retArray addObjectsFromArray:[jsonObject objectForKey:@"data"]];
                    
                    totalItems = [[jsonObject objectForKey:@"total"] integerValue];
                    
                }
                
                [self hideCustomProgress];
                gotResponse = TRUE;
            }] resume];
    
    while (!gotResponse) ;
    
    NSString* strTotalItems = [NSString stringWithFormat:@"%ld", (long)totalItems];
    NSDictionary *aDict = @{
                            @"str_total_items" : strTotalItems,
                            @"retArray" : retArray
                            };
    
    [self hideCustomProgress];
    return aDict;
}

- (UITableViewCell* ) getBlankCell
{
    UITableViewCell *cell = [[UITableViewCell alloc]
                             initWithStyle:UITableViewCellStyleDefault
                             reuseIdentifier:nil];
    return cell;
}
- (UITableViewCell *)getLoadingCell
{
    
    //Start Load more Cell
    UITableViewCell *cell = [[UITableViewCell alloc]
                             initWithStyle:UITableViewCellStyleDefault
                             reuseIdentifier:nil];
    
    cell.textLabel.text = @"Tap to load more";
    cell.textLabel.textColor = [UIColor blueColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    //End Load more Cell
    
    
    /*
     //Start activity indicator
     UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
     activityIndicator.center = cell.center;
     [cell addSubview:activityIndicator];
     
     [activityIndicator startAnimating];
     //End activity indicator
     */
    
    cell.tag = kLoadingCellTag;
    
    return cell;
}

-(UIButton* )getInternetIndicatorButton
{
    UIButton* btnInternetIndicator = nil;
    NSArray* subViews = [self.persistentParent.view subviews];
    
    for( UIView* aview in subViews )
    {
        
        UIView* btnInternetIndicatorTemp = [aview viewWithTag:kInternetIndicatorTag];
        if( btnInternetIndicatorTemp && [btnInternetIndicatorTemp isKindOfClass:[UIButton class]])
        {
            btnInternetIndicator = (UIButton* )btnInternetIndicatorTemp;
            break;
        }
    }
    
    return btnInternetIndicator;
}

- (NSString *)convertDatetimeToLocalWithFormat:(NSString *)strDate format:(NSString *)format
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //upama
    NSLog(@"string Date:%@",strDate);
    //upama
    
    NSDate* utcTime = [dateFormatter dateFromString:strDate];
    
    //upama
    //NSLog(@"UTC time: %@", utcTime);
    //upama
    
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setDateFormat:format];
    //[dateFormatter setDateStyle:NSDateFormatterShortStyle];
    NSString* localTime = [dateFormatter stringFromDate:utcTime];
    NSLog(@"localTime:%@", localTime);
    
    return localTime;
}
- (NSString *)convertDatetimeToLocalWithFormatStyle:(NSString *)strDate format:(NSString *)format style:(NSDateFormatterStyle)style
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* utcTime = [dateFormatter dateFromString:strDate];
    NSLog(@"UTC time: %@", utcTime);
    
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setDateFormat:format];
    [dateFormatter setDateStyle:style];
    NSString* localTime = [dateFormatter stringFromDate:utcTime];
    NSLog(@"localTime:%@", localTime);
    
    return localTime;
}
- (NSString *) convertFromDateToString:(NSDate *) date format: (NSString *) format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    
    //Optionally for time zone conversions
    //[formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    NSString *stringFromDate = [formatter stringFromDate:date];
    
    //unless ARC is active
    //[formatter release]; //-
    
    return stringFromDate;
}
- (NSDate* )convertDatetimeToUTCDateTime:(NSString *)strDate
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* utcTime = [dateFormatter dateFromString:strDate];
    NSLog(@"UTC time: %@", utcTime);
    
    return utcTime;
}
- (NSDate* )convertDatetimeToLocalDate:(NSString *)strDate
{
    
    NSDate* utcTime = [self convertDatetimeToUTCDateTime:strDate];
    NSLog(@"UTC time: %@", utcTime);
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setDateFormat:@"dd-MM-yyyy hh:mm a"];
    NSString* localTime = [dateFormatter stringFromDate:utcTime];
    NSLog(@"localTime:%@", localTime);
    
    return [dateFormatter dateFromString:localTime];
    
}
-(NSDictionary *)formatDateReturnDictionary:(NSString *)strDate{
    NSString* strDay;
    NSString* strMonth;
    NSString* strYear;
    NSString* strMonthYear;
    NSString* strTime;
    NSLog(@"string date:%@", strDate);
    @try {
        strDay = [self convertDatetimeToLocalWithFormat:strDate format:@"dd"];
    }
    @catch(NSException *ex) {
        strDay = @"";
    }
    
    @try {
        strMonth = [self convertDatetimeToLocalWithFormat:strDate format:@"MMMM"];
    }
    @catch(NSException *ex)
    {
        strMonth = @"";
    }
    
    @try {
        strYear = [self convertDatetimeToLocalWithFormat:strDate format:@"yy"];
        strMonthYear = [NSString stringWithFormat:@"%@ %@", strMonth, strYear];
    }
    @catch(NSException *ex)
    {
        strMonthYear = @"";
    }
    
    @try {
        strTime = [self convertDatetimeToLocalWithFormat:strDate format:@"hh:mm a"];
        strTime = [strTime substringToIndex:strTime.length -1];
        strTime = [strTime lowercaseString];
        strTime = [strTime stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    @catch(NSException *ex)
    {
        strTime = @"";
    }
    
    NSDictionary* aDict = @{
                            @"day":strDay,
                            @"month_year":strMonthYear,
                            @"time":strTime
                            };
    
    return aDict;
}
-(NSDictionary* )getTodayReturnDictionary
{
    
    NSDate *date = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd"];
    NSString* dateString2 = [df stringFromDate:date];
    NSLog(@"date: %@", dateString2);
    
    [df setDateFormat:@"yyyy-MMMM-EEEE"];
    NSString *dateString1 = [[df stringFromDate:date] uppercaseString];
    NSLog(@"dateString1: %@", dateString1);
    
    NSArray* tmps = [dateString1 componentsSeparatedByString:@"-"];
    
    return @{
             @"year" : tmps[0],
             @"month" : tmps[1],
             @"day" : tmps[2],
             @"date" : dateString2
             };
}

#pragma mark - UIProgessview Method

-(void) showCustomProgressPriv
{
    
    self.window = [[UIApplication sharedApplication] keyWindow];
    
    CGRect full = self.window.bounds;
    
    self.window.rootViewController.view.frame = full;
    
    //[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self.window.rootViewController.view addSubview:self.whatsHappening.view];
    
}
-(void) showCustomProgress
{
    if( self.whatsHappening == nil )
    {
        NSBundle *currentBundle = [NSBundle bundleWithIdentifier:kLazyPDFKitBundleIdentifier];
        //[NSBundle allFrameworks: bundleForClass:[self class]];
        self.whatsHappening = [[customProgress alloc] initWithNibName:@"customProgress" bundle:currentBundle];
        [self.whatsHappening.view setTag:kCustomProgressTag];
    }
    
    [self performSelector:@selector(showCustomProgressPriv) withObject:nil afterDelay:0.5];
    
}

-(void) hideCustomProgressPriv
{
    self.window = [UIApplication sharedApplication].keyWindow;
    UIView* v = [self.window.rootViewController.view viewWithTag:kCustomProgressTag];
    if( v )
    {
        [v removeFromSuperview];
    }
    self.whatsHappening = nil;
    //[[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
}
-(void) hideCustomProgress
{
    [self performSelector:@selector(hideCustomProgressPriv) withObject:nil afterDelay:0.5];
}
-(NSString *)dateDiff:(NSString *)origDate {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setFormatterBehavior:NSDateFormatterBehavior10_4];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *convertedDate = [df dateFromString:origDate];
    
    NSDate *todayDate = [NSDate date];
    double ti = [convertedDate timeIntervalSinceDate:todayDate];
    ti = ti * -1;
    if(ti < 1) {
        return @"never";
    } else  if (ti < 60) {
        return @"less than a minute ago";
    } else if (ti < 3600) {
        int diff = round(ti / 60);
        return [NSString stringWithFormat:@"%d minutes ago", diff];
    } else if (ti < 86400) {
        int diff = round(ti / 60 / 60);
        return[NSString stringWithFormat:@"%d hours ago", diff];
    } else if (ti < 2629743) {
        int diff = round(ti / 60 / 60 / 24);
        return[NSString stringWithFormat:@"%d days ago", diff];
    } else {
        return @"never";
    }
}
-(double)dateDiffBetweenTwoDates:(NSString *)strDate1 withDate2: (NSString* )strDate2
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setFormatterBehavior:NSDateFormatterBehavior10_4];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //[df setDateFormat:@"EEE, dd MMM yy HH:mm:ss VVVV"];
    NSDate *convertedDate1 = [df dateFromString:strDate1];
    NSDate *convertedDate2 = [df dateFromString:strDate2];
    
    double ti = [convertedDate1 timeIntervalSinceDate:convertedDate2];
    
    return ti;
}
-(NSString* ) createSubDirectoriesInPath: (nonnull NSString *)path
{
    NSError* error;
    BOOL dirCreated;
    BOOL dirExist;
    BOOL isDirectory;
    NSFileManager* fm = [NSFileManager defaultManager];
    NSArray* strSubDirs = [path componentsSeparatedByString:@"/"];
    NSString* fullPath = DocumentsDirectory;
    for( NSString* strDir in strSubDirs)
    {
        fullPath = [NSString stringWithFormat:@"%@/%@", fullPath, strDir];
        dirExist = [fm fileExistsAtPath:fullPath isDirectory:&isDirectory];
        if( !dirExist )
        {
            dirCreated = [fm createDirectoryAtPath:fullPath withIntermediateDirectories:NO attributes:nil error:&error];
            if( dirCreated )
            {
                NSLog(@"Dir Created Successfully!");
            }
            else
            {
                NSLog(@"Dir Couldn't Create bcoz of error: %@!", [error description] );
            }
        }
    }
    
    return fullPath;
}

-(nonnull UIImage* ) getInfoSapexLogo
{
    return [UIImage imageNamed:@"infosapex_logo_1"];
}

- (nonnull UIColor *)randomColor
{
    CGFloat red = arc4random_uniform(255) / 255.0;
    CGFloat green = arc4random_uniform(255) / 255.0;
    CGFloat blue = arc4random_uniform(255) / 255.0;
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    NSLog(@"color: %@", color);
    return color;
}

-(NSString* )getMyPassword
{
    NSString* strSavedPassword = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    return strSavedPassword;
}

-(NSString* )sendDeviceToken : (NSString* ) strDeviceToken
{
    __block NSString *messageString = @"";
    NSString *deviceAddurl = [NSString stringWithFormat:@"%@/api/user/device/add?token=%@", self.serverIpOrDomain, self.Token];
    BOOL nullYES = [self isNULL:strDeviceToken];
    if( nullYES == NO && [strDeviceToken length] > 0 )
    {
        
            NSString *postData = [NSString stringWithFormat:@"device_uid=%@", strDeviceToken ];
#ifdef SHOWLOG
            NSLog(@"post value: %@", postData);
#endif
            messageString = [self postData:deviceAddurl data:postData];
            
#ifdef SHOWLOG
            NSLog(@"messageString: %@", messageString);
#endif
        
    }
    
    return messageString;
}

-(void)showNotOnlineAlert
{
    [self showAlert:@"" message:@"Check Network Status"];
}

- (void) showAlert : (NSString *)title message:(NSString *)msg
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:msg
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"Okay"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    [alert addAction:ok];
    
    [self.persistentParent presentViewController:alert animated:YES completion:nil];
}

- (void) showToast : (UIViewController *)__parent title:(NSString *)title message:(NSString *)msg
{
    
    //UIViewController *parent1 = [__parent base
    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
    style.messageColor = [UIColor redColor];
    style.messageAlignment = NSTextAlignmentCenter;
    style.backgroundColor = [UIColor whiteColor];
    [__parent.view makeToast:msg
                    duration:ToastDuration
                    position:CSToastPositionCenter
                       title:title
                       image:nil
                       style:nil
                  completion:nil];
}
@end
