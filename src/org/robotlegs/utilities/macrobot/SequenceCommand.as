/*
* Copyright (c) 2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/
package org.robotlegs.utilities.macrobot
{
	import org.robotlegs.utilities.macrobot.core.MacroBase;
	
	import flash.events.Event;
	
	import org.robotlegs.mvcs.Command;

	public class SequenceCommand extends MacroBase
	{
		protected var executionIndex:uint;
		
		override public function execute():void
		{
			super.execute();
			executeNext();
		}
		
		protected function executeNext():void
		{
			executionIndex < commands.length ? 
					executeCommand(commands[executionIndex]) :
					dispatchComplete(success);
		}
		
		override protected function commandCompleteHandler(success:Boolean):void
		{
			super.commandCompleteHandler(success);
			this.success &&= success;
			executionIndex++;
			(this.success || !atomic) ? executeNext() : dispatchComplete(false);
		}
	}
}