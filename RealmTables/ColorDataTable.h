//
//  ColorDataTable.h
//  AppstorePreparation
//
//  Created by InfoSapex on 7/12/17.
//  Copyright © 2017 Infosapex Limited. All rights reserved.
//

#ifndef ColorDataTable_h
#define ColorDataTable_h

#import <Realm/Realm.h>

@interface ColorDataTable : RLMObject
@property(nonatomic, assign) NSInteger id;
@property(nonatomic, strong) NSString *color;
@property(nonatomic, strong) NSString *value;
@end
RLM_ARRAY_TYPE(ColorDataTable)

#endif /* ColorDataTable_h */
