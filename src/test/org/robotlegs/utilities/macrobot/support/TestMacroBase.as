package test.org.robotlegs.utilities.macrobot.support
{
	import org.robotlegs.utilities.macrobot.core.MacroBase;
	
	public class TestMacroBase extends MacroBase
	{
		override public function execute():void
		{
			super.execute();
			for each (var commandOrDescriptor:Object in commands)
			{
				executeCommand(commandOrDescriptor);
			}
		}
		
		public function getSubcommands():Array
		{
			return commands;
		}
	}
}