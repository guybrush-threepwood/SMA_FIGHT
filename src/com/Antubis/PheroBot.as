package com.Antubis 
{
	import com.novabox.expertSystem.Rule;
	import com.novabox.expertSystem.Fact;
	import com.novabox.MASwithTwoNests.AgentType;
	import com.novabox.MASwithTwoNests.AgentFacts;
	import com.novabox.MASwithTwoNests.AgentCollideEvent;
	import com.novabox.MASwithTwoNests.Bot;
	import com.novabox.MASwithTwoNests.BotHome;
	import com.novabox.MASwithTwoNests.Agent;
	import com.novabox.MASwithTwoNests.Resource;
	import com.novabox.expertSystem.ExpertSystem;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Maximiliien Noal & Antubis-Team
	 */
	public class PheroBot extends AntubisBot {
		protected var lastDropedPhero:Phero;
		public static var livingPheros:Number;
		public	var antubisMode:Boolean;
		private var pheroMode:Boolean;
		
		public function PheroBot(_type:AgentType) {
			super(_type);
			livingPheros = 0;
		}
		
		public override function Update() : void {
			if (reachedResource && !antubisMode) {
				antubisMode = true;
				pheroMode = false;
				super.InitExpertSystem();
			}
			if (IsAtHome() && !hasResource && !pheroMode) {
				antubisMode = false;
				pheroMode = true;
				InitExpertSystem();
			}
			
			super.Update();
		}
		
		protected override function InitExpertSystem() : void {
			expertSystem = new ExpertSystem();
			
			expertSystem.AddRule(new Rule(AgentFacts.GO_TO_RESOURCE,	new Array( 	AgentFacts.SEE_RESOURCE)));
																					
			expertSystem.AddRule(new Rule(CustomBotFacts.DROP_PHERO, 	new Array(	CustomBotFacts.LAST_DROPED_PHERO_IS_TOO_FAR,
																					AgentFacts.SEE_RESOURCE)));
																					
			expertSystem.AddRule(new Rule(AgentFacts.PUT_DOWN_RESOURCE,	new Array(	AgentFacts.AT_HOME,
																					AgentFacts.GOT_RESOURCE)));
																					
			expertSystem.AddRule(new Rule(AgentFacts.TAKE_RESOURCE, 	new Array(	AgentFacts.NO_RESOURCE,
																					AgentFacts.AT_HOME,
																					AgentFacts.REACHED_RESOURCE)));
																					
			expertSystem.AddRule(new Rule(AgentFacts.CHANGE_DIRECTION, 	new Array(	CustomBotFacts.NEAR_EDGES)));
		}
		
		protected override function UpdateFacts() : void {
			var lastSeenPhero:Phero = lastDropedPhero != null ? lastDropedPhero : seenPhero;
			if (lastSeenPhero) {
				if(Point.distance(new Point(lastSeenPhero.x, lastSeenPhero.y), new Point(x, y)) >= perceptionRadius/1.5) {
					expertSystem.SetFactValue(CustomBotFacts.LAST_DROPED_PHERO_IS_TOO_FAR, true);
				}
			} else {
				expertSystem.SetFactValue(CustomBotFacts.LAST_DROPED_PHERO_IS_TOO_FAR, true);
			}
			
			super.UpdateFacts();
		}
		
		protected override function Act() : void {
			for (var i:int = 0; i < expertSystem.GetInferedFacts().length; i++) {
				var fact:Fact = expertSystem.GetInferedFacts()[i] as Fact;
				switch (fact) {
					case CustomBotFacts.DROP_PHERO:
					DropPhero();
					break;
				}
			}
			super.Act();
		}
		
		protected function DropPhero() : void {
			Drop(lastDropedPhero = new Phero(AntubisAgentType.PHERO, Phero.BASE_LIFETIME*seenResource.GetLife()));
		}
	}
}