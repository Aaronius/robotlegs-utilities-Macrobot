package test.org.robotlegs.utilities.macrobot
{
	import flexunit.framework.Assert;
	
	import org.robotlegs.mvcs.Command;
	
	import test.org.robotlegs.utilities.macrobot.support.TestMacroBase;

	public class MacroBaseTest
	{		
		[Test]
		public function testAddCommand():void
		{
			var command:TestMacroBase = new TestMacroBase();
			var subcommands:Array = command.getSubcommands() || []; 
			Assert.assertEquals('No commands should have been added yet.', subcommands.length, 0);
			command.addCommandInstance(new Command());
			subcommands = command.getSubcommands();
			Assert.assertEquals('A single command should have been added.', subcommands.length, 1);
		}
	}
}