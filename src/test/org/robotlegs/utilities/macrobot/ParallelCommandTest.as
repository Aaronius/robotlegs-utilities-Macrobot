package test.org.robotlegs.utilities.macrobot
{
	import flexunit.framework.Assert;
	
	import test.org.robotlegs.utilities.macrobot.support.SubcommandStatusEvent;
	import test.org.robotlegs.utilities.macrobot.support.TestParallelCommand;
	import test.org.robotlegs.utilities.macrobot.base.MacroTestBase;

	public class ParallelCommandTest extends MacroTestBase
	{		
		public function ParallelCommandTest()
		{
			super();
			commandClass = TestParallelCommand;
		}
		
		// This is here only because all the other tests are in the parent class.
		// Without this, this test class would not show up as a testing option
		// in Flash Builder.  Is there a better way to do this?
		[Test]
		public function dummyTest():void
		{
			Assert.assertTrue(true);
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