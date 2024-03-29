function:[[
      if not x then
              x = 0
      end
      x = x + 1
      return true
]]

say:!bless

function:[[
      if x < 5 then
            gotoLabel("up")
      end
      return true
]]

goto:1606,531,8
goto:1606,531,8
goto:1175,156,6
goto:1164,158,6
goto:1151,158,6
goto:1152,160,6

function:[[
      -- vender todos os items
      local npc = getCreatureByName("Item Buyer")
      if not npc then 
        return false 
      end

      if retries > 10 then
        return false
      end

      local pos = player:getPosition()
      local npcPos = npc:getPosition()

      if math.max(math.abs(pos.x - npcPos.x), math.abs(pos.y - npcPos.y)) > 3 then
        autoWalk(npcPos, {precision=3})
        delay(300)
        return "retry"
      end

      if not NPC.isTrading() then
        NPC.say("hi")
        NPC.say("trade")
        delay(200)
        return "retry"
      end

      NPC.sellAll()
      schedule(1000, function()
        NPC.sellAll()
        NPC.closeTrade()
        NPC.say("bye")
      end)

      delay(1200)
      return true
]]

goto:1152,160,6
goto:1160,158,6
goto:1171,156,6
goto:1176,155,6
goto:1176,153,6
goto:1176,153,6
goto:1512,573,7
goto:1512,574,7
goto:1512,574,7

function:[[
      if x > 5 then
            x = 0
      end
      return true
]]

label:up
goto:1610,532,8
goto:1616,529,8
goto:1622,529,8
goto:1628,532,8
goto:1628,538,8
goto:1628,532,8
goto:1634,533,8
goto:1640,533,8
goto:1646,533,8
goto:1649,527,8
goto:1655,525,8
goto:1657,519,8
goto:1657,513,8
goto:1657,507,8
goto:1663,508,8
goto:1669,508,8
goto:1674,502,8
goto:1680,497,8
goto:1686,499,8
goto:1687,505,8
goto:1687,511,8
goto:1681,515,8
goto:1675,511,8
goto:1669,509,8
goto:1663,509,8
goto:1658,515,8
goto:1658,521,8
goto:1664,525,8
goto:1666,531,8
goto:1666,537,8
goto:1660,541,8
goto:1657,547,8
goto:1657,553,8
goto:1657,559,8
goto:1663,559,8
goto:1669,559,8
goto:1675,559,8
goto:1675,553,8
goto:1681,552,8
goto:1684,558,8
goto:1684,564,8
goto:1678,566,8
goto:1678,560,8
goto:1672,560,8
goto:1666,560,8
goto:1660,560,8
goto:1658,554,8
goto:1658,548,8
goto:1658,542,8
goto:1652,542,8
goto:1650,536,8
goto:1650,530,8
goto:1644,532,8
goto:1638,532,8
goto:1632,532,8
goto:1626,532,8
goto:1624,538,8
goto:1618,541,8
goto:1612,541,8
goto:1612,535,8
goto:1612,529,8
goto:1612,535,8
goto:1612,541,8
goto:1618,541,8
goto:1619,547,8
goto:1619,553,8
goto:1619,559,8
goto:1613,563,8
goto:1610,569,8
goto:1610,575,8
goto:1616,578,8
goto:1622,578,8
goto:1628,576,8
goto:1634,571,8
goto:1640,571,8
goto:1646,571,8
goto:1649,577,8
goto:1648,583,8
goto:1654,586,8
goto:1660,589,8
goto:1660,595,8
goto:1654,600,8
goto:1648,597,8
goto:1643,591,8
goto:1648,585,8
goto:1648,579,8
goto:1648,573,8
goto:1642,570,8
goto:1636,570,8
goto:1630,570,8
goto:1627,564,8
goto:1621,562,8
goto:1618,556,8
goto:1618,550,8
goto:1618,544,8
goto:1613,538,8
goto:1613,532,8
goto:1613,526,8
goto:1619,526,8
goto:1625,526,8
goto:1628,532,8
goto:1626,526,8
goto:1620,525,8
goto:1618,519,8
goto:1618,513,8
goto:1618,507,8
goto:1612,507,8
goto:1610,501,8
goto:1610,495,8
goto:1616,491,8
goto:1622,491,8
goto:1627,497,8
goto:1627,503,8
goto:1633,499,8
goto:1639,499,8
goto:1645,499,8
goto:1648,493,8
goto:1648,487,8
goto:1654,483,8
goto:1658,477,8
goto:1659,471,8
goto:1653,468,8
goto:1647,471,8
goto:1641,471,8
goto:1639,477,8
goto:1645,482,8
goto:1648,488,8
goto:1648,494,8
goto:1642,498,8
goto:1636,498,8
goto:1630,498,8
goto:1628,492,8
goto:1622,491,8
goto:1616,491,8
goto:1612,497,8
goto:1612,503,8
goto:1618,506,8
goto:1618,512,8
goto:1618,518,8
goto:1618,524,8
goto:1612,525,8
goto:1611,531,8
goto:976,250,7
goto:976,250,7
goto:1643,489,7

config:{"useDelay":400,"mapClickDelay":100,"walkDelay":10,"ping":100,"ignoreFields":true,"skipBlocked":true,"mapClick":true}
extensions:[[
      {"Depositer": [], "Supply": []}
]]
