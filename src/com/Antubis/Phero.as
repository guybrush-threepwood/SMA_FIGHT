package com.Antubis 
{
	import com.novabox.MASwithTwoNests.Agent;
	import com.Antubis.AntubisBot;
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
		public static const MAX_LIFETIME:Number = 3000;
		
		public function Phero(_type:AgentType) {
			super(_type);
			AntubisBot.livingPheros++;
			if (AntubisBot.livingPheros > AntubisBot.MAX_LIVING_PHEROS) {
				dead = true;
			}
			color = 0X6F2020;
			lifetime = MAX_LIFETIME;
			graphics.beginFill(0XAAAAAA, 0);
			graphics.endFill();
		}
		
		public override function Update() : void {
			lifetime -= TimeManager.timeManager.GetFrameDeltaTime();
			if (lifetime <= 0) {
				AntubisBot.livingPheros--;
				dead = true;
			}
			graphics.clear();
			graphics.beginFill(color, lifetime/MAX_LIFETIME);
			graphics.drawCircle(0, 0, 2);
			graphics.endFill();
		}
	}

}