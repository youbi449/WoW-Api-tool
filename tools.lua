local youbi = {}

function youbi.AoeHeal(limit, number)
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

function youbi.Buff(buff, unit)
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

function youbi.minHp(unitHp, minHp)
    return unitHp <= minHp
end

return youbi
