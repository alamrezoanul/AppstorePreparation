//
//  CommonMethods.h
//  Boardmeeting
//
//  Created by InfoSapex on 2/9/17.
//  Copyright © 2017 InfoSapex Limited. All rights reserved.
//

#ifndef CommonMethods_h
#define CommonMethods_h

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "UIView+Toast.h"
#import "customProgress.h"
//Linked
@interface CommonMethods : NSObject
{
    //
    BOOL _showNotification;
    
    
}
@property (nonatomic, retain) customProgress* _Nullable  whatsHappening; //Static
-(UIButton* )getInternetIndicatorButton;
-(id)initWithParent : (UIViewController *) __parent;
-(void) toggleObserver: (BOOL)_value;
- (BOOL) isNULL: (id) value;

- (NSDictionary *) getPollDictFromServer : (NSString *) __pollId;
-(NSString *) postData : (NSString *) posturl data: (NSString *) postdata;
-(void) getData : (NSString *)url withCompletion: (void (^)(NSString *))completion;
-(NSString *) getData : (NSString *)url;

//For Paging
- (NSDictionary* ) getJSONFromServerReturnArray: (NSString *)fullUrl;
- (UITableViewCell *)getLoadingCell;

@property (nonatomic, retain) NSString *currentCompany;
@property (nonatomic, retain) NSString *UserId;
@property (nonatomic, retain) UIViewController *persistentParent;
@property (nonatomic, retain) NSString *serverIpOrDomain;
@property (nonatomic, retain) NSString *Token;

//Start For Paging
//For Paging
- (UITableViewCell* ) getBlankCell;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger totalItems;
@property (nonatomic, assign) NSInteger totalPages;
@property (nonatomic, assign) NSInteger skipRow;
@property (nonatomic, assign) BOOL loading;
//End For Paging

- (NSString *) convertFromDateToString:(NSDate *) date format: (NSString *) format;
- (NSString *)convertDatetimeToLocalWithFormat:(NSString *)strDate format:(NSString *)format;
- (NSDate* )convertDatetimeToUTCDateTime:(NSString *)strDate;
- (NSDate *)convertDatetimeToLocalDate:(NSString *)strDate;
-(NSDictionary* ) formatDateReturnDictionary: (NSString* )strDate;
- (NSString *)convertDatetimeToLocalWithFormatStyle:(NSString *)strDate format:(NSString *)format style:(NSDateFormatterStyle)style;
-(NSDictionary* )getTodayReturnDictionary;

//custom hud/progress
-(void) showCustomProgress;
-(void) hideCustomProgress;
@property (nonatomic, retain) UIWindow* window;

#pragma mark -
#pragma mark Popover methods
@property (nonatomic, strong) UIPopoverController* popover;
@property (nonatomic, assign) BOOL _shouldDismissOnBackgroundTouch;
@property (nonatomic, assign) BOOL _shouldDismissOnContentTouch;
@property (nonatomic, assign) BOOL _shouldDismissAfterDelay;

-(NSString *)dateDiff:(NSString *)origDate;
-(double)dateDiffBetweenTwoDates:(NSString *)strDate1 withDate2: (NSString* )strDate2;
-(NSString* ) createSubDirectoriesInPath: (nonnull NSString *)path;
-(nonnull UIImage* ) getInfoSapexLogo;
- (nonnull UIColor *)randomColor;
- (nullable NSString* )getMyPassword;
-(NSString* )sendDeviceToken : (NSString* ) strDeviceToken;
-(NSDictionary* )prepareBasicAuthenticationForLicenseServer;

- (void) showAlert : (NSString *)title message:(NSString *)msg;
- (void) showToast : (UIViewController *)__parent title:(NSString *)title message:(NSString *)msg;
- (void)showNotOnlineAlert;
@end
#endif /* CommonMethods_h */
