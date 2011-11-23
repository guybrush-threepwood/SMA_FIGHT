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
		
		public static const NEAR_EDGES:Fact			= new Fact("Near one of the world's edges");
		
		public static const TOO_MUCH_PEOPLE:Fact	= new Fact("Too much people of my team on this resource.");
		
		public static const NOT_TOO_MUCH_PEOPLE:Fact	= new Fact("Not too much people of my team on this resource.");
	}

}