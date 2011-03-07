//
//  FRCoreDataOperation.m
//  
//
//  Created by Jonathan Dalrymple on 19/09/2010.
//  Copyright 2010 Float:Right. All rights reserved.
//

#import "FRCoreDataOperation.h"

@interface FRCoreDataOperation(private)

-(void) threadContextDidSave:(NSNotification*) aNotification;

@end

@implementation FRCoreDataOperation

@synthesize mainContext		= _mainContext;
@synthesize mergeChanges	= _mergeChanges;
@dynamic threadContext;

#pragma mark -
#pragma mark Object life cycle
-(id) init{
	
	if( !(self = [super init])) return nil;
	
	_threadContext	= nil;
	_mainContext	= nil;
	_mergeChanges	= YES;
	
	[self addObserver:self 
		   forKeyPath:@"isCancelled" 
			  options:NSKeyValueObservingOptionNew 
			  context:NULL
	 ];
	
	return self;
}



#pragma mark -
#pragma mark CoreData Stack management
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
		
		//[[[UIApplication sharedApplication] delegate] performSelector:@selector(persistentStoreCoordinator)];
		
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
		
		//NSLog(@"Merging %@ & %@",[self mainContext], [self threadContext]);
		
		SEL selector = @selector(mergeChangesFromContextDidSaveNotification:);
		
		[[self mainContext] performSelectorOnMainThread:selector
											 withObject:aNotification
										  waitUntilDone:YES
		 ];	
	}

}


#pragma mark -
#pragma mark KVO Observing
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
	
	NSLog(@"%@ cancelled",self);
}

-(NSString*) description{
	return [NSString stringWithFormat:@"%@ Ready:%d Executing:%d Finished:%d Cancelled:%d",[super description],[self isReady],[self isExecuting],[self isFinished],[self isCancelled]];
}

-(void) dealloc{
	
	[self removeObserver:self 
			  forKeyPath:@"isCancelled"
	 ];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:NSManagedObjectContextDidSaveNotification 
												  object:_threadContext
	 ];
	
	[_threadContext release];
	_threadContext = nil;
	
	[_mainContext release];
	_mainContext = nil;

	[super dealloc];
}

@end
