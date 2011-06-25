package test.org.robotlegs.utilities.macrobot
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import flexunit.framework.Assert;
	
	import org.robotlegs.adapters.SwiftSuspendersInjector;
	import org.robotlegs.adapters.SwiftSuspendersReflector;
	import org.robotlegs.base.MediatorMap;
	import org.robotlegs.core.ICommandMap;
	import org.robotlegs.core.IInjector;
	import org.robotlegs.core.IMediatorMap;
	import org.robotlegs.core.IReflector;
	import org.robotlegs.utilities.macrobot.MacroCommandMap;
	import org.robotlegs.utilities.macrobot.core.IMacroCommandMap;
	
	import test.org.robotlegs.utilities.macrobot.support.SubcommandConfigEvent;
	import test.org.robotlegs.utilities.macrobot.support.SubcommandStatusEvent;
	import test.org.robotlegs.utilities.macrobot.support.TestAsyncCommand;
	import test.org.robotlegs.utilities.macrobot.support.TestSyncCommand;


	public class MacroCommandMapTest
	{		
		protected var reflector:IReflector;
		protected var injector:IInjector;
		protected var commandMap:IMacroCommandMap;
		protected var eventDispatcher:IEventDispatcher;
		
		protected var commandExecuted:Boolean;
		
		[Before]
		public function setUp():void
		{
			var contextView:Sprite = new Sprite();
			reflector = new SwiftSuspendersReflector();
			eventDispatcher = new EventDispatcher();
			injector = new SwiftSuspendersInjector();
			injector.mapValue(IInjector, injector);
			injector.mapValue(IReflector, reflector);
			injector.mapValue(DisplayObjectContainer, contextView);
			commandMap = new MacroCommandMap(eventDispatcher, injector, reflector);
			injector.mapValue(ICommandMap, commandMap);
			injector.mapValue(IEventDispatcher, eventDispatcher);
			injector.mapValue(IMediatorMap, new MediatorMap(contextView, injector, reflector));
		}
		
		[After]
		public function tearDown():void
		{
			reflector = null;
			injector = null;
			commandMap = null;
			eventDispatcher = null;
			commandExecuted = false;
		}
		
		[Test]
		public function testPrepare():void
		{
			var command:Object = commandMap.prepare(
					TestAsyncCommand, new SubcommandConfigEvent(SubcommandConfigEvent.CONFIG));
			Assert.assertTrue("Prepared command isn't of expected type.", command is TestAsyncCommand);
			Assert.assertNotNull("Injection didn't occur for command.", TestAsyncCommand(command).event);
		}
		
		[Test]
		public function testExecutePrepared():void
		{
			eventDispatcher.addEventListener(SubcommandStatusEvent.COMPLETE, completeHandler, false, 0, true);
			var command:Object = new TestSyncCommand(new SubcommandConfigEvent(SubcommandConfigEvent.CONFIG));
			injector.injectInto(command);
			commandMap.executePrepared(command);
			Assert.assertTrue("Command never executed.", commandExecuted);
		}
		
		[Test]
		public function testExecute():void
		{
			eventDispatcher.addEventListener(SubcommandStatusEvent.COMPLETE, completeHandler, false, 0, true);
			commandMap.execute(TestSyncCommand, new SubcommandConfigEvent(SubcommandConfigEvent.CONFIG));
			Assert.assertTrue("Command never executed.", commandExecuted);
		}
		
		protected function completeHandler(event:SubcommandStatusEvent):void
		{
			commandExecuted = true;
		}
	}
}