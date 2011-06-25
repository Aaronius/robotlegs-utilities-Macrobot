package test.org.robotlegs.utilities.macrobot.support
{
	import flash.events.IEventDispatcher;
	
	import org.robotlegs.core.IInjector;
	import org.robotlegs.core.IReflector;
	import org.robotlegs.utilities.macrobot.MacroCommandMap;
	
	public class TestMacroCommandMap extends MacroCommandMap
	{
		public var executeCallCount:uint;
		public var executePreparedCallCount:uint;
		public var prepareCallCount:uint;
		
		public function TestMacroCommandMap(eventDispatcher:IEventDispatcher, injector:IInjector, reflector:IReflector)
		{
			super(eventDispatcher, injector, reflector);
		}
		
		override public function execute(commandClass:Class, payload:Object=null, payloadClass:Class=null, named:String=""):void
		{
			executeCallCount++;
			super.execute(commandClass, payload, payloadClass, named);
		}
		
		override public function executePrepared(command:Object):void
		{
			executePreparedCallCount++;
			super.executePrepared(command);
		}
		
		override public function prepare(commandClass:Class, payload:Object=null, payloadClass:Class=null, named:String=''):Object
		{
			prepareCallCount++;
			return super.prepare(commandClass, payload, payloadClass, named);
		}
	}
}