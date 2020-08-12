package 
{
	import caurina.transitions.properties.ColorShortcuts;
	import caurina.transitions.properties.DisplayShortcuts;
	import com.greensock.easing.Linear;
	import com.greensock.plugins.SetActualSizePlugin;
	import com.greensock.TweenLite;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Shader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.ErrorEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader; 
	import flash.net.URLRequest;
	import flash.events.UncaughtErrorEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.Font;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.xml.XMLDocument
	import se.svt.caspar.template.CasparTemplate;
	import se.svt.caspar.template.components.CasparTextField;
	import tjenkinson.scroller.Scroller;
	import flash.system.System;
	import mx.utils.StringUtil;
	
	
	
	[SWF(width=1920,height=1080, frameRate="50")]
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

		private var crawlStage:Sprite = new Sprite();
		private var clocks:Array; 
		private var scroller:Scroller;
		private var background:Bitmap;
		private var clockBackground:Bitmap;
		private var separator:Bitmap;
		private var textFormat:TextFormat;
		private var fontFilters: Array;
		private var bufferListernerId:uint = 0;
		private var repeatLeft: int = int.MAX_VALUE;
		private var contentUrl:String;
		private var nullInputTimer:Timer = new Timer(10000); // when there is no input data, check for data every 10s
		
		private var fontLoaded: Boolean;
		private var backgroundLoaded: Boolean;
		private var clockBackgroundLoaded: Boolean;
		private var separatorLoaded: Boolean;
		private var stageReady: Boolean;
			
		private var font:Font;
		
		private var text:String;
		
		private static const TWEEN_DURATION:Number = 0.5;
		private static const TIME_TO_PRELOAD_CONTENT:Number = 3000;
		
		public function Main():void 
		{
			TraceToLog("Main constructor entered");
			this.originalFrameRate = 50;
			this.originalWidth = 1920;
			this.originalHeight = 1080;
			crawlStage.alpha = 0;
			addChild(crawlStage);
			this.description = new XML(
				 <template version="1.0.0" authorName="Jerzy Jaśkiewicz" authorEmail="jurek@tvp.pl" templateInfo="Generic crawl CasparCG template" originalWidth="1920" originalHeight="1080" originalFrameRate="50" >
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
				<!--
					<componentData id="config">
						<data id="text" value="simplecrawl.config"></data> 
					</componentData>
					<componentData id="text">
						<data id="text" value="A text to show in debug mode"></data> 
					</componentData>
				-->
					<componentData id="repeat">
						<data id="text" value="2"></data> 
					</componentData>
				</templateData>
				));
			}

			TraceToLog("Main class initialized successfully");
		}
		
		public override function SetData(xmlData:XML) : void {

			var configFileName:String = "simplecrawl.config";
			
			for each (var element:XML in xmlData.children()) {
				//seems to be our data
				if (element.@id == "config" && element.data.@value != "") 		
					configFileName = element.data.@value;
				if (element.@id == "text" && element.data.@value != "")
					text = element.data.@value;
				if (element.@id == "repeat" && element.data.@value)
					repeatLeft = element.data.@value;
			}
			loadConfig(configFileName);
		}		
		
		
		private function loadConfig(configURL:String):void {
			TraceToLog("Config file about to load.");
			var configLoader:URLLoader = new URLLoader(new URLRequest(configURL));
			configLoader.addEventListener(Event.COMPLETE, function(event:Event):void
			{
				event.currentTarget.removeEventListener(event.type, arguments.callee);
				var configXML:XML = new XML(configLoader.data);
				loadCrawl(configXML);
				TraceToLog("Config file loaded.");
			});
		}
		
		
		private function loadCrawl(config:XML):void
		{
			TraceToLog("loading config");
			contentUrl = config.content.@url;
			if (config.font) {
				textFormat = new TextFormat(config.font.@name, config.font.@size, config.font.@color, config.font.@bold == "true", config.font.@italic == "true");
				textFormat.letterSpacing = config.font.@spacing;
				}
				else
				textFormat = null;
			fontFilters = new Array();
			if (config.font.glow)
				fontFilters.push(new GlowFilter(config.font.glow.@color, config.font.glow.@alpha, config.font.glow.@blur, config.font.glow.@blur, config.font.glow.@strength));
			if (config.font.dropShadow)
				fontFilters.push(new DropShadowFilter(config.font.dropShadow.@distance, config.font.dropShadow.@angle, config.font.dropShadow.@color, config.font.dropShadow.@alpha, config.font.dropShadow.@blur, config.font.dropShadow.@blur, config.font.dropShadow.@strength)); 
			if (!fontFilters[0])
				fontFilters.push(new GlowFilter(alpha = 0));
			clocks = new Array();
			var clockConfig:XMLList = config.clock;
			if (clockConfig)
			{
				for each(var clockXml:XML in clockConfig)
				{
					var clockTextFormat:TextFormat = new TextFormat(clockXml.font.@name, clockXml.font.@size, clockXml.font.@color, clockXml.font.@bold == "true", clockXml.font.@italic == "true");
					clockTextFormat.letterSpacing = clockXml.font.@spacing;
					var clockFontFilters:Array = new Array();
					if (clockXml.font.glow)
						clockFontFilters.push(new GlowFilter(clockXml.font.glow.@color, clockXml.font.glow.@alpha, clockXml.font.glow.@blur, clockXml.font.glow.@blur, clockXml.font.glow.@strength));
					if (clockXml.font.dropShadow)
						clockFontFilters.push(new DropShadowFilter(clockXml.font.dropShadow.@distance, clockXml.font.dropShadow.@angle, clockXml.font.dropShadow.@color, clockXml.font.dropShadow.@alpha, clockXml.font.dropShadow.@blur, clockXml.font.dropShadow.@blur, clockXml.font.dropShadow.@strength)); 
					var clockBackgroundFilter:ColorMatrixFilter = null;
					var clock:Clock = new Clock(clockXml.@timeFormat, clockTextFormat, clockFontFilters, 1);
					clock.x = clockXml.@left;
					clock.y = clockXml.@top;
					clocks.push(clock);
					loadClockBackground(clockXml.background.@url, config.background.@left, config.background.@top);
				}
			}
			var repeatCount:int = config.repeat;
			if (repeatLeft == int.MAX_VALUE && repeatCount > 0)
				repeatLeft = repeatCount;
				
			if (config.font){
				scroller = new Scroller(config.font.@width, config.font.@speed);
				scroller.x = config.font.@left;
				scroller.y = config.font.@top;
			}
			else
				scroller = null;
			TraceToLog("config loaded, preparing to load content elements");
			loadBackground(config.background);
			loadSeparator(config.separator.@url);
		}

		private function loadBackground(backgroundXML:XMLList):void
		{
			if (backgroundXML.@url) {
				TraceToLog("loading background");
				var loader:Loader = new Loader();
				loader.load(new URLRequest(backgroundXML.@url));
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(event:Event):void
				{
					event.currentTarget.removeEventListener(event.type, arguments.callee);
					background = loader.content as Bitmap;
					background.x = backgroundXML.@left;
					background.y = backgroundXML.@top;
					backgroundLoaded = true;
					TraceToLog("background loaded, trying to load content");
					setupStage();
				});
			}
			else {
				TraceToLog("empty background");
				background = null;
				backgroundLoaded = true;
				setupStage();
			}
		}

		private function loadClockBackground(url:String, left: int, top: int):void
		{
			if (url) {
				//TraceToLog("loading clock background from " + url);
				var loader:Loader = new Loader();
				loader.load(new URLRequest(url));
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(event:Event):void
				{
					event.currentTarget.removeEventListener(event.type, arguments.callee);
					clockBackground = loader.content as Bitmap;
					clockBackground.x = left;
					clockBackground.y = top;
					clockBackgroundLoaded = true;
					TraceToLog("clock background loaded, trying to load content");
					setupStage();
				});
			}
			else {
				TraceToLog("empty background");
				clockBackground = null;
				clockBackgroundLoaded = true;
				setupStage();
			}
		}

		private function loadSeparator(separatorURL:String):void
		{
			if (separatorURL) {
				//TraceToLog("loading separator from " + separatorURL);
				var loader:Loader = new Loader()
				loader.load(new URLRequest(separatorURL));
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(event:Event):void
				{
					event.currentTarget.removeEventListener(event.type, arguments.callee);
					separator = loader.content as Bitmap;
					TraceToLog("separator loaded, continuing to load content");
					separatorLoaded = true;
					setupStage();
				});
			}
			else {
				separatorLoaded = true;
				setupStage();
			}
		}		
		
		private function setupStage():void
		{
			if (backgroundLoaded == true && separatorLoaded == true && (clocks.length == 0|| clockBackgroundLoaded))
			{
				if (background)
					crawlStage.addChild(background);
				if (scroller)
					crawlStage.addChild(scroller);
				if (clocks.length > 0) {
					if (clockBackground) {
						crawlStage.addChild(clockBackground);
					}
					for each (var clock:Clock in clocks)
						crawlStage.addChild(clock);
				}
				stageReady = true;
				loadTextContent(null);
			}
		}
		
		private function loadTextContent(event:Event): void
		{
			if (stageReady == false
				|| (scroller && (scroller.getIsRunning() == true) && scroller.getTimeRemaining() > TIME_TO_PRELOAD_CONTENT)
				|| (repeatLeft) <= 0
				)
				return;
			repeatLeft -= 1;
			
			if (text != null)
			{
				if (LoadElements(text))
					StartCrawl();
			}
			else
			if (contentUrl)
			{
				var loader:URLLoader = contentUrl.indexOf("http") > 0 
					? new URLLoader(new URLRequest(contentUrl + "?anticache=" + (Math.random() * 10000)))
					: new URLLoader(new URLRequest(contentUrl));
				loader.addEventListener(Event.COMPLETE, contentLoaded); 
				nullInputTimer.stop(); nullInputTimer.reset();
				loader.addEventListener(IOErrorEvent.IO_ERROR, contentLoadError);
				loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, contentLoadError);
			}
			else
				StartCrawl();

			function contentLoadError(event:Event):void
			{
				event.currentTarget.removeEventListener(event.type, arguments.callee);
				TraceToLog("loadContent error: " + event);
				loadTextContent(event); // retry
			}
			
			function contentLoaded(event:Event): void
			{
				event.currentTarget.removeEventListener(event.type, arguments.callee);
				if (!scroller) {
					TraceToLog("Scroller not found after loading content");
					return;
				}
				
				var containsElement:Boolean = LoadElements(loader.data);

				loader.close();

				if (containsElement == false)
				{ 
					nullInputTimer.start();	
					TraceToLog("Loaded empty text");
				}
				else
				{
				if (!scroller.getIsRunning())
					StartCrawl();
				}
			}
		}
		
		private function LoadElements(data:String):Boolean
		{
			if (!data)
				return false;
			var content:Array = data.split("\n"); 
			if (!content)
				return false;
			var result:Boolean = false;
			for each (var value:String in content)
				{
					var text:String = StringUtil.trim(value);
					if (value != "")
					{
						scroller.addElement(new Bitmap(separator.bitmapData), false, true);
						scroller.addElement(new CrawlElement(value, textFormat, fontFilters));
						result = true;
					}
				}
			return result;
		}
			
		private function StartCrawl():void 
		{
			TweenLite.to(crawlStage, TWEEN_DURATION, { 
					alpha:1, 
					ease:Linear.easeIn, 
					onComplete: function():void {
						if (scroller && bufferListernerId == 0)
							{
							bufferListernerId = scroller.addBufferListener(function():void 
								{
									if (scroller.getIsRunning() == true)
										loadTextContent(null);				
								}, [], TIME_TO_PRELOAD_CONTENT); // three seconds before finish
							}
						scroller.start();
						scroller.addEventListener(Scroller.LAST_OFF_SCREEN, scrollerLAST_OFF_SCREEN);
						TraceToLog("StartCrawl executed");
					} 
				} 
			);
		}

		private function StopCrawl():void 
		{
			TweenLite.to(crawlStage, TWEEN_DURATION, { 
					alpha:0, 
					ease:Linear.easeOut, 
					onComplete: function():void {
					TraceToLog("Stop executed");
					}			
				} 
			);
		}
		
		private function scrollerLAST_OFF_SCREEN(event:Event):void
		{
			event.currentTarget.removeEventListener(event.type, arguments.callee);
			StopCrawl();
		}
		
		public override function TraceToLog (message:String) : void
		{
			super.TraceToLog(message);
			trace(message);
		}
		
	}
}