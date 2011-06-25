/*
* Copyright (c) 2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/
package org.robotlegs.utilities.macrobot
{
	import org.robotlegs.utilities.macrobot.core.MacroBase;

	/**
	 * A command for executing multiple other commands in parallel.  All commands will start
	 * execution as simultaneously as possible in the order they were added.  This command will
	 * not be marked complete until all commands have completed.  It can be nested inside other 
	 * parallel or sequence commands.
	 */
	public class ParallelCommand extends MacroBase
	{
		/**
		 * The number of commands currently executing.
		 */
		protected var numCommandsExecuting:uint = 0;
		
		/**
		 * @inheritDoc
		 */
		override public function execute():void
		{
			super.execute();
			if (commands && commands.length > 0)
			{
				numCommandsExecuting = commands.length;
				for each (var command:Object in commands)
				{
					success ? executeCommand(command) : dispatchComplete(false);
				}
			}
			else
			{
				dispatchComplete(true);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function commandCompleteHandler(success:Boolean):void
		{
			super.commandCompleteHandler(success);
			this.success &&= success;
			numCommandsExecuting--;
			
			if (numCommandsExecuting == 0)
			{
				dispatchComplete(this.success);
			}
		}
	}
}