//
//  FRCoreDataBlockOperation.m
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

#import "FRCoreDataBlockOperation.h"

@implementation FRCoreDataBlockOperation

+ (id)coreDataBlockOperationWithManagedObjectContext:(NSManagedObjectContext *)aMOC {
  return [[self alloc] initWithManagedObjectContext:aMOC];
}

+ (id)coreDataBlockOperationWithManagedObjectContext:(NSManagedObjectContext *)aMOC
                                               block:(FRCoreDataBlock)aBlock {
  
  return [[self alloc] initWithManagedObjectContext:aMOC
                                              block:aBlock];
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)aMOC
                             block:(FRCoreDataBlock)aBlock {
  
  self = [self initWithManagedObjectContext:aMOC];
  if (self) {
    [self addExecutionBlock:aBlock];
  }
  return self;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)aMOC {
  self = [super initWithManagedObjectContext:aMOC];
  if (self) {
    [self setSaveAfterExecution:NO];
  }
  return self;
}

- (void)addExecutionBlock:(FRCoreDataBlock)aBlock {
  
  if (![self executionBlocks]) {
    [self setExecutionBlocks:[NSArray arrayWithObject:aBlock]];
  }
  else {
    [self setExecutionBlocks:[[self executionBlocks] arrayByAddingObject:aBlock]];
  }
  
}

- (void)main {
  
  @autoreleasepool {
    
    NSError *error = nil;
    
    //Iterate over the blocks
    for (FRCoreDataBlock block in [self executionBlocks]) {
      
      error = nil;
      //Execute and save if required
      if (block([self threadContext])) {
        if ([[self threadContext] save:&error]) {
          NSLog(@"Save Error %@",error);
        }
      }
    }
  
     //Return early if we do not want save
    if ([self saveAfterExecution]) {
    
      error = nil;  //Reset the error
      
      //Save after executing all blocks
      if (![[self threadContext] save:&error]) {
        NSLog(@"Save Error %@",error);
      }
    }
  }
  
}


@end
