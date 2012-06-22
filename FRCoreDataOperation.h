//
//  FRCoreDataOperation.h
//  
//
//  Created by Jonathan Dalrymple on 19/09/2010.
//  Copyright 2010 Float:Right. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface FRCoreDataOperation : NSOperation

/**
 *	A reference to the main context
 */
@property (nonatomic,readonly)	NSManagedObjectContext		*mainContext;


/**
 *	Determines if the changes should be merged into the main context
 *	Defaults to YES
 */
@property (nonatomic,assign)	BOOL						mergeChanges;

-(void) operationWillCancel;

@end
