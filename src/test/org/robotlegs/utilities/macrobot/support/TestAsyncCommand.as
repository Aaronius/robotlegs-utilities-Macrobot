package test.org.robotlegs.utilities.macrobot.support
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.robotlegs.utilities.macrobot.AsyncCommand;
	
	public class TestAsyncCommand extends AsyncCommand
	{
		public var event:SubcommandConfigEvent;
		protected var timer:Timer;
		
		public function TestAsyncCommand(event:SubcommandConfigEvent)
		{
			super();
			this.event = event;
		}

		override public function execute():void
		{
			dispatch(new SubcommandStatusEvent(SubcommandStatusEvent.EXECUTED, event.id));
			
			super.execute();
			
			if (event.asyncDelay == 0)
			{
				handleCompletion();
			}
			else
			{
				timer = new Timer(event.asyncDelay, 1);
				timer.addEventListener(TimerEvent.TIMER_COMPLETE, timer_completeHandler);
				timer.start();
			}
		}
		
		protected function timer_completeHandler(e:TimerEvent):void
		{
			timer.removeEventListener(TimerEvent.TIMER_COMPLETE, timer_completeHandler);
			timer = null;
			handleCompletion();
		}
		
		protected function handleCompletion():void
		{
			if (event.completionDirective != CompletionDirective.PREVENT_COMPLETION)
			{
				dispatchComplete(event.completionDirective == CompletionDirective.SUCCESS);
			}
		}
		
		override protected function dispatchComplete(success:Boolean):void
		{
			dispatch(new SubcommandStatusEvent(SubcommandStatusEvent.COMPLETE, event.id));
			super.dispatchComplete(success);
		}
	}
}