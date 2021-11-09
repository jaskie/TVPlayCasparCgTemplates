package 
{
	import Ticker;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader; 
	import flash.net.URLRequest;
	import flash.events.UncaughtErrorEvent;
	import flash.xml.XMLDocument
	import flash.system.System;
	import se.svt.caspar.template.CasparTemplate;
	import com.greensock.TweenLite;

	
	
	[SWF(width=1024,height=576, frameRate="50")]
	public class Main extends CasparTemplate
	{		
		//Embed the fonts, important to set the embedAsCFF to false!
		
		/*
		[Embed(source="../assets/ARIALBD.TTF", fontFamily="Arial", fontWeight = FontWeight.BOLD, fontStyle="regular", embedAsCFF = "false")]
		private var _fontArialBold:Class;
		[Embed(source="../assets/ARIAL.TTF", fontFamily="Arial", fontWeight = FontWeight.NORMAL, fontStyle="regular", embedAsCFF = "false")]
		private var _fontArial:Class;
		*/
		/*
		[Embed(source="../assets/ARIALBI.TTF", fontFamily="Arial", fontWeight = FontWeight.BOLD, fontStyle="italic", embedAsCFF = "false")]
		private var _fontArialBoldItalic:Class;
		[Embed(source="../assets/ARIALI.TTF", fontFamily="Arial", fontWeight = FontWeight.NORMAL, fontStyle="italic", embedAsCFF = "false")]
		private var _fontArialItalic:Class;
		
		[Embed(source="../assets/TIMESBD.TTF", fontFamily="Times", fontWeight = FontWeight.BOLD, fontStyle="regular", embedAsCFF = "false")]
		private var _fontTimesBold:Class;
		[Embed(source="../assets/TIMES.TTF", fontFamily="Times", fontWeight = FontWeight.NORMAL, fontStyle="regular", embedAsCFF = "false")]
		private var _fontTimes:Class;
		[Embed(source="../assets/TIMESBI.TTF", fontFamily="Times", fontWeight = FontWeight.BOLD, fontStyle="italic", embedAsCFF = "false")]
		private var _fontTimesBoldItalic:Class;
		[Embed(source="../assets/TIMESI.TTF", fontFamily="Times", fontWeight = FontWeight.NORMAL, fontStyle="italic", embedAsCFF = "false")]
		private var _fontTimesItalic:Class;
		[Embed(source="../assets/BreuerText-Medium.ttf", fontFamily="BreuerText-Medium", fontWeight = FontWeight.NORMAL, fontStyle="regular", embedAsCFF = "false")]
		private var _fontBreuerTextMedium:Class;
		[Embed(source="../assets/BreuerText-Regular.ttf", fontFamily="BreuerText", fontWeight = FontWeight.NORMAL, fontStyle="regular", embedAsCFF = "false")]
		private var _fontBreuerTextRegular:Class;
		[Embed(source="../assets/BreuerText-Bold.ttf", fontFamily="BreuerText", fontWeight = FontWeight.BOLD, fontStyle="regular", embedAsCFF = "false")]
		private var _fontBreuerTextBold:Class;
		*/
		
		[Embed(source="../assets/Lato-Medium.ttf", fontFamily="Lato", fontWeight = FontWeight.NORMAL, fontStyle="regular", embedAsCFF = "false")]
		private var _fontLatoMedium:Class;
		[Embed(source="../assets/Lato-Bold.ttf", fontFamily="Lato", fontWeight = FontWeight.BOLD, fontStyle="regular", embedAsCFF = "false")]
		private var _fontLatoBold:Class;

		private const positionX:Number = 900; // counting from right side, in 1024 px scale
		private const positionY:Number = 60; //from top
		
		private var next:Ticker;
		
		public function Main():void 
		{
			TraceToLog("Main constructor entered");
			this.originalFrameRate = 50;
			this.originalWidth = 1024;
			this.originalHeight = 576;
			this.description = new XML(
				 <template version="1.0.0" authorName="Jerzy Jaśkiewicz" authorEmail="jurek@tvp.pl" templateInfo="Next to play notify ticker" originalWidth="720" originalHeight="576" originalFrameRate="50" >
				 	<components>
					</components>
					<keyframes>
					</keyframes>
					<parameters>
					</parameters>
				</template>			
			);
			CONFIG::debug {
				graphics.beginFill(0x808080, 1);
				graphics.drawRect(0, 0, originalWidth, originalHeight);
				graphics.endFill();
				SetData(new XML(
				<templateData>
					<componentData id="next">
						<data id="text" value="KRONIKA"></data> 
					</componentData>
				</templateData>
				));
				TweenLite.to(this, 1, { onComplete: Play});
			}
			TraceToLog("Main class initialized successfully");
		}
		
		public override function SetData(xmlData:XML) : void {
			for each (var element:XML in xmlData.children()) {
				if (element.@id == "next" && element.data.@value != "")
				{
					next = new Ticker("ZA CHWILĘ", element.data.@value);
					next.x = positionX - next.width;
					next.y = positionY;
				}
			}
		}
		
		override public function Play():void 
		{
			if (next)
			{
				addChild(next);
				next.addEventListener(Ticker.FINISHED, TickerFinished);
				next.Show();
			}
		}	
		
		
		override public function gotoAndPlay(frame:Object, scene:String = null):void 
		{
			switch(frame)
			{
			case "outro":
				Hide();
				break;
			default:
				super.gotoAndPlay(frame, scene);
				break;
			}
		}

		private function Hide():void
		{
			if (next)
			{
				next.Hide();
				next = null;
			}
			else
				Exit();
		}
		
		private function TickerFinished(event:Event):void
		{
			event.currentTarget.removeEventListener(event.type, arguments.callee);
			Exit();
			
		}
		
		private function Exit():void
		{
			CONFIG::debug {
				System.exit(0);
			}
			CONFIG::release {
				removeTemplate();
			}
		}
		
		
		public override function TraceToLog (message:String) : void
		{
			super.TraceToLog(message);
			trace(message);
		}
		
	}
}