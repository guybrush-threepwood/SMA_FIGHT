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
		
		protected var not_moving:Boolean;
		protected var old_position:Point;
		protected var seenBot:AntubisBot;
		
		public override function AntubisBot(_type:AgentType) {
			super(_type);
			old_position = new Point(0, 0);
		}
		
		public override function Update() : void
		{
			UpdateFacts();
			Infer();
			Act();
			
			DrawSprite();
			
			if (botSprite) {
				old_position.x = botSprite.x;
				old_position.y = botSprite.y;
			}
			
			Chat();
			
			Move();
			
			not_moving = false;
			if (old_position.x == botSprite.x && old_position.y == botSprite.y) {
				not_moving = true;
			}

			reachedResource = null;
			home = null;
		}
		
		protected override function InitExpertSystem() : void {
			expertSystem = new ExpertSystem();
			
			expertSystem.AddRule(new Rule(AgentFacts.GO_TO_RESOURCE, 	new Array(	AgentFacts.NO_RESOURCE,
																					AgentFacts.SEE_RESOURCE)));
			
			expertSystem.AddRule(new Rule(AgentFacts.GO_TO_RESOURCE, 	new Array(	AgentFacts.NO_RESOURCE,
																					AgentFacts.NOTHING_SEEN,
																					CustomBotFacts.RESOURCE_FOUND)));

			expertSystem.AddRule(new Rule(AgentFacts.TAKE_RESOURCE, 	new Array(	AgentFacts.NO_RESOURCE,
																					AgentFacts.REACHED_RESOURCE)));

			expertSystem.AddRule(new Rule(AgentFacts.GO_HOME, 			new Array(	AgentFacts.GOT_RESOURCE,
																					AgentFacts.SEEING_HOME)));
			
			expertSystem.AddRule(new Rule(AgentFacts.PUT_DOWN_RESOURCE,	new Array(	AgentFacts.AT_HOME,
																					AgentFacts.GOT_RESOURCE)));

			expertSystem.AddRule(new Rule(AgentFacts.CHANGE_DIRECTION, 	new Array(	AgentFacts.NO_RESOURCE,
																					AgentFacts.NOTHING_SEEN,
																					CustomBotFacts.NO_RESOURCE_FOUND,
																					AgentFacts.CHANGE_DIRECTION_TIME)));
			
			expertSystem.AddRule(new Rule(AgentFacts.CHANGE_DIRECTION, new Array(	AgentFacts.GOT_RESOURCE,
																					AgentFacts.NOT_SEEING_HOME,
																					AgentFacts.CHANGE_DIRECTION_TIME)));
			
			expertSystem.AddRule(new Rule(AgentFacts.CHANGE_DIRECTION, new Array( 	CustomBotFacts.NOT_MOVING,
																					AgentFacts.CHANGE_DIRECTION_TIME)));
			
		}
		
		protected override function UpdateFacts() : void {
			updateTime += TimeManager.timeManager.GetFrameDeltaTime();
			if (updateTime > directionChangeDelay) {
				expertSystem.SetFactValue(AgentFacts.CHANGE_DIRECTION_TIME, true);
				updateTime = 0;
			}
			
			if (updateTime > directionChangeDelay && not_moving) {
				expertSystem.SetFactValue(CustomBotFacts.NOT_MOVING, true);
				updateTime = 0;
			}
		
			if (hasResource) {
				expertSystem.SetFactValue(AgentFacts.GOT_RESOURCE, true);
			}
			else {
				expertSystem.SetFactValue(AgentFacts.NO_RESOURCE, true);
			}
			
			if(seenResource) {
				expertSystem.SetFactValue(AgentFacts.SEE_RESOURCE, true);
			} else {
				expertSystem.SetFactValue(AgentFacts.NOTHING_SEEN, true);
			}
			
			if (reachedResource) {
				expertSystem.SetFactValue(AgentFacts.REACHED_RESOURCE, true);
			}
			
			if (takenResource != null && takenResource.GetLife() > 0) {
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
			if (collidedAgent.GetType() == CustomAgentType.ANTUBIS_BOT) {
						seenBot = (collidedAgent  as AntubisBot);
			}
		}
		
		public override function GoToResource():void {
			
			if (seenResource != null) {
				direction = seenResource.GetTargetPoint().subtract(targetPoint);
				direction.normalize(1);
				seenResource = null;
			} else if (takenResource != null) {
				direction = takenResource.GetTargetPoint().subtract(targetPoint);
				direction.normalize(1);
			}
		}
		
		protected function Chat():void {
			if(seenBot != null) {
				if (homePosition == null) {
					homePosition = seenBot.GetHomePosition();
				}
				if (seenResource == null) {
					seenResource = seenBot.GetSeenResource();
				}
				if (takenResource == null) {
					takenResource = seenBot.GetTakenResource();
				}
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
			return seenResource;
		}
		
		public function GetTakenResource() : Resource
		{
			return takenResource;
		}
	}
}