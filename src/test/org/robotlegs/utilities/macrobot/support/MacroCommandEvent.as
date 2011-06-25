package test.org.robotlegs.utilities.macrobot.support
{
	import flash.events.Event;
	
	public class MacroCommandEvent extends Event
	{
		public static const COMPLETE:String = 'macroCommandComplete';
		
		public var success:Boolean;
		
		public function MacroCommandEvent(type:String, success:Boolean, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.success = success;
		}
		
		override public function clone():Event
		{
			return new MacroCommandEvent(type, success, bubbles, cancelable);
		}
	}
}