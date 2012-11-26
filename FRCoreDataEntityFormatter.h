//
//  FRCoreDataEntityFormatter.h
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
#import <CoreData/CoreData.h>

/**
 *  Data formatter protocol
 *  Note:
 *  It would be nice to leverage NSCoding if possible
 */
@protocol FRCoreDataEntityFormatter <NSObject>

@required;

/**
 *  Transform/encode the object passed as a dictionary into the data format of choice
 *  @param aDictionary A dictionary of values
 *  @param aEntity The Entity 
 *  @return The encoded binary representation of the delimiter
 */
- (NSData *)dataForDictionaryRespresentation:(NSDictionary *)aDictionary
                                    ofEntity:(NSEntityDescription *)aEntity; // 'foo','bar',0.0

/**
 *  The data used to delimit each object encoded by the dataForDictionaryRepresentation:ofEntity: method
 *  @param aEnity The entity that is currently being decoded
 *  @return The encoded binary representation of the delimiter
 */
- (NSData *)dataForObjectDelimiterOfEntity:(NSEntityDescription *)aEntity; // ,

/**
 *  The file name for the entity
 *  @param aEntity The entity that is currently being decoded
 *  @return the file name to be used to save the file
 */
- (NSString *)fileNameForEntity:(NSEntityDescription *)aEntity;

@optional;

/**
 *  Attempt to encode the relationships for an entity
 */
- (BOOL)encodeRelationshipsForEntity:(NSEntityDescription *)aEntity;

/**
 *  Returns a propery formatted stiring value, in a binary/raw form for writting to a file
 *
 *  @param aString The string to be converted into data
 *  @param aName The name of the attribute that is being converted
 *  @retutn a representation of the string in binary form
 */
- (id)transformStringValue:(NSString *)aString withAttributeName:(NSString *)aName;

/**
 *  Returns a propery formatted number value, in a binary/raw form for writting to a file
 *
 *  @param aNumber The a number to be converted into data
 *  @param aName The name of the attribute that is being converted
 *  @retutn a representation of the number in binary form
 */
- (id)transformNumberValue:(NSNumber *)aNumber withAttributeName:(NSString *)aName;

/**
 *  Returns a propery formatted number value, in a binary/raw form for writting to a file
 *
 *  @param aNumber The a number to be converted into data
 *  @param aName The name of the attribute that is being converted
 *  @return a representation of the number in binary form
 */
- (id)transformDateValue:(NSDate *)aDate withAttributeName:(NSString *)aName;

/**
 *  Data to prefixed to each entity
 *
 *  @param
 *  @return
 */
- (NSData *)dataForObjectPrefixOfEntity:(NSEntityDescription *)aEntity;  // nil

/**
 *  Data to be suffixed to each entity
 *
 *  @param
 *  @return
 */
- (NSData *)dataForObjectSufffixOfEntity:(NSEntityDescription *)aEntity; // nil

/**
 *  Returns a Document header for a specific entity
 *  @param aEntityName The name of the entity being processed
 *  @return The NSData/ binary representation of the document header
 */
- (NSData *)dataForHeaderOfEntity:(NSEntityDescription *)aEntity;

/**
 *  Returns a Document footer for a specific entity
 *  @param aEntityName The name of the entity being processed
 *  @return The NSData/ binary representation of the document footer
 */
- (NSData *)dataForFooterOfEntity:(NSEntityDescription *)aEntity;

@end