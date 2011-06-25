package test.org.robotlegs.utilities.macrobot
{
	import flexunit.framework.Assert;
	
	import org.flexunit.async.Async;
	import org.robotlegs.utilities.macrobot.SequenceCommand;
	
	import test.org.robotlegs.utilities.macrobot.support.CompletionDirective;
	import test.org.robotlegs.utilities.macrobot.support.MacroCommandEvent;
	import test.org.robotlegs.utilities.macrobot.support.SubcommandConfigEvent;
	import test.org.robotlegs.utilities.macrobot.support.SubcommandStatusEvent;
	import test.org.robotlegs.utilities.macrobot.support.TestAsyncCommand;
	import test.org.robotlegs.utilities.macrobot.support.TestSequenceCommand;
	import test.org.robotlegs.utilities.macrobot.base.MacroTestBase;
	
	public class SequenceCommandTest extends MacroTestBase
	{		
		public function SequenceCommandTest()
		{
			super();
			commandClass = TestSequenceCommand;
		}

		[Test(async)]
		public function testFailExecutionWithAtomicTrue():void
		{
			Assert.assertTrue(true);
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
			eventDispatcher.addEventListener(SubcommandStatusEvent.EXECUTED, subcommand_statusHandler);
			eventDispatcher.addEventListener(SubcommandStatusEvent.COMPLETE, subcommand_statusHandler);
			
			var ids:Vector.<uint> = new Vector.<uint>();
			ids.push(1);
			ids.push(2); // Only the first two commands should execute.
			var asyncHandler:Function = Async.asyncHandler(this, 
					macro_completeHandler, 5000, 
					{ids: ids}, 
					macro_timeoutHandler)
			eventDispatcher.addEventListener(MacroCommandEvent.COMPLETE, asyncHandler);
			
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