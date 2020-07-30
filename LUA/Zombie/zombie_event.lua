<!-- <monster name="Zombie Event" file="zombie_event.xml" /> -->

<?xml version="1.0" encoding="ISO-8859-1"?>
<monster name="Zombie" nameDescription="a zombie" race="undead" experience="280" speed="300">
	<health now="1000000" max="1000000" />
	<look type="311" corpse="9875" />
	<targetchange interval="4000" chance="10" />
	<strategy attack="100" defense="0"/>
	<flags>
		<flag summonable="0" />
		<flag attackable="1" />
		<flag hostile="1" />
		<flag illusionable="0" />
		<flag convinceable="0" />
		<flag pushable="0" />
		<flag canpushitems="1" />
		<flag canpushcreatures="1" />
		<flag targetdistance="1" />
		<flag staticattack="90" />
		<flag runonhealth="0" />
		<flag canwalkonfire="1" />
	</flags>
	<attacks>
		<attack name="lifedrain" interval="1000" chance="100" radius="1" target="1" range="1" min="-1" max="-1">
			<attribute key="areaEffect" value="smallclouds" />
		</attack>
	</attacks>
	<defenses armor="20" defense="22">
		<defense name="healing" interval="10000" chance="100" min="1000000" max="1000000">
			<attribute key="areaEffect" value="blueshimmer"/>
		</defense>
	</defenses>
	<immunities>
		<immunity death="1" />
		<immunity energy="1" />
		<immunity ice="1" />
		<immunity earth="1" />
		<immunity drown="1" />
		<immunity drunk="1" />
		<immunity lifedrain="1" />
		<immunity paralyze="1" />
	</immunities>
	<voices interval="5000" chance="10">
		<voice sentence="Mst.... klll...." />
		<voice sentence="Whrrrr... ssss.... mmm.... grrrrl" />
		<voice sentence="Dnnnt... cmmm... clsrrr...." />
		<voice sentence="Httt.... hmnnsss..." />
	</voices>
</monster>
