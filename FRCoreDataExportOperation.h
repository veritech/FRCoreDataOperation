//
//  FRCoreDataExportOperation.h
//
//  Created by Jonathan Dalrymple on 11/11/2012.
//
//  Copyright (C) 2012 Jonathan Dalrymple
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE // USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <Foundation/Foundation.h>
#import "FRCoreDataOperation.h"
#import "FRCoreDataEntityFormatter.h"

@interface FRCoreDataExportOperation : FRCoreDataOperation

/**
 *  The Entity name
 */
@property (nonatomic,strong,readonly) NSString *entityName;

/**
 *  The search predicate
 */
@property (nonatomic,strong,readonly) NSPredicate *predicate;

/**
 *  The sort Descriptor
 */
@property (nonatomic,strong,readonly) NSArray *sortDescriptors;

/**
 *  The formatter
 */
@property (nonatomic,strong) id<FRCoreDataEntityFormatter> entityFormatter;

/**
 *  Create a operation with a given Entity name and a Managed Object context
 *  @param aName The name of the entity to export
 *  @param aMOC The Managed Object context to use to gather the data
 */
- (id)initWithEntityName:(NSString *)aName
    managedObjectContext:(NSManagedObjectContext *)aMOC;

/**
 *  Create a operation with a given Entity name, predicate, and a Managed Object context
 *  @param aName The name of the entity to export
 *  @param aPredicate The search predicate to use, can be nil
 *  @param aMOC The Managed Object context to use to gather the data
 */
- (id)initWithEntityName:(NSString *)aName
               predicate:(NSPredicate *)aPredicate
    managedObjectContext:(NSManagedObjectContext *)aMOC;

/**
 *  Create a operation with a given Entity name, predicate, sort descriptor, and a Managed Object context
 *  @param aName The name of the entity to export
 *  @param aPredicate The search predicate to use, can be nil
 *  @param sortDescriptors An array of NSSortDescriptors to arrange the export, can be nil
 *  @param aMOC The Managed Object context to use to gather the data
 */
- (id)initWithEntityName:(NSString *)aName
               predicate:(NSPredicate *)aPredicate
         sortDescriptors:(NSArray *)sortDescriptors
    managedObjectContext:(NSManagedObjectContext *)aMOC;

@end
