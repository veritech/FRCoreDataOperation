FRCoreDataOperation
===================

A Collection of NSOperation subclasses that provide the boilerplate code to work with *NSManagedObjects* on a background thread.

Currently the project consists 3 classes:

* **FRCoreDataOperation** - Abstract class for building custom operations
* **FRCoreDataBlockOperation** - A Helper class that doesn't require subclassing, and takes a block
* **FRCoreDataExportOperation** - A Helper class that archive sets of objects.

With introduction of the *performBlock* and *performBlockAndWait* on *NSManagedObjectContext* in iOS 5, it could be argued that the importance of these classes is less relevant. However while blocks are awesome, the block based methods do not provide any scope for queuing, dependency chaining, and cancellation, FRCoreDataOperation does.

*Update 2015/1/23* After reading some research by [Florian Kugler](http://floriankugler.com/2013/05/13/backstage-with-nested-managed-object-contexts/), I've come to the conclusion to revert the code back to using the 'old fashione'd Merge technique as it provides better performance, and allows for imports to remain almost completely off the main thread, assuming the context that you pass to your *FRCoreDataOperation* is a private queue context linked to the persistent store Coordinator. 

Basic Usage
-----------

**FRCoreDataOperation**

This class is designed to be be subclassed. Your subclass can override main, and all the other NSOperation methods just fine.
You could just insert your own main method in the parent, but that would be kinda silly ^_^.

	FRCoreDataOperation *op = [[FRCoreDataOperation alloc] initWithManagedObjectContext:<MAIN MANAGED OBJECT CONTEXT>];
	
	[<YOUR NSOperationQueue> addOperation:op];

Inside your subclass's operation all of your requests for a *NSManagedObjectContext* should use

	[self threadContext]

This will return a thread safe managedObjectContext, which will use the persistent store coordinator as the managed object that you passed in.
Do not call this method outside of the operation or in the *-(void)start* method of your NSOperation, as that will break it's thread isolation.

Lets say i want to import a list of countries i've visited into my new awesome travel app, but because i'm globe trotter, the list is huge.
the main method of my 'Travel import operation' should look a little something like this ...

	-(void) main{
		
		@autorelease{
		
			NSArray *countries = @[
				@"Argentina",
				@"Australia",
				...
				@"Wales",
				nil
			];
		
			for( NSString* country in countries ){
			
				//Destination is a our subclassed NSManagedObject
				//We create one for each country, and assign it to thread context
				[Destination destinationWithName:country
							inContext:[self threadContext]
				]
			
			}
		
			//Save the context
			if( ![[self threadContext] save:&error] ){
				NSLog(@"Save failed %@",error);
			}
		
		}
	}

If your operation is going to run for any serious length of time, you'll want to consider checking *isCancelled* periodically to make sure you need to continue.

**FRCoreDataBlockOperation**

This class is CoreData focused version of the NSBlockOperation class. You can assign
an operation a *NSManagedObjectContext* and then add multiple blocks to the operation
to be executed. Like the native *NSBlockOperation*, you do not need to subclass 
*FRCoreDataBlockOperation* to use it.

	FRCoreDataBlockOperation *op = [[FRCoreDataBlockOperation alloc] initWithManagedObjectContext:<MAIN MANAGED OBJECT CONTEXT>];

	[op addExecutionBlock:^(NSManagedObjectContext *threadContext){
	
		//Do your work on the supplied NSManagedObjectContext
	
		return NO;	//Return YES to save, NO to not save
	}];

	[<YOUR NSOperationQueue> addOperation:op];

The NSManagedObjectContext is shared between all of the execution blocks so you can
share state between blocks.

The execution block return value determines if the NSManagedObjectContext should 
be saved.

There is also a *saveAfterExecution* property on the operation to determine whether
the *NSManagedObjectContext* is saved or not when all of the execution blocks have
been executed.

Also the *completionBlock* property is not used internally, so you may use it to perform
cleanup. Alternatively the blocks are executed in the sequence they are added, so if
you require access to the threaded NSManagedObjectContext for any cleanup you can
add a clean block using the *addExecutionBlock:*

**FRCoreDataExportOperation**

This operation takes an entity name, and an optional predicate and sort order and will export all objects that match that description to disk.

The format in which they are written to disk can be customized. The *FRCSVEntityFormatter* will export the properties of an object to a CSV file, and save it in the user's Documents directory.

The class can used without subclassing:

	FRCoreDataExportOperation *op = [[FRCoreDataExportOperation alloc] initWithEntityName:@"Destination" 
									 managedObjectContext:<MAIN CONTEXT>];
    
	//[Optional] Set the name of the output file
	[op setFileName:@"output.txt"];
	
	//Set the entity formatter
	[op setEntityFormatter:[[FRCSVEntityFormatter alloc] init]];
	
	[<YOUR OPERATION QUEUE> addOperation:op];
	
	//[Optional] Set a completion block to know when the file is complete
	[op setCompletionBlock:^{
		//Refresh the UI or send a notification
	}];

'Entity Formatters' conform to the FRCoreDataEntityFormatter protocol. It is important to bear in mind that your Custom entity formatter will be retained by the Operation, and will called from a background thread.

**All Operations are ARC compatible**!

Change Log
----------

**0.4.0**

* [Feature] Columns can be whitelisted in the FRCSVCoreDataFormatter
* [Feature] You can now specify a file name in the operation
* [Enhancement] Relatated properties of the search entity are visible in the formatter
* [Enhancement] Improved the ability to format different data types

Credit
------

Jonathan Dalrymple [E-mail](mailto:jonathan@float-right.co.uk) [twitter](http://twitter/veritech) [Online](http://float-right.co.uk)

While I wrote the code, the Fantastic Marcus Zara gave me the inspiration and direction, get his book on CoreData, it's worth it!

License (MIT)
-------------

Copyright (C) 2012 Jonathan Dalrymple

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
