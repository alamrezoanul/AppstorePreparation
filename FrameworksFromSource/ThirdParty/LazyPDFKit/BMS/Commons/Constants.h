//
//  Constants.h
//  Boardmeeting
//
//  Created by InfoSapex on 1/3/17.
//  Copyright © 2017 InfoSapex Limited. All rights reserved.
//

//Linked
#ifndef Constants_h
#define Constants_h

//#define DEBUG 1
#define BMAPIPROTOCOL @"https"
#define JABBER_DOMAIN @"localhost"
//#define EXECUTE_DEVELOPER_CODE 1

#pragma mark -
#pragma mark Color Constants
#define kClearColor [UIColor clearColor]
#define kWhiteColor [UIColor whiteColor]
#define kGreenColor [UIColor greenColor]
#define kBlackColor [UIColor blackColor]
#define kGrayColor [UIColor grayColor]
#define kAgendaPageMainBackgroundColorHex [UIColor whiteColor]
#define kMainViewBackgroundColorHex 0xF9FAFB
#define kTopIconsColorHex 0xF1F1F1
#define kAgendaPageMeetingSectionBackgroundColorHex 0xECF1F5
#define kAgendaParticipantBorderColor 0xF1F4F7  
#define kGradientColor [UIColor colorWithRed: 0.051 green: 0.416 blue: 0.604 alpha: 1]
#define kOrangeColor [UIColor orangeColor]
#define kRedColor [UIColor redColor]
#define kLabelBackgroundColor 0x01CCFE
#define kLabelTextColor 0xFFFFFF

#pragma mark - BMS Tab Index
#define kMeetingTabIndex 1
#define kNoticeTabIndex 7

#pragma mark -
#pragma mark Methods
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define kGradientColorArrayForHeaders [NSArray arrayWithObjects:(id) UIColorFromRGB(0x0d6a9a), (id) UIColorFromRGB(0x0d6a9a), nil]
#define _networkQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
#define mainQueue dispatch_get_main_queue()
#define highQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)

#pragma mark -
#pragma mark String and Number Constants
#define kTNRLMDB_Version 1
#define kTOONRealmDBExtension @"realm"
#define kPlatformType @"ios"
#define kEnterCompanyTextBoxPlaceHolderText @"Enter Company UID(e.g. 1587618556):"
#define kLicenseServerBaseURL @"http://10.160.72.57:8080" //@"http://182.160.114.45:8080"
#define kLicenseServerUserName @"riad@infosapex.com"
#define kLicenseServerPassword @"12345678"
#define kSavingCompanyUIDKey @"CurrentCompanyUid"
#define kLazyPDFKitBundleIdentifier @"com.lazyprogram.LazyPDFKit"
#define kYearPlannerAllMeetingCellText @"All Months"
#define SERVER_FOUND_TEXT @"{\"status\":\"You have found InfoSapex BoardMeeting\"}"
#define BMSNotificationName @"BMS_Notification"
#define CVNotificationName @"CastingVote_Notification"
#define ReloadMeetingNotificationName @"ReloadMeeting_Notification"
#define HandleMeetingNotificationName @"Handle_Notifications"
#define HandleRemoteWipe @"Handle_RemoteWipe"
#define ToastDuration 3.0
#define ToastActivityMaxDurationInSeconds 10.0
#define kMeetingMaxLimit 10000 //Meaning NO LIMIT

#pragma mark -
#pragma mark Paging related
#define PagingEnabled TRUE
#define kPagingEnabledNotice TRUE
#define PagingEnabledAgenda FALSE
#define PageRecordCount 10
#define kTopNoticeRecordCount 5
#define kPagingEnabledTopNotice TRUE
#define kPagingEnabledMeeting TRUE
#define kMeetingRecordCount 7
#define kNoticeRecordCount 5
#pragma mark -
#pragma mark Tags
#define kNoticeAlertMainView 246
#define kNoticeCommentTag 247
#define kNoticeResponseShareToAllTag 248
#define kCustomProgressTag 249

#define kLoadingCellTag 250
#define kInternetIndicatorTag 251
#define kPollChartViewTag 252
#define DocumentsDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#endif /* Constants_h */
