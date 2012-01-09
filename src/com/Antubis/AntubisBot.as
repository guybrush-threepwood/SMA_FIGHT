﻿package com.Antubis 
{
	import com.novabox.MASwithTwoNests.World;
	import com.novabox.MASwithTwoNests.AgentCollideEvent;
	import com.novabox.MASwithTwoNests.AgentType;
	import com.novabox.MASwithTwoNests.Bot;
	import com.novabox.MASwithTwoNests.BotHome;
	import com.novabox.expertSystem.ExpertSystem;
	import com.novabox.MASwithTwoNests.AgentFacts;
	import com.novabox.MASwithTwoNests.TimeManager;
	import com.novabox.MASwithTwoNests.Agent;
	import com.novabox.MASwithTwoNests.Main;
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
		
		protected static const EDGE_LIMIT:Number = 6;
		protected var seenPhero:Phero;
		protected var seenEnemyBot:Point;
		protected var seenTeamBot:AntubisBot;
		protected var lastSeenResource:Point;
		protected var stolen:Boolean 			= false;
		
		public override function AntubisBot(_type:AgentType) {
			super(_type);
		}
		
		public override function Update() : void {
			CorrectLastSeenResource();
			super.Update();
			seenPhero = null;
			seenResource = null;
			lastSeenResource = null;
			seenEnemyBot = null;
			seenTeamBot = null;
			stolen = false;
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
																					AgentFacts.NO_RESOURCE)));
																					
			expertSystem.AddRule(new Rule(CustomBotFacts.GO_TO_ENEMY_BOT, new Array(CustomBotFacts.SEEN_ENEMY_BOT,
																					CustomBotFacts.NO_TEAM_BOT_SEEN,	
																					AgentFacts.NO_RESOURCE,
																					CustomBotFacts.NO_RESOURCE_SEEN,
																					CustomBotFacts.SEE_NO_RESOURCE)));
																					
			expertSystem.AddRule(new Rule(AgentFacts.TAKE_RESOURCE, 	new Array(	AgentFacts.NO_RESOURCE,
																					AgentFacts.REACHED_RESOURCE)));
																					
			expertSystem.AddRule(new Rule(AgentFacts.GO_HOME, 			new Array(	AgentFacts.GOT_RESOURCE,
																					AgentFacts.SEEING_HOME)));
																					
			expertSystem.AddRule(new Rule(AgentFacts.PUT_DOWN_RESOURCE,	new Array(	AgentFacts.AT_HOME,
																					AgentFacts.GOT_RESOURCE)));
			
			expertSystem.AddRule(new Rule(AgentFacts.CHANGE_DIRECTION, 	new Array(	CustomBotFacts.NEAR_EDGES)));
		}
		
		protected override function UpdateFacts() : void {
			if (seenPhero) {
				expertSystem.SetFactValue(CustomBotFacts.SEEN_PHERO, true);
			}
			
			if (seenEnemyBot) {
				expertSystem.SetFactValue(CustomBotFacts.SEEN_ENEMY_BOT, true);
			}
			
			if (!seenTeamBot) {
				expertSystem.SetFactValue(CustomBotFacts.NO_TEAM_BOT_SEEN, true);
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
			} else {
				expertSystem.SetFactValue(CustomBotFacts.NO_RESOURCE_SEEN, true);
			}
				
			if (seenResource) {
				expertSystem.SetFactValue(AgentFacts.SEE_RESOURCE, true);
				if (IsCloser(seenResource)) {
					expertSystem.SetFactValue(CustomBotFacts.CLOSER_RESOURCE, true);
				} 
				if (takenResource && seenResource.GetLife() > takenResource.GetLife()) {
					expertSystem.SetFactValue(AgentFacts.BIGGER_RESOURCE, true);							
				}
			} else {
				expertSystem.SetFactValue(CustomBotFacts.SEE_NO_RESOURCE, true);
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
		
		public override function onAgentCollide(_event:AgentCollideEvent) : void  {
			var collidedAgent:Agent = _event.GetAgent();
			super.onAgentCollide(_event);
			
			if (collidedAgent as Resource) {
				lastSeenResource = (collidedAgent as Resource).GetCurrentPoint();
			}
			
			if (collidedAgent as Phero && !(collidedAgent as Phero).IsDead()) {
				seenPhero = (collidedAgent as Phero);
			}
			
			if (collidedAgent as Bot) {
				if ((collidedAgent  as Bot).GetTeamId() == teamId) {
					seenTeamBot = collidedAgent as AntubisBot;
					Chat(seenTeamBot);
				} else if (IsCollided(collidedAgent)) {
					seenEnemyBot = (collidedAgent as Bot).GetCurrentPoint();
					if ((collidedAgent as Bot).HasResource() && !hasResource && !stolen) {
						StealResource(collidedAgent as Bot);
						stolen = true;
					}
				}
			}
		}
		
		protected function Chat(_seenBot:AntubisBot) : void {
			CorrectLastSeenResource();
			if (!lastSeenResource) {
				lastSeenResource = _seenBot.GetLastSeenResource();
			}
			if (!homePosition) {
				homePosition = _seenBot.GetHomePosition();
			}
		}
		
		protected override function Act() : void {
			for (var i:int = 0; i < expertSystem.GetInferedFacts().length; i++) {
				var fact:Fact = expertSystem.GetInferedFacts()[i] as Fact;
				switch (fact) {
					case CustomBotFacts.GO_TO_PHERO:
					GoToPhero();
					break;
					
					case CustomBotFacts.GO_TO_ENEMY_BOT:
					GoToEnemyBot();
					break;
				}
			}
			super.Act();
		}
		
		protected function GetLastSeenResource() : Point {
			CorrectLastSeenResource();
			return lastSeenResource;
		}
		
		protected function CorrectLastSeenResource() : void {
			if (lastSeenResource) {
				if (Point.distance(lastSeenResource, new Point(x, y)) <= perceptionRadius && !seenResource) {
					lastSeenResource = null;
				}
			}
		}
		
		protected function GoToPoint(_direction:Point) : void {
			direction = _direction.subtract(targetPoint);
			direction.normalize(1);
		}
		
		protected function GoToEnemyBot() : void {
			GoToPoint(seenEnemyBot);
			seenEnemyBot = null;
		}
		
		public override function GoToResource() : void {
			GoToPoint(lastSeenResource);
			lastSeenResource = null;
			seenResource = null;
			takenResource = null;
			lastReachedResource = null;
		}
		
		public function GoToPhero() : void {
			if (seenPhero) {
				GoToPoint(seenPhero.GetCurrentPoint());
				seenPhero = null;
			}
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
					Point.distance(direction, new Point(x, y)));
		}
	}
}