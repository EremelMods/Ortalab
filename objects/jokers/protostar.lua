SMODS.Joker({
	key = "protostar",
	atlas = "jokers",
	pos = {x=7,y=10},
	rarity = 1,
	cost = 4,
	unlocked = true,
	discovered = false,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	config = {extra = {chips = 100, change = 2, poker_hand = ''}},
    artist_credits = {'gappie'},
	loc_vars = function(self, info_queue, card)
		return {vars = {card.ability.extra.chips, card.ability.extra.change}}
	end,
	calculate = function(self, card, context)
		if context.joker_main then
            card.ability.extra.poker_hand = context.scoring_name
            return {
                chips = card.ability.extra.chips
            }
        end
        if context.after and not context.blueprint and (card.ability.extra.poker_hand ~= '') then
            local poker_hand = card.ability.extra.poker_hand;
            card.ability.extra.poker_hand = '';
            local change = G.GAME.hands[poker_hand].played * card.ability.extra.change
            if change >= card.ability.extra.chips then
                card_eval_status_text(card,'extra', nil, nil, nil, {message = localize('ortalab_protostar')})
                card.getting_sliced = true
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.4,
                    func = function() 
                        local edition = card.edition and card.edition.key or nil
                        local stickers = {}
                        for k, v in pairs(SMODS.Stickers) do
                            if card.ability[k] then
                                table.insert(stickers, k)
                            end
                        end

                        card:start_dissolve()
                        local new_joker = SMODS.create_card({area = G.jokers, set = 'Joker', rarity = (pseudorandom('protostar')+pseudorandom('protostar',7,9))/10, edition = edition, stickers = stickers})
                        new_joker:add_to_deck()
                        G.jokers:emplace(new_joker)
                        new_joker:start_materialize()
                        return true
                end}))  
            else
                SMODS.scale_card(card, {
                    ref_table = card.ability.extra,
                    ref_value = "chips",
                    scalar_value = "change",
                    operation = function(ref_table, ref_value, initial, change)
                        ref_table[ref_value] = initial - change * G.GAME.hands[poker_hand].played
                    end,
                    scaling_message = {
                        message = localize{type = 'variable', key = 'a_chips_minus', vars = {card.ability.extra.change * G.GAME.hands[poker_hand].played}},
                        colour = G.C.BLUE,
                        no_juice = true
                    }
                })
            end
        end
    end
})
