package com.Antubis 
{
	import com.novabox.MASwithTwoNests.Agent;
	import com.novabox.MASwithTwoNests.AgentType;
	import com.novabox.MASwithTwoNests.Resource;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Maximilien Noal & Antubis-Team
	 */
	public class Phero extends Agent 
	{
		protected var sprite:Sprite;
		protected var color:int;
		protected var homePosition:Point;
		protected var resourcePosition:Point;
		protected var lifetime:Number;
		protected var phero_type:String;
		public static const MAX_LIFETIME:Number = 150;
		
		public function Phero(_type:AgentType, _home:Point, _resource:Point) 
		{
			super(_type);
			homePosition = _home;
			resourcePosition = _resource;
			color = 0X6F2020;
			InitSprites();
			if (resourcePosition) {
				lifetime = 100;
				color = color + 0XA;
				phero_type = "Resource"
			} else {
				lifetime = MAX_LIFETIME;
				color = color + 0XB;
			}
			if (homePosition) {
				phero_type = "Home"
			}
		}
		
		public override function Update() : void {
			lifetime--;
			if (lifetime == 0) {
				dead = true;
			}
			DrawSprite();
			Harakiri();
		}
		
		public function	InitSprites() : void
		{
			this.graphics.beginFill(0XAAAAAA, 0);
			this.graphics.endFill();
			
			sprite = new Sprite();
			addChild(sprite);
		}
		
		protected function DrawSprite() : void
		{	
			
			sprite.graphics.clear();
			sprite.graphics.beginFill(color, lifetime/MAX_LIFETIME);
			sprite.graphics.drawCircle(0, 0, 2);
			sprite.graphics.endFill();
		}
		
		public function GetResourcePos() : Point {
			return resourcePosition;
		}
		
		public function GetHomePosition() : Point {
			return homePosition;
		}
		
		public function GetPheroType() : String {
			return phero_type;
		}
		
		public function SetInfos(_home:Point, _resource:Point) : void {
			if(_home) {
				homePosition = _home;
			}
			resourcePosition = _resource;
		}
		
		private function Harakiri() : void {
			if (GetResourcePos() == null) {
				dead = true;
			}
		}
		
	}

}