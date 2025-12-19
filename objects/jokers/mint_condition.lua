SMODS.Joker({
	name = "Mint Condition",
	key = "mint_condition",
	atlas = "jokers",
	pos = {x = 0, y = 6},
	rarity = 3,
	cost = 8,
	unlocked = true,
	discovered = false,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	config = {extra = {Xmult = 1.75}},
	artist_credits = {'hat'},
	loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.Xmult}}
    end,
	calculate = function(self, card, context)
		if context.money_altered and G.GAME.Ortalab_Scoring_Active and context.amount > 0 then
			return {
				xmult = card.ability.extra.Xmult
			}
		end
	end
})

local ortalab_calc_individual_effect = SMODS.calculate_individual_effect
function SMODS.calculate_individual_effect(effect, scored_card, key, amount, from_edition)
  local ret = ortalab_calc_individual_effect(effect, scored_card, key, amount, from_edition)
	if (key == 'p_dollars' or key == 'dollars' or key == 'h_dollars') and amount then
		if G.GAME.Ortalab_Scoring_Active and to_big(amount) > to_big(0) then
			local mint_jokers = SMODS.find_card('j_ortalab_mint_condition')
			if next(mint_jokers) then
				SMODS.calculate_context({ortalab_money_gain = true, amount = amount})
			end
		end
	end
return ret
end