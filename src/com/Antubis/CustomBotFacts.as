package com.Antubis 
{
	import com.novabox.expertSystem.Fact;
	/**
	 * Cognitive Multi-Agent System Example
	 * Part 2 : Two distinct termite nests
	 * (Termites collecting wood)
	 * 
	 * @author Maximilien Noal & Antubis Team
	 * @version 1.0
	 */

	 //*****************************************************************
	// TODO : Register here all new facts used by your custom bots.
	//*****************************************************************

	public class CustomBotFacts {
		
		public static const NEAR_EDGES:Fact		= new Fact("Near one of the world's edges");
		
		public static const CLOSER_RESOURCE:Fact= new Fact("Another resource is closer.");
		
		public static const NO_PHERO_SEEN:Fact	= new Fact("Can see no phero.");
		
		public static const DROP_PHERO:Fact		= new Fact("Droping a new phero.");
	}

}