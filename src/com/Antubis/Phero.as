package com.Antubis 
{
	import com.novabox.MASwithTwoNests.Agent;
	import com.Antubis.PheroBot;
	import com.novabox.MASwithTwoNests.AgentType;
	import com.novabox.MASwithTwoNests.Bot;
	import com.novabox.MASwithTwoNests.Resource;
	import com.novabox.MASwithTwoNests.TimeManager;
	import com.novabox.MASwithTwoNests.AgentCollideEvent;
	import flash.geom.Point;
	import flash.events.Event;
	import flash.ui.MouseCursor;
	
	/**
	 * ...
	 * @author Maximilien Noal & Antubis-Team
	 */
	public class Phero extends Agent 
	{
		protected var color:int;
		public var lifetime:Number;
		protected var start_lifetime:Number;
		protected static const MAX_LIVING_PHEROS:Number	= 300;
		public static const BASE_LIFETIME:Number		= 9000;
		
		public function Phero(_type:AgentType, _lifetime:Number) {
			super(_type);
			PheroBot.livingPheros++;
			color = 0X6F2020;
			lifetime = _lifetime;
			start_lifetime = _lifetime;
			graphics.beginFill(0XAAAAAA, 0);
			graphics.endFill();
		}
		
		public override function Update() : void {
			lifetime -= TimeManager.timeManager.GetFrameDeltaTime();
			if (lifetime <= 0 || PheroBot.livingPheros > MAX_LIVING_PHEROS) {
				PheroBot.livingPheros--;
				dead = true;
			}
			graphics.clear();
			graphics.beginFill(color, lifetime/start_lifetime);
			graphics.drawCircle(0, 0, 2);
			graphics.endFill();
		}
	}

}