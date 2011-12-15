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
		
		private static const EDGE_LIMIT:Number = 6;
		private var lastSeenResource:Point;
		private var lastDropedPhero:Phero;
		private var seenPhero:Phero;
		private var chatted:Boolean;
		
		public override function AntubisBot(_type:AgentType) {
			super(_type);
		}
		
		public override function Update() : void {
			super.Update();
			chatted = false;
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
																					
			expertSystem.AddRule(new Rule(CustomBotFacts.DROP_PHERO,	new Array(	CustomBotFacts.NO_PHERO_SEEN)));
																					
			expertSystem.AddRule(new Rule(AgentFacts.TAKE_RESOURCE, 	new Array(	AgentFacts.NO_RESOURCE,
																					AgentFacts.REACHED_RESOURCE)));
																					
			expertSystem.AddRule(new Rule(AgentFacts.GO_HOME, 			new Array(	AgentFacts.GOT_RESOURCE,
																					AgentFacts.SEEING_HOME)));
																					
			expertSystem.AddRule(new Rule(AgentFacts.PUT_DOWN_RESOURCE,	new Array(	AgentFacts.AT_HOME,
																					AgentFacts.GOT_RESOURCE)));
			
			expertSystem.AddRule(new Rule(AgentFacts.CHANGE_DIRECTION, 	new Array(	CustomBotFacts.NEAR_EDGES)));
		}
		
		protected override function UpdateFacts() : void {
			if (!seenPhero || seenPhero !=null && seenPhero.GetPheroType() == "Resource" && homePosition) {
				expertSystem.SetFactValue(CustomBotFacts.NO_PHERO_SEEN, true);
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
			
			if(GetLastSeenResource() != null ) {
				expertSystem.SetFactValue(CustomBotFacts.SEEN_RESOURCE, true);
			}
				
			if (seenResource) {
				expertSystem.SetFactValue(AgentFacts.SEE_RESOURCE, true);
				if (Point.distance(new Point(direction.x, direction.y), new Point(x, y)) > 
					Point.distance(new Point(seenResource.x, seenResource.y), new Point(x, y))) {
					expertSystem.SetFactValue(CustomBotFacts.CLOSER_RESOURCE, true);
				} else if (seenResource.GetLife() > takenResource.GetLife()) {
					expertSystem.SetFactValue(AgentFacts.BIGGER_RESOURCE, true);							
				}
			}
			
			if (reachedResource) {
				expertSystem.SetFactValue(AgentFacts.REACHED_RESOURCE, true);
			}
			
			if(homePosition) {
				expertSystem.SetFactValue(AgentFacts.SEEING_HOME, true);
			}
			
			if (IsAtHome()) {
				expertSystem.SetFactValue(AgentFacts.AT_HOME, true);
			}
			
			if (hasResource) {
				expertSystem.SetFactValue(AgentFacts.GOT_RESOURCE, true);
			}
		}
		
		protected override function Act() : void {
			for (var i:int = 0; i < expertSystem.GetInferedFacts().length; i++) {
				switch(expertSystem.GetInferedFacts()[i] as Fact) {	
					case CustomBotFacts.DROP_PHERO:
					DropPhero();
					break;
				}
			}
			super.Act();
		}
		
		public override function onAgentCollide(_event:AgentCollideEvent) : void  {
			var collidedAgent:Agent = _event.GetAgent();
			super.onAgentCollide(_event);
			
			if(seenResource) {
				lastSeenResource = seenResource.GetCurrentPoint();
			}
			
			if (collidedAgent as Bot) {
				if ((collidedAgent  as Bot).GetTeamId() == teamId) {
					if(!chatted) {
						Chat(collidedAgent as AntubisBot);
						chatted = true;
					}
				} else if ((collidedAgent as Bot).HasResource() && !hasResource) {
					StealResource(collidedAgent as Bot);
				}
			}
			
			if (collidedAgent as Phero) {
				seenPhero = (collidedAgent as Phero);
				if(!chatted) {
					GetPheroInfos(seenPhero);
					seenPhero.SetInfos(homePosition, GetLastSeenResource());
					chatted = true;
				}
			}
			
		}
		
		protected function Chat(seenBot:AntubisBot) : void {
			if (!lastSeenResource) {
				lastSeenResource = seenBot.GetLastSeenResource();
			}
			if (!homePosition) {
				homePosition = seenBot.GetHomePosition();
			}
		}
		
		protected function GetPheroInfos(phero:Phero) : void {
			if (phero != lastDropedPhero || !lastDropedPhero) {
				if (!homePosition) {
					homePosition = phero.GetHomePosition();
				}
				if (!lastSeenResource) {
					lastSeenResource = phero.GetResourcePos();
					CheckLastSeenResource();
				}
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
		
		protected function DropPhero() : void {
			var dropedPhero:Phero;
			
			if(homePosition && !World.BOT_START_FROM_HOME || GetLastSeenResource || seenResource) {
				if(seenResource) {
					Drop(dropedPhero = new Phero(CustomAgentType.PHERO, homePosition, seenResource.GetCurrentPoint()));
				} else {
					Drop(dropedPhero = new Phero(CustomAgentType.PHERO, homePosition, GetLastSeenResource()));	
				}
			}
			lastDropedPhero = dropedPhero;
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
		
		public function GetLastSeenResource() : Point {
			CheckLastSeenResource();
			return lastSeenResource;
		}
		
		private function CheckLastSeenResource() : void {
			if(lastSeenResource) {
				if (Point.distance(new Point(x, y), lastSeenResource) <= perceptionRadius && !seenResource) {
					lastSeenResource = null;
				}
			}
		}
	}
}