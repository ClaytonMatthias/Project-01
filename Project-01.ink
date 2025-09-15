/*
    Project 01
    
    Requirements (for 15 base points)
    - Create an interactive fiction story with at least 8 knots 
    - Create at least one major choice that the player can make
    - Reflect that choice back to the player
    - Include at least one loop
    
    To get a full 20 points, expand upon the game in the following ways
    [+2] Include more than eight passages
    [+1] Allow the player to pick up items and change the state of the game if certain items are in the inventory. Acknowledge if a player does or does not have a certain item
    [+1] Give the player statistics, and allow them to upgrade once or twice. Gate certain options based on statistics (high or low. Maybe a weak person can only do things a strong person can't, and vice versa)
    [+1] Keep track of visited passages and only display the description when visiting for the first time (or requested)
    
    Make sure to list the items you changed for points in the Readme.md. I cannot guess your intentions!

*/
VAR strength = 0
VAR items_inventory = 0
VAR fall_count = 0
VAR blacksmith_count = 0

-> Start

== Start ==
{Start > 1: Would you like to start your adventure or grow stronger? | Villager: Hello Adventurer! Welcome to our humble village! We've heard the tales of your legendary actions. We desperately need your help as there is a mysterious monster that has been attacking our village. Will you help us stop this monster now or do you need time to grow stronger?} 

+ [Start Adventure] -> beginning
+ {strength < 3} [Grow Stronger] -> stronger

== stronger ==
You hit an amazing workout and are now quite stronger.
    ~ strength += 1
{strength > 0: Your current strength is: {strength}}
    {
        - beginning == 0:
            -> Start
        - beginning > 0:
            -> beginning
    }

== beginning ==
{
    - (not grab_head) && (east.easy_cavern or night_village.kill or night_village.defend):
        * [Recieve your praise] -> loser
    - not grab_head:
        {beginning > 1:What else would you like to do before night? |Villager: We have been experiencing many odd occurences which can only be explained by a mysterious creature. We believe this creature only comes out at night. I suggest you wait until night to search for clues.}
        {
            -strength < 3:
                +  [Grow Stronger] -> stronger
            -(strength < 5 && (blacksmith.sword or blacksmith.armor)):
                +  [Grow Stronger] -> stronger
        }
        + [Explore the Village] -> village
        + [Visit the blacksmith] -> blacksmith
        * [Wait until Dark] -> night_village
    - grab_head:
        * [Recieve your praise] -> winner
        
}
== blacksmith ==
{blacksmith_count > 0: You are at the blacksmith. |You arrive at the blacksmith. Blacksmith Villager: Hello Adventurer! I will let you use any of my tools to create whatever you may need to stop this dreadful creature.}
~ blacksmith_count += 1
{
    -sword:
    You have already made a sword.
    -(west.junk && east.attacked_house) && strength >= 2:
        + [Make a Sword] -> sword
    -not ((west.junk && east.attacked_house) && strength >= 2):
        + [Make a Sword] -> not_sword

}
{
    -armor:
    You have already made armor.
    -(west.broken_house && west.junk && east.hole) && strength >= 3:
        + [Make Armor] -> armor
    -not ((west.broken_house && west.junk && east.hole) && strength >= 3):
        + [Make Armor] -> not_armor
}
+ [Go back] -> beginning

= sword
You create a legendary sword that will surely destroy whatever that creature may be.
-> blacksmith

= armor
You create strong armor that will protect you from any danger
-> blacksmith

= not_sword 
You do not have the resources to make a sword. 
You need:
{not west.junk: Two Pieces of metal}
{not east.attacked_house: One Scale}
{not (strength >= 2): Strength level of 2 or higher}
+ [Go Back]-> blacksmith

= not_armor 
You do not have the resources to make armor. 
You need:
{not west.broken_house: A broken set of Armor}
{not west.junk: One Piece of metal}
{not east.hole: One Gem}
{not (strength >= 3): Strength level of 3 or higher}
+ [Go Back]-> blacksmith

== village ==
What are part of the village would you like to explore? 
+ [West Side] -> west
+ [East Side] -> east
+ [Go back] -> beginning

== west ==
The west side of the village has a pile of junk and a broken down house.
* [Explore the broken down house] -> broken_house
* [Dig through the junk] -> junk
+[Go Back] -> village

= broken_house
You look through the house and only find a very broken set of armor.
~ items_inventory += 1
+ [Go back] -> west

= junk
You dig through the pile of junk and find three pieces of bent metal.
~ items_inventory += 3
* [Go Back] -> west

== east ==
The east side of the village has a house that the creature attacked. There is also a large hole nearby.
* [Explore attacked house] -> attacked_house
+ [Inspect hole] -> hole
+ [Go back] -> village

= attacked_house
You explore the attacked house and find some sort of scale that must have been left by the mysterious creature.
~ items_inventory += 1
* [Go Back] -> east

= hole
{
    -hole < 2:
        You inspect the hole and find an odd rock nearby. Upon closer inspection you realize that it is a gem.
        ~ items_inventory += 1
}
+ {fall == 0} [Look down into the hole] -> lean1
+ [Go Back] -> east

= lean1
You lean over the edge to get a better look down into the hole. It is hard to see into the hole.
+ [Lean over the edge more] -> lean2
+ [Go Back] -> east

= lean2
You lean over the edge even more to the point you are on your toes, but still can not see anything else
+ [Lean over the edge more] -> fall
+ [Go Back] -> east

= fall
{fall_count > 0: and down | You lean over and begin to fall down}
{
    -fall_count > 20:
        -> pit_of_sorrow
    -fall_count < 21:
        ~ fall_count += 1
        -> fall
}



= pit_of_sorrow
thud
You find yourself laying on the floor of a large cavern. You look up to see the mysterious creature that has been haunting the village. It appears to be a giant lizard or maybe some sort of dinosaur? It matters very little because before you can react it is charging towards you. 
{
    -(blacksmith.sword && blacksmith.armor) and (strength >= 5):
        -> defend
    -(blacksmith.sword && blacksmith.armor) and not (strength >= 5):
        You have both your new sword and new armor at the ready. The beast runs directly into you and sends you flying. Clearly you are not as strong as you thought. 
        -> Cavern_fight
    -(blacksmith.sword or blacksmith.armor) and (strength >= 5):
        You have very little to defend yourself. While you are very strong without both a sword and armor there is nothing you can do to prevent the beast's attacks. You last very little time against the strong beast before you can fight no longer.
    -(blacksmith.sword or blacksmith.armor) and not (strength >= 5):
        You have very little to defend yourself and your are just too weak to defend yourself. You last very little time against the strong beast before you can fight no longer.
    -(not blacksmith.armor or not blacksmith.sword):
        With nothing to defend yourself there is nothing you can do to stop the beast from tearing you to shreads.



}
The village will not be safe tonight...
-> END

= defend
Because of your high strength and good defense you are able to react quickly to the beast.
*[Fight the beast] -> easy_cavern
*[Spare the beast] -> beast_escape
= easy_cavern
You have both your new sword and new armor at the ready. The beast runs directly into you but bounces off your impecable body and goes flying. You run after the beast and swiftly dislodge its head from the rest of its body with your amazing sword and unparalleled strength before it can get it up. 
*[Grab the beast's head] -> grab_head
+[Find a way back to the surface] -> surface_exit

= Cavern_fight
You are able to recover from the beast's hit and prepare to hit back.
*[Swing at the beast's feet] -> win_cavern
*[Swing at the beast's head] -> lose_cavern

= win_cavern
The beast is not quick enough to avoid your attack and its swept off its feet by the attack. Quickly, it gets to its feet and <>
-> beast_escape

= lose_cavern
The beast ducks your attack and sinks its dagger like teeth into your flabby stomach. Since you are so weak you die on the spot.
The village will not be safe tonight...
-> END

= beast_escape
{defend:You lower your new sword. The beast runs directly into you but bounces off your impecable body and goes flying. It quickly recovers before running off deeper into the cavern.|runs off deeper into the cavern.} 
+[Find a way back to the surface] -> surface_exit

= surface_exit
You see a dim light in the corner of the cavern and are able to follow it back to the surface. It leads you back to the center of the village.
-> beginning

== grab_head ==
You grab the beast's head as proof of your victory.
~ items_inventory += 1
{
    -east.win_cavern or east.easy_cavern:
        +[Find a way back to the surface] -> east.surface_exit
    -night_village.defend or night_village.kill:
        +[Return Victorous] -> beginning
}



== night_village ==
{
    -night_village == 1:
        Night has now set on the village. The beast is still at large {east.beast_escape:, no thanks to you}. Its time to finally put an end to this mess. Where should you start looking for the monster?
        + [East side of the village] -> night_east
        + [West side of the village] -> night_west
    -night_village > 1:
        As you get back to the center of the village you see the beast in the light of a latern. <>
        -> battle_experience
}

= battle_experience
The beast sees you approach and turns ready to fight you. <>
{
    - east.fall:
        -> experience_battle
    - not east.fall:
        -> inexperience_battle
}

= inexperience_battle
It appears to be a giant lizard or maybe some sort of dinosaur? It matters very little because before you can react it is charging towards you. 
{
    -(blacksmith.sword && blacksmith.armor) and (strength >= 5):
        -> defend
    -(blacksmith.sword && blacksmith.armor) and not (strength >= 5):
        You have both your new sword and new armor at the ready. The beast runs directly into you and sends you flying. Clearly you are not as strong as you thought. 
        -> fight
    -(blacksmith.sword or blacksmith.armor) and (strength >= 5):
        You have very little to defend yourself. While you are very strong without both a sword and armor there is nothing you can do to prevent the beast's attacks. You last very little time against the strong beast before you can fight no longer.
    -(blacksmith.sword or blacksmith.armor) and not (strength >= 5):
        You have very little to defend yourself and your are just too weak to defend yourself. You last very little time against the strong beast before you can fight no longer.
    -(not blacksmith.armor or not blacksmith.sword):
        With nothing to defend yourself there is nothing you can do to stop the beast from tearing you to shreads.
}
The village will not be safe tonight...
-> END

= experience_battle
The beast looks larger than the last time you saw it which must mean it has fed since then.
{
    -(blacksmith.sword && blacksmith.armor) and (strength >= 5):

        -> defend
    -(blacksmith.sword && blacksmith.armor) and not (strength >= 5):
        You have both your new sword and new armor at the ready. The beast runs directly into you and sends you flying. Clearly you are not as strong as you thought. 
        -> fight
}
The village will not be safe tonight...
-> END

= defend
You have both your new sword and new armor at the ready. The beast runs directly into you but bounces off your impecable body and goes flying. You run after the beast and swiftly dislodge its head from the rest of its body with your amazing sword and unparalleled strength before it can get it up. 
*[Grab the beast's head] -> grab_head
+[Return victorous] -> beginning

= fight
You are able to recover from the beast's hit and prepare to hit back.
*[Swing at the beast's feet] -> win_first
*[Swing at the beast's head] -> lose_first

= win_first
The beast is not quick enough to avoid your attack and its swept off its feet by the attack. Quickly, it gets to its feet and prepares for its next attack. 
*[Dodge Left] -> Left
*[Dodge Right] -> Right


= lose_first
The beast ducks your attack and sinks its dagger like teeth into your flabby stomach. Since you are so weak you die on the spot.
The village will not be safe tonight...
-> END

= Right
You try rolling right but end up rolling into a latern post. The Beast tackles you to the ground and proceeds to tear you apart. 
The village will not be safe tonight...
-> END

= Left
You roll left and narrowly avoid the beast's attack. It is sent tumbling and is temporarily dazed.
*[Kill the beast] -> kill

= kill
You kill the beast by stabbing its chest and cutting off its head.
*[Grab the beast's head] -> grab_head
+[Return victorous] -> beginning


== night_west ==
The west side of the village is very dark but you can make out the broken down house in the moonlight.
* [Explore the broken down house] -> broken_house
+ [Go Back] -> night_village

= broken_house
You enter the broken house{west.broken_house: and notice that everything appears the same as earlier today}. Something catches your attention out of the corner of your eye. There is a hole in the corner of the room{west.broken_house: that was not there earlier}. 
* [Investigate the hole] -> night_hole

= night_hole
{east.hole: This new hole looks similar to the one near the eastern attacked house.|The hole must have been made by the beast.} The beast must be nearby, maybe near the village center?
+ [Hurry back to the center of the village] -> night_village

== night_east ==
The east side of the village is very dark. You can just make out the attacked house in the dark.
* [Explore attacked house] -> attacked_house
+ [Go back] -> night_village

= attacked_house
As you approach the house you see something coming around the opposite side of the house. You quickly duck into a nearby bush just in time to see the beast come around the corner. It must have been looking for survivors from its last attack. 
It then starts to head towards the center of the village.
+ [Hurry back to the center of the village] -> night_village

== winner ==
You return to the village and show the villagers the beast's decapitated head as proof of your glorious victory. The villagers start celebrating and you are hailed as a hero across the entire land.
-> END

== loser ==
You return to the village expecting praise but when they ask for proof of the beast's death you have nothing to show. They declare you a liar and coward and banish you from the village. Word spreads and you become know as just that, a liar and coward, until the end of your days.
-> END

