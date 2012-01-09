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
	import com.novabox.MASwithTwoNests.World;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Maximiliien Noal & Antubis-Team
	 */
	public class PheroBot extends AntubisBot {
		private var lastDropedPhero:Phero;
		public static var livingPheros:Number;
		private var seenPheroBot:PheroBot;
		private var onceReachedResource:Resource;
		private var changed:Boolean;
		
		public function PheroBot(_type:AgentType) {
			super(_type);
			livingPheros = 0;
		}
		
		public override function Update() : void {
			if(onceReachedResource) {
				ChangeIntoAntubisBotIfDead();
			}
			if (reachedResource) {
				onceReachedResource = reachedResource;
			}
			
			super.Update();
			seenPheroBot = null;
		}
		
		protected override function InitExpertSystem() : void {
			expertSystem = new ExpertSystem();
			
			expertSystem.AddRule(new Rule(AgentFacts.GO_TO_RESOURCE,	new Array( 	AgentFacts.SEE_RESOURCE,
																					CustomBotFacts.NO_PHERO_BOT_ON_THIS_RESOURCE)));
																					
			expertSystem.AddRule(new Rule(CustomBotFacts.GO_TO_ENEMY_BOT,new Array(	CustomBotFacts.SEEN_ENEMY_BOT,
																					CustomBotFacts.NO_RESOURCE_SEEN,
																					CustomBotFacts.SEE_NO_RESOURCE,
																					CustomBotFacts.NO_TEAM_BOT_SEEN,
																					AgentFacts.NO_RESOURCE)));
			
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
				if(Point.distance(new Point(lastSeenPhero.x, lastSeenPhero.y), new Point(x, y)) >= perceptionRadius/2) {
					expertSystem.SetFactValue(CustomBotFacts.LAST_DROPED_PHERO_IS_TOO_FAR, true);
				}
			} else {
				expertSystem.SetFactValue(CustomBotFacts.LAST_DROPED_PHERO_IS_TOO_FAR, true);
			}
			
			if (seenResource) {
				expertSystem.SetFactValue(AgentFacts.SEE_RESOURCE, true);
				if (seenPheroBot) {
					if(seenPheroBot.seenResource != seenResource && !seenPheroBot.IsCollided(seenResource)) {
						expertSystem.SetFactValue(CustomBotFacts.NO_PHERO_BOT_ON_THIS_RESOURCE, true);
					}
				}
			}
			
			super.UpdateFacts();
		}
		
		public override function onAgentCollide(_event:AgentCollideEvent) : void  {
			var collidedAgent:Agent = _event.GetAgent();
			super.onAgentCollide(_event);
			
			if (collidedAgent as PheroBot) {
				seenPheroBot = collidedAgent as PheroBot;
			}
		}
		
		protected override function Act() : void {
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
		
		protected function ChangeIntoAntubisBotIfDead() : void {
			if(onceReachedResource.GetLife() <= 0 && !changed) { 
				changed = true;
				super.InitExpertSystem();
			}
		}
	}
}