if not myHero.ChampName == "Soraka" then
	PrintChat(myHero.ChampName.. " is not supported by [SoF] Soraka!")
	return
end

require("Inspired")

AutoUpdate("/SenusGOS/GOS/master/SoFSoraka.lua","/SenusGOS/GOS/master/SoFSoraka_version","SoF Soraka.lua",1.0)

require("OpenPredict")
LoadIOW()

class "Soraka"
function Soraka:__init()
	menu = MenuConfig("[SoF] Soraka", "SOF-Soraka")
	
	--> Combo
	menu:Menu("combo", "Combo")
	menu.combo:Boolean("Q", "Use Q", true)
	menu.combo:Boolean("E", "Use E", true)
	
	--> Auto W
	menu:Menu("autow", "Auto W")
	menu.autow:Boolean("enabled", "Enabled", true)
	menu.autow:DropDown("mode", "Mode", 1, {"Lowest %AllyHP", "Closest Ally"})
	menu.autow:Slider("minhp", "Ally %HP <", 70, 50, 100, 5)
	menu.autow:Slider("myhp", "My %HP >", 20, 5, 100, 5)
	menu.autow:Slider("enemy", "Enemies around >", 1, 0, 5, 1)
	
	--> Auto R
	menu:Menu("autor", "Auto R")
	menu.autor:Boolean("enabled", "Enabled", true)
	menu.autor:DropDown("mode", "Mode", 3, {"Save Allies", "Save Yourself", "Both"})
	menu.autor:Slider("minhp", "Ally/My %HP <", 10, 5, 50, 5)
	menu.autor:Slider("enemy", "Enemies around >", 1, 1, 5, 1)
	
	--> Gapcloser E
	menu:Menu("egap", "E-Gapclose")
	AddGapcloseEvent(_E, 900, false, menu.egap)
	
	OnTick(function() self:Tick() end)
end

function Soraka:Tick()
	if not IsDead(myHero) then
		local target = GetCurrentTarget()
		if IOW:Mode() == "Combo" then
			if menu.combo.Q:Value() then
				local predict = GetCircularAOEPrediction(target, {delay = 0.250, speed = 1000, width = 260, range = 900})
				if IsReady(_Q) and ValidTarget(target, GetCastRange(myHero, _Q)) and predict and predict.hitChance >= 0.5 then
					CastSkillShot(_Q, predict.castPos)
				end
			end
			if menu.combo.E:Value() then
				local predict = GetCircularAOEPrediction(target, {delay = 1.75, speed = math.huge, width = 310, range = 900})
				if IsReady(_Q) and ValidTarget(target, GetCastRange(myHero, _Q)) and predict and predict.hitChance >= 0.5 then
					CastSkillShot(_E, predict.castPos)
				end
			end
		end
		if menu.autow.enabled:Value() and IsReady(_W) and GetPercentHP(myHero) >= menu.autow.myhp:Value() then
			self:AutoW()
		end
		if menu.autor.enabled:Value() and IsReady(_R) then
			self:AutoR()
		end
	end
end

function Soraka:AutoW()
	if menu.autow.mode:Value() == 1 then
		local target, last = nil, 100
		for n,ally in pairs(GetAllyHeroes()) do
			if GetPercentHP(ally) <= menu.autow.minhp:Value()
				and EnemiesAround(GetOrigin(ally), 1000) >= menu.autow.enemy:Value()
				and GetDistance(myHero,ally) < GetCastRange(myHero,_W) then
				if GetPercentHP(ally) < last then
					last = GetPercentHP(ally)
					target = ally
				end
			end
		end
		if target then CastTargetSpell(target, _W) end
	elseif menu.autow.mode:Value() == 2 then
		local target, dist = nil, GetCastRange(_W)
		for n,ally in pairs(GetAllyHeroes()) do
			if GetPercentHP(ally) <= menu.autow.minhp:Value()
				and EnemiesAround(GetOrigin(ally), 1000) >= menu.autow.enemy:Value()
				and GetDistance(myHero,ally) < GetCastRange(myHero,_W) then
				if GetDistance(myHero,ally) < dist then
					dist = GetDistance(myHero,ally)
					target = ally
				end
			end
		end
		if target then CastTargetSpell(target, _W) end
	end
end

function Soraka:AutoR()
	if menu.autor.mode:Value() == 1 then
		for n,ally in pairs(GetAllyHeroes()) do
			if GetPercentHP(ally) <= menu.autor.minhp:Value()
				and EnemiesAround(GetOrigin(ally), 1000) >= menu.autor.enemy:Value() then
				CastSpell(_R)
				break
			end
		end
	elseif menu.autor.mode:Value() == 2 then
		if GetPercentHP(myHero) <= menu.autor.minhp:Value()
			and EnemiesAround(GetOrigin(myHero), 1000) >= menu.autor.enemy:Value() then
			CastSpell(_R)
		end
	elseif menu.autor.mode:Value() == 3 then
		for n,ally in pairs(GetAllyHeroes()) do
			if GetPercentHP(ally) <= menu.autor.minhp:Value()
				and EnemiesAround(GetOrigin(ally), 1000) >= menu.autor.enemy:Value() then
				CastSpell(_R)
				return
			end
		end
		if GetPercentHP(myHero) <= menu.autor.minhp:Value()
			and EnemiesAround(GetOrigin(myHero), 1000) >= menu.autor.enemy:Value() then
			CastSpell(_R)
		end
	end
end

PrintChat("[SoF] Soraka has been loaded.")
