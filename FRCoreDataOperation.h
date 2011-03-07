//
//  FRCoreDataOperation.h
//  
//
//  Created by Jonathan Dalrymple on 19/09/2010.
//  Copyright 2010 Float:Right. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface FRCoreDataOperation : NSOperation {
	//Two contexts
	NSManagedObjectContext	*_threadContext;
	NSManagedObjectContext	*_mainContext;
	
	BOOL					_mergeChanges;
}

@property (nonatomic,retain)	NSManagedObjectContext		*mainContext;
@property (readonly)			NSManagedObjectContext		*threadContext;
@property (nonatomic,assign)	BOOL						mergeChanges;

-(void) operationWillCancel;

@end
