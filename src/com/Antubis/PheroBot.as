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
	import flash.display.ShaderJob;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Maximiliien Noal & Antubis-Team
	 */
	public class PheroBot extends AntubisBot {
		private var lastDropedPhero:Phero;
		private var seenPheroBot:PheroBot;
		public var antubisMode:Boolean = false;
		
		public function PheroBot(_type:AgentType) {
			super(_type);
		}
		
		public override function Update() : void {
			super.Update();
			seenPheroBot = null;
			seenResource = null;
		}
		
		public function SetAntubisMode() : void {
			super.InitExpertSystem();
			antubisMode = true;
		}
		
		protected override function InitExpertSystem() : void {
			expertSystem = new ExpertSystem();
			
			expertSystem.AddRule(new Rule(AgentFacts.GO_TO_RESOURCE,	new Array( 	AgentFacts.SEE_RESOURCE,
																					CustomBotFacts.NO_PHERO_BOT_ON_THIS_RESOURCE)));
			
			expertSystem.AddRule(new Rule(CustomBotFacts.DROP_PHERO, 	new Array(	CustomBotFacts.LAST_DROPED_PHERO_IS_TOO_FAR,
																					AgentFacts.GO_TO_RESOURCE)));
																						
			expertSystem.AddRule(new Rule(CustomBotFacts.DROP_PHERO,	new Array(	CustomBotFacts.NO_PHERO_DROPED,
																					AgentFacts.GO_TO_RESOURCE)));
																				
			expertSystem.AddRule(new Rule(AgentFacts.CHANGE_DIRECTION, 	new Array(	CustomBotFacts.NEAR_EDGES)));
		}
		
		protected override function UpdateFacts() : void {
			if (antubisMode) {
				super.UpdateFacts();
				return;
			}
			
			if (IsNearEdges()) {
				expertSystem.SetFactValue(CustomBotFacts.NEAR_EDGES, true);
			}
			
			if (lastDropedPhero) {
				if(Point.distance(new Point(lastDropedPhero.x, lastDropedPhero.y), new Point(x, y)) >= perceptionRadius/4) {
					expertSystem.SetFactValue(CustomBotFacts.LAST_DROPED_PHERO_IS_TOO_FAR, true);
				}
			} else {
				expertSystem.SetFactValue(CustomBotFacts.NO_PHERO_DROPED, true);
			}
			
			if (seenResource) {
				expertSystem.SetFactValue(AgentFacts.SEE_RESOURCE, true);
				if (seenPheroBot) {
					if(seenPheroBot.seenResource != seenResource && !seenResource.hitTestObject(seenPheroBot)) {
						expertSystem.SetFactValue(CustomBotFacts.NO_PHERO_BOT_ON_THIS_RESOURCE, true);
					}
				}
			}
		}
		
		public override function onAgentCollide(_event:AgentCollideEvent) : void  {
			if (antubisMode) {
				super.onAgentCollide(_event);
				return;
			}
			
			var collidedAgent:Agent = _event.GetAgent();
			
			if (collidedAgent as Resource) {
				seenResource = collidedAgent as Resource;
				lastSeenResource = seenResource.GetCurrentPoint();
			}
			
			if (collidedAgent as PheroBot) {
				seenPheroBot = collidedAgent as PheroBot;
			}
			
			if (collidedAgent as Bot) {
				if ((collidedAgent  as Bot).GetTeamId() == teamId) {
					Chat(collidedAgent as AntubisBot);
				}
			}
			
			if (collidedAgent.GetType() == AgentType.AGENT_BOT_HOME) {
				if ((collidedAgent as BotHome).GetTeamId() == teamId) {
					home = collidedAgent as BotHome;
					homePosition = new Point(home.GetTargetPoint().x, home.GetTargetPoint().y);
				}
			}
		}
		
		protected override function Act() : void {
			if (antubisMode) {
				super.Act();
				return;
			}
			
			var inferedFacts:Array = expertSystem.GetInferedFacts();
			
			for (var i:int = 0; i < inferedFacts.length; i++) {
				var fact:Fact = (inferedFacts[i] as Fact);
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