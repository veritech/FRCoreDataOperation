FRCoreDataOperation & FRCoreDataBlockOperation
===========================

**Problem**

* So you like multithreading, cool.
* But you heard (correctly) that NSManagedObjects and CoreData isn't thread safe
* But you want NSManagedObjects in your threads/Operations

Well here is the solution. FRCoreDataOperation, will generate a thread context on demand and make it nice and easy for you to use.

Basic Usage
-----------

**FRCoreDataOperation**

This class is designed to be be subclassed. Your subclass can override main, and all the other NSOperation methods just fine.
You could just insert your own main method in the parent, but that would be kinda silly ^_^


	FRCoreDataOperation *op = [[FRCoreDataOperation alloc] initWithManagedObjectContext:<MAIN MANAGED OBJECT CONTEXT>];
	
	[<YOUR NSOperationQueue> addOperation:op];

Inside your subclass's operation all of your requests for a *NSManagedObjectContext* should use

	[self threadContext]

This will return a thread safe managedObjectContext, which will use the persistent store coordinator as the managed object that you passed in.
Do not call this method outside of the operation or in the *-(void)start* method of your NSOperation, as that will break it's thread isolation.

**FRCoreDataBlockOperation** [NEW!]

This class is CoreData focused version of the NSBlockOperation class. You can assign
an operation a *NSManagedObjectContext* and then add multiple blocks to the operation
to be executed. Like the native *NSBlockOperation*, you do not need to subclass 
*FRCoreDataBlockOperation* to use it.

	FRCoreDataBlockOperation *op = [[FRCoreDataBlockOperation alloc] initWithManagedObjectContext:<MAIN MANAGED OBJECT CONTEXT>];

	[op addExecutionBlock:^(NSManagedObjectContext *threadContext){
	
		//DO your work on threaded NSManagedObjectContext
	
		return NO;	//Return YES to save, no to not save
	}];

	[<YOUR NSOperationQueue> addOperation:op];

The NSManagedObjectContext is shared between all of the execution blocks so you can
share state between blocks.

The execution block return value determines if the NSManagedObjectContext should 
be saveed.

There is also a *saveAfterExecution* property on the operation to determine whether
the *NSManagedObjectContext* is saved or not when all of the execution blocks have
been executed.

Also the *completionBlock* property is not used internally, so you may use it to perform
cleanup. Alternatively the blocks are performed in the sequence they are added, so if
you require access to the threaded NSManagedObjectContext for any cleanup you can
use this approach.

**Both Operations are ARC compatible**!

Example
-------

Lets say i want to import a list of countries i've visited into my new awesome travel app, but because i'm globe trotter, the list is huge.
the main method of my 'Travel import operation' should look a little something like this ...

	-(void) main{
		
		@autorelease{
		
			//My travel history
			NSArray *countries = [NSArray arrayWithObjects:
				@"China",
				@"Spain",
				@"Greece",
				@"France",
				@"Germany",
				@"Hong Kong",
				@"Jamaica",
				@"Ukraine",
				@"USA",
				@"Canada",
				@"Denmark",
				@"Belgium",
				@"Netherlands",
				@"Ireland",
				@"Thailand",
				@"Malaysia",
				@"Australia",
				@"Israel",
				@"Vietnam",
				@"Macau",
				@"Iceland",
				@"Cambodia"
				@"Wales",
				@"Qatar",
				@"Malta",
				nil
			];
		
			for( country in countries ){
			
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

Thats all folks, if your actually doing some proper work, you want want to sleep your thread in-between iterations of your main loop.
Also if your operation is going to run for any serious length of time, you'll want to consider checking *isCancelled* periodically to make sure you need to continue.

Credit
------

Jonathan Dalrymple [E-mail](mailto:jonathan@float-right.co.uk) [twitter](http://twitter/veritech) [Online](http://float-right.co.uk)

While i wrote the code, the Fantastic Marcus Zara gave me the inspiration and direction, get his book on CoreData, it's worth it!

License (MIT)
-------------

Copyright (C) 2012 Jonathan Dalrymple

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
