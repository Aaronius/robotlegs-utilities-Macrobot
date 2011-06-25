package test.org.robotlegs.utilities.macrobot
{
	import test.org.robotlegs.utilities.macrobot.base.MacroTestBase;
	import test.org.robotlegs.utilities.macrobot.support.SubcommandStatusEvent;
	import test.org.robotlegs.utilities.macrobot.support.TestParallelCommand;

	public class ParallelCommandTest extends MacroTestBase
	{		
		public function ParallelCommandTest()
		{
			super();
			commandClass = TestParallelCommand;
		}
		
		[Before]
		override public function setUp():void
		{
			super.setUp();
		}
		
		[After]
		override public function tearDown():void
		{
			super.tearDown();
		}
		
		[Test(async)]
		override public function testSyncCommandInstanceExecution():void
		{
			super.testSyncCommandInstanceExecution();
		}
		
		[Test(async)]
		override public function testAsyncCommandInstanceExecution():void
		{
			super.testAsyncCommandInstanceExecution();
		}
		
		[Test(async)]
		override public function testAsyncAndSyncCommandInstanceExecution():void
		{
			super.testAsyncAndSyncCommandInstanceExecution();
		}
		
		[Test(async)]
		override public function testSyncCommandDescriptorExecution():void
		{
			super.testSyncCommandDescriptorExecution();
		}
		
		[Test(async)]
		override public function testAsyncCommandDescriptorExecution():void
		{
			super.testAsyncCommandDescriptorExecution();
		}
		
		[Test(async)]
		override public function testAsyncAndSyncCommandDescriptorExecution():void
		{
			super.testAsyncAndSyncCommandDescriptorExecution();
		}
		
		[Test(async)]
		override public function testNoCommandExecution():void
		{
			super.testNoCommandExecution();
		}
		
		[Test(async)]
		override public function testFailedExecution():void
		{
			super.testFailedExecution();
		}
		
		[Test(async)]
		override public function testExecutionWithMacroCommandMap():void
		{
			super.testExecutionWithMacroCommandMap();
		}
		
		override protected function wereSubcommandsExecutedAsExpected(ids:Vector.<uint>):Boolean
		{
			ids = ids.slice(); // Dereference for good measure.
			for each (var event:SubcommandStatusEvent in statusEvents)
			{
				if (event.type != SubcommandStatusEvent.COMPLETE)
				{
					continue;
				}
				
				var index:int = ids.indexOf(event.id);
				if (index > -1)
				{
					ids.splice(index, 1);
				}
				else
				{
					// A command was executed that wasn't expected to execute.
					return false;
				}
			}
			
			// Not all commands expected to execute were executed.
			return ids.length == 0;
		}
	}
}