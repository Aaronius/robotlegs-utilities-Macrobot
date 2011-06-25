package test.org.robotlegs.utilities.macrobot.support
{
	import flash.events.IEventDispatcher;
	
	import org.robotlegs.base.CommandMap;
	import org.robotlegs.core.IInjector;
	import org.robotlegs.core.IReflector;
	
	public class TestCommandMap extends CommandMap
	{
		public function TestCommandMap(eventDispatcher:IEventDispatcher, injector:IInjector, reflector:IReflector)
		{
			super(eventDispatcher, injector, reflector);
		}
		
		public function get isCommandDetained():Boolean
		{
			for (var command:* in detainedCommands)
			{
				return true;
			}
			return false;
		}
	}
}