//
//  FRCSVEntityFormatter.m
//
//  Copyright (C) 2012 Jonathan Dalrymple
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE // USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "FRCSVEntityFormatter.h"

@interface FRCSVEntityFormatter ()

@property (nonatomic,strong,readwrite) NSDateFormatter *dateFormatter;
@property (nonatomic,strong,readwrite) NSArray *sortedKeys;

@end

@implementation FRCSVEntityFormatter

- (NSDateFormatter *)dateFormatter {
  
  if (!_dateFormatter) {
    _dateFormatter = [[NSDateFormatter alloc] init];
    
    [_dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
  }
  return _dateFormatter;
}

- (NSData *)dataWithString:(NSString *)aString {
  return [aString dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - FRCoreDataEntityFormatter protocol
- (NSString *)fileNameForEntity:(NSEntityDescription *)aEntity {
    
  return [NSString stringWithFormat:@"%@.csv",
          [aEntity name]
          ];
}


//Create a data header
- (NSData *)dataForHeaderOfEntity:(NSEntityDescription *)aEntity {
  
  NSDictionary *attributes = [aEntity attributesByName];
  NSArray *columnNames;
  NSString *header;
  
  //Get all the attribute names
  columnNames = [[attributes allKeys] sortedArrayUsingSelector:@selector(compare:)];
  
  header = [columnNames componentsJoinedByString:@","];
  
  header = [header stringByAppendingString:@"\n"];
  
  //Join them with a comma
  return [self dataWithString:header];
  
}

// Format values
- (id)transformDateValue:(NSDate *)aDate withAttributeName:(NSString *)aName {
  return [NSNumber numberWithDouble:[aDate timeIntervalSince1970]];
}

- (id)transformNumberValue:(NSNumber *)aNumber withAttributeName:(NSString *)aName {
  return [aNumber stringValue];
}

//Escape quotes, and remove trim whitespace
- (id)transformStringValue:(NSString *)aString withAttributeName:(NSString *)aName {
  return [[aString stringByReplacingOccurrencesOfString:@"\"" withString:@"'\"\""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

//Encode a objects
- (NSData *)dataForDictionaryRespresentation:(NSDictionary *)aDictionary
                                    ofEntity:(NSEntityDescription *)aEntity {
  
  NSArray *keys;
  NSArray *values;
  
  //Sort the keys
  keys = [[aDictionary allKeys] sortedArrayUsingSelector:@selector(compare:)];
  
  //Get the values in the order of the sorted keys
  values = [aDictionary objectsForKeys:keys
                        notFoundMarker:@"NAN"];
  
  //Encode
  return [self dataWithString:[values componentsJoinedByString:@","]];
  
}

//Delimit a line
- (NSData *)dataForObjectDelimiterOfEntity:(NSEntityDescription *)aEntity {
  return [@"\n" dataUsingEncoding:NSUTF8StringEncoding];
}

@end