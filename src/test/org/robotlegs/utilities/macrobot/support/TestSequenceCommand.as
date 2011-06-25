package test.org.robotlegs.utilities.macrobot.support
{
	import org.robotlegs.utilities.macrobot.SequenceCommand;
	
	public class TestSequenceCommand extends SequenceCommand
	{
		override protected function dispatchComplete(success:Boolean):void
		{
			super.dispatchComplete(success);
			dispatch(new MacroCommandEvent(MacroCommandEvent.COMPLETE, success));
		}
	}
}