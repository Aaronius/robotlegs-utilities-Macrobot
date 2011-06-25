package test.org.robotlegs.utilities.macrobot.support
{
	import org.robotlegs.mvcs.Command;
	
	public class TestSyncCommand extends Command
	{
		protected var event:SubcommandConfigEvent;
		
		public function TestSyncCommand(event:SubcommandConfigEvent)
		{
			super();
			this.event = event;
		}
		
		override public function execute():void
		{
			dispatch(new SubcommandStatusEvent(SubcommandStatusEvent.EXECUTED, event.id));
			dispatch(new SubcommandStatusEvent(SubcommandStatusEvent.COMPLETE, event.id));
			super.execute();
		}
	}
}