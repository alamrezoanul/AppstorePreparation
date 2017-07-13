//
//  AppUtility.m
//  Boardmeeting
//
//  Created by InfoSapex on 10/17/16.
//  Copyright © 2016 InfoSapex Limited. All rights reserved.
//

#import "AppUtility.h"

@implementation AppUtility
{
	
}

-(id)initWithParent : (UIViewController *) __parent
{
	self = [super initWithParent:__parent];
	
	if( self )
	{
				
		NSLog(@"AppUtility initWithParent initialized: %@", self);
		self.parent = __parent;
		
	}
	
	return self;
}

//https://adobe.github.io/Spry/samples/data_region/JSONDataSetSample.html#Example1
-(NSString* ) getRealmDBPath : (NSString* ) strRealmScope
{
	//BOOL nullYES = [super isNULL:strCompanyUID];
		
	NSString* strNamePrefix = @"data";
	
	NSString *libraryDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject]; //[[NSBundle mainBundle] bundlePath];
	NSString* strPath =[NSString stringWithFormat:@"%@/DB_Realm/%@-%@.%@",
					 libraryDirectory,
					 strNamePrefix,
					 strRealmScope,
					 kTOONRealmDBExtension];
	
	return strPath;
}

-(RLMRealmConfiguration*) getRealmConfigurationForPath : (NSString* ) strPath
{
	RLMRealmConfiguration* realmConfiguration = [[RLMRealmConfiguration alloc] init];
	
	NSURL* ru = [NSURL URLWithString:strPath];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:[strPath stringByDeletingLastPathComponent] ])
	{
		NSError* error = nil;
		BOOL successBool= [[NSFileManager defaultManager] createDirectoryAtPath:[strPath stringByDeletingLastPathComponent]
								  withIntermediateDirectories:YES
												   attributes:nil
														error:&error];
		
		NSLog(@"%i", successBool);
	}
	realmConfiguration.fileURL = ru;
	NSLog(@"------------realm path: %@",strPath );
	realmConfiguration.schemaVersion = kTNRLMDB_Version;
	//realmConfiguration.readOnly = NO;
	return realmConfiguration;
}

-(RLMRealmConfiguration* ) getCurrentContextRealmConfiguration
{
	
	NSString* strPath = [self getRealmDBPath: @"defecto"]; // aka default
	
	return [self getRealmConfigurationForPath:strPath];
}

-(RLMRealm *)getAndBeginWriteTransaction : (BOOL) begin
{
	RLMRealm *realm = nil;
	@try
	{
		RLMRealmConfiguration* realmConfiguration = [self getCurrentContextRealmConfiguration];
		NSError* rlmError;
		realm = [RLMRealm realmWithConfiguration:realmConfiguration error:&rlmError];
        
        if( begin )
        {
            if( ![realm inWriteTransaction] )
            {
                [realm beginWriteTransaction];
            }
        }
	}
	@catch (NSException *exception)
	{
		NSLog(@"Exception: %@", [exception callStackSymbols]);
	}
	
	return realm;
}
-(void)commitWriteTransaction : (RLMRealm *)__realm
{
	if( __realm && [__realm inWriteTransaction] )
	{
		NSError *error= nil;
		BOOL status = [__realm commitWriteTransaction:&error];
		//[realm commitWriteTransaction];
		NSLog(@"realm commit status: %d", status);
		//[realm invalidate];
		//[realm release];
		//[realm dealloc];
		//realm = nil;
		
	}
}


- (RLMResults *) saveAndLoadToRealmResultsFromArray : (NSArray *) arr forKey: (NSString *) strObjectType
{
    if( [[strObjectType uppercaseString] isEqualToString:@"COLOR"] )
    {
        NSInteger i = 1;
        for( NSDictionary *adict in arr )
        {
            NSDictionary *adictwithPK = @{
                                          @"id" : [NSString stringWithFormat:@"%ld", i++],
                                          @"color" : [adict objectForKey:@"color"],
                                          @"value" : [adict objectForKey:@"value"]
                                          };
            [self saveAndLoadToColorTableFromDictionary:adictwithPK];
        }
        
        RLMRealm *realm = [self getAndBeginWriteTransaction : NO];
        RLMResults *colors = [ColorDataTable allObjectsInRealm:realm];
        
        return colors;
    }
    
    return nil;
}
- (ColorDataTable* ) saveAndLoadToColorTableFromDictionary : (NSDictionary* ) aColorDict
{
	ColorDataTable *aColorTbl = [[ColorDataTable alloc] init];
	@try {
		
		// Start : Save Data into Realm
        RLMRealm *realm = [self getAndBeginWriteTransaction : YES];
        aColorTbl.id = [[aColorDict objectForKey:@"id"] intValue];
        aColorTbl.color = [aColorDict objectForKeyedSubscript:@"color"];
        aColorTbl.value = [aColorDict objectForKeyedSubscript:@"value"];
        
        [realm addOrUpdateObject:aColorTbl];
		[self commitWriteTransaction: realm];
		// End : Save Data into Realm
		
	} @catch (NSException *exception) {
		NSLog(@"Error on getMeetingFromServer: %@", [exception callStackSymbols]);
	}
	
	return aColorTbl;
}

- (NSString *) formatSize:(float)size
{
	return [NSString stringWithFormat:@"%0.3f", size];
}

- (void) forceACrash
{
    [[Crashlytics sharedInstance] crash];
}
@end
