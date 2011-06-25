package test.org.robotlegs.utilities.macrobot.support
{
	import flash.events.Event;
	
	public class SubcommandStatusEvent extends Event
	{
		public static const EXECUTED:String = 'subcommandExecuted';
		public static const COMPLETE:String = 'subcommandComplete';
		
		public var id:uint;
				
		public function SubcommandStatusEvent(type:String, id:uint, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.id = id;
		}
		
		override public function clone():Event
		{
			return new SubcommandStatusEvent(type, id, bubbles, cancelable);
		}
	}
}