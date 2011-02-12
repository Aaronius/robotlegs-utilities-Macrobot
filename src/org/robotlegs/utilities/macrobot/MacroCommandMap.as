package org.robotlegs.utilities.macrobot
{
	import flash.events.IEventDispatcher;
	
	import org.robotlegs.base.CommandMap;
	import org.robotlegs.core.IInjector;
	import org.robotlegs.core.IReflector;
	import org.robotlegs.utilities.macrobot.core.IMacroCommandMap;
	
	/**
	 * A <code>IMacroCommandMap</code> implementation
	 */
	public class MacroCommandMap extends CommandMap implements IMacroCommandMap
	{
		public function MacroCommandMap(eventDispatcher:IEventDispatcher, injector:IInjector, 
				reflector:IReflector)
		{
			super(eventDispatcher, injector, reflector);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function execute(commandClass:Class, payload:Object=null, 
				payloadClass:Class=null, named:String=""):void
		{
			var command:Object = prepare(commandClass, payload, payloadClass, named);
			executePrepared(command);
		}
		
		/**
		 * @inheritDoc
		 */
		public function prepare(commandClass:Class, payload:Object = null, 
				payloadClass:Class = null, named:String = ''):Object
		{
			verifyCommandClass(commandClass);
			
			if (payload != null || payloadClass != null)
			{
				payloadClass ||= reflector.getClass(payload);
				injector.mapValue(payloadClass, payload, named);
			}
			
			var command:Object = injector.instantiate(commandClass);
			
			if (payload !== null || payloadClass != null)
				injector.unmap(payloadClass, named);
			
			return command;
		}
		
		/**
		 * @inheritDoc
		 */
		public function executePrepared(command:Object):void
		{
			command.execute();
		}
	}
}