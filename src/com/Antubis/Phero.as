package com.Antubis 
{
	import com.novabox.MASwithTwoNests.Agent;
	import com.Antubis.PheroBot;
	import com.novabox.MASwithTwoNests.AgentType;
	import com.novabox.MASwithTwoNests.Resource;
	import com.novabox.MASwithTwoNests.TimeManager;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Maximilien Noal & Antubis-Team
	 */
	public class Phero extends Agent 
	{
		protected var color:int;
		protected var lifetime:Number;
		protected var start_lifetime:Number;
		public static const BASE_LIFETIME:Number = 3000;
		
		public function Phero(_type:AgentType, _lifetime:Number) {
			super(_type);
			color = 0X6F2020;
			lifetime = _lifetime;
			start_lifetime = _lifetime;
			graphics.beginFill(0XAAAAAA, 0);
			graphics.endFill();
		}
		
		public override function Update() : void {
			lifetime -= TimeManager.timeManager.GetFrameDeltaTime();
			if (lifetime <= 0) {
				dead = true;
			}
			graphics.clear();
			graphics.beginFill(color, lifetime/start_lifetime);
			graphics.drawCircle(0, 0, 2);
			graphics.endFill();
		}
	}

}