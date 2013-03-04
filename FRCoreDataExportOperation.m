//
//  FRCoreDataExportOperation.m
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

#import "FRCoreDataExportOperation.h"

@interface FRCoreDataExportOperation ()

@property (nonatomic,copy,readwrite) NSString *fileName
@property (nonatomic,copy,readwrite) NSPredicate *predicate;
@property (nonatomic,copy,readwrite) NSArray *sortDescriptors;
@property (nonatomic,strong,readwrite) NSEntityDescription *entityDescription;

@end

@implementation FRCoreDataExportOperation

#pragma mark - Object creation
- (id)initWithEntityName:(NSString *)aName
    managedObjectContext:(NSManagedObjectContext *)aMOC {

  self = [super initWithManagedObjectContext:aMOC];
  if (self) {
    [self setEntityDescription:[NSEntityDescription entityForName:aName
                                           inManagedObjectContext:aMOC]];
  }
  return self;
}

- (id)initWithEntityName:(NSString *)aName
               predicate:(NSPredicate *)aPredicate
    managedObjectContext:(NSManagedObjectContext *)aMOC {
  
  self = [self initWithEntityName:aName
             managedObjectContext:aMOC];
  if (self) {
    [self setPredicate:aPredicate];
  }
  return self;
}

- (id)initWithEntityName:(NSString *)aName
               predicate:(NSPredicate *)aPredicate
         sortDescriptors:(NSArray *)sortDescriptors
    managedObjectContext:(NSManagedObjectContext *)aMOC {
  
  self = [self initWithEntityName:aName
             managedObjectContext:aMOC];
  if (self) {
    [self setPredicate:aPredicate];
    [self setSortDescriptors:sortDescriptors];
  }
  return self;
}



#pragma mark - Formatting

- (NSString *)entityName {
  return [[self entityDescription] name];
}

- (void)setEntityFormatter:(id<FRCoreDataEntityFormatter>)aFormatter {
  
  NSAssert(![self isExecuting], @"Cannot change the operation once it has started");
  
  _entityFormatter = nil;
  _entityFormatter = aFormatter;
  
}

#pragma mark - Object stringification
-(id)transformValue:(id)aValue withAttributeName:(NSString *)aName {
  
  if ([aValue isKindOfClass:[NSNumber class]]) {
    
    if ([[self entityFormatter] respondsToSelector:@selector(transformNumberValue:withAttributeName:)]) {
      return [[self entityFormatter] transformNumberValue:aValue
                                        withAttributeName:nil];
    }
  }
  else if ([aValue isKindOfClass:[NSString class]]) {
    
    if ([[self entityFormatter] respondsToSelector:@selector(transformStringValue:withAttributeName:)]) {
      return [[self entityFormatter] transformStringValue:aValue
                                        withAttributeName:nil];
    }

  }
  else if ([aValue isKindOfClass:[NSDate class]]) {
   
    if ([[self entityFormatter] respondsToSelector:@selector(transformDateValue:withAttributeName:)]) {
      return [[self entityFormatter] transformDateValue:aValue
                                      withAttributeName:nil];
    }

  }

  return aValue ;
}

- (NSDictionary *)dictionaryRepresentationOfManagedObject:(NSManagedObject *)aObject {
  
  NSMutableDictionary *dictionary;
  NSDictionary *attributes;
  
  dictionary = [NSMutableDictionary dictionaryWithCapacity:0];
  
  attributes = [[aObject entity] attributesByName];
  
  for (NSString *key in [attributes allKeys]) {
    
    [dictionary setObject:[self transformValue:[aObject valueForKey:key] withAttributeName:key]
                   forKey:key];
  }
  
  return [dictionary copy];
}

- (NSString *)filePath {

  NSString *fileName = nil;
  
	if (!fileName = [self fileName]) {
		fileName = [NSString stringWithFormat:@"%@.dat",[[self entityName] lowercaseString]];		
	}
  
  return [NSString pathWithComponents:@[
          NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0],
          fileName
   ]];
  
}

#pragma mark - Object formatting proxy
- (NSData *)dataForManagedObject:(NSManagedObject *)aObject {
  
  return [[self entityFormatter] dataForDictionaryRespresentation:[self dictionaryRepresentationOfManagedObject:aObject]
                                                         ofEntity:[self entityDescription]];
}

#pragma mark - Main
- (void)main {

  NSEntityDescription *entityDescription = nil;
  NSFetchRequest *fetchRequest = nil;
  NSFileHandle *fileHandle = nil;
  NSDictionary *attributes = nil;
  NSArray *results = nil;
  NSError *error = nil;
  
  
  @autoreleasepool {
    
    fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setPredicate:[self predicate]];
    
    entityDescription = [NSEntityDescription entityForName:[self entityName]
                                    inManagedObjectContext:[self threadContext]];
    
    NSAssert(entityDescription, @"Invalid Entity %@",[self entityName]);
    
    [fetchRequest setEntity:entityDescription];
    
    //Fetch all the objects within the predicate
    results = [[self threadContext] executeFetchRequest:fetchRequest
                                                  error:&error];
    
    NSLog(@"Exporting %d %@ objects",[results count],[self entityName]);
    
    if (!results || error) {
      NSLog(@"Fetch error %@",error);
    }
    
    //Reuse the error prtr
    error = nil;

    ///////////////////////////////
    // Prepare the file for writing
    ///////////////////////////////
    
    // Open a mapped NSMutableData
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    if ([fileManager fileExistsAtPath:[self filePath]]) {
      [fileManager removeItemAtPath:[self filePath]
                              error:&error];
    }
    
    [fileManager createFileAtPath:[self filePath]
                         contents:[NSData data]
                       attributes:nil];
    
    fileHandle = [NSFileHandle fileHandleForWritingAtPath:[self filePath]];
    
    if (!fileHandle || error ) {
      NSLog(@"File error %@",error);
    }
    
    attributes = [entityDescription attributesByName];
    
    //Header
    if ([[self entityFormatter] respondsToSelector:@selector(dataForHeaderOfEntity:)]) {
      [fileHandle writeData:[[self entityFormatter] dataForHeaderOfEntity:[self entityDescription]]];
    }
    
    //Exact the attribute names and print them
    for (NSUInteger i=0; i < [results count]; i++) {
      
      NSManagedObject *obj = (NSManagedObject *)[results objectAtIndex:i];
      
      //Keep the object overhead low
      @autoreleasepool {
        
        NSData *data;
        
        data = [[self entityFormatter] dataForDictionaryRespresentation:[self dictionaryRepresentationOfManagedObject:obj]
                                                               ofEntity:[self entityDescription]];
        
        [fileHandle writeData:data];
        
        //Insert the delimiter
        if ( i < ([results count]-1) ) {
          [fileHandle writeData:[[self entityFormatter] dataForObjectDelimiterOfEntity:[self entityDescription]]];
        }
        
        //Force the object we've just read to fault to 
        [[self threadContext] refreshObject:obj
                               mergeChanges:NO];
        
      }
    }
    
    // Append the Footer
    if ([[self entityFormatter] respondsToSelector:@selector(dataForFooterOfEntity:)]) {
      [fileHandle writeData:[[self entityFormatter] dataForFooterOfEntity:[self entityDescription]]];
    }
    
    //Reuse the error prtr
    error = nil;
    
    //Close the file
    [fileHandle closeFile];
    
    if (error) {
      NSLog(@"File Error %@",error);
    }
   
  }
  
}

@end
