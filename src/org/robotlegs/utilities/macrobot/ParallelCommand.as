/*
* Copyright (c) 2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/
package org.robotlegs.utilities.macrobot
{
	import org.robotlegs.utilities.macrobot.core.MacroBase;

	public class ParallelCommand extends MacroBase
	{
		protected var numIncompleteExecutions:uint = 0;
		
		override public function execute():void
		{
			super.execute();
			if (commands.length > 0)
			{
				numIncompleteExecutions = commands.length;
				for each (var command:Object in commands)
				{
					(atomic || success) ? executeCommand(command) : dispatchComplete(false);
				}
			}
			else
			{
				dispatchComplete(true);
			}
		}
		
		override protected function commandCompleteHandler(success:Boolean):void
		{
			super.commandCompleteHandler(success);
			this.success &&= success;
			numIncompleteExecutions--;
			
			if (numIncompleteExecutions == 0)
			{
				dispatchComplete(this.success);
			}
		}
	}
}