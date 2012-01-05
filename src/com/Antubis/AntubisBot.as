package com.Antubis 
{
	import com.novabox.MASwithTwoNests.AgentCollideEvent;
	import com.novabox.MASwithTwoNests.AgentType;
	import com.novabox.MASwithTwoNests.Bot;
	import com.novabox.MASwithTwoNests.BotHome;
	import com.novabox.expertSystem.ExpertSystem;
	import com.novabox.MASwithTwoNests.AgentFacts;
	import com.novabox.MASwithTwoNests.TimeManager;
	import com.novabox.MASwithTwoNests.Agent;
	import com.novabox.MASwithTwoNests.Main;
	import com.novabox.MASwithTwoNests.World;
	import com.novabox.MASwithTwoNests.Resource;
	import com.novabox.expertSystem.Fact;
	import com.novabox.expertSystem.Rule;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	
	/**
	 * Cognitive Multi-Agent System Example
	 * Part 2 : Two distinct termite nests
	 * (Termites collecting wood)
	 * 
	 * @author Maximilien Noal & Antubis Team
	 * @version 1.1
	 */
	 

	//*********************************************************************************
	// TODO : Rename class and override InitExpertSystem, UpdateFacts and Act methods.
	//*********************************************************************************

	public class AntubisBot extends Bot {
		
		private static const EDGE_LIMIT:Number 			= 6;
		public static const MAX_LIVING_PHEROS:Number 	= 80; //Ideally, the number of bots in the team * 2
		public static var livingPheros:Number 			= 0;
		public  var lastSeenResource:Point;
		private var lastDropedPhero:Phero;
		private var seenPhero:Phero;
		
		public override function AntubisBot(_type:AgentType) {
			super(_type);
		}
		
		public override function Update() : void {
			CorrectLastSeenResource();
			super.Update();
			seenPhero = null;
		}
		
		protected override function InitExpertSystem() : void {
			expertSystem = new ExpertSystem();
			
			expertSystem.AddRule(new Rule(AgentFacts.GO_TO_RESOURCE, 	new Array(	AgentFacts.NO_RESOURCE,
																					CustomBotFacts.SEEN_RESOURCE)));
			
			expertSystem.AddRule(new Rule(AgentFacts.GO_TO_RESOURCE, 	new Array(	AgentFacts.NO_RESOURCE,
																					AgentFacts.SEE_RESOURCE,
																					CustomBotFacts.CLOSER_RESOURCE)));
																					
			expertSystem.AddRule(new Rule(AgentFacts.GO_TO_RESOURCE, 	new Array(	AgentFacts.NO_RESOURCE,
																					AgentFacts.SEE_RESOURCE,
																					AgentFacts.BIGGER_RESOURCE)));
																					
			expertSystem.AddRule(new Rule(CustomBotFacts.GO_TO_PHERO,	new Array( 	CustomBotFacts.SEEN_PHERO,
																					AgentFacts.NO_RESOURCE,
																					AgentFacts.NOTHING_SEEN)));
																					
			expertSystem.AddRule(new Rule(CustomBotFacts.DROP_PHERO,	new Array(	CustomBotFacts.NO_PHERO_SEEN,
																					CustomBotFacts.DROP_ALLOWED,
																					CustomBotFacts.SEEN_RESOURCE)));
																					
			expertSystem.AddRule(new Rule(AgentFacts.TAKE_RESOURCE, 	new Array(	AgentFacts.NO_RESOURCE,
																					AgentFacts.REACHED_RESOURCE)));
																					
			expertSystem.AddRule(new Rule(AgentFacts.GO_HOME, 			new Array(	AgentFacts.GOT_RESOURCE,
																					AgentFacts.SEEING_HOME)));
																					
			expertSystem.AddRule(new Rule(AgentFacts.PUT_DOWN_RESOURCE,	new Array(	AgentFacts.AT_HOME,
																					AgentFacts.GOT_RESOURCE)));
			
			expertSystem.AddRule(new Rule(AgentFacts.CHANGE_DIRECTION, 	new Array(	CustomBotFacts.NEAR_EDGES)));
		}
		
		protected override function UpdateFacts() : void {
			if (!seenPhero) {
				expertSystem.SetFactValue(CustomBotFacts.NO_PHERO_SEEN, true);
			} else if (seenPhero != lastDropedPhero) {
				expertSystem.SetFactValue(CustomBotFacts.SEEN_PHERO, true);
			}
			
			if (livingPheros < MAX_LIVING_PHEROS) {
				expertSystem.SetFactValue(CustomBotFacts.DROP_ALLOWED, true);	
			}
			
			if (IsNearEdges()) {
				expertSystem.SetFactValue(CustomBotFacts.NEAR_EDGES, true);
			}
			
			if (hasResource) {
				expertSystem.SetFactValue(AgentFacts.GOT_RESOURCE, true);
			}
			else {
				expertSystem.SetFactValue(AgentFacts.NO_RESOURCE, true);
			}
			
			if (lastSeenResource) {
				expertSystem.SetFactValue(CustomBotFacts.SEEN_RESOURCE, true);
			}
				
			if (seenResource) {
				expertSystem.SetFactValue(AgentFacts.SEE_RESOURCE, true);
				if (IsCloser(seenResource)) {
					expertSystem.SetFactValue(CustomBotFacts.CLOSER_RESOURCE, true);
				} 
				if (takenResource && seenResource.GetLife() > takenResource.GetLife()) {
					expertSystem.SetFactValue(AgentFacts.BIGGER_RESOURCE, true);							
				}
			}
			
			if (reachedResource) {
				expertSystem.SetFactValue(AgentFacts.REACHED_RESOURCE, true);
			}
			
			if (homePosition) {
				expertSystem.SetFactValue(AgentFacts.SEEING_HOME, true);
			}
			
			if (IsAtHome()) {
				expertSystem.SetFactValue(AgentFacts.AT_HOME, true);
			}
			
			if (hasResource) {
				expertSystem.SetFactValue(AgentFacts.GOT_RESOURCE, true);
			}
		}
		
		public override function GoToResource() : void {
			direction = lastSeenResource.subtract(targetPoint);
			direction.normalize(1);
			lastSeenResource = null;
			seenResource = null;
			takenResource = null;
			lastReachedResource = null;
		}
		
		public function GoToPhero() : void {
			direction = seenPhero.GetCurrentPoint().subtract(targetPoint);
			seenPhero = null;
		}
		
		public override function onAgentCollide(_event:AgentCollideEvent) : void  {
			var collidedAgent:Agent = _event.GetAgent();
			super.onAgentCollide(_event);
			
			if (collidedAgent as Resource) {
				lastSeenResource = GetCurrentOrTargetPoint(collidedAgent as Resource);
			}
			
			if (collidedAgent as Phero) {
				seenPhero = (collidedAgent as Phero);
			}
			
			if (collidedAgent as Bot) {
				if ((collidedAgent  as Bot).GetTeamId() == teamId) {
					Chat(collidedAgent as AntubisBot);
				} else if ((collidedAgent as Bot).HasResource() && !hasResource) {
					StealResource(collidedAgent as Bot);
				}
			}
		}
		
		protected override function Act() : void {
			for (var i:int = 0; i < expertSystem.GetInferedFacts().length; i++) {
				switch(expertSystem.GetInferedFacts()[i] as Fact) {	
					case CustomBotFacts.DROP_PHERO:
					DropPhero();
					break;
					
					case CustomBotFacts.GO_TO_PHERO:
					GoToPhero();
					break;
				}
			}
			super.Act();
		}
		
		protected function Chat(seenBot:AntubisBot) : void {
			if (!lastSeenResource) {
				lastSeenResource = seenBot.lastSeenResource;
			}
			if (!homePosition) {
				homePosition = seenBot.GetHomePosition();
			}
		}
		
		protected function DropPhero() : void {
			Drop(lastDropedPhero = new Phero(CustomAgentType.PHERO));
		}
		
		protected function IsAtHome() : Boolean {
			if (home) {
				return (IsCollided(home));
			} else {
				return false;
			}
		}
		
		protected function IsNearEdges() : Boolean {
			return (x <= EDGE_LIMIT || x >= World.WORLD_WIDTH - EDGE_LIMIT ||
					y <= EDGE_LIMIT || y >= World.WORLD_HEIGHT - EDGE_LIMIT);
		}
		
		protected function IsCloser(_agent:Agent) : Boolean {
			return (Point.distance(new Point(_agent.x, _agent.y), new Point(x, y)) > 
					Point.distance(new Point(direction.x, direction.y), new Point(x, y)));
		}
		
		protected function GetCurrentOrTargetPoint(_agent:Agent):Point {
			if (Main.world.IsOut(_agent.GetTargetPoint())) {
				return _agent.GetCurrentPoint();
			} else {
				return _agent.GetTargetPoint();
			}
		}
		
		protected function CorrectLastSeenResource() : void {
			if(lastSeenResource) {
				if (Point.distance(new Point(lastSeenResource.x, lastSeenResource.y), new Point(x, y)) <= perceptionRadius && !seenResource) {
					lastSeenResource = null;
				}
			}
		}
	}
}