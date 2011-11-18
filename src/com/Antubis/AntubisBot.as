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

	public class AntubisBot extends Bot
	{
		private var last_valid_rule:String = "";
		
		protected override function InitExpertSystem() : void
		{
			expertSystem = new ExpertSystem();
			
			expertSystem.AddRule(new Rule(AgentFacts.GO_TO_RESOURCE, 	new Array(	AgentFacts.NO_RESOURCE,
																					AgentFacts.SEE_RESOURCE)));

			expertSystem.AddRule(new Rule(AgentFacts.TAKE_RESOURCE, 	new Array(	AgentFacts.NO_RESOURCE,
																					AgentFacts.REACHED_RESOURCE)));

			expertSystem.AddRule(new Rule(AgentFacts.GO_HOME, 			new Array(	AgentFacts.GOT_RESOURCE,
																					AgentFacts.SEEING_HOME)));
			
			expertSystem.AddRule(new Rule(AgentFacts.PUT_DOWN_RESOURCE,	new Array(	AgentFacts.AT_HOME,
																					AgentFacts.GOT_RESOURCE )));

			expertSystem.AddRule(new Rule(AgentFacts.CHANGE_DIRECTION, 	new Array(	AgentFacts.NOTHING_SEEN,
																					AgentFacts.CHANGE_DIRECTION_TIME )));
																				
			expertSystem.AddRule(new Rule(AgentFacts.CHANGE_DIRECTION, 	new Array(	AgentFacts.TAKE_RESOURCE )));

			expertSystem.AddRule(new Rule(AgentFacts.CHANGE_DIRECTION, 	new Array(	AgentFacts.PUT_DOWN_RESOURCE )));

		}
		
		public function AntubisBot(_type:AgentType) {
			super(_type);
		}
		
		protected override function UpdateFacts() : void {
			updateTime += TimeManager.timeManager.GetFrameDeltaTime();
			if (updateTime > directionChangeDelay)
			{
				expertSystem.SetFactValue(AgentFacts.NOTHING_SEEN, true);
				expertSystem.SetFactValue(AgentFacts.CHANGE_DIRECTION_TIME, true);
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
			}
			
			if (reachedResource) {
				expertSystem.SetFactValue(AgentFacts.REACHED_RESOURCE, true);
			}
			
			if(homePosition != null) {
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
		
		protected function IsAtHome() : Boolean {
			if (home != null) {
				return (IsCollided(home));
			} else {
				return false;
			}
		}
	}
}