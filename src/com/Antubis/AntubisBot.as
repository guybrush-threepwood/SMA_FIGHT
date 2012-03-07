package com.Antubis 
{
	import com.novabox.expertSystem.*;
	import com.novabox.MASwithTwoNests.*;
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
		
		protected static const EDGE_LIMIT:Number= 6;
		protected var stolen:Boolean 			= false;
		protected var seenPhero:Phero;
		protected var takenResourcePos:Point;
		protected var seenTeamBot:AntubisBot;
		protected var lastSeenResource:Point;
		protected var lastDropedPhero:Phero;
		protected var takenResourceLife:Number;
		protected var passedPheros:Array;
		public static var livingPheros:Number;
		public var seenEnemyBot:Point;
		public static var dropedPheros:Array;
		public var lastSeenResourceLife:Number;
		
		public override function AntubisBot(_type:AgentType) {
			super(_type);
			dropedPheros = new Array();
			passedPheros = new Array();
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
																					CustomBotFacts.PHERO_NOT_ALREADY_PASSED,
																					AgentFacts.NO_RESOURCE,
																					CustomBotFacts.SEE_NO_RESOURCE,
																					CustomBotFacts.NO_RESOURCE_SEEN)));
			
			expertSystem.AddRule(new Rule(CustomBotFacts.DROP_PHERO,	new Array(	CustomBotFacts.SEEN_RESOURCE,
																					CustomBotFacts.LAST_DROPED_PHERO_IS_TOO_FAR)));
																					
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
																					
			expertSystem.AddRule(new Rule(CustomBotFacts.GO_BACK, 			new Array(	AgentFacts.PUT_DOWN_RESOURCE)));
			
			expertSystem.AddRule(new Rule(AgentFacts.CHANGE_DIRECTION, 	new Array(	CustomBotFacts.NEAR_EDGES,
																					CustomBotFacts.NOT_GOING_HOME)));
																					
			expertSystem.AddRule(new Rule(AgentFacts.CHANGE_DIRECTION, 	new Array(	CustomBotFacts.NEAR_EDGES,
																					CustomBotFacts.NOT_GOING_TO_RESOURCE)));
		}
		
		protected override function UpdateFacts() : void {
			var lastSeenPhero:Phero = lastDropedPhero != null ? lastDropedPhero : seenPhero;
			if (lastSeenPhero) {
				if(Point.distance(new Point(lastSeenPhero.x, lastSeenPhero.y), new Point(x, y)) >= perceptionRadius) {
					expertSystem.SetFactValue(CustomBotFacts.LAST_DROPED_PHERO_IS_TOO_FAR, true);
				}
			} else {
				expertSystem.SetFactValue(CustomBotFacts.LAST_DROPED_PHERO_IS_TOO_FAR, true);
			}
			
			if (seenPhero) {
				expertSystem.SetFactValue(CustomBotFacts.SEEN_PHERO, true);
				if (passedPheros.indexOf(seenPhero) == -1) {
					expertSystem.SetFactValue(CustomBotFacts.PHERO_NOT_ALREADY_PASSED, true);
				}
			}
			
			if (home && !home.hitTestPoint(direction.x, direction.y) || !home) {
				expertSystem.SetFactValue(CustomBotFacts.NOT_GOING_HOME, true);
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
			
			
			if (!seenResource || seenResource && !seenResource.hitTestPoint(direction.x, direction.y)) {
				expertSystem.SetFactValue(CustomBotFacts.NOT_GOING_TO_RESOURCE, true);
			}
				
			if (seenResource) {
				expertSystem.SetFactValue(AgentFacts.SEE_RESOURCE, true);
				if (IsCloser(seenResource)) {
					expertSystem.SetFactValue(CustomBotFacts.CLOSER_RESOURCE, true);
				} 
				if (takenResourceLife && seenResource.GetLife() > takenResourceLife) {
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
		}
		
		public override function onAgentCollide(_event:AgentCollideEvent) : void  {
			var collidedAgent:Agent = _event.GetAgent();
			super.onAgentCollide(_event);
			
			if (collidedAgent as Resource) {
				lastSeenResource = (collidedAgent as Resource).GetCurrentPoint();
				lastSeenResourceLife = (collidedAgent as Resource).GetLife();
			}
			
			if (collidedAgent as Phero && !(collidedAgent as Phero).IsDead()) {
				seenPhero = (collidedAgent as Phero);
			}
			
			var enemyBot:Bot;
			if (collidedAgent as Bot) {
				if ((collidedAgent  as Bot).GetTeamId() == teamId) {
					seenTeamBot = collidedAgent as AntubisBot;
					Chat(seenTeamBot);
				} else {
					enemyBot = (collidedAgent as Bot);
				}
			}
			
			if (enemyBot) {
				seenEnemyBot = enemyBot.GetCurrentPoint();
				if (IsCollided(enemyBot) && enemyBot.HasResource() && !hasResource && !stolen) {
					StealResource(enemyBot);
					stolen = true;
				}
			}
		}
		
		protected function Chat(chatBot:AntubisBot) : void {
			CorrectLastSeenResource();
			if (!lastSeenResource) {
				lastSeenResource = chatBot.GetLastSeenResource();
				lastSeenResourceLife = chatBot.lastSeenResourceLife;
			}
			if (chatBot.GetHomePosition()) {
				homePosition = chatBot.GetHomePosition();
			}
			if (!seenPhero) {
				seenPhero = chatBot.GetSeenPhero();
			}
			if (!seenEnemyBot) {
				seenEnemyBot = chatBot.seenEnemyBot;
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
					
					case CustomBotFacts.DROP_PHERO:
					DropPhero();
					break;
					
					case CustomBotFacts.GO_BACK:
					GoBack()
					break;
				}
			}
			super.Act();
		}
		
		protected function GetLastSeenResource() : Point {
			CorrectLastSeenResource();
			return lastSeenResource;
		}
		
		protected function GetSeenPhero () : Phero {
			if (seenPhero && passedPheros.indexOf(seenPhero) != -1) {
				return seenPhero;
			}
			return null;
		}
		
		protected function CorrectLastSeenResource() : void {
			if (lastSeenResource) {
				if (Point.distance(lastSeenResource, new Point(x, y)) <= perceptionRadius && !seenResource) {
					lastSeenResource = null;
				}
			}
		}
		
		protected function DropPhero() : void {
			Drop(lastDropedPhero = new Phero(AntubisAgentType.PHERO, Phero.BASE_LIFETIME * lastSeenResourceLife));
			dropedPheros.push(lastDropedPhero);
		}
		
		protected function GoToPoint(_direction:Point) : void {
			direction = _direction.subtract(targetPoint);
			direction.normalize(1);
		}
		
		protected function GoBack() : void {
			GoToPoint(takenResourcePos);
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
		
		protected function GoToPhero() : void {
			if (seenPhero) {
				passedPheros.push(seenPhero);
				GoToPoint(seenPhero.GetCurrentPoint());
				seenPhero = null;
			}
		}
		
		public override function TakeResource() : void {
			super.TakeResource();
			takenResourceLife = takenResource.GetLife();
			takenResourcePos = takenResource.GetCurrentPoint();
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
			return (Point.distance(new Point(_agent.x, _agent.y), new Point(x, y)) < 
					Point.distance(direction, new Point(x, y)));
		}
	}
}