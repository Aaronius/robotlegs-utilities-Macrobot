package test.org.robotlegs.utilities.macrobot.support
{
	import flash.events.Event;
	
	public class SubcommandConfigEvent extends Event
	{
		public static const CONFIG:String = 'config';
		
		public var id:uint;
		public var asyncDelay:uint;
		public var completionDirective:String;
		
		public function SubcommandConfigEvent(type:String, id:uint = 0, asyncDelay:uint = 1, 
										   completionDirective:String = 'success',
										   bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.id = id;
			this.asyncDelay = asyncDelay;
			this.completionDirective = completionDirective;
		}
		
		override public function clone():Event
		{
			return new SubcommandConfigEvent(type, id, asyncDelay, completionDirective, bubbles, cancelable);
		}
	}
}