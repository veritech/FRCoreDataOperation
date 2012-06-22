//
//  FRCoreDataOperation.m
//  
//
//  Created by Jonathan Dalrymple on 19/09/2010.
//  Copyright 2010 Float:Right. All rights reserved.
//

#import "FRCoreDataOperation.h"

@interface FRCoreDataOperation(){
	//Two contexts
	NSManagedObjectContext	*_threadContext;
	NSManagedObjectContext	*_mainContext;
	
	BOOL					_mergeChanges;
}

/**
 *	A context linked to the same persistent store as the main context, 
 *	created on a background thread. To onlt be used within the operation
 */
-(NSManagedObjectContext*) threadContext;

/**
 *	Called when the thread context saves
 */
-(void) threadContextDidSave:(NSNotification*) aNotification;

@end

@implementation FRCoreDataOperation

@synthesize mainContext		= _mainContext;
@synthesize mergeChanges	= _mergeChanges;

#pragma mark - Object life cycle
-(id) initWithManagedObjectContext:(NSManagedObjectContext*) aMOC{
	
	if( !(self = [super init])) return nil;
	
	_mainContext	= aMOC;	
	_threadContext	= nil;
	_mergeChanges	= YES;
	
	[self addObserver:self 
		   forKeyPath:@"isCancelled" 
			  options:NSKeyValueObservingOptionNew 
			  context:NULL
	 ];
	
	return self;
}

-(void) dealloc{
	
	[self removeObserver:self 
			  forKeyPath:@"isCancelled"
	 ];
	
	//Remove the observer if we've used the thread context
	if(_threadContext){
		[[NSNotificationCenter defaultCenter] removeObserver:self 
														name:NSManagedObjectContextDidSaveNotification 
													  object:_threadContext
		 ];		
	}

}

#pragma mark - CoreData Stack management
/**
 *	Get a new managed object context for this thread
 */
-(NSManagedObjectContext*) threadContext{
	
	NSPersistentStoreCoordinator	*storeCoordinator;
	
	//Create on demand
	if( !_threadContext ){
		
		//Throw an exception if there is no main context
		if( ![self mainContext] ){
			[NSException raise:@"FRCoreDataOperationException" 
						format:@"No Main context set in %@, cannot create thread context!",self
			 ];
		}
		
		//TODO:
		//We need to stop doing this and have a proper mutator so that it can provided
		storeCoordinator = [[self mainContext] persistentStoreCoordinator];
		
		_threadContext = [[NSManagedObjectContext alloc] init];
		
		//Use the same merge policy as the main thread
		[_threadContext setMergePolicy:[[self mainContext] mergePolicy]];
		
		[_threadContext setPersistentStoreCoordinator:storeCoordinator];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(threadContextDidSave:) 
													 name:NSManagedObjectContextDidSaveNotification 
												   object:_threadContext
		 ];
	}
	
	return _threadContext;
}

//Context did save
-(void) threadContextDidSave:(NSNotification*) aNotification{
	
	if( [self mergeChanges] ){
		
		NSManagedObjectContext *blockContext = [self mainContext];
		
		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			[blockContext mergeChangesFromContextDidSaveNotification:aNotification];
		}];
		
	}

}


#pragma mark - KVO Observing
-(void) observeValueForKeyPath:(NSString *) aKeyPath 
					  ofObject:(id) aObject 
						change:(NSDictionary *) aChange 
					   context:(void *)aContext{
	
	if( [aKeyPath isEqualToString:@"isCancelled"] ){
	
		if( [[aChange objectForKey:NSKeyValueChangeNewKey] boolValue] ){
			[self operationWillCancel];
		}
	}
	
}

-(void) operationWillCancel{
	NSLog(@"%@ operationWillCancel",self);
}

-(NSString*) description{
	return [NSString stringWithFormat:@"%@ Ready:%d Executing:%d Finished:%d Cancelled:%d",[super description],[self isReady],[self isExecuting],[self isFinished],[self isCancelled]];
}

@end
