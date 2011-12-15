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
		protected var color:int;
		protected var homePosition:Point;
		protected var resourcePosition:Point;
		protected var lifetime:Number;
		protected var phero_type:String;
		public static const MAX_LIFETIME:Number = 300;
		
		public function Phero(_type:AgentType, _home:Point, _resource:Point) 
		{
			super(_type);
			homePosition = _home;
			resourcePosition = _resource;
			color = 0X6F2020;
			lifetime = MAX_LIFETIME;
			graphics.beginFill(0XAAAAAA, 0);
			graphics.endFill();
			if (resourcePosition) {
				phero_type = "Resource";
			}
			if (homePosition) {
				phero_type = "Home";
			}
		}
		
		public override function Update() : void {
			lifetime--;
			if (lifetime == 0) {
				dead = true;
			}
			graphics.clear();
			graphics.beginFill(color, lifetime/MAX_LIFETIME);
			graphics.drawCircle(0, 0, 2);
			graphics.endFill();
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
		
	}

}