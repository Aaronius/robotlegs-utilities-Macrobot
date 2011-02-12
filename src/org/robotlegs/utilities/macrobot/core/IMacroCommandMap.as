package org.robotlegs.utilities.macrobot.core
{
	import org.robotlegs.core.ICommandMap;

	/**
	 * Provides an interface for preparing and executing a command in a manner that allows for
	 * both macro management and a single point of execution.
	 * 
	 * It provides macro management by preparing an instance of a command and returning it before
	 * execution.  This allows macro commands to attach required listeners to subcommands before
	 * execution.
	 * 
	 * It provides a single point of execution because an instance of an IMacroCommandMap can
	 * replace a context's default command map.  Without this replacement, a macro command
	 * is itself responsible for executing its subcommands because the default command map is 
	 * insufficient for macro requirements.  Having a single point of command execution
	 * (the context's command map) is helpful when, for example, implementing a logging mechanism
	 * to track when any command is executed within a context.
	 * 
	 * It is not required to use an IMacroCommandMap for executing macro commands.  If one is not 
	 * used, there will not be a single point of command execution within the context as previously
	 * explained which is fine for most needs. To understand how to replace the default command map 
	 * within a context, please visit the Robotlegs forums. 
	 */ 
	public interface IMacroCommandMap extends ICommandMap
	{
		/**
		 * Instantiates and prepares a command with everything it needs to be executed but does
		 * not execute it.
		 * 
		 * @param commandClass The Class to instantiate - must have an execute() method
		 * @param payload An optional payload
		 * @param payloadClass  An optional class to inject the payload as
		 * @param named An optional name for the payload injection
		 * 
		 * @return The instantiated command.
		 * 
		 * @throws org.robotlegs.base::ContextError
		 */
		function prepare(commandClass:Class, payload:Object = null, payloadClass:Class = null, 
				named:String = ''):Object
			
		/**
		 * Executes and command that has already been prepared for execution.
		 */
		function executePrepared(command:Object):void
	}
}