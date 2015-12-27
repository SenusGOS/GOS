if GetObjectName(GetMyHero()) ~= "Alistar" then return end

require("Inspired")

AutoUpdate("/SenusGOS/GOS/master/SoFAlistar.lua","/SenusGOS/GOS/master/SoFAlistar_version","SoFAlistar.lua",1.0)

local QRange, WRange, ERange = GetCastRange(myHero, _Q), GetCastRange(myHero, _W), GetCastRange(myHero, _E)

local menu = MenuConfig("[SoF] Alistar","Alistar")

menu:Menu("Combo","Combo")
menu:Menu("AutoQ","Auto Q")
menu:Menu("AutoR","Auto R")
menu:Menu("Misc","Misc")
menu:Menu("Draw","Drawings")
menu:Menu("GapClose","Gap Closers")

menu.Combo:Boolean("Q","Use Q",true)
menu.Combo:Boolean("W","Use W",true)

menu.AutoQ:Boolean("Enabled","Enabled",true)

menu.AutoR:Boolean("Enabled","Enabled",true)
menu.AutoR:Slider("Health","Min % HP <",15,1,100)
menu.AutoR:Slider("Enemies","Enemies nearby >=",1,1,5)

menu.Misc:Boolean("Autolvl","Auto Level",true)
menu.Misc:DropDown("Priority","Priority",1,{"Q-W-E","W-Q-E"})

menu.Draw:Boolean("DrawQ","Draw Q Range",true)
menu.Draw:Boolean("DrawW","Draw W-Combo Range",true)
menu.Draw:Boolean("DrawE","Draw E Range",true)

local lvls = {
	{_Q, _W, _E, _Q, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _R, _E, _E},
	{_W, _Q, _E, _W, _W, _R, _W, _Q, _W, _Q, _R, _Q, _Q, _E, _E, _R, _E, _E}
}

local lastlvl = GetLevel(myHero)-1
OnTick(function()

	if menu.AutoR.Enabled:Value() and IsReady(_R) then
		if GetPercentHP(myHero) <= menu.AutoR.Health:Value()
			and EnemiesAround(GetOrigin(myHero), 900) >= menu.AutoR.Enemies:Value() then
			CastSpell(_R)
		end
	end

	if IOW:Mode() == "Combo" then
		local target = GetCurrentTarget()
		if ValidTarget(target, WRange-25) then
			if menu.Combo.W:Value() and IsReady(_W) then
				CastTargetSpell(target, _W)
			end
			if menu.Combo.Q:Value() and IsReady(_Q) then
				if GetDistance(target, myHero) <= QRange then
					CastSpell(_Q)
				end
			end
		end
	elseif menu.AutoQ.Enabled:Value() and IsReady(_Q) then
		local target = GetCurrentTarget()
		if ValidTarget(target, QRange) then
			CastSpell(_Q)
		end
	end

	if menu.Misc.Autolvl:Value() then
		if GetLevel(myHero) > lastlvl then
			LevelSpell(lvls[menu.Misc.Priority:Value()][GetLevel(myHero)])
			lastlvl = GetLevel(myHero)
		end
	end
end)

OnDraw(function()
	local myPos = GetOrigin(myHero)
	if menu.Draw.DrawQ:Value() then
		DrawCircle(myPos,365,1,25,GoS.Blue)
	end
	if menu.Draw.DrawW:Value() then
		DrawCircle(myPos,625,1,25,GoS.Pink)
	end
	if menu.Draw.DrawE:Value() then
		DrawCircle(myPos,575,1,25,GoS.Green)
	end
end)

AddGapcloseEvent(_Q, 365, false, menu.GapClose)
AddGapcloseEvent(_W, 650, true, menu.GapClose)

PrintChat("[Supp Or Feed] Alistar Loaded")
