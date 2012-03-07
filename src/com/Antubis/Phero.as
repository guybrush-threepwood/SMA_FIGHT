package com.Antubis 
{
	import flash.geom.Point;
	import com.Antubis.AntubisBot;
	import com.novabox.MASwithTwoNests.Agent;
	import com.novabox.MASwithTwoNests.AgentType;
	import com.novabox.MASwithTwoNests.TimeManager;
	
	/**
	 * ...
	 * @author Maximilien Noal & Antubis-Team
	 */
	public class Phero extends Agent 
	{
		protected var color:int;
		public var lifetime:Number;
		protected var start_lifetime:Number;
		protected static const MAX_LIVING_PHEROS:Number	= 200;
		public static const BASE_LIFETIME:Number		= 10000;
		
		public function Phero(_type:AgentType, _lifetime:Number) {
			super(_type);
			AntubisBot.livingPheros++;
			color = 0X6F2020;
			lifetime = _lifetime;
			start_lifetime = _lifetime;
			graphics.beginFill(0XAAAAAA, 0);
			graphics.endFill();
		}
		
		public override function Update() : void {
			lifetime -= TimeManager.timeManager.GetFrameDeltaTime();
			if (lifetime <= 0 || AntubisBot.livingPheros > MAX_LIVING_PHEROS || PherosTooClose()) {
				AntubisBot.livingPheros--;
				AntubisBot.dropedPheros[AntubisBot.dropedPheros.indexOf(this)] = null;
				dead = true;
			}
			graphics.clear();
			graphics.beginFill(color, lifetime/start_lifetime);
			graphics.drawCircle(0, 0, 2);
			graphics.endFill();
		}
		
		protected function PherosTooClose() : Boolean {
			for (var i:int = 0; i < AntubisBot.dropedPheros.length; i++) {
			if (AntubisBot.dropedPheros[i] != this && AntubisBot.dropedPheros[i] && Point.distance(AntubisBot.dropedPheros[i].GetCurrentPoint(), this.GetCurrentPoint()) < 40) {
					return true;
				}
			}
			return false;
		}
	}

}