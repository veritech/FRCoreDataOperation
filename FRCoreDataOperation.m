//
//  FRCoreDataOperation.m
//  
//
//  Created by Jonathan Dalrymple on 19/09/2010.
//  
//  Copyright (C) 2012 Jonathan Dalrymple
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
- (NSManagedObjectContext *)threadContext;

/**
 *	Called when the thread context saves
 */
- (void)threadContextDidSave:(NSNotification *) aNotification;

@end

@implementation FRCoreDataOperation

@synthesize mainContext		= _mainContext;
@synthesize mergeChanges	= _mergeChanges;

#pragma mark - Object life cycle
- (id)initWithManagedObjectContext:(NSManagedObjectContext *)aMOC {
	
	if (!(self = [super init])) return nil;
	
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

- (void)dealloc {
	
	[self removeObserver:self 
            forKeyPath:@"isCancelled"
	 ];
	
	//Remove the observer if we've used the thread context
	if (_threadContext) {
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
- (NSManagedObjectContext *)threadContext {
	
	//Create on demand
	if( !_threadContext ){
		
		//Throw an exception if there is no main context
		NSAssert([self mainContext], @"No Main context set in %@, cannot create thread context!",self);
		//NSAssert(![NSThread isMainThread], @"Thread Context called from the main context");
    
		_threadContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    
    [_threadContext setParentContext:[self mainContext]];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(threadContextDidSave:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:_threadContext
		 ];
	}
	
	return _threadContext;
}

//Context did save
- (void)threadContextDidSave:(NSNotification *) aNotification {
	
	if( [self mergeChanges] ){
		
		NSManagedObjectContext *blockContext = [self mainContext];
    
    /**
     *  TODO
     *  Consider refactoring this to use performBlock: method of the NSManagedObjectContext
     */
		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			[blockContext mergeChangesFromContextDidSaveNotification:aNotification];
		}];
		
	}

}

#pragma mark - KVO Observing
- (void)observeValueForKeyPath:(NSString *)aKeyPath 
                      ofObject:(id) aObject
                        change:(NSDictionary *) aChange
                       context:(void *)aContext {
	
	if ([aKeyPath isEqualToString:@"isCancelled"]) {
	
		if ([[aChange objectForKey:NSKeyValueChangeNewKey] boolValue]) {
			[self operationWillCancel];
		}
	}
	
}

- (void)operationWillCancel {
	NSLog(@"%@ operationWillCancel",self);
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ Ready:%d Executing:%d Finished:%d Cancelled:%d",
          [super description],
          [self isReady],
          [self isExecuting],
          [self isFinished],
          [self isCancelled]
          ];
}

@end
