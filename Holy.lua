local _, addonTable = ...;


if not MaxDps then
    return;
end

local Priest = addonTable.Priest;
local MaxDps = MaxDps;

local S = {
    Smite = 585,
    ShadowWordPain = 589,
    HolyFire = 14914,
    ShadowWordDeath = 32379,
    PowerInfusion = 10060,
    Sanctification = 34861,
    PriereDuDesespoir = 19236,
    SoinRapide = 2061,
    PriereDeGuerison = 33076,
    PriereDeGuerisonBuff = 41635,
    Renovation = 139,
    PriereDeSoins = 596,
    EspritGardien = 47788,
    Soin = 2060,
    Serenite = 2050,
    JaillitTenebreBuff = 390617,
    JaillitTenebre = 390615,
    HymneDivin = 64843,
    CercleDeSoin = 204883
};

local CN = {
    None      = 0,
    Kyrian    = 1,
    Venthyr   = 2,
    NightFae  = 3,
    Necrolord = 4
};

setmetatable(S, Priest.spellMeta);


function PartyMemberHaveBuff(buff)
    if (IsInGroup()) then
        for i = 1, 40 do
            if Buff(buff, "party" .. i) then
                return true
            end
        end
        return false
    else
        if Buff(buff, 'player') then
            return true
        end
        return false
    end
end

function AoeHeal(limit, number, spell)
    local aoe = 0
    if math.floor((UnitHealth("player") / UnitHealthMax("player")) * 100) <= limit then
        aoe = aoe + 1
    end
    for i = 1, 4 do
        local healthPercent = math.floor((UnitHealth("party" .. i) / UnitHealthMax("party" .. i)) * 100)
        if not UnitIsDead("party" .. i) then
            if UnitInRange("party" .. i) then
                if healthPercent <= limit then
                    aoe = aoe + 1
                end
            end
        end
    end
    if aoe >= number and IsSpellKnown(spell) then
        return true
    else
        return false
    end
end

function Buff(buff, unit)
    for i = 1, 40 do
        name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId,
            canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod =
        UnitBuff(unit, i)
        if spellId == buff then
            return true
        end
    end
    return false
end

function heal(unitHp, minHp, spell)
    return unitHp <= minHp and IsSpellKnown(spell)
end

function Priest:Holy()
    fd = MaxDps.FrameData;
    covenantId = fd.covenant.covenantId;
    targets = MaxDps:SmartAoe();
    cooldown = fd.cooldown;
    buff = fd.buff;
    debuff = fd.debuff;
    talents = fd.talents;
    targets = fd.targets;
    gcd = fd.gcd;
    targetHp = MaxDps:TargetPercentHealth() * 100;
    selfHealth = UnitHealth('player');
    selfHealthMax = UnitHealthMax('player');
    selfHealthPercent = (selfHealth / selfHealthMax) * 100;
    health = UnitHealth('target');
    healthMax = UnitHealthMax('target');
    healthPercent = (health / healthMax) * 100;
    MaxDps:GlowEssences();


    --[[ DEFENSIVE PRIEST  ]]
    if cooldown[S.PriereDuDesespoir].ready and heal(selfHealthMax, 25, S.PriereDuDesespoir) then
        return S.PriereDuDesespoir
    end

    --[[ handle AOE Healing ]]
    if AoeHeal(40, 4, S.HymneDivin) and cooldown[S.HymneDivin].ready then
        return S.HymneDivin
    end
    if AoeHeal(70, 4, S.Sanctification) and cooldown[S.Sanctification].ready then
        return S.Sanctification
    end
    if AoeHeal(75, 4, S.CercleDeSoin) and cooldown[S.CercleDeSoin].ready then
        return S.CercleDeSoin
    end
    if AoeHeal(80, 4, S.PriereDeSoins) then
        return S.PriereDeSoins
    end

    if UnitCanAttack('player', 'target') then
        if (not UnitIsDead('player')) then
            return Priest:selfHeal()
        end
    else
        if (not UnitIsDead('target') and UnitExists('target')) then
            return Priest:TargetHeal()
        end
    end

end

function Priest:TargetHeal()

    if heal(healthPercent, 15, S.EspritGardien) and cooldown[S.EspritGardien].ready then
        return S.EspritGardien;
    end
    if heal(healthPercent, 35, S.Serenite) and cooldown[S.Serenite].ready then
        return S.Serenite;
    end
    if heal(healthPercent, 50, S.SoinRapide) then
        return S.SoinRapide;
    end
    if heal(healthPercent, 75, S.SoinRapide) and talents[S.JaillitTenebre] and buff[S.JaillitTenebreBuff].count > 45 then
        return S.SoinRapide
    end
    if heal(healthPercent, 75, S.Soin) then
        return S.Soin;
    end
    if not Buff(S.Renovation, 'target') and heal(healthPercent, 90, S.Renovation) then
        return S.Renovation
    end
    if not PartyMemberHaveBuff(S.PriereDeGuerisonBuff) and heal(healthPercent, 99, S.PriereDeGuerison) and
        cooldown[S.PriereDeGuerison].ready then
        return S.PriereDeGuerison
    end
end

function Priest:selfHeal()

    if heal(selfHealthPercent, 15, S.EspritGardien) and cooldown[S.EspritGardien].ready then
        return S.EspritGardien;
    end

    if heal(selfHealthPercent, 35, S.Serenite) and cooldown[S.Serenite].ready then
        return S.Serenite;
    end
    if heal(selfHealthPercent, 50, S.SoinRapide) then
        return S.SoinRapide;
    end
    if heal(selfHealthPercent, 75, S.SoinRapide) and talents[S.JaillitTenebre] and buff[S.JaillitTenebreBuff].count > 45 then
        return S.SoinRapide
    end
    if heal(selfHealthPercent, 75, S.Soin) then
        return S.Soin;
    end
    if not Buff(S.Renovation, 'player') and heal(selfHealthPercent, 90, S.Renovation) then
        return S.Renovation
    end
    if not PartyMemberHaveBuff(S.PriereDeGuerisonBuff) and heal(selfHealthPercent, 99, S.PriereDeGuerison) and
        cooldown[S.PriereDeGuerison].ready then
        return S.PriereDeGuerison
    end
end
