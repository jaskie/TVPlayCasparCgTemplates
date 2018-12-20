package tjenkinson.scroller
{
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.display.DisplayObject;
	
	public class Scroller extends Sprite
	{
		private var theWidth:Number;
		private var elements:Array = [];
		private var speed:Number; // pixels per second
		private var moveAmount:Number; //speed / framerate
		private var lastElementId:int; // this will always increase so there will always be unique ids
		private var noElements:int = 0; // count of no of elements that have ever been. always increasing
		private var onScreen:Boolean = false; // true if there is anything on screen (even if leaving)
		private var running:Boolean = false; // true after start called, false after stopped called
		private var stopImmediatey:Boolean = false;
		private var spacing:Number; // spacing between clips (pixels)
		private var theMask:Shape;
		private var nextElementMustShow:Boolean = false;
		private var justStarted:Boolean = false;
		private var timeRemaining:Number = 0; // the time remaining before run out of elements
		
		private var bufferListeners:Vector.<BufferListener> = new Vector.<BufferListener>();
		
		// events
		public static const NO_MORE_ELEMENTS:String = "NO_MORE_ELEMENTS"; // stopped automatically bevause ran out of elements
		public static const LAST_OFF_SCREEN:String = "LAST_OFF_SCREEN"; // last element scrolled off screen
		public static const ELEMENT_REMOVED:String = "ELEMENT_REMOVED"; // element removed from list
		
		public function Scroller(theWidth:Number, speed:Number, spacing:Number=10)
		{
			this.cacheAsBitmap = true;
			this.theWidth = theWidth;
			// create the mask around object
			this.theMask = new Shape();
			updateMask(0, true);
			this.theMask.visible = false;
			addChild(this.theMask);
			this.mask = this.theMask;
			
			addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void { 
				e.currentTarget.removeEventListener(e.type, arguments.callee);
				init(e, speed, spacing ); 
				addEventListener(Event.REMOVED_FROM_STAGE, function (e:Event):void {
					e.currentTarget.removeEventListener(e.type, arguments.callee);
					stage.removeEventListener(Event.ENTER_FRAME, timerTick); 
				});
			} );
		}
		
		public function dispose():void
		{
			trace("Scroller disposed");
		}
		
		// the function passed in will be called whenever more elements are needed to keep a buffer of the time passed in
		// the listener will be called once and then wait until addElement is called before any future calls
		public function addBufferListener(f:Function, p:Array, t:Number):uint
		{
			var bufferListener:BufferListener = new BufferListener(f, p, t);
			bufferListeners.push(bufferListener);
			return bufferListener.getId();
		}
		
		public function removeBufferListener(id:uint):void
		{
			var found:Boolean = false;
			for (var i:uint=0; i<bufferListeners.length; i++)
			{
				if (bufferListeners[i].getId() == id)
				{
					bufferListeners.splice(i, 1);
					found = true;
					break;
				}
			}
			if (!found)
			{
				throw new Error("The buffer listener could not be removed as it doesn't exist.");
			}
		}
		
		public function setWidth(w:Number):void {
			if(getIsRunning()) {
				throw new Error("You can't change the width whilst the scroller is running.");
			}
			else if (getNoElementsOnScreen() !== 0) {
				throw new Error("You can't change the width whilst there are still elements scrolling.");
			}
			theWidth = w;
			updateMask(0, true);
		}
		
		private function init(e:Event, speed:Number, spacing:Number)
		{
			setSpeed(speed);
			setSpacing(spacing);
			this.stage.addEventListener(Event.ENTER_FRAME , timerTick); // run on every frame
		}
		
		private function updateMask(theMskHeight:Number, firstRun:Boolean=false)
		{
			if (!firstRun && theMskHeight <= theMask.height)
			{
				return; // only redraw the mask if necessary
			}
			if (firstRun) {
				theMask.graphics.clear();
			}
			theMask.graphics.beginFill(0x0);
			theMask.graphics.drawRect(0, 0, theWidth, theMskHeight);
			theMask.graphics.endFill();
		}
	
		public function addElement(element:DisplayObject, mustShow:Boolean=false, ignoreIfFirst:Boolean=false):int
		{
			var id:int = (getNoElements() !== 0) ? getLastElementId()+1 : 0;
			elements.push({id: id, element:element, onScreen: false, mustShow: mustShow, ignoreIfFirst: ignoreIfFirst});
			this.noElements++;
			this.lastElementId = id;
			for(var i:uint=0; i<bufferListeners.length; i++)
			{
				bufferListeners[i].clearFlag();
			}
			return id;
		}
		
		public function removeElement(id:int):void
		{
			var index:int = getArrayIndex(id);
			if (index == -1)
			{
				throw new Error("No elements exists with that id.");
			}
			removeElementIndex(index);
		}
		
		public function getTimeRemaining():Number
		{
			return timeRemaining;
		}
		
		private function removeElementIndex(index:int)
		{
			if (this.elements[index].onScreen)
			{
				throw new Error("Cannot remove element because it's on screen.");
			}
			var id:int = this.elements[index].id;
			elements.splice(index, 1);
			dispatchEvent(new ElementRemovedEvent(Scroller.ELEMENT_REMOVED, id, true, true));
		}
		
		public function setSpeed(speed:Number):void
		{
			this.speed = speed;
			this.moveAmount = speed/this.stage.frameRate;
		}
		
		public function getSpeed():Number
		{
			return this.speed;
		}
		
		// not sure whether shouold be changeable after initialisation. maybe only when nothing on screen
		private function setSpacing(val:Number)
		{
			this.spacing = val;
		}
		
		public function start():void
		{
			if (getIsRunning())
			{
				return;
			}
			//check stopping and starting has had an effect
			if (!wouldBeContinuous())
			{
				justStarted = true;
			}
			this.running = true;
		}
		
		public function stop(immediately:Boolean=false):void
		{
			this.running = false;
			if (immediately)
			{
				this.stopImmediatey = true;
				timerTick(); // don't wait for next frame. this means that when this function finishes it will definately have stopped
			}
		}
		
		public function clearAll():void
		{
			if (getIsRunning())
			{
				throw new Error("Can't remove all elements because I'm still running.");
			}
			removeChildren();
			addChild(theMask);
			elements = [];
		}
		
		private function getLastElementId():int
		{
			if (getNoElements() === 0)
			{
				throw new Error("No elements.");
			}
			return this.lastElementId;
		}
		
		public function getNoElements():int
		{
			return this.noElements;
		}
		
		public function getRemainingElements():int
		{
			var count:int = elements.length;
			if (!wouldBeContinuous())
			{
				// any elements that are meant to be ignored will be so deduct them from remaining elements
				for (var i:int=0; i<elements.length; i++)
				{
					if (elements[i].ignoreIfFirst)
					{
						count--;
					}
					else
					{
						break;
					}
				}
			}
			return count;
		}
		
		public function getOnScreen():Boolean
		{
			return this.onScreen;
		}
		
		public function getNoElementsOnScreen():int
		{
			var count:int = 0;
			for (var i:int=0; i<elements.length; i++)
			{
				if (elements[i].onScreen)
				{
					count++;
				}
				else {
					break;
				}
			}
			return count;
		}
		
		public function getIsRunning():Boolean
		{
			return this.running;
		}
		
		public function getActualWidth():Number
		{
			var lastElement:DisplayObject = null;
			for (var i:int=0; i<elements.length; i++)
			{
				if (elements[i].onScreen)
				{
					lastElement = elements[i].element;
				}
			}
			if (lastElement == null) {
				return 0;
			}
			else {
				var val:Number = lastElement.x + lastElement.width + spacing;
				return val > theWidth ? theWidth : val;
			}
		}
		
		// returns true if starting scrolling again would not result in a gap.
		private function wouldBeContinuous():Boolean
		{
			if (getIsRunning())
			{
				return true;
			}
			
			var lastElement:Object = null;
			for (var i:int=0; i<elements.length; i++)
			{
				if (elements[i].onScreen)
				{
					lastElement = elements[i];
				}
				else
				{
					break;
				}
			}
			
			// if it can't find the last element on screen (which should never happen!) OR the last element on screen is now completley on screen
			return (!(lastElement == null || lastElement.element.x+lastElement.element.width+this.spacing < this.theWidth));
		}
	
		// runs on each frame
		private function timerTick(e:Event=null):void
		{
			if (this.stopImmediatey)
			{
				// remove any elements that are on screen or any subsequent elements that has mustShow set
				this.stopImmediatey = false;
				nextElementMustShow = false;
				var elementsToRemove:Array = [];
				for (var i:int=0; i<elements.length; i++)
				{
					if (elements[i].onScreen || elements[i].mustShow)
					{
						if (elements[i].onScreen)
						{
							removeChild(elements[i].element);
						}
						elements[i].onScreen = false; // removeElement() will only remove off screen
						elementsToRemove.push(i);
					}
					else
					{
						break;
					}
				}
				for(var i:int=elementsToRemove.length-1; i>=0; i--)
				{
					removeElementIndex(elementsToRemove[i]);
				}
			}
			else
			{
				if (getIsRunning() || nextElementMustShow)
				{
					// determine if next element needs to be added
					var lastElement:Object; // last element on screen
					var nextElement:Object;
					var found:Boolean = false;
					var foundNextElement:Boolean = false;
					var elementsToRemove:Array = [];
					nextElementMustShow = false;
					
					for (var i:int=0; i<elements.length; i++)
					{
						if (elements[i].onScreen)
						{
							found = true;
							lastElement = elements[i];
						}
						else if (justStarted && elements[i].ignoreIfFirst)
						{
							elementsToRemove.push(i);
						}
						else
						{
							nextElement = elements[i];
							nextElementMustShow = elements[i].mustShow;
							foundNextElement = true;
							break;
						}
					}
					// elements must be removed here and not in loop bacause it changes indexing. must be in reverse
					for (var i:int=elementsToRemove.length-1; i>=0; i--)
					{
						removeElementIndex(elementsToRemove[i]);
					}
					// if not found an element on screen OR the last element on screen will be completley on screen in next shift
					if (!found || lastElement.element.x+lastElement.element.width+this.spacing-this.moveAmount < this.theWidth) // ready to add one
					{
						if (foundNextElement)
						{
							// set the position off screen to start
							nextElement.element.x = this.theWidth;
							nextElement.element.cacheAsBitmap=true;
							nextElement.onScreen = true;
							this.addChildAt(nextElement.element,0);
							this.onScreen = true; // update global on screen status
						}
						else // there are no more elements to add
						{
							stop();
							dispatchEvent(new Event(Scroller.NO_MORE_ELEMENTS, true, true));
						}
					}
					justStarted = false;
				}
				// shift everything on screen across to left and remove if results in off screen
				var elementIndexesToRemove:Array = new Array();
				for (var i:int=0; i<elements.length; i++)
				{
					if (elements[i].onScreen)
					{
						elements[i].element.x -= this.moveAmount; // move it
						if (elements[i].element.x + elements[i].element.width < 0)
						{
							elementIndexesToRemove.push(i);
						}
					}
				}
				for each (var i:int in elementIndexesToRemove) {
					elements[i].onScreen = false; // removeElement() will only remove offscreen
					removeChild(this.elements[i].element); // remove element
					removeElementIndex(i);
				}
				updateMask(this.height);
			}
			// update global onScreen
			var found:Boolean = false;
			for (var i:int=0; i<elements.length; i++)
			{
				if (elements[i].onScreen)
				{
					found = true;
					break;
				}
			}
			
			if (!found && onScreen)
			{
				dispatchEvent(new Event(Scroller.LAST_OFF_SCREEN, true, true));
			}
			this.onScreen = found;
			
			// calculate the amount of time left (milliseconds) in the scroller until the last element appears fully on screen
			var distanceRemaining:Number = 0;
			var lastOnScreen:Object = null;
			var hadFirstPending:Boolean = false;
			
			for (var i:int=0; i<elements.length; i++)
			{
				// if there is something on screen and the current element is on screen. onScreen check is for efficiency
				if (onScreen && elements[i].onScreen)
				{
					lastOnScreen = elements[i];
				}
				else
				{
					// element that's not on screen
					
					// only consider elements that will be shown
					if (hadFirstPending || (wouldBeContinuous() || !elements[i].ignoreIfFirst))
					{
						hadFirstPending = true;
						distanceRemaining += elements[i].element.width;
					}
				}
			}
			// timeRemaining is now the time of all pending elements
			
			// now add distance remaining for last scrolling element
			if (lastOnScreen != null)
			{
				distanceRemaining += (lastOnScreen.element.x + lastOnScreen.element.width + this.spacing) - this.theWidth;
			}
			var tempTimeRemaining:Number = (distanceRemaining / speed) * 1000;
			timeRemaining = tempTimeRemaining > 0 ? tempTimeRemaining : 0;
			
			// call any buffer listeners
			for(var i:int=0; i<bufferListeners.length; i++)
			{
				if (timeRemaining <= bufferListeners[i].getTime())
				{
					bufferListeners[i].callListener();
				}
			}
		}
		
		private function getArrayIndex(id:int):int
		{
			for (var i:int=0; i<elements.length; i++)
			{
				if (elements[i].id == id)
				{
					return i;
				}
			}
			return -1;
		}
		
	}
}


class BufferListener
{
	private static var idCount:uint = 0;
	
	private var f:Function;
	private var p:Array; // params
	private var t:Number;
	private var id:uint;
	private var fnCalled:Boolean = false;
	
	public function BufferListener(f:Function, p:Array, t:Number):void
	{
		this.f = f;
		this.p = p;
		this.t = t;
		this.id = idCount;
		idCount++;
	}
	
	public function callListener():void
	{
		if (fnCalled)
		{
			return;
		}
		fnCalled = true;
		f.apply(NaN, p);
	}

	public function getTime():Number
	{
		return t;
	}
	
	public function getId():uint
	{
		return id;
	}
	
	public function clearFlag():void
	{
		fnCalled = false;
	}
}