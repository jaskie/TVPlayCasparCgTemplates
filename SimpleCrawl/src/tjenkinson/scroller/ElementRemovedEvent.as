package tjenkinson.scroller
{
	import flash.events.Event;
	public class ElementRemovedEvent extends Event
	{
		private var elementId:int;

		public function ElementRemovedEvent(type:String, id:int, bubbles:Boolean=false, cancelable:Boolean=false):void
		{
			//we call the super class Event
			super(type, bubbles, cancelable);
			this.elementId = id;
		}

		public function getId():int
		{
			return elementId;
		}
	}
}