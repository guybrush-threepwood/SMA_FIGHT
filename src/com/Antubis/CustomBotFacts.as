package com.Antubis 
{
	import com.novabox.expertSystem.Fact;
	/**
	 * Cognitive Multi-Agent System Example
	 * Part 2 : Two distinct termite nests
	 * (Termites collecting wood)
	 * 
	 * @author Ophir / Nova-box
	 * @version 1.0
	 */

	 //*****************************************************************
	// TODO : Register here all new facts used by your custom bots.
	//*****************************************************************

	public class CustomBotFacts
	{		
		//public static const CUSTOM_FACT:Fact = new Fact("");
		
		public static const RESOURCE_FOUND:Fact 	= new Fact("Found a resource");
		
		public static const NO_RESOURCE_FOUND:Fact 	= new Fact("Found no resource");
		
		public static const NOT_MOVING:Fact 		= new Fact("Not moving");
		
		public static const STEALABLE_BOT:Fact		= new Fact("Collided with an enemy bot carying resources");
		
		public static const NO_STEALABLE_BOT:Fact	= new Fact("Collided with no enemy bot carying resources");
		
		public static const STEAL_BOT:Fact			= new Fact("Stealing enemy bot");
	}

}