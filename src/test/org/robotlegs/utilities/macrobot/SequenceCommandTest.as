package test.org.robotlegs.utilities.macrobot
{
	import org.flexunit.async.Async;
	import org.robotlegs.utilities.macrobot.SequenceCommand;
	
	import test.org.robotlegs.utilities.macrobot.base.MacroTestBase;
	import test.org.robotlegs.utilities.macrobot.support.CompletionDirective;
	import test.org.robotlegs.utilities.macrobot.support.MacroCommandEvent;
	import test.org.robotlegs.utilities.macrobot.support.SubcommandConfigEvent;
	import test.org.robotlegs.utilities.macrobot.support.SubcommandStatusEvent;
	import test.org.robotlegs.utilities.macrobot.support.TestAsyncCommand;
	import test.org.robotlegs.utilities.macrobot.support.TestSequenceCommand;
	
	public class SequenceCommandTest extends MacroTestBase
	{		
		public function SequenceCommandTest()
		{
			super();
			commandClass = TestSequenceCommand;
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
		
		[Test(async)]
		public function testFailExecutionWithAtomicFalse():void
		{
			var command:SequenceCommand = new commandClass();
			command.atomic = false;
			
			for (var i:uint = 1; i < 11; i++)
			{
				var completionDirective:String = i == 2 ? 
						CompletionDirective.FAILURE :
						CompletionDirective.SUCCESS;
				command.addCommand(TestAsyncCommand, 
						new SubcommandConfigEvent(SubcommandConfigEvent.CONFIG, i, 1, completionDirective));
			}
			
			injector.injectInto(command);
			eventDispatcher.addEventListener(SubcommandStatusEvent.EXECUTED, subcommand_statusHandler, false, 0, true);
			eventDispatcher.addEventListener(SubcommandStatusEvent.COMPLETE, subcommand_statusHandler, false, 0, true);
			
			var ids:Vector.<uint> = new Vector.<uint>();
			ids.push(1);
			ids.push(2); // Only the first two commands should execute.
			var asyncHandler:Function = Async.asyncHandler(this, 
					macro_completeHandler, 5000, 
					{ids: ids}, 
					macro_timeoutHandler)
			eventDispatcher.addEventListener(MacroCommandEvent.COMPLETE, asyncHandler, false, 0, true);
			
			command.execute();
		}
		
		override protected function wereSubcommandsExecutedAsExpected(ids:Vector.<uint>):Boolean
		{
			for (var i:uint = 0; i < ids.length; i++)
			{
				var id:uint = ids[i];
				
				var executeEvent:SubcommandStatusEvent = statusEvents[i * 2];
				
				if (executeEvent.id != id || executeEvent.type != SubcommandStatusEvent.EXECUTED)
				{
					return false;
				}
				
				var completeEvent:SubcommandStatusEvent = statusEvents[i * 2 + 1];
				
				if (completeEvent.id != id || completeEvent.type != SubcommandStatusEvent.COMPLETE)
				{
					return false;
				}
			}
			
			return true;
		}
		
	}
}