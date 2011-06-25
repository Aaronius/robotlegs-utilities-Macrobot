package test.org.robotlegs.utilities.macrobot.support
{
	import org.robotlegs.utilities.macrobot.ParallelCommand;
	
	public class TestParallelCommand extends ParallelCommand
	{
		override protected function dispatchComplete(success:Boolean):void
		{
			super.dispatchComplete(success);
			dispatch(new MacroCommandEvent(MacroCommandEvent.COMPLETE, success));
		}
	}
}