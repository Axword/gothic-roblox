--!strict
local Formulae = {}
function Formulae.maxHp(level: number, vitality: number): number return 80 + level * 12 + vitality * 2 end
function Formulae.levelForXp(xp: number): number
	local level = 1
	while xp >= Formulae.xpForNext(level) do level += 1 end
	return level
end
function Formulae.xpForNext(level: number): number return 100 * level * level end
function Formulae.swordDamage(base: number, strength: number): number return base + strength * 0.55 end
function Formulae.bowDamage(base: number, dexterity: number): number return base + dexterity * 0.65 end
return Formulae
