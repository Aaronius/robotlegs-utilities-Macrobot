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
	 * A command for executing multiple other commands in sequence in the order they were added.
	 * In other words, the second command will not begin execution until the first command has
	 * completed.  This command will not be marked complete until all commands have completed.  It 
	 * can be nested inside other parallel or sequence commands.
	 */
	public class SequenceCommand extends MacroBase
	{
		/**
		 * Whether the sequence command should execute subsequent commands when a command fails.
		 * If <code>atomic</code> is true, the sequence command will continue executing commands.
		 */
		public var atomic:Boolean = true;
		
		/**
		 * The index of the command in execution.
		 */
		protected var executionIndex:uint;
		
		/**
		 * @inheritDoc
		 */
		override public function execute():void
		{
			super.execute();
			executionIndex = 0; // undo/redo compatibility
			executeNext();
		}
		
		/**
		 * Executes the next subcommand.
		 */
		protected function executeNext():void
		{
			commands && executionIndex < commands.length ? 
					executeCommand(commands[executionIndex]) :
					dispatchComplete(success);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function commandCompleteHandler(success:Boolean):void
		{
			super.commandCompleteHandler(success);
			this.success &&= success;
			executionIndex++;
			(atomic || this.success) ? executeNext() : dispatchComplete(false);
		}
	}
}