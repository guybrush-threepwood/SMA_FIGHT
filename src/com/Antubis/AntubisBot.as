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
	 * @author Ophir / Nova-box
	 * @version 1.1
	 */
	 

	//*********************************************************************************
	// TODO : Rename class and override InitExpertSystem, UpdateFacts and Act methods.
	//*********************************************************************************

	public class AntubisBot extends Bot {
		
		private static const LIMIT:Number = 4;
		private var seenBots:Array;
		private var too_much_team_bots:Boolean = false;
		private var LastSeenResourcePos:Point;
		
		public override function AntubisBot(_type:AgentType) {
			seenBots = new Array();
			super(_type);
		}
		
		public override function Update():void {
			super.Update();
			too_much_team_bots = false;
		}
		
		protected override function InitExpertSystem() : void {
			expertSystem = new ExpertSystem();
			
			expertSystem.AddRule(new Rule(AgentFacts.GO_TO_RESOURCE, 	new Array(	AgentFacts.NO_RESOURCE,
																					AgentFacts.SEE_RESOURCE,
																					CustomBotFacts.NOT_TOO_MUCH_PEOPLE)));
			
			expertSystem.AddRule(new Rule(AgentFacts.GO_TO_RESOURCE, 	new Array(	AgentFacts.NO_RESOURCE,
																					AgentFacts.SEE_RESOURCE,
																					CustomBotFacts.CLOSER_RESOURCE)));
			
			expertSystem.AddRule(new Rule(AgentFacts.GO_TO_RESOURCE, 	new Array(	AgentFacts.NO_RESOURCE,
																					AgentFacts.NOTHING_SEEN,
																					CustomBotFacts.RESOURCE_FOUND)));

			expertSystem.AddRule(new Rule(AgentFacts.TAKE_RESOURCE, 	new Array(	AgentFacts.NO_RESOURCE,
																					AgentFacts.REACHED_RESOURCE)));

			expertSystem.AddRule(new Rule(AgentFacts.GO_HOME, 			new Array(	AgentFacts.GOT_RESOURCE,
																					AgentFacts.SEEING_HOME)));
			
			expertSystem.AddRule(new Rule(AgentFacts.PUT_DOWN_RESOURCE,	new Array(	AgentFacts.AT_HOME,
																					AgentFacts.GOT_RESOURCE)));
			
			expertSystem.AddRule(new Rule(AgentFacts.CHANGE_DIRECTION, new Array(	CustomBotFacts.NEAR_EDGES)));
		}
		
		protected override function UpdateFacts() : void {
			updateTime += TimeManager.timeManager.GetFrameDeltaTime();
			if (updateTime > directionChangeDelay)
			{
				expertSystem.SetFactValue(AgentFacts.CHANGE_DIRECTION_TIME, true);
				updateTime = 0;
			}
			
			if ( x <= LIMIT || x >= World.WORLD_WIDTH - LIMIT || y <= LIMIT || y >= World.WORLD_HEIGHT - LIMIT) {
				expertSystem.SetFactValue(CustomBotFacts.NEAR_EDGES, true);
			}
			
			if (too_much_team_bots) {
				expertSystem.SetFactValue(CustomBotFacts.TOO_MUCH_PEOPLE, true);
			} else {
				expertSystem.SetFactValue(CustomBotFacts.NOT_TOO_MUCH_PEOPLE, true);
			}
			
			if (hasResource) {
				expertSystem.SetFactValue(AgentFacts.GOT_RESOURCE, true);
			}
			else {
				expertSystem.SetFactValue(AgentFacts.NO_RESOURCE, true);
			}
			
			if(seenResource) {
				expertSystem.SetFactValue(AgentFacts.SEE_RESOURCE, true);
				if (takenResource != null) {
					if(seenResource.GetLife() > takenResource.GetLife()) {
						expertSystem.SetFactValue(AgentFacts.BIGGER_RESOURCE, true);
					} else {
						expertSystem.SetFactValue(AgentFacts.SMALLER_RESOURCE, true);
					}
					if (Point.distance(new Point(takenResource.x, takenResource.y), new Point(x, y)) > 
						Point.distance(new Point(seenResource.x, seenResource.y), new Point(x, y))) {
							expertSystem.SetFactValue(CustomBotFacts.CLOSER_RESOURCE, true);
						} else {
							expertSystem.SetFactValue(CustomBotFacts.NO_CLOSER_RESOURCE, true);
						}
				}
			} else {
				expertSystem.SetFactValue(AgentFacts.NOTHING_SEEN, true);
			}
			
			if (reachedResource) {
				expertSystem.SetFactValue(AgentFacts.REACHED_RESOURCE, true);
			}
			
			if (LastSeenResourcePos) {
				expertSystem.SetFactValue(CustomBotFacts.RESOURCE_FOUND, true);
			} else {
				expertSystem.SetFactValue(CustomBotFacts.NO_RESOURCE_FOUND, true);
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
		
		public override function onAgentCollide(_event:AgentCollideEvent) : void
		{
			var collidedAgent:Agent = _event.GetAgent();
			super.onAgentCollide(_event);
			if(seenResource != null) {
				LastSeenResourcePos = seenResource.GetCurrentPoint();
			}
			
			if (IsPercieved(collidedAgent) || IsCollided(collidedAgent)) {
				if ((collidedAgent as Bot) != null) {
					if ((collidedAgent  as Bot).GetTeamId() == teamId) {
						if(seenBots.indexOf(collidedAgent as AntubisBot) == -1) {
							seenBots.push(collidedAgent as AntubisBot);
						}
						Chat(collidedAgent as AntubisBot);
					} else {
							if ((collidedAgent as Bot).HasResource() && !hasResource) {
								StealResource(collidedAgent as Bot);
							}
					}
				}
			}
		}
		
		public function Chat(seenBot:AntubisBot):void {
			var i:Number = 0;
			var PerceivableOtherTeamBotsOnIt:Number = 0;
			for (i = 0; i < seenBots.length; i++) {
				if (IsPercieved(seenBots[i])) {
					if (homePosition == null) {
						homePosition = seenBots[i].GetHomePosition();
					}
					if (seenResource == seenBots[i].GetSeenResource() && !seenBots[i].HasResource()) {
						PerceivableOtherTeamBotsOnIt ++;
					}
				}
			}
			
			if (seenResource != null && PerceivableOtherTeamBotsOnIt > ((seenResource.GetLife() / World.RESOURCE_UPDATE_VALUE) + 1)) {
					too_much_team_bots = true;
			}
			if(seenBot.GetSeenResource() != null) {
				if(!too_much_team_bots) {
					if (seenResource == null || seenBot.GetSeenResource() != null && seenResource.GetLife() < seenBot.GetSeenResource().GetLife()) {
						seenResource = seenBot.GetSeenResource();
					}
					if (takenResource == null || seenBot.GetTakenResource() != null && takenResource.GetLife() < seenBot.GetTakenResource().GetLife()) {
						if(seenBot.GetSeenResource() != seenBot.GetTakenResource()) {
							takenResource = seenBot.GetTakenResource();
						}
					}
				}
			}
		}
		
		public override function GoToResource():void {
			if(LastSeenResourcePos != null) {
				direction = LastSeenResourcePos.subtract(targetPoint);
				direction.normalize(1);
				LastSeenResourcePos = null;
				seenResource = null;
			}
		}
		
		protected function IsAtHome() : Boolean {
			if (home != null) {
				return (IsCollided(home));
			} else {
				return false;
			}
		}
		
		public function GetSeenResource() : Resource
		{
			if(seenResource != null && seenResource.IsDead()) {
				seenResource = null;
			}
			return seenResource;
		}
		
		public function GetTakenResource() : Resource
		{
			if (takenResource != null && takenResource.IsDead()) {
				takenResource = null;
			}
			return takenResource;
		}
	}
}