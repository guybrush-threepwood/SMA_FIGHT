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
		
		public override function AntubisBot(_type:AgentType) {
			super(_type);
		}
		
		public override function Update() : void {
			super.Update();
			seenPhero = null;
		}
		
		protected override function InitExpertSystem() : void {
			expertSystem = new ExpertSystem();
			
			expertSystem.AddRule(new Rule(AgentFacts.GO_TO_RESOURCE, 	new Array(	AgentFacts.NO_RESOURCE,
																					AgentFacts.SEE_RESOURCE)));
			
			expertSystem.AddRule(new Rule(AgentFacts.GO_TO_RESOURCE, 	new Array(	AgentFacts.NO_RESOURCE,
																					AgentFacts.SEE_RESOURCE,
																					CustomBotFacts.CLOSER_RESOURCE)));
																					
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
			if (!seenPhero || !IsPercieved(seenPhero)) {
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
			
			if(GetLastSeenResource()) {
				expertSystem.SetFactValue(AgentFacts.SEE_RESOURCE, true);
				if(seenResource) {
					if (Point.distance(new Point(direction.x, direction.y), new Point(x, y)) > 
						Point.distance(new Point(seenResource.x, seenResource.y), new Point(x, y))) {
							expertSystem.SetFactValue(CustomBotFacts.CLOSER_RESOURCE, true);
						}
				}
			} else if (!seenResource) {
				expertSystem.SetFactValue(AgentFacts.NOTHING_SEEN, true);
			}
			
			if (reachedResource) {
				expertSystem.SetFactValue(AgentFacts.REACHED_RESOURCE, true);
			}
			
			if(homePosition) {
				expertSystem.SetFactValue(AgentFacts.SEEING_HOME, true);
			} else {
				expertSystem.SetFactValue(AgentFacts.NOT_SEEING_HOME, true);
			}
			
			if (IsAtHome()) {
				expertSystem.SetFactValue(AgentFacts.AT_HOME, true);
			}
			
			if (hasResource) {
				expertSystem.SetFactValue(AgentFacts.GOT_RESOURCE, true);
			}
		}
		
		protected override function Act() : void {
			var inferedFacts:Array = expertSystem.GetInferedFacts();
			
			for (var i:int = 0; i < inferedFacts.length; i++)
			{
				var fact:Fact = (inferedFacts[i] as Fact);
				
				switch(fact)
				{
					case CustomBotFacts.DROP_PHERO:
					DropPhero();
					break;
					
					case AgentFacts.CHANGE_DIRECTION:
					ChangeDirection();
					break;
					
					case AgentFacts.GO_TO_RESOURCE:
					GoToResource();
					break;
					
					case AgentFacts.GO_HOME:
					GoHome();
					break;
					
					case AgentFacts.TAKE_RESOURCE:
					TakeResource();
					break;
					
					case AgentFacts.PUT_DOWN_RESOURCE:
					PutDownResource();
					break;
					
				}
			}
			expertSystem.ResetFacts();
		}
		
		public override function onAgentCollide(_event:AgentCollideEvent) : void  {
			var collidedAgent:Agent = _event.GetAgent();
			super.onAgentCollide(_event);
			
			if(seenResource != null) {
				lastSeenResource = seenResource.GetCurrentPoint();
			}
			
			if ((collidedAgent as Bot) != null) {
				if ((collidedAgent  as Bot).GetTeamId() == teamId) {
					Chat(collidedAgent as AntubisBot);
				} else if ((collidedAgent as Bot).HasResource() && !hasResource) {
					StealResource(collidedAgent as Bot);
				}
			}
			
			if ((collidedAgent as Phero != null)) {
				seenPhero = (collidedAgent as Phero);
				GetPheroInfos(collidedAgent as Phero);
			}
			
		}
		
		public function Chat(seenBot:AntubisBot) : void {
			if (lastSeenResource == null) {
				lastSeenResource = seenBot.GetLastSeenResource();
			}
			if (homePosition == null) {
				homePosition = seenBot.GetHomePosition();
			}
		}
		
		public function GetPheroInfos(phero:Phero) : void {
			if (phero != lastDropedPhero || lastDropedPhero == null) {
				if (homePosition == null) {
					homePosition = phero.GetHomePosition();
				}
				if (lastSeenResource == null) {
					lastSeenResource = phero.GetResourcePos();
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
		
		public function DropPhero() : void {
			var dropedPhero:Phero;
			
			if(seenResource) {
				Drop(dropedPhero = new Phero(CustomAgentType.PHERO, homePosition, seenResource.GetCurrentPoint()));
			} else {
				Drop(dropedPhero = new Phero(CustomAgentType.PHERO, homePosition, GetLastSeenResource()));	
			}
			lastDropedPhero = dropedPhero;
		}
		
		protected function IsAtHome() : Boolean {
			if (home != null) {
				return (IsCollided(home));
			} else {
				return false;
			}
		}
		
		public function IsNearEdges() : Boolean {
			return (x <= EDGE_LIMIT || x >= World.WORLD_WIDTH - EDGE_LIMIT ||
					y <= EDGE_LIMIT || y >= World.WORLD_HEIGHT - EDGE_LIMIT);
		}
		
		public function GetLastSeenResource() : Point {
			if(lastSeenResource) {
				if (Point.distance(new Point(x, y), lastSeenResource) <= perceptionRadius && !seenResource) {
					lastSeenResource = null;
				}
			}
			return lastSeenResource;
		}
	}
}