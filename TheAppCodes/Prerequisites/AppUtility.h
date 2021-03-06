//
//  AppUtility.h
//  AppstorePreparation
//
//  Created by InfoSapex on 10/17/16.
//  Copyright © 2016 InfoSapex Limited. All rights reserved.
//
#import <AudioToolbox/AudioServices.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <Realm/Realm.h>
#import "ColorDataTable.h"

#import "LazyPDFKit/HeadersExposedFromLazyPDFKit.h"

#import <Crashlytics/Crashlytics.h>

@interface AppUtility : CommonMethods
{
	
	RLMResults *tableDataArray;
	
}

@property (nonatomic, retain) UIViewController *parent;

-(RLMRealm *)getAndBeginWriteTransaction : (BOOL) begin;
-(void)commitWriteTransaction : (RLMRealm *)realm;

- (RLMResults *) saveAndLoadToRealmResultsFromArray : (NSArray *) arr forKey: (NSString *) strObjectType;

- (void) forceACrash;
@end
