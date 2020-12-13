
model Festival
global {
	
	int circleDistance <- 8;	
	int talkRangeArea <- 5; //ask if smaller or equal	
	int globalDelayTime <- 20; //time before agent starts talking
	int willingToDanceMetric<-50;
	int willingToAcceptDrinkMetric<-50;

	
	int globalHappinessValue <- 0 update: sum((MetalHead) collect (each.happy) + (ChillPerson) collect (each.happy) + (Gamer) collect (each.happy));
	int globalDrunkValue <- 0 update: sum((MetalHead) collect (each.drunk) + (ChillPerson) collect (each.drunk) +  (Gamer) collect (each.drunk));

	init {		
		
		create MetalHead number: 10;
		create ChillPerson number: 10;
		create Thief number: 10;
		create Police number: 10;
		create Photographer number: 10;
		create Gamer number: 10;
		
//		create MetalHead number: 0;
//		create ChillPerson number: 15;
//		create Thief number: 0;
//		create Police number: 0;
//		create Photographer number: 0;
//		create Gamer number: 15;
		

		
		create Studio number: 1
		{
		location <- {80,10,0};
		}
		
		
		create GamingArea number: 1
		{
		location <- {50,80,0};
		}
		
				
		create Stage number: 1
		{
		location <- {50,50,0};
		}
		
		create Pub number: 1
		{
		location <- {20,80,0};
		}
		
		create ShadyPlace number: 1
		{
		location <- {90,90,0};
		}
		
		create PoliceStation number: 1
		{
		location <- {10,10,0};
		}
	}
}

species Studio{
	
		aspect base {
		draw square(3) color: #chocolate;
	}
	
}

species PoliceStation{
	int money<-rnd(20,100);
		aspect base {
		draw square(3) color: #blue;
	}
		
}

species Pub{
	
		aspect base {
		draw square(3) color: #green ;
	}
		
}

species GamingArea{
		aspect base {
		draw square(3) color: #indigo ;
	}
		
}


species ShadyPlace{
	int money <-0;
		aspect base {
		draw circle(3) color: #grey;
	}

}


species Stage skills: [fipa] {
	aspect base {
		draw square(5) color: #darkslategrey;
		
	}
}


species Gamer skills: [fipa, moving]{
	bool busy <- false;
	point initPoint <- {(rnd(0,100)),(rnd(0,100)),0};
	point targetPoint <- nil;
	bool talking <- false;
	bool isRobbed <- false;
	int gameSpiritMetric <- rnd(1,100);  //sending and accepting the challenge proposals depends on this value
	int localDelayTime;
	bool delayOK<-true;
	int startDelay;
	bool phone_call<-false;
	bool wait_for_phone_answer <-false;
	
		reflex countDelay when: !delayOK 
	{
		if((time-startDelay)>globalDelayTime)
		{
			delayOK<-true;
			talking<-false;
		
		}
			
	}
	
	//traits
	int willingToChallenge<-rnd(1,100);
	int willingToGetClicked <- rnd(1,100);
	int willingToGetDrunk <-rnd(1,100);

	
	//communication with chill guy
	list<string> askPhotographer <- ["You should take a Photo of me!","I hate being clicked"];
	list<string> askChillPerson <-["Up for challenge at the gaming area ?","You dont seem free , another day ,peace" ];
	list<string> askGamer <-["Up for challenge at the gaming area ?","You dont seem free , another day ,peace" ];
	
	//communication with thief
	list<string> askThief <- ["Why are you so close? Answer or I will hit you!"];
	
	//communication with police
	list<string> askPolice <- ["Catch the thiefs, they are everywhere?","Hello Police"];
	
	
	// attributes
	int happy<-0 max:100;
	int drunk<-0 max:100;
	
	
	reflex initiateTalkPhotographer when: !empty(Photographer at_distance talkRangeArea) and !talking {
		list PhotographerNotBusy <- Photographer at_distance talkRangeArea;
				
		if(length(PhotographerNotBusy)>0)
		{
			Photographer talkTo <- one_of(PhotographerNotBusy);
			
			ask talkTo {
				myself.talking<-true;				
							
				if(myself.willingToGetClicked>50)
				{
				write myself.name+" says "+myself.askPhotographer[0];
				if(self.gotGoodSkills)
				{
					write self.name+" says "+self.answerGamer[0];
				}
				else{
					write self.name+" says "+self.answerGamer[1];
				}
				}			
				else{
				write myself.name+"says"+myself.askPhotographer[1];
				}				myself.talking<-false;
				
				
			}
		}
				
	} 
	
	reflex initiateTalkPolice when: !empty(Police at_distance talkRangeArea) and !talking{
		list PolicesNotBusy <- Police at_distance talkRangeArea;
				
		if(length(PolicesNotBusy)>0)
		{
			Police talkTo <- one_of(PolicesNotBusy);
			
			ask talkTo {
				myself.talking<-true;				
							
			
				write myself.name+" says "+myself.askPolice[0];
				if(self.catchThiefSuccessfullyFlag)
				{
					write self.name+" says "+self.answerGamer[0];
				}
				else{
					write self.name+" says "+self.answerGamer[1];
				}
				myself.talking<-false;
							
				
			}
		}
				
	} 
	
		reflex initiateTalkThief when: !empty(Thief at_distance talkRangeArea) and !talking{
		list ThiefsNotBusy <- Thief at_distance talkRangeArea;
				
		if(length(ThiefsNotBusy)>0)
		{
			Thief talkTo <- one_of(ThiefsNotBusy);
			
			ask talkTo {
				myself.talking<-true;				
							
			
				write myself.name+" says "+myself.askThief[0];
				if(self.willEventuallySucceedRobbing)
				{
					write self.name+" says "+self.answerGamer[0];
				}
				else{
					write self.name+" says "+self.answerGamer[1];
				}
				myself.talking<-false;
							
				
			}
		}
	
}

		reflex initiateTalkWithChillPerson when: !empty(ChillPerson at_distance talkRangeArea) and !talking{
		list ChillNotBusy <- ChillPerson at_distance talkRangeArea;
			
		if(length(ChillNotBusy)>0)
		{
			
			ChillPerson talkTo <- one_of(ChillNotBusy);
			
			ask talkTo {
				myself.talking<-true;				
				if(flip(0.9)){
					write myself.name + " says "+ myself.askChillPerson[0];
					if(self.busy){
						write myself.name + " says "+ myself.askChillPerson[1];
						myself.happy <- myself.happy-5;
						if(myself.willingToGetDrunk > 40){
								write name+"Am gonna get drunk, huh";
				                busy<-true;
				                targetPoint<- any_location_in(one_of(Pub));
				                drunk<-drunk +1;
						}
					}else{
							
						write  self.name + ' Its on then!!, lets go to the gamimng area';
						myself.targetPoint <- {50,80,0};
						self.targetPoint <-{50,80,0};
						myself.busy<- true;
						self.busy<- true;
						myself.happy<-myself.happy+5;
						self.happy<-self.happy+5;
						
					//}
				}	
							
			}
			myself.talking<-false;	
			}
		}
	
}


		reflex initiateTalkWithOtherGamer when: !empty(Gamer at_distance talkRangeArea) and !talking{
		list GamerNotBusy <- Gamer at_distance talkRangeArea;
			
		if(length(GamerNotBusy)>0)
		{
			
			Gamer talkTo <- one_of(GamerNotBusy);
			
			ask talkTo {
				myself.talking<-true;				
				if(flip(0.9)){
					write myself.name + " says "+ myself.askGamer[0];
					if(self.busy){
						write myself.name + " says "+ myself.askGamer[1];
						myself.happy <- myself.happy-2;
						if(myself.willingToGetDrunk > 50){
								write name+"Am gonna get drunk, huh";
				                busy<-true;
				                targetPoint<- any_location_in(one_of(Pub));
				                drunk<-drunk +1;
						}
					}else{
							
						write self.name +' Its on then!!, lets go to the gamimng area';
						myself.targetPoint <- {50,80,0};
						self.targetPoint <-{50,80,0};
						myself.busy<- true;
						self.busy<- true;
						myself.happy<-myself.happy+5;
						self.happy<-self.happy+5;
						
				}	
							
			}
			myself.talking<-false;	
			}
		}
	
}

reflex beIdle when: !(busy) and !talking {
		do wander;
		}
		
reflex moveToTarget when: targetPoint != nil and !talking
    {  
	do goto target:targetPoint;
	}
	
reflex arrivedAtDestination when: busy{
		if(distance_to(self,targetPoint)<1){
		
		write self.name + "At destination";
		self.targetPoint <- nil;
		self.busy<-false;	
		
			
		}
	}	
aspect base {
	draw circle(1) color: #cyan depth:1;
}

}

species Thief skills: [fipa,moving] {
	
	 
	point initPoint <- {(rnd(0,100)),(rnd(0,100)),0};
	
	point targetPoint <- nil;
	list<ChillPerson> ChillGuysNotBusy;
	list<MetalHead> RockFanNotBusy;
	ChillPerson chill;
	MetalHead rock;
	bool getCaught <- false;
	int localDelayTime <- 80;
	bool delayOK<-true;
    int startDelay;
    
    // traits
    int randomChoiceNumber <- rnd(40,60);
    int money <- 5;
    bool willEventuallySucceedRobbing <- flip(0.5);
    int caughtChance <- rnd(2,4);
    bool willRobFlag<-false;	
    
    //attributes
    int happy <- 0;
    
    /* Rules */
    list<string> answerChillguy1 <- ["That's none of your business","I'm looking for my friend"];
    
    list<string> answerRockfan1 <- ["Sorry","Sorry my mistake "];
    list<string> answerGamer<- ["Sorry","Sorry my mistake "];

    list<string> answerThief <- ["Yes thank you my friend I have low on money","No thank you I have enough money"];
    list<string> askFellowThief <- ["Hello, Do you want some financial help homie?","Hello thief homie"];
    
    
    
    
		
    reflex beIdle when: empty(ChillGuysNotBusy) and empty(RockFanNotBusy) {
		do wander;
	}
	
		
	reflex moveToTarget when: targetPoint != nil{
		do goto target:targetPoint;
	}
	
		reflex initiateTalkThief when: !empty(Thief at_distance talkRangeArea){
		list ThiefsNotBusy <- Thief at_distance talkRangeArea;
				
		if(length(ThiefsNotBusy)>0)
		{
			Thief talkTo <- one_of(ThiefsNotBusy);
			
			ask talkTo {
							
				if(myself.money>5)
				{
				write myself.name+" says "+myself.askFellowThief[0];
				if(self.money>25)
				{
					write self.name+" says "+self.answerThief[1];	
				}
				else{
					write self.name+" says "+self.answerThief[0];
					self.money<-self.money+1;
					myself.money<-myself.money-1;
				}
				}			
				else{
				write myself.name+"says"+myself.askFellowThief[1];
				}
										
				
			}
		}
				
	} 

	
	reflex initiateRob when: !willRobFlag and self.money <30 and !getCaught {
	
	ChillGuysNotBusy <- ChillPerson where (each.talking=true and each.isRobbed =false);	
	RockFanNotBusy <- MetalHead where (each.talking=true and each.isRobbed =false);	
		
	
	if(randomChoiceNumber >= 50 and !empty(ChillGuysNotBusy)){	
	  chill <- one_of(ChillGuysNotBusy);
	  targetPoint<- any_location_in(chill);
	  write name+"$$$$$$$$$$$Handle me your wallet$$$$$$$$$$$$$$$$$";
	  willRobFlag <- true;
	}
	else if(randomChoiceNumber < 50 and !empty(RockFanNotBusy)){	
	rock <-one_of(RockFanNotBusy);
	targetPoint<- any_location_in(rock);
	write name+"$$$$$$$$$$$Handle me your wallet$$$$$$$$$$$$$$$$$";
	willRobFlag <- true;
	}
	}
	
	
	reflex Talktopolice when: !empty(cfps){
		message proposalFromInitiator <- cfps[0];
		string suspectInfo <- list(proposalFromInitiator.contents)[0];
		string guiltyInfo <- list(proposalFromInitiator.contents)[1];
		string warningInfo <- list(proposalFromInitiator.contents)[2];
		bool catchThiefFlag <- bool(list(proposalFromInitiator.contents)[3]);
		
		write suspectInfo;
		if(self.money=5 or catchThiefFlag){
			write warningInfo;
		}
		else if(self.money>5){
			write guiltyInfo;
			getCaught <- true;
			targetPoint <- any_location_in(one_of(PoliceStation));
			do start_conversation with: [ to :: list(Photographer), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self]];
			self.money <-0;
		}
	}	
	
	
	reflex startRob when:willRobFlag and !getCaught{
	
	if(!empty(Police at_distance caughtChance)){
	 write name+"^^^^^^^^^^^^^^^POLICE SPOTTED!!!^^^^^^^^^^^^^^^^";
	  willRobFlag <- false;
	  targetPoint <- nil;
	  happy<-happy-5;
	 
	  
	  do start_conversation with: [ to :: list(one_of(Police at_distance 4)), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self,self.location]];
	}
	
	else{
		
		if(randomChoiceNumber>=50 and distance_to(self, targetPoint)<1){	
			ask chill{
			if(self.money>5 and myself.willEventuallySucceedRobbing){
				write name+"Wow that was a good heist !!!!!!!!!";
			myself.money <- myself.money+5; 
			self.money <- self.money-5;
			write myself.money;
			myself.willRobFlag <- false;
			myself.happy<-myself.happy+1;
			self.happy<-self.happy-1;
			}
			else{
				write name+"Cant rob this already poor lad :( ";
				myself.willRobFlag <- false;
				myself.happy<-myself.happy-1;
				self.happy<-self.happy+1;
				self.isRobbed<-true;
				
			}
			}	
		}
		else if(randomChoiceNumber < 50 and distance_to(self, targetPoint)<1){
			ask rock {
			if(self.money>5 and myself.willEventuallySucceedRobbing){
				write "Wow that was a good heist !!!!!!!!!";
			myself.money <- myself.money+5; 
			self.money <- self.money-5;
			write myself.money;
			myself.willRobFlag <- false;
			myself.happy<-myself.happy+1;
			self.happy<-self.happy-1;
			
			}
			else{
				write "Cant rob this already poor lad :( ";
				myself.willRobFlag <- false;
				myself.happy<-myself.happy-1;
				self.happy<-self.happy+1;
				self.isRobbed<-true;
				
				
			  }
		   }	
		}
	}
	
 }
 
 reflex gotoRobbed when:!willRobFlag and self.money=30{
 	 targetPoint<- any_location_in(one_of(ShadyPlace));
 }
 
 reflex saveRobbed when: !empty(ShadyPlace at_distance 1) {
 	
 	ask ShadyPlace at_distance 1{	
 		self.money <- self.money + myself.money;
 		myself.money<- 5;		
 	}
 	
 }
 
	aspect base {
		draw circle(1) color: #red depth:1;
	}
	
}


species Police skills: [fipa,moving] { 

	point initPoint <- {(rnd(0,100)),(rnd(0,100)),0};
	
	point targetPoint <- nil;
	bool isPatroling <- false;
	bool shouldTakeMoneyFromOtherSource <- false;
	
	
	//traits
	int money <-0;
    bool catchThiefSuccessfullyFlag<- flip(0.5);
	bool wishToPatrol <- flip(0.5);
	
	/* Some rules, more inside functions */
	list<string> answerChillguy1 <- ["I have catched many thiefs","I have not catched so many"];
	
	list<string> answerRockfan1 <- ["Yes I will continue cath them","I am a looser Police. I can't"];
	list<string> answerGamer <- ["Yes I will continue catch them","I cant catch them , am messed up"];
	//Rules for talking
	list<string> askChillguy <- ["Why are you so sad?","Have fun and take care"];
	
	list<string> askMetalHead <- ["Why are you so over excited and disturbing?","You are very loud. Please be quiet."];	
	
	
		reflex initiateRockFan when: !empty(MetalHead at_distance talkRangeArea){
		list MetalHeadsNotBusy <- MetalHead at_distance talkRangeArea;
				
		if(length(MetalHeadsNotBusy)>0)
		{
			MetalHead talkTo <- one_of(MetalHeadsNotBusy);
			
			ask talkTo {
							
				if(myself.wishToPatrol)
				{
				write myself.name+" says "+myself.askMetalHead[0];
				if(self.drunk>0)
				{
					write self.name+" says "+self.answerPolice[0];				
				}
				else{
					write self.name+" says "+self.answerPolice[1];
				}
				}			
				else{
				write myself.name+"says"+myself.askMetalHead[1];
				}
										
				
			}
		}
				
	} 
	
	reflex salute_other_police when: !empty(Police at_distance 1){
		
		ask Police at_distance 1{
			
			if(self.shouldTakeMoneyFromOtherSource = false and myself.shouldTakeMoneyFromOtherSource = false){
				write "Supp my donut homie!!!!!!";		
			}
			if(self.shouldTakeMoneyFromOtherSource = true){
				write "I should probably get some protection money form shady area!!";
			}
			
		}
	}
	
	
		reflex initiateChillGuy when: !empty(ChillPerson at_distance talkRangeArea){
		list ChillGuysNotBusy <- ChillPerson at_distance talkRangeArea;
				
		if(length(ChillGuysNotBusy)>0)
		{
			ChillPerson talkTo <- one_of(ChillGuysNotBusy);
			
			ask talkTo {
							
				if(myself.wishToPatrol)
				{
				write myself.name+" says "+myself.askChillguy[0];
				if(self.drunk>0)
				{
					write self.name+" says "+self.answerPolice[0];
					
				}
				else{
					write self.name+" says "+self.answerPolice[1];
				}
				}			
				else{
				write myself.name+"says"+myself.askChillguy[1];
				}
										
				
			}
		}
				
	} 
	
		
    reflex beIdle when: empty(Thief at_distance 3)and !isPatroling and !shouldTakeMoneyFromOtherSource{  
		if(wishToPatrol){
				targetPoint <- any_location_in(one_of(Stage+Pub+Studio));
				isPatroling <- true;
}
             
	}
	
	reflex moveToTarget when: targetPoint != nil{
		do goto target:targetPoint;
	}
	
	
	reflex gotoRobbed when:!empty(informs) and !shouldTakeMoneyFromOtherSource{
		
	   write name+"FBI Open up!!!!!";
	   
	  
	  
	   list<string> askThief<-["&&&&I have doubt on you ,Show me your pockets&&&&&","&&&&&&Your are going to jail ,lol&&&&&&","&&&&&&&Remember,I have my eyes on you, its a warning&&&&&&&&&&"];	   
	   message informFromInitiator <- informs[0];
	   agent thief <- list(informFromInitiator.contents)[0];
	   point thiefLoc <- list(informFromInitiator.contents)[1];
	   
	
	   do start_conversation with: [ to :: list(thief), protocol :: 'fipa-contract-net', performative :: 'cfp', contents :: [askThief[0],askThief[1],askThief[2],catchThiefSuccessfullyFlag]];
	
	   targetPoint<-any_location_in(one_of(PoliceStation));
	
      }

    reflex inStation when: !empty(Pub at_distance 1) or!empty(Studio at_distance 1) or !empty(Stage at_distance 1) and !shouldTakeMoneyFromOtherSource{
	self.isPatroling <- false;
	
}
  	
	reflex initiate_raid when: !empty(PoliceStation at_distance 2){
		
		ask PoliceStation at_distance 1{
			
			if(self.money=0 or self.money<0 and myself.money=0 or myself.money<0){
				
				myself.targetPoint <- any_location_in(one_of(ShadyPlace));	    
			    myself.shouldTakeMoneyFromOtherSource <- true;
			    
			}
			else if(myself.money>0){
				
				myself.shouldTakeMoneyFromOtherSource <- false;
				self.money <- myself.money;
				myself.money <-0;
				if(myself.wishToPatrol){
					 myself.targetPoint <- any_location_in(one_of(Stage+Pub+Studio));
              
               myself.isPatroling <- true; 
				}
         
			}
			else{
				if(myself.wishToPatrol){
					 myself.targetPoint <- any_location_in(one_of(Stage+Pub+Studio));
              
               myself.isPatroling <- true; 
				}
			}
		}
	}
	
	reflex goto_shady_area when: !empty(ShadyPlace at_distance 1) and shouldTakeMoneyFromOtherSource  {
		ask ShadyPlace{
			
			if(self.money>0){
				myself.money <- self.money;
				self.money<-0;
				myself.targetPoint <- any_location_in(one_of(PoliceStation));
				
			}
			else{
				myself.targetPoint <- any_location_in(one_of(Stage+Pub+Studio));
				myself.shouldTakeMoneyFromOtherSource <- false;
			}
		
		}
	}
	
	
	aspect base {
		draw circle(1) color: #blue depth:1;
	}
	
}

species Photographer skills: [fipa,moving] {
	
	int startDelay <- 200;
	bool caught <- false;
	int cameraBattery <- rnd(5,20);
		
	point initPoint <- {(rnd(0,100)),(rnd(0,100)),0};
		
	
	point targetPoint <- nil;
	
	/* Traits */
	bool willingToClickFlag <- flip(0.5);
	bool gotGoodSkills <- flip(0.5);
	
	/*Rules, more are below	 */
	list<string> answerChillguy1 <- ["Yes of course, I use to send information to everyone","Go away I'm busy"];
	list<string> answerGamer <- ["I promise to send Information to you","I'm busy right now"];
	list<string> answerRockfan1 <- ["I promise to send Information to you","I'm busy right now"];
		
    reflex beIdle when: targetPoint = nil {
		do wander;
	}
	
	reflex moveToTarget when: targetPoint != nil{
		do goto target:targetPoint;
	}
	
	reflex take_chill_person_picture when: !empty(ChillPerson at_distance 1)   {
	write name+" found a chill person";
	if(willingToClickFlag)
	{    
    targetPoint <- any_location_in(one_of(ChillPerson at_distance 1));
	do start_conversation with: [ to :: list(ChillPerson at_distance 1), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: ["You want a Picture?","Come to Photoshop to collect the photos!","Clicked",self,gotGoodSkills]]; 
      	cameraBattery <- cameraBattery - 1;
	}
	else{
		write name+" I don't want to take a photograph of you, I just dont feel like doing it! ";
	}
	}
	
	
	
	reflex take_metal_head_picture when:  !empty(MetalHead at_distance 1) {
	write name+" found a metal head ";	
		if(willingToClickFlag)
	{
    
    targetPoint <- any_location_in(one_of(MetalHead at_distance 1));
	do start_conversation with: [ to :: list(one_of(MetalHead at_distance 1)), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: ["You want a Picture?","Come to Photoshop to collect the photos!","Clicked",self,gotGoodSkills]];
	cameraBattery <- cameraBattery - 1;
	}
	else{
		write name+" I don't want to take photo of you. I just dont feel like doing it!";
		
	}
	}
 	
  	reflex go_to_studio when: cameraBattery <=0{
 		targetPoint <- any_location_in(one_of(Studio));
 		
 		
 	}
 	
 	reflex at_studio when: !empty(Studio at_distance 1){
 		write "???????I want to charge my battery please?????????";
 		cameraBattery <- rnd(5,20);
 		targetPoint <- any_location_in(one_of(MetalHead));
 	}
 	
 	reflex take_police_picture when:  !empty(Police at_distance 1) and !caught {
 		list<string> askPolice<-["Clicked the pic , you want it, its for free though?", "Here's your photo!"];	  
        do start_conversation with: [ to :: list(one_of(Police at_distance 1)), protocol :: 'fipa-contract-net', performative :: 'cfp', contents :: [askPolice[0],askPolice[1]]];
        cameraBattery <- cameraBattery - 1;
 	
 	}
 	
 	reflex talk_to_photographer when:  !empty(Photographer at_distance 1) and !caught {
 		list<string> askPhotographer<-["Hello fellow photographer homie", "hey man , nice festival"];	  
        do start_conversation with: [ to :: list(one_of(Photographer at_distance 1)), protocol :: 'fipa-contract-net', performative :: 'cfp', contents :: [askPhotographer[0],askPhotographer[1]]];
 	
 	}
 	
  	reflex talk_when_notCaught when:  !empty(cfps) and caught {
 	
 		message talkToJournalist <- cfps[0];
		string info <- list(talkToJournalist.contents)[0];
		string info2 <- list(talkToJournalist.contents)[1];
		write info;
		write "<<<<<<<<<<Hey homie photographer>>>>>>>>>>>>";
		write info2;
		write "<<<<<<<<<<<<Yeah! pretty good business!>>>>>>>>>>>>>>>";		
 	}
 
 	
 	reflex take_pic when: !empty(informs){
	 message informFromInitiator <- informs[0];
	   agent thief <- list(informFromInitiator.contents)[0];
	  caught <- true;
	   write"Seems like "+ thief + " has been caught";
	  targetPoint <- any_location_in(one_of(PoliceStation));
		
	}
	
	
	reflex ask_police_station when: !empty(PoliceStation at_distance 1){
	
		if((time-startDelay)>globalDelayTime)
		{
			write name+" please notify all festival guests to be careful for the thiefs
";
		
			caught <- false;
		}
	}
	
	
	reflex ignore when: !empty(refuses){
			loop r over: refuses {
		string info <- list(r.contents)[0];
		write info;
		int picrand <- rnd(1,100);
		if(picrand<=50){
		targetPoint <- any_location_in(one_of(ChillPerson));
	}
	else{
		targetPoint <- any_location_in(one_of(MetalHead));
	}
	}
	}
	
	aspect base {
		draw circle(1) color: #chocolate depth:1;
	}
	
}


species ChillPerson skills: [fipa,moving] {
	
	bool isBad <- false;
	bool busy <- false;
	bool talking<-false;
	int localDelayTime;
	
	
	bool delayOK<-true;
	int startDelay;
	
	reflex countDelay when: !delayOK 
	{
		if((time-startDelay)>localDelayTime)
		{
			delayOK<-true;
			talking<-false;
		}
			
	}
	point initPoint <- {(rnd(0,100)),(rnd(0,100)),0};
	
	/* TRAITS */
	int generous<-rnd(1,100);
	int willingToAcceptDrink<-rnd(1,100);
	int willingToDance<-rnd(1,100);
	int willingToFight<-rnd(1,100);
	int fightingSkills <-rnd(1,100);
	
	/* RULES */

	//ROCKFAN
	list<string> answerPub1<-["No I don't want a drink?","Yes I want a drink?"];
	list<string> answerStage1<-["No I don't want to dance?","Yes I want to dance"];
	string answerOutside1  <-  "None of your business!!!";
	
	//CHILLGUY
	list<string> answerChillGuy1 <- ["Hi! Thanks, it's a nice day today.","I will defend myself.","No I don't want to fight"];	
	list<string> askChillGuy1 <- ["Hello, good day to you sir","I want to fight you","I will fight you another day then"];
	
	//THIEF
	list<string> askThief1 <- ["Hello, why are you so close?","Help, I will go away from you thief"];
	
	//POLICE
	list<string> askPolice1 <- ["Have you seen any Thiefs somewhere?","Good day to you Officer"];
	list<string> answerPolice <- ["Because I am too drunk sorry","I have always been quiet"];
	
	
	//Journalist
	list<string> askJournalist1 <- ["Can you take my Photo?","Damn you journalist go away"];
	
	
	
	
	
	/* ATTRIBUTES */
	int drunk<-0;
	int happy<-0;
	int money<-rnd(50,100);
	int savings <- money;
	bool isRobbed <- false;
	int diff<-0;
		
	
	point targetPoint <- nil;
	
		reflex arrivedAtDestination when: busy{
			if(distance_to(self,targetPoint)<1){
			
			write self.name + "At destination";
			self.targetPoint <- nil;
			self.busy<-false;			
			}
		}
	    
	    
	    reflex take_pic_chill when: !empty(informs){
	   message informFromInitiator <- informs[0];
	   message proposalFromInitiator <-list(informFromInitiator.contents)[3];
	   string photo <- list(informFromInitiator.contents)[0];
	   string collectphoto <- list(informFromInitiator.contents)[1];
	   string takingphoto <- list(informFromInitiator.contents)[2];
	   int isGoodPhotograph<- int(list(informFromInitiator.contents)[3]);

	   int takepic <- rnd(40,60);
	   
	   if(takepic<=50 and isGoodPhotograph>25){
	   	 write photo;
	   	 write "Yeah Totally";
	   	 write takingphoto;
	   	 write collectphoto;
	   	 targetPoint <- any_location_in(one_of(Studio)); 
	   }
	   else{
	   	do refuse with: [ message :: informFromInitiator, contents :: ["No Thanks!!"] ];
	   }
		
	}
	
	
	
	reflex initiateTalkPhotographer when: !empty(Photographer at_distance talkRangeArea) and !talking {
		list PhotographersNotBusy <- Photographer at_distance talkRangeArea;
				
		if(length(PhotographersNotBusy)>0)
		{
			Photographer talkTo <- one_of(PhotographersNotBusy);
			
			ask talkTo {
				myself.talking<-true;				
							
				if(myself.generous>50)
				{
				write myself.name+" says "+myself.askJournalist1[0];
				if(self.gotGoodSkills)
				{
					write self.name+" says "+self.answerChillguy1[0];
				}
				else{
					write self.name+" says "+self.answerChillguy1[1];
				}
				}			
				else{
				write myself.name+"says"+myself.askJournalist1[1];
				}
				
				myself.talking<-false;
							
				
			}
		}
				
	} 
	
	reflex initiateTalkPolice when: !empty(Police at_distance talkRangeArea) and !talking {
		list PolicesNotBusy <- Police at_distance talkRangeArea;
				
		if(length(PolicesNotBusy)>0)
		{
			Police talkTo <- one_of(PolicesNotBusy);
			
			ask talkTo {
				myself.talking<-true;				
							
				if(myself.generous>50)
				{
				write myself.name+" says "+myself.askPolice1[0];
				if(self.catchThiefSuccessfullyFlag)
				{
					write self.name+" says "+self.answerChillguy1[0];
				}
				else{
					write self.name+" says "+self.answerChillguy1[1];
				}
				}			
				else{
				write myself.name+"says"+myself.askPolice1[1];
				}
			    myself.talking<-false;
			}
		}
				
	} 
	
	reflex initiateTalkThief when: !empty(Thief at_distance talkRangeArea) and !talking {
		list ThiefsNotBusy <- Thief at_distance talkRangeArea;
				
		if(length(ThiefsNotBusy)>0)
		{
			Thief talkTo <- one_of(ThiefsNotBusy);
			
			ask talkTo {
				myself.talking<-true;				
							
				if(myself.generous>50)
				{
				write myself.name+" says "+myself.askThief1[0];
				if(self.willEventuallySucceedRobbing)
				{
					write self.name+" says "+self.answerChillguy1[0];
				}
				else{
					write self.name+" says "+self.answerChillguy1[1];
				}
				}			
				else{
				write myself.name+"says"+myself.askThief1[1];
				}
				myself.talking<-false;
			}
		}
				
	} 
	
	
		reflex initiateTalkMetalHead when: !empty(MetalHead at_distance talkRangeArea) and !talking {
		list MetalHeadsNotBusy <- MetalHead at_distance talkRangeArea where (each.talking=false);
				
		if(length(MetalHeadsNotBusy)>0)
		{
			MetalHead talkTo <- one_of(MetalHeadsNotBusy);
			
			ask talkTo {
				self.talking<-true;
				myself.talking<-true;				
				bool inPub<-false;
				bool inStage <- false;
				bool inOutside <- false;
				
				if (distance_to(myself,one_of(Pub))<8)
				{
					inPub<-true;
				}
												
				if (distance_to(myself,one_of(Stage))<8)
				{
					inStage<-true;
				}
				
				if(!inStage and !inPub)
				{
					inOutside<-true;
				}
						
				write myself.name+" says hello. I'm usually not interested in talking to you.";
				write self.name+" says hello back";
			
				string localAsk <- inStage ? self.askStage1 : (inPub ? self.askPub1 : self.askOutside1);

				write self.name+" says" + localAsk;
				
				if(inPub)
				{
					if(myself.willingToAcceptDrink<willingToAcceptDrinkMetric)
					{
					myself.happy<-myself.happy-5;
					self.happy<-self.happy-5;
					myself.drunk<-myself.drunk-1;
					self.drunk<-self.drunk-1;
					}
					else{
					write myself.name+" says"+myself.answerPub1[1];
					myself.happy<-myself.happy+5;
					self.happy<-self.happy+5;
					myself.drunk<-myself.drunk+1;
					self.drunk<-self.drunk+1;
					}
				}
				//TODO more interactions can be added here
				// STAGE 
				if(inStage)
				{
					if(myself.willingToDance<willingToDanceMetric)
					{
					write myself.name+" says"+myself.answerStage1[0] ;
					myself.happy<-myself.happy-1;
					self.happy<-self.happy-1;
					}
					else{
					write myself.name+" says"+myself.answerStage1[1];
					myself.happy<-myself.happy+5;
					self.happy<-self.happy+5;
					}
				}

				/* OUTSIDE */
				if(inOutside)
				{
				write myself.answerOutside1;
				}
				
				//MAKE DIFFERENT DELAYS SO THEY DON't START TALKING
				myself.talking<-false;
				self.talking<-false;
				
				
			}
	}
				
	} 
	
	 reflex photo_area when: !empty(Studio at_distance 1){
	 	ask Studio{
	 		write "There you go! Your Photos";
	 	}
	 }
	    
	    reflex gotoPS1 when: savings != money{
	   
	    	isRobbed <- true;
	    	
	    	targetPoint <- any_location_in(one_of(PoliceStation));
	    	diff <- savings-money;
	    	
	    	
	    	ask PoliceStation at_distance 1{
	    		
	    		self.money <- self.money-myself.diff;
	    		myself.money <- myself.savings;
	    		myself.isRobbed <- false;
	    	}	  	
	    }

		reflex decideWhatToDo when:!talking {
		
		//decide where to go or not go somewhere
		if(!busy)
		{
			int whereToGo <- rnd(0,40);
			
			if(whereToGo=0)
			{
				//Stage
				write name+"goes to stage";
				busy<-true;
				targetPoint<- any_location_in(one_of(Stage));
				targetPoint <- {(targetPoint.x-rnd(-circleDistance/2,circleDistance/2)),(targetPoint.y-rnd(-circleDistance/2,circleDistance/2)),targetPoint.z };
			}
			
			if(whereToGo=2)
			{
				//Pub
				write name+"goes to pub";
				busy<-true;
				targetPoint<- any_location_in(one_of(Pub));	
				targetPoint <- {(targetPoint.x-rnd(-circleDistance/2,circleDistance/2)),(targetPoint.y-rnd(-circleDistance/2,circleDistance/2)),targetPoint.z };
			}
			
			bool mightBecomeBad <- flip(0.3);
			if(mightBecomeBad){
				write name+"becomes bad";
				isBad<-true;
			}
		}

	}
	
	
	reflex initiateTalk when: !empty(ChillPerson at_distance talkRangeArea) and !talking {
	list ChillGuysNotBusy <- ChillPerson at_distance talkRangeArea where (each.talking=false);
				
		if(length(ChillGuysNotBusy)>0)
		{
			ChillPerson talkTo <- one_of(ChillGuysNotBusy);
			
			ask talkTo {
				self.talking<-true;
				myself.talking<-true;				
										
				string localAsk <- myself.isBad ? myself.askChillGuy1[1] : myself.askChillGuy1[0];

				write myself.name+" says" + localAsk;
				
				
				if(myself.isBad)
				{
					
						if(self.willingToFight>50)
						{
							write self.name+" says"+self.answerChillGuy1[1];
							
							if(myself.fightingSkills>self.fightingSkills)
							{
								//badguy wins
								write myself.name+" wins the fight";
								myself.fightingSkills<-myself.fightingSkills+5;
								myself.happy<-myself.happy+5;
								self.happy<-self.happy-5;
								
							}
							else{
								write self.name+" wins the fight";
								self.fightingSkills<-myself.fightingSkills+5;
								self.happy<-self.happy+5;
								myself.happy<-myself.happy-5;
							}
							
							
						}
						else{
							write self.name+" says"+self.answerChillGuy1[2];
							write myself.name+" says"+myself.askChillGuy1[2];							
						}
					
					//random so differente behaviour next time
					self.willingToFight<-rnd(1,100);
					myself.willingToFight<-rnd(1,100);
		
				}
				
				/* NOT BAD */
				else
				{
					if(self.willingToDance>willingToDanceMetric)
					{
					write self.name+" says"+answerChillGuy1[0] ;
					self.happy<-self.happy+5;
					myself.happy<-myself.happy+5;
					}

				}
					
				//MAKE DIFFERENT DELAYS SO THEY DON'T START TALKING
				self.delayOK<-false;		
				self.startDelay<-time;
				self.localDelayTime<-globalDelayTime+30;
					
				myself.delayOK<-false;		
				myself.startDelay<-time;
				myself.localDelayTime<-globalDelayTime;
				
				
			}
		}
				
	} 
	
		
    reflex beIdle when: !(busy) and !talking {
		do wander;
		}
		
	reflex moveToTarget when: targetPoint != nil and !talking
	{
		do goto target:targetPoint;
	}
	
	
	aspect base {
		draw circle(1) color: #green depth:1;
			
		
	}
	
}

species MetalHead skills: [fipa,moving] {
	
	//random value of half of the first initiatior.
	bool busy <- false;
	point initPoint <- {(rnd(0,100)),(rnd(0,100)),0};
	point targetPoint <- nil;
	bool talking <- false;
	bool isRobbed <- false;
	int willingToGetDrunk <-rnd(1,100);
	
	int localDelayTime;
	bool delayOK<-true;
	int startDelay;
	bool phone_call<-false;
	bool wait_for_phone_answer <-false;
	
		reflex countDelay when: !delayOK 
	{
		if((time-startDelay)>globalDelayTime)
		{
			delayOK<-true;
			talking<-false;
		}
			
	}
	
	
	 reflex take_pic when: !empty(informs){
	 message informFromInitiator <- informs[0];
	  message proposalFromInitiator <-list(informFromInitiator.contents)[3];
	   string photo <- list(informFromInitiator.contents)[0];
	   string collectphoto <- list(informFromInitiator.contents)[1];
	   string takingphoto <-list(informFromInitiator.contents)[2];
	   int isGoodPhotograph<- int(list(informFromInitiator.contents)[3]);
	   
	   int takepic <- rnd(40,60);
	   
	   if(takepic<=50 and isGoodPhotograph>25){
	   	 write photo;
	   	 write "Sure why not!!";
	   	 write takingphoto;
	   	 write collectphoto;
	   	 targetPoint <- any_location_in(one_of(Studio)); 
	   }
	   else{
	   	do refuse with: [ message :: informFromInitiator, contents :: ["No thanks"] ];
	   }	
	}
	
	reflex photo_area when: !empty(Studio at_distance 1){
	 	ask Studio{
	 		write "There you go! Here are Your Photos";
	 	}
	 }
			reflex arrivedAtDestination when: busy{
				if(targetPoint!=nil)
				{
			if(distance_to(self,targetPoint)<1){
			
			write self.name + "At destination";
			self.targetPoint <- nil;
			self.busy<-false;			
			}
			
			}
		}
	
	
	/* TRAITS */
	int generous<-rnd(1,100);

	
	string askPub1<-"Do you want a drink?";
	string askStage1<-"Do you want to dance?";
	string askOutside1<-"Where are you going?";
	
	list<string> askThief <- ["Why are you so close what do you want ","Just leave me alone"];
	
	list<string> askPolice <- ["Catch the thiefs, they are everywhere?","Hello Police"];
	
	list<string> askJournalist1 <- ["You should take a Photo of me!","I hate Photographers"];
	
	list<string> answerPolice <- ["Because I am too drunk sorry","I love the music"];
	
	
	
	
	/* ATTRIBUTES */
	int drunk<-0 max:100;
	int happy<-0 max:100;
	int money<-rnd(50,100);
	int savings <- money;
	bool robbed <- false;
	int diff <-0;
	
	reflex initiateTalkJournalist when: !empty(Photographer at_distance talkRangeArea) and !talking {
		list PhotographerNotBusy <- Photographer at_distance talkRangeArea;
				
		if(length(PhotographerNotBusy)>0)
		{
			Photographer talkTo <- one_of(PhotographerNotBusy);
			
			ask talkTo {
				myself.talking<-true;				
							
				if(myself.generous>50)
				{
				write myself.name+" says "+myself.askJournalist1[0];
				if(self.gotGoodSkills)
				{
					write self.name+" says "+self.answerRockfan1[0];
				}
				else{
					write self.name+" says "+self.answerRockfan1[1];
				}
				}			
				else{
				write myself.name+"says"+myself.askJournalist1[1];
				}
			
				myself.talking<-false;
							
				
			}
		}
				
	} 
	
		reflex initiateTalkPolice when: !empty(Police at_distance talkRangeArea) and !talking{
		list PolicesNotBusy <- Police at_distance talkRangeArea;
				
		if(length(PolicesNotBusy)>0)
		{
			Police talkTo <- one_of(PolicesNotBusy);
			
			ask talkTo {
				myself.talking<-true;				
							
				if(myself.generous>50)
				{
				write myself.name+" says "+myself.askPolice[0];
				if(self.catchThiefSuccessfullyFlag)
				{
					write self.name+" says "+self.answerRockfan1[0];
				}
				else{
					write self.name+" says "+self.answerRockfan1[1];
				}
				}			
				else{
				write myself.name+"says"+myself.askPolice[1];
				}
			
				myself.talking<-false;
							
				
			}
		}
				
	} 
	
		reflex initiateTalkThief when: !empty(Thief at_distance talkRangeArea) and !talking {
		list ThiefsNotBusy <- Thief at_distance talkRangeArea;
				
		if(length(ThiefsNotBusy)>0)
		{
			Thief talkTo <- one_of(ThiefsNotBusy);
			
			ask talkTo {
				myself.talking<-true;				
							
				if(myself.generous>50)
				{
				write myself.name+" says "+myself.askThief[0];
				if(self.willEventuallySucceedRobbing)
				{
					write self.name+" says "+self.answerRockfan1[0];
				}
				else{
					write self.name+" says "+self.answerRockfan1[1];
				}
				}			
				else{
				write myself.name+"says"+myself.askThief[1];
				}
			
				
				
				//MAKE DIFFERENT DELAYS SO THEY DON't START TALKING
				myself.talking<-false;
							
				
			}
		}
				
	} 

	   reflex goto_police_station when: savings != money{
	    	isRobbed <- true;
	    	targetPoint <- any_location_in(one_of(PoliceStation));
	    	diff <- savings- money;
	    	
	    	
	    	ask PoliceStation at_distance 1{
	    		self.money <- self.money-myself.diff;
	    		myself.money <- myself.savings;
	    		myself.isRobbed <- false;
	    	}
	  	
	    }
	    
	reflex receivePhoneCall when: !empty(cfps){
		talking<-true;
		busy <-true;
		
		message phoneCall <- cfps[0];
		agent caller <- agent(phoneCall.sender);
		
		string query <- list(phoneCall.contents)[0];
		
		if(query="PhonecallTo")
		{
			string proposal <- list(phoneCall.contents)[1];
			point toGo <-list(phoneCall.contents)[2];
			string answer;
			
			write name+" receives phone call from:"+agent(phoneCall.sender).name+": "+proposal;
			bool answerYesorNo <- flip(0.5);
			if(answerYesorNo)
			{
			answer<-"Yes, I would love to meet you. I'm going";	
			targetPoint<-toGo;
			talking <- false;
			}
			else{
			answer<-"No I do not want to meet you. Go alone";	
			talking<-false;
			busy <-false;			
			}
			
			do start_conversation with: [ to :: list(agent(phoneCall.sender)), protocol :: 'fipa-contract-net', performative :: 'accept_proposal', contents :: ["PhoneAnswer",answer,toGo] ];
			
						
		}
		
	}
	
	reflex startPhoneCall when: phone_call{
		phone_call<-false;
		list RockFansNotBusy <- MetalHead where (each.talking=false and each.busy=false);
		
		if(length(RockFansNotBusy)>0)
		{
		
		point suggestPoint;
		bool goToPuborStage <- flip(0.5);
		string whereTogo;
		if(goToPuborStage)
		{
		suggestPoint<- any_location_in(one_of(Stage));
		whereTogo<-"Stage";	
		}
		else{
		suggestPoint<- any_location_in(one_of(Pub));	
		whereTogo<-"Pub";	
		}
		
		do start_conversation with: [ to :: list(one_of(RockFansNotBusy)), protocol :: 'fipa-contract-net', performative :: 'cfp', contents :: ["PhonecallTo","Would you meet me at"+whereTogo,suggestPoint] ];
		wait_for_phone_answer<-true;
		}
		else{
			if(self. willingToGetDrunk >70){
				write name+": no one to call... will probably get drunk ,huh";
				 busy<-true;
				 targetPoint<- any_location_in(one_of(Pub));
				 drunk<-drunk +1;
			}else{
				write "no one to call and not even feeling like drinking , should probably nuk this festival";
			}
			
				
		}
		
	}
	
	reflex waitForAnswer when: !empty(accept_proposals) and wait_for_phone_answer {
		
	wait_for_phone_answer<-false;		
	
	message a <- accept_proposals[0];
	write name + ' receives a answer from ' + agent(a.sender).name + ' with content ' + list(a.contents)[1];
	string answer1 <- list(a.contents)[1];

	point toGoresponse <- list(a.contents)[2];
	
	
	
	if(answer1 contains "Yes" )
	{
		happy<-happy+1;
	}
	else{
		happy<-happy-1;		
	}
	
	write name + "says ok bye, see you there";
	talking<-false;
	
	targetPoint <- toGoresponse;
	
	}
	
	
	reflex initiateTalk when: !empty(ChillPerson at_distance talkRangeArea) and !talking {
	list ChillGuysNotBusy <- ChillPerson at_distance talkRangeArea where (each.talking=false);
				
		if(length(ChillGuysNotBusy)>0)
		{
			ChillPerson talkTo <- one_of(ChillGuysNotBusy);
			
			ask talkTo {
				self.talking<-true;
				myself.talking<-true;				
				bool inPub<-false;
				bool inStage <- false;
				bool inOutside <- false;
				
				if (distance_to(myself,one_of(Pub))<8)
				{
					inPub<-true;
				}
												
				if (distance_to(myself,one_of(Stage))<8)
				{
					inStage<-true;
				}
				
				if(!inStage and !inPub)
				{
					inOutside<-true;
				}
						
				write myself.name+" says hello.";
				write self.name+" says hello back";
				string localAsk <- inStage ? myself.askStage1 : (inPub ? myself.askPub1 : myself.askOutside1);
				
				write myself.name+" says" + localAsk;
				
				/* PUB */
				if(inPub)
				{
					if(self.willingToAcceptDrink<willingToAcceptDrinkMetric)
					{
					self.happy<-self.happy-5;
					myself.happy<-myself.happy-5;
					self.drunk<-self.drunk-1;
					myself.drunk<-myself.drunk-1;
					}
					else{
					write self.name+" says"+answerPub1[1];
					self.happy<-self.happy+5;
					myself.happy<-myself.happy+5;
					self.drunk<-self.drunk+1;
					myself.drunk<-myself.drunk+1;
					}
				}
				
				/* STAGE */
				if(inStage)
				{
					if(self.willingToDance<willingToDanceMetric)
					{
					write self.name+" says"+answerStage1[0] ;
					self.happy<-self.happy-1;
					myself.happy<-myself.happy-1;
					}
					else{
					write self.name+" says"+answerStage1[1];
					self.happy<-self.happy+5;
					myself.happy<-myself.happy+5;
					}
				}

				/* OUTSIDE */
				if(inOutside)
				{
				write self.answerOutside1;
				}
				
				self.delayOK<-false;		
				self.startDelay<-time;
				self.localDelayTime<-globalDelayTime+30;
				
				myself.delayOK<-false;		
				myself.startDelay<-time;
				myself.localDelayTime<-globalDelayTime;
				
				
			}
		}
				
	} 
	
	reflex decideWhatToDo when: !talking{
			
		//decide where to go or not go somewhere
		if(!busy)
		{
			int whereToGo <- rnd(0,20);
			
			if(whereToGo=0)
			{
				//Stage
				write name+"goes to stage";
				busy<-true;
				targetPoint<- any_location_in(one_of(Stage));	
				targetPoint <- {(targetPoint.x-rnd(-circleDistance/2,circleDistance/2)),(targetPoint.y-rnd(-circleDistance/2,circleDistance/2)),targetPoint.z };
			}
			
			if(whereToGo=2)
			{
				//Pub
				write name+"goes to pub";
				busy<-true;
				targetPoint<- any_location_in(one_of(Pub));
				targetPoint <- {(targetPoint.x-rnd(-circleDistance/2,circleDistance/2)),(targetPoint.y-rnd(-circleDistance/2,circleDistance/2)),targetPoint.z };
					
			}
			
			if(whereToGo=3)
			{
				//StartPhoneCall
				write name+"Tries to call another Rockfan";
				busy<-true;
				phone_call<-true;
				talking<-true;
			}
						
			
		}

	}
	
		
    reflex beIdle when: !(busy) and !talking {
		do wander;
		}
		
	reflex moveToTarget when: targetPoint != nil and !talking
	{
		
		do goto target:targetPoint;
		
	}
	
	aspect base {
		draw circle(1) color: #black depth:1;
			
		
	}
	
}

experiment run_festival type: gui {
	output {

		   
		  
		display my_display type:opengl {
			species Stage aspect:base;
			
			species ChillPerson aspect:base;	
			species MetalHead aspect:base;	
			species Thief aspect:base;	
			species Police aspect:base;	
			species Photographer aspect:base;	
			species Gamer aspect:base;
			
			
			species Pub aspect:base;
			species ShadyPlace aspect:base;
			species PoliceStation aspect:base;
			species Studio aspect:base;
			species GamingArea aspect:base;
			
			
			}
			
			    display chart refresh: every(10 #cycles) {
        chart "Happiness" type: series style: spline {
        data "Happy value" value: globalHappinessValue color: #green marker: false;
        data "Drunk valuen" value: globalDrunkValue color: #red marker: false;   
        }       
        }

  	
	}
}