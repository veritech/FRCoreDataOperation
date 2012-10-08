//
//  FRCoreDataBlockOperation.h
//
//  Created by Jonathan Dalrymple on 06/10/2012.
//  Copyright (C) 2012 Jonathan Dalrymple
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "FRCoreDataOperation.h"

/**
 *  The return value of the block determines if the context should be saved when the block
 * is finished executing
 *
 */
typedef BOOL(^FRCoreDataBlock)(NSManagedObjectContext *threadContext);

@interface FRCoreDataBlockOperation : FRCoreDataOperation

/**
 *  All of the blocks to be executed
 */
@property (nonatomic,copy) NSArray *executionBlocks;

/**
 *  Should we log run times
 *  Defaults to NO
 */
@property (nonatomic,assign) BOOL profilingEnabled;

/**
 *  Should the operation save after all blocks have been executed
 *  Defaults to NO
 */
@property (nonatomic,assign) BOOL saveAfterExecution;

/**
 *  Create a instance with a given main context
 *
 */
+ (id)coreDataBlockOperationWithManagedObjectContext:(NSManagedObjectContext *)aMOC;

/**
 *  Create a instance with a given context and a block
 *
 */
+ (id)coreDataBlockOperationWithManagedObjectContext:(NSManagedObjectContext *)aMOC
                                               block:(FRCoreDataBlock)aBlock;

/**
 *  Create a instance with a given context and a block
 *
 */
- (id)initWithManagedObjectContext:(NSManagedObjectContext *)aMOC
                             block:(FRCoreDataBlock)aBlock;

/**
 *  Add a block to be executed
 *
 */
- (void)addExecutionBlock:(FRCoreDataBlock)aBlock;

@end
