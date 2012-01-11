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
	
	public class CustomBotFacts {
		public static const SEE_NO_RESOURCE:Fact				= new Fact("No Resource is perceived.");
		public static const SEEN_RESOURCE:Fact					= new Fact("Seen a Resource.");
		public static const NO_RESOURCE_SEEN:Fact				= new Fact("No Resource seen.");
		public static const NEAR_EDGES:Fact						= new Fact("Near one of the World's edges");
		public static const CLOSER_RESOURCE:Fact				= new Fact("Another Resource is closer.");
		public static const SEEN_ENEMY_BOT:Fact					= new Fact("Seen an enemy Bot.");
		public static const NO_TEAM_BOT_SEEN:Fact				= new Fact("Seen no team Bot.");
		public static const SEEN_PHERO:Fact						= new Fact("Seen a Phero.");
		public static const PHERO_NOT_ALREADY_PASSED:Fact		= new Fact("Not already passed on this Phero.");
		public static const LAST_DROPED_PHERO_IS_TOO_FAR:Fact	= new Fact("Last droped Phero is at midway of the perceptionRadius.");
		public static const DROP_PHERO:Fact						= new Fact("Drop Phero action.");
		public static const GO_TO_PHERO:Fact					= new Fact("Go to Phero action.");
		public static const GO_TO_ENEMY_BOT:Fact				= new Fact("Go to enemy bot action.");
		public static const RENFORCE_PHERO:Fact					= new Fact("Renforce Phero action.");
	}
}