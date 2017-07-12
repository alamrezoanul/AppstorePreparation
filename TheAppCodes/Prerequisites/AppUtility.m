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
-(NSString* ) getRealmDBPath : (NSString* ) strCompanyUID
{
	BOOL nullYES = [super isNULL:strCompanyUID];
	
	if( nullYES || [strCompanyUID length] < 1 )
	{
		CompanyTable* aCompanyTbl = [self getActiveCompanyTable];
		strCompanyUID = aCompanyTbl.uid;
	}
	NSString* strNamePrefix = @"data";
	
	NSString *libraryDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject]; //[[NSBundle mainBundle] bundlePath];
	NSString* strPath =[NSString stringWithFormat:@"%@/DB_Realm/%@-%@.%@",
					 libraryDirectory,
					 strNamePrefix,
					 strCompanyUID,
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

-(RLMRealmConfiguration* ) getCurrentCompanyRealmConfiguration
{
	
	NSString* strPath = [self getRealmDBPath: nil];
	
	return [self getRealmConfigurationForPath:strPath];
}

-(RLMRealm *)getAndBeginWriteTransaction
{
	RLMRealm *realm = nil;
	@try
	{
		RLMRealmConfiguration* realmConfiguration = [self getCurrentCompanyRealmConfiguration];
		NSError* rlmError;
		realm = [RLMRealm realmWithConfiguration:realmConfiguration error:&rlmError];
		if( ![realm inWriteTransaction] )
		{
			[realm beginWriteTransaction];
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
-(RLMRealm *)getAndBeginWriteTransactionOfDefaultRealm
{
	RLMRealm *realm = nil;
	@try
	{
		NSString* strPath = [self getRealmDBPath:@"default"];
		RLMRealmConfiguration* realmConfiguration = [self getRealmConfigurationForPath:strPath];
		NSError* rlmError;
		realm = [RLMRealm realmWithConfiguration:realmConfiguration error:&rlmError];
		
		if( ![realm inWriteTransaction] )
		{
			[realm beginWriteTransaction];
		}
		
	}
	@catch (NSException *exception)
	{
		NSLog(@"Exception: %@", [exception callStackSymbols]);
	}
	
	return realm;
}
-(void)commitWriteTransactionOfDefaultRealm : (RLMRealm *)__realm
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
-(NSDictionary* )getAMeetingDictFromServer: (NSString* ) strMeetingId
{
	if( [self connectedToInternet] == NO )
	{
		return nil;
	}
	
	
	//Start Get the meeting details here
	NSString *strUrl = [NSString stringWithFormat:@"%@/api/meeting/id/%@?token=%@",self.serverIpOrDomain, strMeetingId, self.Token];
	NSLog(@"Single Meeting Url: %@", strUrl);
	
	NSString *messageString = [self getData:strUrl];
#ifdef SHOWLOG
	NSLog(@"messageString: %@", messageString);
#endif
	NSMutableDictionary *dict=[NSJSONSerialization JSONObjectWithData:[messageString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
	
#ifdef SHOWLOG
	NSLog(@"dict data: %@", dict);
#endif
	NSDictionary *aMeetingDict = [[dict objectForKey:@"data"]  mutableCopy];
#ifdef SHOWLOG
	NSLog(@"aMeetingDict: %@", aMeetingDict);
#endif
	
	BOOL nullYES = [self isNULL:aMeetingDict];
	if( nullYES )
	{
		return nil;
	}
	
	return aMeetingDict;
}
-(MeetingTable *) getMeetingFromServer:(NSString *)strMetingId
{
	
	if( [self connectedToInternet] == NO )
	{
		RLMRealm* realm = [self getAndBeginWriteTransaction];
		NSString* strQry = [NSString stringWithFormat:@"id == '%@'", strMetingId];
		tableDataArray = [MeetingTable objectsInRealm:realm where:strQry];
		if( [tableDataArray count] > 0 )
		{
			return tableDataArray[0];
		}
		else
		{
			return nil;
		}
	}
	
	NSDictionary* aMeetingDict = [self getAMeetingDictFromServer:strMetingId];
	
	BOOL nullYES = [super isNULL:aMeetingDict];
	if( nullYES )
	{
		return nil;
		
	}
	
	MeetingTable* aMeetingTbl = [self loadToMeetingTableFromDictionary: aMeetingDict];
	return aMeetingTbl;
}

- (MeetingTable* ) loadToMeetingTableFromDictionary : (NSDictionary* ) aMeetingDict
{
	MeetingTable *aMeetingL = [[MeetingTable alloc] init];
	@try {
		
		// Start : Save Data into Realm
		RLMRealm *realm = [self getAndBeginWriteTransaction];
		
		aMeetingL.id = [NSString stringWithFormat:@"%i", [[aMeetingDict objectForKey:@"id"] intValue]];
		aMeetingL.committee_id = [NSString stringWithFormat:@"%i",[[aMeetingDict objectForKey:@"committee_id"] intValue]];
		aMeetingL.title = [aMeetingDict objectForKey:@"title"];
		aMeetingL.desc = [aMeetingDict objectForKey:@"description"];
		aMeetingL.meeting_acceptance_status = [aMeetingDict objectForKey:@"meeting_acceptance_status"];
		NSString* str_publish_date = [aMeetingDict objectForKey:@"published_at"];
		aMeetingL.published_at = [self isNULL:str_publish_date]?nil:str_publish_date;
		NSString* strStartDateTemp = [aMeetingDict objectForKey:@"start"];
		aMeetingL.startTime = strStartDateTemp;
		NSDate* dtStartDateTemp = [super convertDatetimeToUTCDateTime:strStartDateTemp];
		aMeetingL.startTimeInterval = [dtStartDateTemp timeIntervalSince1970];
		
		NSString* strEndDateTemp = [aMeetingDict objectForKey:@"finish"];
		aMeetingL.finishTime = strEndDateTemp;
		
		aMeetingL.started_at = [self isNULL:[aMeetingDict objectForKey:@"started_at"]]?nil:[aMeetingDict objectForKey:@"started_at"];
		aMeetingL.finished_at = [self isNULL:[aMeetingDict objectForKey:@"finished_at"]]?nil:[aMeetingDict objectForKey:@"finished_at"];
		NSDictionary *acommittee = [aMeetingDict objectForKey:@"committee"];
		aMeetingL.committee_title = [acommittee objectForKey:@"title"];
		aMeetingL.total_accepted  = [NSString stringWithFormat:@"%i",[[aMeetingDict objectForKey:@"total_accepted"] intValue]];
		aMeetingL.total_invited = [NSString stringWithFormat:@"%i", [[aMeetingDict objectForKey:@"total_invited"] intValue]];
		aMeetingL.attendanceStatus = [aMeetingDict objectForKey:@"attendance"];
		aMeetingL.status = [aMeetingDict objectForKey:@"status"];
		
		
		
		NSDictionary *afilepack = [aMeetingDict objectForKey:@"file_pack"];
		aMeetingL.file_pack_id = [NSString stringWithFormat:@"%i", [[afilepack objectForKey:@"id"] intValue]];
		
		[realm addOrUpdateObject:aMeetingL];
		
		//Start Get all responses from here
		NSString* strUrl = [NSString stringWithFormat:@"%@/api/meeting/member/response/%i?token=%@", self.serverIpOrDomain, [aMeetingL.id intValue], self.Token];
		NSString* msgString = [super getData:strUrl];
#ifdef SHOWLOG
		NSLog(@"msgString: %@", msgString);
#endif
		NSMutableDictionary *dict=[NSJSONSerialization JSONObjectWithData:[msgString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
		
#ifdef SHOWLOG
		NSLog(@"dict data: %@", dict);
#endif
		NSMutableArray* aMeetingResponses = [[dict objectForKey:@"data"]  mutableCopy];
#ifdef SHOWLOG
		NSLog(@"aMeetingResponses: %@", aMeetingResponses);
#endif
		//End Get all responses from here
		
		
		//Start : Add Participants here
		NSString* strQry = [NSString stringWithFormat:@"meeting_id == '%i'", [aMeetingL.id intValue]];
		tableDataArray = [MeetingParticipantTable objectsInRealm:realm where:strQry];
		[realm deleteObjects:tableDataArray];
		
		NSMutableArray *users_ = [aMeetingDict objectForKey:@"users"];
		for( NSDictionary* aDictUser in users_ )
		{
			MeetingParticipantTable* aMeetingPartcipantTbl = [[MeetingParticipantTable alloc] init];
			NSDictionary* aDictUserPivot = [aDictUser objectForKey:@"pivot"];
			
			NSString* strTemp = [NSString stringWithFormat:@"%i_%i", [[aDictUserPivot objectForKey:@"meeting_id"] intValue], [[aDictUserPivot objectForKey:@"user_id"] intValue]];
			aMeetingPartcipantTbl.id = strTemp;
			aMeetingPartcipantTbl.user_id = [NSString stringWithFormat:@"%i", [[aDictUserPivot objectForKey:@"user_id"] intValue]];
			aMeetingPartcipantTbl.meeting_id = [NSString stringWithFormat:@"%i", [[aDictUserPivot objectForKey:@"meeting_id"] intValue]];
			aMeetingPartcipantTbl.company_id = [NSString stringWithFormat:@"%i", [[aDictUser objectForKey:@"company_id"] intValue]];
			aMeetingPartcipantTbl.address = [aDictUser objectForKey:@"address"];
			aMeetingPartcipantTbl.avatar = [aDictUser objectForKey:@"avatar"];
			strTemp = [aDictUser objectForKey:@"created_at"];
			BOOL nullYES = [super isNULL:strTemp];
			strTemp = nullYES ? nil : strTemp;
			aMeetingPartcipantTbl.created_at = strTemp;
			strTemp = [aDictUser objectForKey:@"deleted_at"];
			nullYES = [super isNULL:strTemp];
			strTemp = nullYES ? nil : strTemp;
			aMeetingPartcipantTbl.deleted_at = strTemp;
			strTemp = [aDictUser objectForKey:@"updated_at"];
			nullYES = [super isNULL:strTemp];
			strTemp = nullYES ? nil : strTemp;
			aMeetingPartcipantTbl.deleted_at = strTemp;
			aMeetingPartcipantTbl.email = [aDictUser objectForKey:@"email"];
			aMeetingPartcipantTbl.first_name = [aDictUser objectForKey:@"first_name"];
			aMeetingPartcipantTbl.last_name = [aDictUser objectForKey:@"last_name"];
			strTemp = [aDictUser objectForKey:@"jabber_alias"];
			strTemp = [super isNULL:strTemp] ? nil: strTemp;
			aMeetingPartcipantTbl.jabber_alias = strTemp;
			aMeetingPartcipantTbl.name = [aDictUser objectForKey:@"name"];
			aMeetingPartcipantTbl.phone = [aDictUser objectForKey:@"phone"];
			strTemp = [aDictUserPivot objectForKey:@"accepted"];
			strTemp = [super isNULL:strTemp] ? nil : [NSString stringWithFormat:@"%i", [strTemp intValue]];
			aMeetingPartcipantTbl.accepted = strTemp;
			strTemp = [aDictUserPivot objectForKey:@"attendance"];
			strTemp = [super isNULL:strTemp] ? nil : strTemp;
			aMeetingPartcipantTbl.attendance = strTemp;
			strTemp = [aDictUserPivot objectForKey:@"downloaded"];
			strTemp = [super isNULL:strTemp] ? nil : [NSString stringWithFormat:@"%i", [strTemp intValue]];
			aMeetingPartcipantTbl.downloaded = strTemp;
			strTemp = [aDictUserPivot objectForKey:@"invited"];
			strTemp = [super isNULL:strTemp] ? nil : [NSString stringWithFormat:@"%i", [strTemp intValue]];
			aMeetingPartcipantTbl.invited = strTemp;
			strTemp = [aDictUserPivot objectForKey:@"rejected"];
			strTemp = [super isNULL:strTemp] ? nil : [NSString stringWithFormat:@"%i", [strTemp intValue]];
			aMeetingPartcipantTbl.rejected = strTemp;
			strTemp = [aDictUserPivot objectForKey:@"tentative"];
			strTemp = [super isNULL:strTemp] ? nil : [NSString stringWithFormat:@"%i", [strTemp intValue]];
			aMeetingPartcipantTbl.tentative = strTemp;
			
			NSString* result = nil;
			BOOL nullYESAccepted = [super isNULL:aMeetingPartcipantTbl.accepted];
			BOOL nullYESRejected = [super isNULL:aMeetingPartcipantTbl.rejected];
			BOOL nullYESTentative = [super isNULL:aMeetingPartcipantTbl.tentative];
			if( !nullYESAccepted && [aMeetingPartcipantTbl.accepted isEqualToString:@"1"] )
			{
				result = @"Accepted";
			}
			else if( !nullYESRejected && [aMeetingPartcipantTbl.rejected isEqualToString:@"1"] )
			{
				result = @"Rejected";
			}
			else if( !nullYESTentative && [aMeetingPartcipantTbl.tentative isEqualToString:@"1"] )
			{
				result = @"Tentative";
			}
			else
			{
				result = @"Invited";
			}
			aMeetingPartcipantTbl.members_response = result;
			
			 NSString *strAvatar = [NSString stringWithFormat: @"%@/api/user/avatar/%@", self.serverIpOrDomain, aMeetingPartcipantTbl.user_id];
			 strAvatar = [NSString stringWithFormat:@"%@?token=%@",strAvatar, self.Token];
			 NSLog(@"strAvatar : %@", strAvatar);
			 
			 NSData* avatarData = [NSData dataWithContentsOfURL:[NSURL URLWithString:strAvatar]];
			 if( avatarData != nil )
			 {
				 aMeetingPartcipantTbl.avatarData = avatarData;
			 }
			
			
			strTemp = [aDictUser objectForKey:@"designation"];
			strTemp = [super isNULL:strTemp] || [strTemp length] == 0 ? nil : strTemp;
			aMeetingPartcipantTbl.designation = strTemp;
			
			NSPredicate* pred = [NSPredicate predicateWithFormat:@"uid == %i", [aMeetingPartcipantTbl.user_id intValue]];
			NSArray* responses = [aMeetingResponses filteredArrayUsingPredicate:pred];
			NSDictionary* aDictResponse = responses[0];
			strTemp = [aDictResponse objectForKey:@"reason"];
			strTemp = [super isNULL:strTemp] ? nil : strTemp;
			//strTemp = [strTemp isEqualToString:@"N/A"] ? nil : strTemp;
			aMeetingPartcipantTbl.response_comment = strTemp;
			
			[realm addOrUpdateObject:aMeetingPartcipantTbl];
		}
		//End : Add Participants here
		
		
		[self commitWriteTransaction: realm];
		// End : Save Data into Realm
		
	} @catch (NSException *exception) {
		NSLog(@"Error on getMeetingFromServer: %@", [exception callStackSymbols]);
	}
	
	return aMeetingL;
}

- (PollTable *) getPollFromServer : (NSString *) __polId
{
	PollTable *pollTbl = nil;
	
	NSDictionary *apollDict = [super getPollDictFromServer : __polId];
	
	if( apollDict != nil )
	{
		pollTbl = [self loadToPollTableFromDictionary:apollDict];
		
		RLMRealm *realm = [self getAndBeginWriteTransaction];
		[realm addOrUpdateObject:pollTbl];
		[self commitWriteTransaction:realm];
	}
	
	return pollTbl;
}

- (PollTable *) loadToPollTableFromDictionary : (NSDictionary *) apoll
{
	
	PollTable *pollTbl = [[PollTable alloc] init];
	
	pollTbl.id = [NSString stringWithFormat:@"%i",[[apoll objectForKey:@"id"] intValue]];
	pollTbl.meeting_id = [NSString stringWithFormat:@"%i",[[apoll objectForKey:@"meeting_id"] intValue]];
	
	pollTbl.agenda_id = [NSString stringWithFormat:@"%i",[[apoll objectForKey:@"agenda_id"] intValue]];
	pollTbl.proposal_id =[NSString stringWithFormat:@"%i",[[apoll objectForKey:@"proposal_id"] intValue]];
	pollTbl.circular_id = [ NSString stringWithFormat:@"%i",[[apoll objectForKey:@"circular_id"] intValue]];
	
	pollTbl.title = [apoll objectForKey:@"title"];
	pollTbl.desc = [apoll objectForKey:@"description"];
	pollTbl.weight = [ NSString stringWithFormat:@"%i",[[apoll objectForKey:@"weight"] intValue]];
	pollTbl.status = [apoll objectForKey:@"status"];
	
	pollTbl.created_at = [apoll objectForKey:@"created_at"];
	pollTbl.updated_at = [apoll objectForKey:@"updated_at"];
	pollTbl.deleted_at = [apoll objectForKey:@"deleted_at"];
	
	
	NSMutableArray *results_ = [apoll objectForKey:@"result"];
	for(NSDictionary *aresult in results_)
	{
		ResultTable *resultTbl = [[ResultTable alloc] init];
		
		
		resultTbl.poll_option_id =[NSString stringWithFormat:@"%i",[[aresult objectForKey:@"poll_option_id"] intValue]];
		
		resultTbl.option_label = [aresult objectForKey:@"option_label"];
		resultTbl.totalcount = [NSString stringWithFormat:@"%i", [[aresult objectForKey:@"count"] intValue]];
		resultTbl.type = [aresult objectForKey:@"type"];
		
		[pollTbl.results addObject:resultTbl];
	}
	NSMutableArray *decisions_ = [apoll objectForKey:@"decision"];
	for(NSDictionary *adecision in decisions_)
	{
		DecisionTable *decisionTbl = [[DecisionTable alloc] init];
		
		
		decisionTbl.user_id = [NSString stringWithFormat:@"%i", [[adecision objectForKey:@"user_id"] intValue]];
		
		decisionTbl.poll_id = [NSString stringWithFormat:@"%i", [[adecision objectForKey:@"poll_id"] intValue]];
		decisionTbl.poll_option_id = [NSString stringWithFormat:@"%i", [[adecision objectForKey:@"poll_option_id"] intValue]];
		
		[pollTbl.decisions addObject:decisionTbl];
	}
	
	NSMutableArray *options_ = [apoll objectForKey:@"options"];
	for(NSDictionary *aoption in options_)
	{
		OptionsTable *optionTbl = [[OptionsTable alloc] init];
		
		optionTbl.id = [NSString stringWithFormat:@"%i",[[aoption objectForKey:@"id"] intValue]];
		optionTbl.poll_id = [NSString stringWithFormat:@"%i",[[aoption objectForKey:@"poll_id"] intValue]];
		
		optionTbl.option_label = [aoption objectForKey:@"option_label"];
		optionTbl.option_value = [NSString stringWithFormat:@"%i",[[aoption objectForKey:@"option_value"] intValue]];
		
		optionTbl.weight = [NSString stringWithFormat:@"%i",[[aoption objectForKey:@"weight"] intValue]];
		optionTbl.created_at = [aoption objectForKey:@"created_at"];
		optionTbl.updated_at = [aoption objectForKey:@"updated_at"];
		optionTbl.deleted_at = [aoption objectForKey:@"deleted_at"];
		
		[pollTbl.options addObject:optionTbl];
	}
	
	return pollTbl;
}

- (RLMResults* ) loadToCommitteeTableFromArray : (NSMutableArray *) committeeListArr_
{
	RLMResults* allResults = nil;
	RLMRealm* realm = [self getAndBeginWriteTransaction];
	tableDataArray = [CommitteeTable allObjectsInRealm:realm];
	[realm deleteObjects:tableDataArray];
	for( NSDictionary* aDictCommittee in committeeListArr_ )
	{
		CommitteeTable* aCommitteeTbl = [[CommitteeTable alloc] init];
		aCommitteeTbl.id = [NSString stringWithFormat:@"%i",[[aDictCommittee objectForKey:@"id"] intValue]];
		aCommitteeTbl.title= [aDictCommittee objectForKey:@"title"];
		aCommitteeTbl.desc = [aDictCommittee objectForKey:@"description"];
		aCommitteeTbl.status = [aDictCommittee objectForKey:@"status"];
		aCommitteeTbl.created_at = [aDictCommittee objectForKey:@"created_at"];
		aCommitteeTbl.updated_at = [aDictCommittee objectForKey:@"updated_at"];
		aCommitteeTbl.deleted_at = [aDictCommittee objectForKey:@"deleted_at"];
		
		NSMutableArray *committee_users_ = [aDictCommittee objectForKey:@"users"];
		NSInteger member_count = [super isNULL:committee_users_] ? 0 : [committee_users_ count];
		aCommitteeTbl.member_count = [NSString stringWithFormat:@"%li", member_count];
		
		[realm addOrUpdateObject:aCommitteeTbl];
	}
	[self commitWriteTransaction:realm];
	
	allResults = [CommitteeTable allObjectsInRealm:realm];
	
	return allResults;
}

-(RLMResults* ) getMeetingRealmObjectsOfTheDay : (NSString* ) paramStrDate
{
	NSString* strStartDate = [self convertToUTC: [NSString stringWithFormat:@"%@ 00:00:00",paramStrDate]];
	NSString* strEndDate = [self convertToUTC: [NSString stringWithFormat:@"%@ 23:59:59",paramStrDate]];
	
	NSDate* dtUTCStartDate = [self convertDatetimeToUTCDateTime:strStartDate];
	NSDate* dtUTCEndDate = [self convertDatetimeToUTCDateTime:strEndDate];
	NSString* strQry = [NSString stringWithFormat:@"startTimeInterval BETWEEN {%f, %f}", [dtUTCStartDate timeIntervalSince1970], [dtUTCEndDate timeIntervalSince1970]];
	
	RLMRealm* realm = [self getAndBeginWriteTransaction];
	RLMResults* tableDataArrayLocal = [MeetingTable objectsInRealm:realm where:strQry];
	[self commitWriteTransaction:realm];
	
	return tableDataArrayLocal;
}
-(void) resetPaging :(NSDictionary* )aDict
{
	BOOL isConnectedToInternet = [self connectedToInternet];
	NSString* strType = [aDict objectForKey:@"type"];
	RLMRealm *realm = [self getAndBeginWriteTransaction];
	@try
	{
		
		self.totalPages = 0;
		self.totalItems = 0;
		self.skipRow = 0;
		self.currentPage = 0;
		self.pageSize = PageRecordCount;
		self.loading = FALSE;
		
		if( strType != nil && [strType isEqualToString:@"meeting"] && isConnectedToInternet )
		{
			self.currentPage = 1;
			self.pageSize = kMeetingRecordCount;
			NSString* paramStrDate = [aDict objectForKey:@"strDate"];
			BOOL nullYES = [self isNULL:paramStrDate];
			if( nullYES || [paramStrDate length] == 0 )
			{
				tableDataArray = [MeetingTable allObjectsInRealm:realm];
			}
			else
			{
				tableDataArray = [self getMeetingRealmObjectsOfTheDay:paramStrDate];
			}
			
			[realm deleteObjects:tableDataArray];
		}
		else if( strType != nil && [strType isEqualToString:@"notice"] && isConnectedToInternet )
		{
			self.pageSize = kNoticeRecordCount;
			tableDataArray = [CorrespondenceTable allObjectsInRealm:realm];
			[realm deleteObjects:tableDataArray];
		}
		else if( strType != nil && [strType isEqualToString:@"top_notice"] && isConnectedToInternet  )
		{
			self.pageSize = kTopNoticeRecordCount;
			tableDataArray = [TopNoticeTable allObjectsInRealm:realm];
			[realm deleteObjects:tableDataArray];
		}
	}
	@catch( NSException* ex)
	{
		NSLog(@"In Method AppUtility.resetPaging==>Exception: %@", [ex callStackSymbols]);
	}
	[self commitWriteTransaction:realm];
	
	NSLog(@"in resetPaging==>self.pageSize: %ld", self.pageSize);
}

-(RLMResults*) loadIntoRealmWhenPaging : (NSString *) strType withDictionary:(NSDictionary* ) aDictContainer
{
	
	NSString* strQry = nil;
	RLMResults* allResults = nil;
	if( strType != nil && [strType isEqualToString:@"meeting"] )
	{
		
		NSDictionary* aDictTemp = [aDictContainer objectForKey:@"meetingDict"];
		NSMutableArray* allMeeting_ = [aDictTemp objectForKey:@"retArray"];
		NSLog(@"All Meetings: %@", allMeeting_);
		
		// Start : Save Data into Realm
		for(NSDictionary *aMeetingDict in allMeeting_)
		{
			[self loadToMeetingTableFromDictionary:aMeetingDict];
		}
		// End : Save Data into Realm
		
		NSString* strDateLocal = [aDictContainer objectForKey:@"strDate"];
		BOOL nullYES = [super isNULL:strDateLocal];
		if( nullYES )
		{
			RLMRealm* realm = [self getAndBeginWriteTransaction];
			allResults = [MeetingTable allObjectsInRealm:realm];
			[self commitWriteTransaction:realm];
		}
		else
		{
			allResults = [self getMeetingRealmObjectsOfTheDay:strDateLocal];
		}
	}
	else if( strType != nil && [strType isEqualToString:@"agenda"] )
	{
		@try
		{
			
			NSString* strMeetingId = [aDictContainer objectForKey:@"str_meeting_id"]; //1
			//NSString* file_pack_id = [aDictContainer objectForKey:@"file_pack_id"]; //2
			
			NSDictionary* aDictTemp = [aDictContainer objectForKey:@"agendaDict"];
			NSMutableArray *allAgenda_ = [aDictTemp objectForKey:@"retArray"]; //3
			
			
			NSLog(@"All Agenda: %@", allAgenda_);
			
			// Start : Save Data into Realm
			RLMRealm *realm = [self getAndBeginWriteTransaction];
			
			for(NSDictionary *aagenda in allAgenda_)
			{
				AgendaTable *agendaTbl = [[AgendaTable alloc] init];
				
				agendaTbl.id =[NSString stringWithFormat:@"%i",[[aagenda objectForKey:@"id"] intValue]];
				agendaTbl.meeting_id = [NSString stringWithFormat:@"%@", strMeetingId];
				
				agendaTbl.serial_no = [aagenda objectForKey:@"serial_no"];
				
				agendaTbl.title= [aagenda objectForKey:@"title"];
				agendaTbl.desc = [aagenda objectForKey:@"description"];
				agendaTbl.parent_id = [aagenda objectForKey:@"parent_id"];
				agendaTbl.start = [aagenda objectForKey:@"start"];
				agendaTbl.finish = [aagenda objectForKey:@"finish"];
				agendaTbl.weight = [NSString stringWithFormat:@"%i",[[aagenda objectForKey:@"weight"] intValue]];
				
				agendaTbl.created_at  = [aagenda objectForKey:@"created_at"];
				agendaTbl.updated_at = [aagenda objectForKey:@"updated_at"];
				agendaTbl.deleted_at = [aagenda objectForKey:@"deleted_at"];
				
				BOOL nullYes = FALSE;
				NSString *strFieldValue = ([[aagenda objectForKey:@"deferred_from"] respondsToSelector:@selector(intValue)]) ? [NSString stringWithFormat:@"%i", [[aagenda objectForKey:@"deferred_from"] intValue]] : @"<null>";
				
				nullYes = [self isNULL:strFieldValue];
				if( nullYes )
				{
					agendaTbl.deferred_from = nil;
				}
				else
				{
					agendaTbl.deferred_from = strFieldValue;
				}
				agendaTbl.to_be_deferred = [NSString stringWithFormat:@"%i", [[aagenda objectForKey:@"to_be_deferred"] intValue]];
				
				strFieldValue = [aagenda objectForKey:@"to_be_deferred_at"];
				nullYes = [self isNULL:strFieldValue];
				if( nullYes )
				{
					agendaTbl.to_be_deferred_at = nil;
				}
				else
				{
					agendaTbl.to_be_deferred_at = [self convertDatetimeToLocal:strFieldValue];
				}
				
				agendaTbl.deferred = [NSString stringWithFormat:@"%i", [[aagenda objectForKey:@"deferred"] intValue]];
				
				strFieldValue = [aagenda objectForKey:@"deferred_at"];
				nullYes = [self isNULL:strFieldValue];
				if( nullYes )
				{
					agendaTbl.deferred_at = nil;
				}
				else
				{
					agendaTbl.deferred_at = [self convertDatetimeToLocal:strFieldValue];
				}
				
				NSMutableArray* owners_ = [aagenda objectForKey:@"owner"];
				for(NSDictionary *anowner in owners_)
				{
					OwnerTable *ownerTbl = [[OwnerTable alloc] init];
					
					ownerTbl.id = [NSString stringWithFormat:@"%i",[[anowner objectForKey:@"id"] intValue]];
					
					NSDictionary* owner_pivot_dict = [anowner objectForKey:@"pivot"];
					ownerTbl.agenda_id = [NSString stringWithFormat:@"%i", [[owner_pivot_dict objectForKey:@"agenda_id"] intValue]];
					ownerTbl.user_id = [NSString stringWithFormat:@"%i", [[owner_pivot_dict objectForKey:@"user_id"] intValue]];
					
					ownerTbl.name = [anowner objectForKey:@"name"];
					ownerTbl.first_name = [anowner objectForKey:@"first_name"];
					ownerTbl.last_name = [anowner objectForKey:@"last_name"];
					ownerTbl.email = [anowner objectForKey:@"email"];
					ownerTbl.phone = [anowner objectForKey:@"phone"];
					ownerTbl.address = [anowner objectForKey:@"address"];
					ownerTbl.avatar = [anowner objectForKey:@"avatar"];
					ownerTbl.created_at = [anowner objectForKey:@"created_at"];
					ownerTbl.updated_at = [anowner objectForKey:@"updated_at"];
					ownerTbl.deleted_at = [anowner objectForKey:@"deleted_at"];
					
					[agendaTbl.owners addObject:ownerTbl];
					[realm addOrUpdateObject:ownerTbl];
				}
				
				NSMutableArray* files_ = [aagenda objectForKey:@"files"];
				
				for(NSDictionary *afile in files_)
				{
					FilesTable *fileTbl = [[FilesTable alloc] init];
					
					fileTbl.id = [NSString stringWithFormat:@"%i",[[afile objectForKey:@"id"] intValue]];
					fileTbl.title = [afile objectForKey:@"title"];
					
					fileTbl.desc = [afile objectForKey:@"description"];
					fileTbl.location = [afile objectForKey:@"location"];
					fileTbl.file_pack_id = [NSString stringWithFormat:@"%i",[[afile objectForKey:@"file_pack_id"] intValue]];
					fileTbl.weight = [NSString stringWithFormat:@"%i",[[afile objectForKey:@"weight"] intValue]];
					fileTbl.original_name = [afile objectForKey:@"original_name"];
					fileTbl.extension = [afile objectForKey:@"extension"];
					fileTbl.mime_type = [afile objectForKey:@"mime_type"];
					fileTbl.size = [NSString stringWithFormat:@"%i",[[afile objectForKey:@"size"] intValue]];
					fileTbl.created_at = [afile objectForKey:@"created_at"];
					fileTbl.updated_at = [afile objectForKey:@"updated_at"];
					fileTbl.deleted_at = [afile objectForKey:@"deleted_at"];
					
					AgendaTable2 *agendaTbl2 = [[AgendaTable2 alloc] init];
					agendaTbl2.id = [NSString stringWithFormat:@"%i", [agendaTbl.id intValue]];
					agendaTbl2.serial_no = agendaTbl.serial_no;
					
					
					[fileTbl.agendas addObject:agendaTbl2];
					NSLog(@"fileTbl: %@", [fileTbl description]);
					
					[agendaTbl.files addObject:fileTbl];
					[realm addOrUpdateObject:fileTbl];
				}
				
				
				// Start : Poll
				NSMutableArray* polls_ = [aagenda objectForKey:@"polls"];
				strQry = [NSString stringWithFormat:@"agenda_id == '%@'", agendaTbl.id];
				tableDataArray = [PollTable objectsInRealm:realm where:strQry];
				[realm deleteObjects:tableDataArray];
				for(NSDictionary *apoll in polls_)
				{
					
					PollTable *pollTbl = [self loadToPollTableFromDictionary:apoll];
					
					
					[agendaTbl.polls addObject:pollTbl];
					
					[realm addOrUpdateObject:pollTbl];
				}
				
				// End : Poll
				
				NSLog(@"agendaTbl description: %@", [agendaTbl description]);
				[realm addOrUpdateObject:agendaTbl];
			}
			
			
			[self commitWriteTransaction:realm];
			// End : Save Data into Realm
			
			
			strQry = [NSString stringWithFormat:@"meeting_id == '%@'", strMeetingId];
			allResults = [AgendaTable objectsInRealm:realm where:strQry];
			NSLog(@"allAgenda description: %@", [allResults description]);
			
		}
		@catch( NSException *e)
		{
			NSLog(@"Exception: %@", e);
			NSLog(@"Exception StackTrace: %@", [e callStackSymbols]);
		}
	}
	else if( strType != nil && [strType isEqualToString:@"top_notice"] )
	{
		
		NSMutableArray *allnotice_ = [aDictContainer objectForKey:@"retArray"]; //2
		
#ifdef SHOWLOG
		NSLog(@"allnotice_: %@", allnotice_);
#endif
		
		RLMRealm *realm = [self getAndBeginWriteTransaction];
		@try
		{
			// Start : Save Data into Realm
			for(NSDictionary *aDictNotice in allnotice_)
			{
				TopNoticeTable* aNoticeTbl = [[TopNoticeTable alloc] init];
				
				aNoticeTbl.id = [NSString stringWithFormat:@"%i",[[aDictNotice objectForKey:@"id"] intValue]];
				aNoticeTbl.title= [aDictNotice objectForKey:@"title"];
				aNoticeTbl.ref_no = [aDictNotice objectForKey:@"reference_no"];
				aNoticeTbl.priority = [aDictNotice objectForKey:@"priority"];
				aNoticeTbl.desc = [aDictNotice objectForKey:@"description"];
				aNoticeTbl.company_id = [NSString stringWithFormat:@"%i", [[aDictNotice objectForKey:@"company_id"] intValue]];
				aNoticeTbl.status = [aDictNotice objectForKey:@"status"];
				
				NSDictionary *pivot = [aDictNotice objectForKey:@"pivot"];
#ifdef SHOWLOG
				NSLog(@"topcorrespondence.pivot: %@", pivot);
#endif
				NSString *viewed = [NSString stringWithFormat:@"%i",[[pivot objectForKey:@"viewed"] intValue]];
#ifdef SHOWLOG
				NSLog(@"topcorrespondence.pivot.viewed: %@", viewed);
#endif
				
				aNoticeTbl.viewed = viewed;
				
				aNoticeTbl.response_required = [NSString stringWithFormat:@"%i",[[aDictNotice objectForKey:@"response_required"] intValue]];
				aNoticeTbl.response_given = [NSString stringWithFormat:@"%i",[[aDictNotice objectForKey:@"response_given"] intValue]];
				aNoticeTbl.issued_at = [aDictNotice objectForKey:@"issued_at"];
				aNoticeTbl.expired_at = [aDictNotice objectForKey:@"expired_at"];
				aNoticeTbl.created_at = [aDictNotice objectForKey:@"created_at"];
				aNoticeTbl.updated_at = [aDictNotice objectForKey:@"updated_at"];
				aNoticeTbl.deleted_at = [aDictNotice objectForKey:@"deleted_at"];
				
				[realm addOrUpdateObject:aNoticeTbl];
			}
			
			
			[self commitWriteTransaction:realm];
			// End : Save Data into Realm
		}
		@catch( NSException *exception)
		{
			[self commitWriteTransaction:realm];
			NSLog(@"Uncaught exception %@", exception);
			NSLog(@"Stack trace: %@", [exception callStackSymbols]);
		}
		
		allResults = [TopNoticeTable allObjectsInRealm:realm];
		
#ifdef SHOWLOG
		NSLog(@"allResults aka TopNotice description: %@", [allResults description]);
#endif
		
	}
	else if( strType != nil && [strType isEqualToString:@"notice"] )
	{
		
		NSMutableArray *allcorrespondence_ = [aDictContainer objectForKey:@"retArray"]; //2
		
#ifdef SHOWLOG
		NSLog(@"allcorrespondence_: %@", allcorrespondence_);
#endif
		
		RLMRealm *realm = [self getAndBeginWriteTransaction];
		@try
		{
			// Start : Save Data into Realm
			for(NSDictionary *acorrespondence in allcorrespondence_)
			{
				CorrespondenceTable *correspondenceTbl = [[CorrespondenceTable alloc] init];
				
				correspondenceTbl.id = [NSString stringWithFormat:@"%i",[[acorrespondence objectForKey:@"id"] intValue]];
				correspondenceTbl.title= [acorrespondence objectForKey:@"title"];
				correspondenceTbl.ref_no = [acorrespondence objectForKey:@"reference_no"];
				correspondenceTbl.priority = [acorrespondence objectForKey:@"priority"];
				correspondenceTbl.desc = [acorrespondence objectForKey:@"description"];
				correspondenceTbl.company_id = [acorrespondence objectForKey:@"company_id"];
				correspondenceTbl.status = [acorrespondence objectForKey:@"status"];
				
				NSDictionary *pivot = [acorrespondence objectForKey:@"pivot"];
#ifdef SHOWLOG
				NSLog(@"correspondence.pivot: %@", pivot);
#endif
				NSInteger viewed = [[pivot objectForKey:@"viewed"] intValue];
#ifdef SHOWLOG
				NSLog(@"correspondence.pivot.viewed: %i", viewed);
#endif
				
				if( viewed == 0 )
				{
					NSLog(@"viewed = 0 found!");
				}
				correspondenceTbl.viewed = [NSString stringWithFormat:@"%li", viewed];
				
				correspondenceTbl.response_required = [NSString stringWithFormat:@"%i",[[acorrespondence objectForKey:@"response_required"] intValue]];
				correspondenceTbl.response_given = [NSString stringWithFormat:@"%i",[[acorrespondence objectForKey:@"response_given"] intValue]];
				correspondenceTbl.issued_at = [acorrespondence objectForKey:@"issued_at"];
				correspondenceTbl.expired_at = [acorrespondence objectForKey:@"expired_at"];
				correspondenceTbl.created_at = [acorrespondence objectForKey:@"created_at"];
				correspondenceTbl.updated_at = [acorrespondence objectForKey:@"updated_at"];
				correspondenceTbl.deleted_at = [acorrespondence objectForKey:@"deleted_at"];
				
				[realm addOrUpdateObject:correspondenceTbl];
				
			}
			
			
			[self commitWriteTransaction:realm];
			// End : Save Data into Realm
		}
		@catch( NSException *exception)
		{
			[self commitWriteTransaction:realm];
			NSLog(@"Uncaught exception %@", exception);
			NSLog(@"Stack trace: %@", [exception callStackSymbols]);
		}
		
		allResults = [CorrespondenceTable allObjectsInRealm:realm];
		
#ifdef SHOWLOG
		NSLog(@"allResults aka Correspondences description: %@", [allResults description]);
#endif
		
	}
	
	return allResults;
	
}

- (CorrespondenceTable* ) getANoticeFromServer : (NSString* ) strNoticeId
{
	NSString *noticeURL = [NSString stringWithFormat: @"%@/api/correspondence/%@?token=%@", self.serverIpOrDomain, strNoticeId, self.Token];
	
	NSLog(@"noticeURL : %@", noticeURL);
	
	NSString* retString = [super getData:noticeURL];
#ifdef SHOWLOG
	NSLog(@"retString: %@", retString);
#endif
	NSMutableDictionary *dict=[NSJSONSerialization JSONObjectWithData:[retString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
	
#ifdef SHOWLOG
	NSLog(@"dict data: %@", dict);
#endif
	NSDictionary *aNoticeDict = [[dict objectForKey:@"data"]  mutableCopy];
#ifdef SHOWLOG
	NSLog(@"aNoticeDict: %@", aNoticeDict);
#endif
	
	BOOL nullYES = [self isNULL:aNoticeDict];
	if( nullYES )
	{
		return nil;
	}
	
	CorrespondenceTable* aNoticeTbl = [[CorrespondenceTable alloc] init];
	aNoticeTbl.id = [NSString stringWithFormat:@"%i", [[aNoticeDict objectForKey:@"id"] intValue]];
	aNoticeTbl.title = [aNoticeDict objectForKey:@"title"];
	aNoticeTbl.desc = [aNoticeDict objectForKey:@"description"];
aNoticeTbl.ref_no = [aNoticeDict objectForKey:@"reference_no"];
	NSString* strTemp = [aNoticeDict objectForKey:@"company_id"];
	aNoticeTbl.company_id = [super isNULL:strTemp] ? nil : [NSString stringWithFormat:@"%i", [strTemp intValue]];
aNoticeTbl.status = [aNoticeDict objectForKey:@"status"];
aNoticeTbl.priority = [aNoticeDict objectForKey:@"priority"];
	aNoticeTbl.issued_at = [aNoticeDict objectForKey:@"issued_at"];

	strTemp = [aNoticeDict objectForKey:@"reissued_at"];
	
	aNoticeTbl.expired_at = [aNoticeDict objectForKey:@"expired_at"];
aNoticeTbl.response_required = [NSString stringWithFormat:@"%i", [[aNoticeDict objectForKey:@"response_required"] intValue]];
aNoticeTbl.created_at = [aNoticeDict objectForKey:@"created_at"];
aNoticeTbl.updated_at = [aNoticeDict objectForKey:@"updated_at"];
	
	strTemp = [aNoticeDict objectForKey:@"deleted_at"];
	aNoticeTbl.deleted_at = [super isNULL:strTemp] ? nil : strTemp;

	RLMRealm* realm = [self getAndBeginWriteTransaction];
	[realm addOrUpdateObject:aNoticeTbl];
	[self commitWriteTransaction:realm];
	
	return aNoticeTbl;
}

- (NSString *) formatSize:(float)size
{
	return [NSString stringWithFormat:@"%0.3f", size];
}


-(BOOL) shouldBeDeleted : (NSString *)strId withTableType: (NSString* )strTableType
{
	assert(strId != nil);
	assert(strTableType != nil);
	
	RLMRealm* realm = [self getAndBeginWriteTransaction];
	RLMResults* results = nil;
	NSString* strQry = @"";
	if( [strTableType isEqualToString:@"notice_file"] ) //File no need to Delete
	{
		strQry = [NSString stringWithFormat:@"id == '%@'", strId];
		NSLog(@"strQry: %@", strQry);
		
		results = [CorrespondenceFileTable objectsInRealm:realm where:strQry];
		
		
	}
	
	if( [results count] > 0 )
	{
		
	}
	
	return NO;
}
@end
