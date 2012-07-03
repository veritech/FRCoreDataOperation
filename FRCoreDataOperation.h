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
 *	a NSManagedObjectContext for use by the operation internally
 *  Will throw an Exception if called from the main thread
 */
@property (nonatomic,readonly)  NSManagedObjectContext		*threadContext;

/**
 *	Determines if the changes should be merged into the main context
 *	Defaults to YES
 */
@property (nonatomic,assign)	BOOL						mergeChanges;

/**
 *	Create a core data operation with a given managed object context
 *	@param aMOC a ManagedObjectContext
 *	@return FRCoreDataOperation
 */
-(id) initWithManagedObjectContext:(NSManagedObjectContext*) aMOC;

/**
 *	Called when the operation's isCancelled flag is set
 */
-(void) operationWillCancel;

@end
