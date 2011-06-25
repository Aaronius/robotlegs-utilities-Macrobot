package test.org.robotlegs.utilities.macrobot.base
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import flexunit.framework.Assert;
	
	import org.flexunit.async.Async;
	import org.robotlegs.adapters.SwiftSuspendersInjector;
	import org.robotlegs.adapters.SwiftSuspendersReflector;
	import org.robotlegs.base.CommandMap;
	import org.robotlegs.base.MediatorMap;
	import org.robotlegs.core.ICommandMap;
	import org.robotlegs.core.IInjector;
	import org.robotlegs.core.IMediatorMap;
	import org.robotlegs.core.IReflector;
	import org.robotlegs.utilities.macrobot.MacroCommandMap;
	import org.robotlegs.utilities.macrobot.core.MacroBase;
	
	import test.org.robotlegs.utilities.macrobot.support.CompletionDirective;
	import test.org.robotlegs.utilities.macrobot.support.MacroCommandEvent;
	import test.org.robotlegs.utilities.macrobot.support.SubcommandConfigEvent;
	import test.org.robotlegs.utilities.macrobot.support.SubcommandStatusEvent;
	import test.org.robotlegs.utilities.macrobot.support.TestAsyncCommand;
	import test.org.robotlegs.utilities.macrobot.support.TestMacroCommandMap;
	import test.org.robotlegs.utilities.macrobot.support.TestSyncCommand;

	public class MacroTestBase
	{		
		protected var commandClass:Class;
		
		protected var reflector:IReflector;
		protected var injector:IInjector;
		protected var commandMap:CommandMap;
		protected var eventDispatcher:IEventDispatcher;
		protected var statusEvents:Vector.<SubcommandStatusEvent>;
		
		public function setUp():void
		{
			var contextView:Sprite = new Sprite();
			reflector = new SwiftSuspendersReflector();
			eventDispatcher = new EventDispatcher();
			injector = new SwiftSuspendersInjector();
			injector.mapValue(IInjector, injector);
			injector.mapValue(IReflector, reflector);
			injector.mapValue(DisplayObjectContainer, contextView);
			commandMap = new CommandMap(eventDispatcher, injector, reflector);
			injector.mapValue(ICommandMap, commandMap);
			injector.mapValue(IEventDispatcher, eventDispatcher);
			injector.mapValue(IMediatorMap, new MediatorMap(contextView, injector, reflector));
			
			statusEvents = new Vector.<SubcommandStatusEvent>()
		}
		
		public function tearDown():void
		{
			reflector = null;
			injector = null;
			commandMap = null;
			eventDispatcher = null;
			statusEvents = null;
		}
		
		public function testSyncCommandInstanceExecution():void
		{
			var subcommandFactory:Function = function(command:MacroBase, id:uint):void
			{
				var subcommand:Object = new TestSyncCommand(
					new SubcommandConfigEvent(SubcommandConfigEvent.CONFIG, id));
				command.addCommandInstance(subcommand);
			}
			
			testUsingFactory(subcommandFactory);
		}
		
		public function testAsyncCommandInstanceExecution():void
		{
			var subcommandFactory:Function = function(command:MacroBase, id:uint):void
			{
				var subcommand:Object = new TestAsyncCommand(
					new SubcommandConfigEvent(SubcommandConfigEvent.CONFIG, id));
				command.addCommandInstance(subcommand);
			}
			
			testUsingFactory(subcommandFactory);
		}
		
		public function testAsyncAndSyncCommandInstanceExecution():void
		{
			var subcommandFactory:Function = function(command:MacroBase, id:uint):void
			{
				var config:SubcommandConfigEvent = new SubcommandConfigEvent(SubcommandConfigEvent.CONFIG, id);
				var subcommand:Object = id % 2 == 0 ? new TestAsyncCommand(config) : new TestSyncCommand(config);
				command.addCommandInstance(subcommand);
			}
			
			testUsingFactory(subcommandFactory);
		}
		
		public function testSyncCommandDescriptorExecution():void
		{
			var subcommandFactory:Function = function(command:MacroBase, id:uint):void
			{
				command.addCommand(TestSyncCommand, new SubcommandConfigEvent(SubcommandConfigEvent.CONFIG, id));
			}
			
			testUsingFactory(subcommandFactory);
		}
		
		public function testAsyncCommandDescriptorExecution():void
		{
			var subcommandFactory:Function = function(command:MacroBase, id:uint):void
			{
				command.addCommand(TestAsyncCommand, new SubcommandConfigEvent(SubcommandConfigEvent.CONFIG, id));
			}
			
			testUsingFactory(subcommandFactory);
		}
		
		public function testAsyncAndSyncCommandDescriptorExecution():void
		{
			var subcommandFactory:Function = function(command:MacroBase, id:uint):void
			{
				var config:SubcommandConfigEvent = new SubcommandConfigEvent(SubcommandConfigEvent.CONFIG, id);
				var subcommandClass:Class = id % 2 == 0 ? TestAsyncCommand : TestSyncCommand;
				command.addCommand(subcommandClass, config);
			}
			
			testUsingFactory(subcommandFactory);
		}
		
		public function testNoCommandExecution():void
		{
			testUsingFactory(null, 0);
		}
		
		public function testFailedExecution():void
		{
			var command:MacroBase = new commandClass();
			
			for (var i:uint = 1; i < 11; i++)
			{
				var completionDirective:String = i == 2 ? 
						CompletionDirective.FAILURE :
						CompletionDirective.SUCCESS;
				command.addCommand(TestAsyncCommand, 
						new SubcommandConfigEvent(SubcommandConfigEvent.CONFIG, i, 1, completionDirective));
			}
			
			injector.injectInto(command);
			
			var asyncHandler:Function = Async.asyncHandler(this, 
					testFailedExecution_completeHandler, 5000, 
					null, 
					macro_timeoutHandler)
			eventDispatcher.addEventListener(MacroCommandEvent.COMPLETE, asyncHandler);
			
			command.execute();
		}
		
		public function testExecutionWithMacroCommandMap():void
		{
			commandMap = new TestMacroCommandMap(eventDispatcher, injector, reflector);
			injector.mapValue(ICommandMap, commandMap);
			
			var subcommandFactory:Function = function(command:MacroBase, id:uint):void
			{
				var config:SubcommandConfigEvent = new SubcommandConfigEvent(SubcommandConfigEvent.CONFIG, id);
				var subcommandClass:Class = id % 2 == 0 ? TestAsyncCommand : TestSyncCommand;
				command.addCommand(subcommandClass, config);
			}
			
			testUsingFactory(subcommandFactory, 10, testExecutionWithMacroCommandMap_completeHandler);
		}
		
		protected function testExecutionWithMacroCommandMap_completeHandler(event:MacroCommandEvent, passThru:Object):void
		{
			macro_completeHandler(event, passThru);
			Assert.assertEquals('execute() should not have been called when using MacroCommandMap.', 
					TestMacroCommandMap(commandMap).executeCallCount, 0);
			Assert.assertEquals('prepare() should have been called once for each subcommand.', 
					TestMacroCommandMap(commandMap).prepareCallCount, 10);
			Assert.assertEquals('executePrepared() should have been called once for each subcommand.', 
					TestMacroCommandMap(commandMap).executePreparedCallCount, 10);
		}
		
		protected function testFailedExecution_completeHandler(event:MacroCommandEvent, passThru:Object):void
		{
			Assert.assertFalse('The macro command should have failed since a subcommand failed.', event.success);
		}
		
		protected function testUsingFactory(subcommandFactory:Function, numSubcommands:uint = 10, completeHandler:Function = null):void
		{
			var command:MacroBase = new commandClass();
			var ids:Vector.<uint> = new Vector.<uint>();
			
			for (var i:uint = 1; i < numSubcommands + 1; i++)
			{
				subcommandFactory(command, i);
				ids.push(i);
			}
			
			injector.injectInto(command);
			eventDispatcher.addEventListener(SubcommandStatusEvent.EXECUTED, subcommand_statusHandler);
			eventDispatcher.addEventListener(SubcommandStatusEvent.COMPLETE, subcommand_statusHandler);
			
			completeHandler ||= macro_completeHandler;
			
			var asyncHandler:Function = Async.asyncHandler(this, 
				completeHandler, 5000, 
				{ids: ids}, 
				macro_timeoutHandler)
			eventDispatcher.addEventListener(MacroCommandEvent.COMPLETE, asyncHandler);
			
			command.execute();
		}
		
		protected function macro_completeHandler(event:MacroCommandEvent, passThru:Object):void
		{
			Assert.assertEquals('The incorrect number of commands completed.', passThru.ids.length * 2, statusEvents.length);
			Assert.assertTrue('Subcommands were not completed as expected.', wereSubcommandsExecutedAsExpected(passThru.ids));
		}
		
		protected function macro_timeoutHandler(passThru:Object):void
		{
			Assert.fail('Macro command did not complete.');
		}
		
		protected function wereSubcommandsExecutedAsExpected(ids:Vector.<uint>):Boolean
		{
			// to be overridden
			return true;
		}
		
		protected function subcommand_statusHandler(event:SubcommandStatusEvent):void
		{
			if (statusEvents)
			{
				statusEvents.push(event);
			}
		}
	}
}