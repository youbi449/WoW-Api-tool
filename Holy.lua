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
    PriereDuDesespoir = 19236,
    SoinRapide = 2061,
    PriereDeGuerison = 33076,
    PriereDeGuerisonBuff = 41635,
    Renovation = 139,
    Serenite = 2050,
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

function AoeHeal(limit, number)
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
    if aoe >= number then
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

function minHp(unitHp, minHp)
    return unitHp <= minHp
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




    if UnitIsEnemy('player', 'target') then
        if (not UnitIsDead('player')) then
            return Priest:selfHeal()
        end
    else
        if (not UnitIsDead('target') and UnitExists('target')) then
            return Priest:TargetHeal()
        end
    end

end

function Priest:AoeHealing()
    --[[ handle AOE Healing ]]
end

function Priest:TargetHeal()
    if minHp(healthPercent, 35) and cooldown[S.Serenite].ready then
        return IsSpellKnown(S.Serenite) and S.Serenite;
    end
    if minHp(healthPercent, 50) then
        return IsSpellKnown(S.SoinRapide) and S.SoinRapide;
    end
    if not PartyMemberHaveBuff(S.Renovation) and minHp(healthPercent, 90) then
        return IsSpellKnown(S.Renovation) and S.Renovation
    end
    if not PartyMemberHaveBuff(S.PriereDeGuerisonBuff) and minHp(healthPercent, 99) and cooldown[S.PriereDeGuerison].ready then
        return IsSpellKnown(S.PriereDeGuerison) and S.PriereDeGuerison
    end
end

function Priest:selfHeal()
    Priest:Defensive()
    if minHp(selfHealthPercent, 35) and cooldown[S.Serenite].ready then
        return IsSpellKnown(S.Serenite) and S.Serenite;
    end
    if minHp(selfHealthPercent, 50) then
        return IsSpellKnown(S.SoinRapide) and S.SoinRapide;
    end
    if not PartyMemberHaveBuff(S.Renovation) and minHp(selfHealthPercent, 90) then
        return IsSpellKnown(S.Renovation) and S.Renovation
    end
    if not PartyMemberHaveBuff(S.PriereDeGuerisonBuff) and minHp(selfHealthPercent, 99) and cooldown[S.PriereDeGuerison].ready then
        return IsSpellKnown(S.PriereDeGuerison) and S.PriereDeGuerison
    end
end

function Priest:Defensive()
    if cooldown[S.PriereDuDesespoir].up and minHp(selfHealthMax, 25) then
        return IsSpellKnown(S.PriereDuDesespoir) and S.PriereDuDesespoir
    end
end