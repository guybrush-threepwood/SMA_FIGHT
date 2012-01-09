package com.Antubis 
{
	import com.novabox.MASwithTwoNests.AgentType;
	/**
	 * Cognitive Multi-Agent System Example
	 * Part 2 : Two distinct termite nests
	 * (Termites collecting wood)
	 * 
	 * @author Maximilien Noal & Antubis Team
	 * @version 1.0
	 */
	
	//*****************************************************************
	// TODO : Register here all new agent types (Bot and Messages)
	//*****************************************************************
	 
	public class AntubisAgentType {
		public static const ANTUBIS_BOT:AgentType = new AgentType(	AntubisBot,
																	0.7
																	);
		public static const PHERO_BOT:AgentType = new AgentType( 	PheroBot,
																	0.3
																	);
		public static const PHERO:AgentType = new AgentType(		Phero,
																	0
																	);
	}

}