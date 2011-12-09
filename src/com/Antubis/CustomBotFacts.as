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
		public static const NEAR_EDGES:Fact			= new Fact("Near one of the world's edges");
		
		public static const CLOSER_RESOURCE:Fact	= new Fact("Another resource is closer.");
		
		public static const NO_CLOSER_RESOURCE:Fact	= new Fact("No closer resource.");
		
	}

}