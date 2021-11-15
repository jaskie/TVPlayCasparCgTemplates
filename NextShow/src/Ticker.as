package 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.AntiAliasType;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.GridFitType;
	import flash.display.BlendMode;
	import com.greensock.easing.Sine;
	import com.greensock.easing.Linear;
	import com.greensock.TweenLite;

	
	public class Ticker extends Sprite 
	{
		public static const FINISHED:String = "Finished";

		private const textDissolveTime:Number = 0.2;
		private const animationTime:Number = 1.2;
		private const displayTime:Number = 3.0;
		private const textMargin:Number = 10;
		private const headerFontSize:int = 14;
		private const titleFontSize:int = 18;


		private var textLayer:Sprite = new Sprite();
		private var whiteRect:Shape = new Shape();
		private var darkBlueRect:Shape = new Shape();
		private var lightBlueRect:Shape = new Shape();
		private var fullWidth:Number;

		
		public function Ticker(header:String, title:String) 
		{
			var headerField:TextField = AddTextField(header, headerFontSize, false);
			headerField.x = textMargin;
			textLayer.addChild(headerField);
			var titleField:TextField = AddTextField(title, titleFontSize, true);
			titleField.x = textMargin;
			titleField.y = headerField.height - 8;
			textLayer.addChild(titleField);
			textLayer.alpha = 0;
			fullWidth = textLayer.width + 4 * textMargin;

			lightBlueRect.graphics.beginFill(0x2272e1);
			lightBlueRect.graphics.drawRect(0, 0, fullWidth, textLayer.height);
			lightBlueRect.graphics.endFill();
			lightBlueRect.width = 0;

			darkBlueRect.graphics.beginFill(0x1b579d);
			darkBlueRect.graphics.drawRect(0, 0, fullWidth, textLayer.height);
			darkBlueRect.graphics.endFill();
			darkBlueRect.width = 0;
						
			whiteRect.graphics.beginFill(0xF0F0F0);
			whiteRect.graphics.drawRect(0, 0, fullWidth, textLayer.height);
			whiteRect.graphics.endFill();
			whiteRect.width = 0;

			addChild(lightBlueRect);
			addChild(darkBlueRect);
			addChild(whiteRect);
			addChild(textLayer);
			
			super();
		}
		
		public function Show():void
		{
			TweenLite.to(lightBlueRect, animationTime * 0.5, { width: fullWidth, ease:Sine.easeIn } );
			
			TweenLite.to(new Object(), animationTime * 0.05, { onComplete: function():void // delay
			{
				TweenLite.to(darkBlueRect, animationTime * 0.55, { width: fullWidth, ease:Sine.easeIn } );
			}});
			
			TweenLite.to(new Object(), animationTime * 0.05, { onComplete: function():void { // delay
				TweenLite.to(whiteRect, animationTime * 0.7, { width: fullWidth, ease:Sine.easeIn, onComplete: function():void
				{
					TweenLite.to(textLayer, textDissolveTime, { alpha: 1.0, onComplete: IntroCompleted });			
				} 			
				});
			}});
		}
		
		public function Hide():void
		{
			TweenLite.to(textLayer, textDissolveTime, {
				alpha: 0.0, 
				ease:Sine.easeOut, 
				onComplete: function():void {
					TweenLite.to(whiteRect, animationTime * 0.7, { width: 0.0, x: whiteRect.width, ease:Linear.easeOut, onComplete: function():void 
					{
						dispatchEvent(new Event(FINISHED));
					}});
				}
			});			
		}

		private function IntroCompleted():void
		{
			removeChild(lightBlueRect);
			removeChild(darkBlueRect);
			TweenLite.to(new Object(), displayTime, { onComplete: Hide });
		}

		
		private function AddTextField(text:String, size:int, bold:Boolean, filters:Array = null) :TextField
		{
			var tf:TextField = new TextField(); 
			tf.antiAliasType = AntiAliasType.NORMAL;
			tf.autoSize = TextFieldAutoSize.RIGHT;
			tf.embedFonts = true;
			tf.multiline = false;
			
			tf.gridFitType = GridFitType.SUBPIXEL;
			
			tf.filters =  filters;
			
			tf.defaultTextFormat = new TextFormat("TVP", size, 0x1A589B, bold);
			tf.text = text;
			return tf;
		}

	}

}