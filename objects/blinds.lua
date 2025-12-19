SMODS.Atlas({
    key = 'ortalab_blinds',
    path = 'blinds.png',
    atlas_table = 'ANIMATION_ATLAS',
    frames = 21,
    px = 34,
    py = 34
})

SMODS.Blind({
    key = 'fold',
    atlas = 'ortalab_blinds',
    pos = {x=0, y=33},
    boss_colour = HEX('00b99f'),
    artist_credits = {'coro'},
    mult = 0.7,
    dollars = 2,
    small = {min = 1}
})

SMODS.Blind({
    key = 'check',
    atlas = 'ortalab_blinds',
    pos = {x=0, y=28},
    boss_colour = HEX('27b955'),
    artist_credits = {'coro'},
    mult = 1,
    dollars = 3,
    small = {min = 1}
})

SMODS.Blind({
    key = 'bet',
    atlas = 'ortalab_blinds',
    pos = {x=0, y=30},
    boss_colour = HEX('71ba27'),
    artist_credits = {'eremel'},
    mult = 1.25,
    dollars = 4,
    small = {min = 1}
})

SMODS.Blind({
    key = 'call',
    atlas = 'ortalab_blinds',
    pos = {x=0, y=31},
    boss_colour = HEX('b94a00'),
    artist_credits = {'eremel'},
    mult = 1.15,
    dollars = 3,
    big = {min = 1}
})

SMODS.Blind({
    key = 'raise',
    atlas = 'ortalab_blinds',
    pos = {x=0, y=29},
    boss_colour = HEX('c73a38'),
    artist_credits = {'eremel'},
    mult = 1.5,
    dollars = 4,
    big = {min = 1}
})

SMODS.Blind({
    key = 'all_in',
    atlas = 'ortalab_blinds',
    pos = {x=0, y=32},
    boss_colour = HEX('b92aff'),
    artist_credits = {'eremel'},
    mult = 1.875,
    dollars = 5,
    big = {min = 1}
})

local blind_get_type = Blind.get_type
function Blind:get_type()
    if self.small then return 'Small'
    elseif self.big then return 'Big'
    else return blind_get_type(self) end
end

SMODS.Blind({
    key = 'sinker',
    atlas = 'ortalab_blinds',
    pos = {x = 0, y = 0},
    dollars = 5,
    mult = 2,
    boss = {min = 1, max = 10},
    boss_colour = HEX('5186A8'),
    config = {extra = {hand_size = 1, hands_removed = 0}},
    artist_credits = {'flare'},
    loc_vars = function(self, info_queue, card)
        return {vars = {self.config.extra.hand_size}}
    end,
    collection_loc_vars = function(self)
        return {vars = {self.config.extra.hand_size}}
    end,
    set_blind = function(self)
        G.GAME.blind.effect.extra.hands_removed = 0
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.main_eval then
            G.E_MANAGER:add_event(Event({
                trigger = 'after', delay = 0.7,
                func = function()
                    G.hand:change_size(card.effect.extra.hands_removed)
                    return true
                end
            }))
        end
        if context.after then
            card.effect.extra.hands_removed = card.effect.extra.hands_removed + card.effect.extra.hand_size
            G.E_MANAGER:add_event(Event({ trigger = 'after', delay = 0.7, func = function()
            attention_text({
                text = localize('ortalab_sinker_message'),
                hold = 1.4,
                backdrop_colour = self.boss_colour,
                major = G.play,
                offset = {x = 0, y = -2},
                align = 'cm',
                silent = true
            })
            G.hand:change_size(-1 * card.effect.extra.hand_size)
            return true
        end })) 
        delay(0.7)
        end
    end,
    defeat = function(self)
        if not G.GAME.blind.disabled then  end
    end,
    disable = function(self)
        G.hand:change_size(G.GAME.blind.effect.extra.hands_removed)
        G.FUNCS.draw_from_deck_to_hand(G.GAME.blind.effect.extra.hands_removed)
    end
})

SMODS.Blind({
    key = 'fork',
    atlas = 'ortalab_blinds',
    pos = {x = 0, y = 1},
    dollars = 5,
    mult = 2,
    boss = {min = 1, max = 10},
    boss_colour = HEX('AE718E'),
    config = {extra = {cap = 0.5}},
    artist_credits = {'flare'},
    loc_vars = function(self, info_queue, card)
        return {vars = {self.config.extra.cap*100}}
    end,
    collection_loc_vars = function(self)
        return {vars = {self.config.extra.cap*100}}
    end,
    get_loc_debuff_text = function(self)
        return ""
    end,
    debuff_hand = function(self, cards, hand, handname, check)
        if check then return true end
    end,
})

local ortalab_calc_round_score = SMODS.calculate_round_score
function SMODS.calculate_round_score(flames)
    local score = ortalab_calc_round_score(flames)
    if G.GAME.blind and G.GAME.blind.config.blind.key == 'bl_ortalab_fork' and not G.GAME.blind.disabled then
        score = math.min(score, G.GAME.blind.chips*G.GAME.blind.config.blind.config.extra.cap)
    end
    return score
end

SMODS.Blind({
    key = 'top',
    atlas = 'ortalab_blinds',
    pos = {x = 0, y = 2},
    dollars = 5,
    mult = 2,
    boss = {min = 1, max = 10},
    boss_colour = HEX('A9A295'),
    config = {extra = {frequency = 4}},
    artist_credits = {'flare'},
    loc_vars = function(self, info_queue, card)
        return {vars = {SMODS.get_probability_vars(G.GAME.blind, 1, self.config.extra.frequency)}}
    end,
    collection_loc_vars = function(self)
        return {vars = {G.GAME.probabilities.normal, self.config.extra.frequency}}
    end,
    calculate = function(self, card, context)
        if context.hand_drawn then
            for _, card in ipairs(context.hand_drawn) do
                 if SMODS.pseudorandom_probability(G.GAME.blind, 'top_blind', 1, G.GAME.blind.effect.extra.frequency) then
                    card:set_debuff(true)
                    if card.debuff then card.debuffed_by_blind = true end
                end
            end
        end
    end,
    recalc_debuff = function(self, card, from_blind)
        return card.debuff
    end,
    disable = function(self)
        for _, card in pairs(G.playing_cards) do
            if card.top_check then card:set_debuff(); card.top_check = nil end
        end
    end,
    defeat = function(self)
        for _, card in pairs(G.playing_cards) do
            if card.top_check then card:set_debuff(); card.top_check = nil end
        end
    end
})

SMODS.Blind({
    key = 'hammer',
    atlas = 'ortalab_blinds',
    pos = {x = 0, y = 3},
    dollars = 5,
    mult = 2,
    boss = {min = 3, max = 10},
    boss_colour = HEX('6a3847'),
    artist_credits = {'flare'},
    after_scoring = function(self)
        for k, v in ipairs(G.play.cards) do
            if v.ability.set == 'Enhanced' then 
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.7, func = function()
                    v:set_ability(G.P_CENTERS.c_base)
                    return true
                end}))
                card_eval_status_text(v, 'extra', nil, nil, nil, {message = localize('ortalab_hammer')})
            end
        end
    end
})

SMODS.Blind({
    key = 'parasol',
    atlas = 'ortalab_blinds',
    pos = {x = 0, y = 4},
    dollars = 5,
    mult = 1.75,
    boss = {min = 2, max = 10},
    boss_colour = HEX('A84024'),
    config = {extra = {suit = 'Clubs'}},
    artist_credits = {'flare'},
    loc_vars = function(self, info_queue, card)
        return {vars = {localize(self.config.extra.suit, 'suits_plural')}}
    end,
    collection_loc_vars = function(self)
        return {vars = {localize(self.config.extra.suit, 'suits_plural')}}
    end,
    debuff_hand = function(self, cards, hands, handname, check)
        for _, card in pairs(hands[handname][1]) do
            if not SMODS.has_no_suit(card) and card:is_suit(self.config.extra.suit) then return false end
        end
        return true
    end,
    in_pool = function(self)
        for _, card in pairs(G.playing_cards or {}) do
            if not SMODS.has_no_suit(card) and card:is_suit(self.config.extra.suit) then return true end
        end
        return false
    end
})

SMODS.Blind({
    key = 'glass',
    atlas = 'ortalab_blinds',
    pos = {x = 0, y = 5},
    dollars = 5,
    mult = 2,
    boss = {min = 3, max = 10},
    boss_colour = HEX('3e85bd'),
    config = {extra = {discard_amount = 0}},
    artist_credits = {'flare'},
    set_blind = function(self)
        G.GAME.blind.effect.extra.discard_amount = G.GAME.round_scores.cards_discarded.amt
    end,
    stay_flipped = function(self, area, card)
        if area == G.hand and G.GAME.blind.effect.extra.discard_amount < G.GAME.round_scores.cards_discarded.amt then
            G.GAME.blind.effect.extra.discard_amount = G.GAME.blind.effect.extra.discard_amount + 1
            return true
        end
    end,
    disable = function(self)
        for i = 1, #G.hand.cards do
            if G.hand.cards[i].facing == 'back' then
                G.hand.cards[i]:flip()
            end
        end
        for k, v in pairs(G.playing_cards) do
            v.ability.wheel_flipped = nil
        end
    end
})

SMODS.Blind({
    key = 'tarot',
    atlas = 'ortalab_blinds',
    pos = {x = 0, y = 6},
    dollars = 5,
    mult = 2,
    boss = {min = 2, max = 10},
    boss_colour = HEX('50bf7c'),
    artist_credits = {'flare'},
    debuff_hand = function(self, cards, hand, handname, check)
        if #cards == 1 then return false end
        local _,_,_,scoring_hand,_ = G.FUNCS.get_poker_hand_info(cards)
        local always_scores_count = 0
        for _, card in pairs(cards) do
            if SMODS.always_scores(card) then always_scores_count = always_scores_count + 1 end
        end
        if #scoring_hand + always_scores_count ~= #cards then return true end
    end,
})

SMODS.Blind({
    key = 'buckler',
    atlas = 'ortalab_blinds',
    pos = {x = 0, y = 7},
    dollars = 5,
    mult = 1.75,
    boss = {min = 2, max = 10},
    boss_colour = HEX('efc03c'),
    config = {extra = {suit = 'Spades'}},
    artist_credits = {'flare'},
    loc_vars = function(self, info_queue, card)
        return {vars = {localize(self.config.extra.suit, 'suits_plural')}}
    end,
    collection_loc_vars = function(self)
        return {vars = {localize(self.config.extra.suit, 'suits_plural')}}
    end,
    debuff_hand = function(self, cards, hands, handname, check)
        for _, card in pairs(hands[handname][1]) do
            if not SMODS.has_no_suit(card) and card:is_suit(self.config.extra.suit) then return false end
        end
        return true
    end,
    in_pool = function(self)
        for _, card in pairs(G.playing_cards or {}) do
            if not SMODS.has_no_suit(card) and card:is_suit(self.config.extra.suit) then return true end
        end
        return false
    end
})

SMODS.Blind({
    key = 'oil',
    atlas = 'ortalab_blinds',
    pos = {x = 0, y = 8},
    dollars = 5,
    mult = 2,
    boss = {min = 1, max = 10},
    boss_colour = HEX('5c6e31'),
    artist_credits = {'flare'},
    set_blind = function(self)
        local deck_size = #G.deck.cards
        for i=1, math.floor(deck_size/2) do
            draw_card(G.deck, G.discard)
        end
    end,
})

SMODS.Blind({
    key = 'room',
    atlas = 'ortalab_blinds',
    pos = {x = 0, y = 9},
    dollars = 5,
    mult = 1.75,
    boss = {min = 2, max = 10},
    boss_colour = HEX('b9cb92'),
    config = {extra = {suit = 'Diamonds'}},
    artist_credits = {'flare'},
    loc_vars = function(self, info_queue, card)
        return {vars = {localize(self.config.extra.suit, 'suits_plural')}}
    end,
    collection_loc_vars = function(self)
        return {vars = {localize(self.config.extra.suit, 'suits_plural')}}
    end,
    debuff_hand = function(self, cards, hands, handname, check)
        for _, card in pairs(hands[handname][1]) do
            if not SMODS.has_no_suit(card) and card:is_suit(self.config.extra.suit) then return false end
        end
        return true
    end,
    in_pool = function(self)
        for _, card in pairs(G.playing_cards or {}) do
            if not SMODS.has_no_suit(card) and card:is_suit(self.config.extra.suit) then return true end
        end
        return false
    end
})

SMODS.Blind({
    key = 'bellows',
    atlas = 'ortalab_blinds',
    pos = {x = 0, y = 10},
    dollars = 5,
    mult = 5,
    boss = {min = 4, max = 10},
    boss_colour = HEX('e56a2f'),
    config = {extra = {hand_size = 1}},
    artist_credits = {'flare'},
    loc_vars = function(self, info_queue, card)
        return {vars = {self.config.extra.hand_size}}
    end,
    collection_loc_vars = function(self)
        return {vars = {self.config.extra.hand_size}}
    end,
    set_blind = function(self)
        G.hand:change_size(self.config.extra.hand_size)
    end,
    defeat = function(self)
        if not G.GAME.blind.disabled then G.hand:change_size(-self.config.extra.hand_size) end
    end,
    disable = function(self)
        G.hand:change_size(-self.config.extra.hand_size)
    end
})

SMODS.Blind({
    key = 'spike',
    atlas = 'ortalab_blinds',
    pos = {x = 0, y = 11},
    dollars = 5,
    mult = 2,
    boss = {min = 3, max = 10},
    boss_colour = HEX('4b71e4'),
    config = {extra = {triggered = false}},
    artist_credits = {'flare'},
    loc_vars = function(self, info_queue, card)
        if G.GAME.current_round.most_played_poker_hand then
            return {vars = {localize(G.GAME.current_round.most_played_poker_hand, 'poker_hands')}}
        else
            return {key = 'bl_ortalab_spike_collection'}
        end
    end,
    collection_loc_vars = function(self)
        return {key = 'bl_ortalab_spike_collection'}
    end,
    set_blind = function(self)
        G.GAME.blind.effect.extra.hand_type = G.GAME.current_round.most_played_poker_hand
        G.GAME.blind:set_text()
    end,
    debuff_hand = function(self, cards, hand, handname, check)
        if handname == G.GAME.blind.effect.extra.hand_type and check and not G.GAME.blind.effect.extra.triggered then return true end
    end,
    modify_hand = function(self, cards, poker_hands, handname, mult, hand_chips)
        if not G.GAME.blind.effect.extra.triggered then 
            if handname == G.GAME.blind.effect.extra.hand_type then
                local _,_,_,scoring_hand,_ = G.FUNCS.get_poker_hand_info(cards)
                for _, card in pairs(scoring_hand) do
                    card:set_debuff(true)
                end
                G.GAME.blind.effect.extra.triggered = true
            end
        end
        return mult, hand_chips
    end,
    disable = function(self)
        G.GAME.blind.effect.triggered = nil
        for _, card in pairs(G.playing_cards) do
            if card.debuff then card:set_debuff() end
        end
    end,
    defeat = function(self)
        G.GAME.blind.effect.triggered = nil
        for _, card in pairs(G.playing_cards) do
            if card.debuff then card:set_debuff() end
        end
    end
})

SMODS.Blind({
    key = 'glyph',
    atlas = 'ortalab_blinds',
    pos = {x = 0, y = 14},
    dollars = 5,
    mult = 2,
    boss = {min = 1, max = 10},
    boss_colour = HEX('7e6752'),
    config = {extra = {ranks = {}}},
    artist_credits = {'flare'},
    calculate = function(self, _card, context)
        if context.after then
             G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
                for _, card in ipairs(G.playing_cards) do
                    if not SMODS.has_no_rank(card) and G.GAME.blind.effect.extra.ranks[card.base.id] then
                        card:set_debuff(true)
                    end
                end
            return true end }))
        end
    end,
    modify_hand = function(self, cards, poker_hands, handname, mult, hand_chips)
        for _, card in pairs(poker_hands[handname][1]) do
            if not SMODS.has_no_rank(card) then G.GAME.blind.effect.extra.ranks[card.base.id] = true end
        end
        return mult, hand_chips
    end,
    set_blind = function(self)
        for _, card in pairs(G.playing_cards) do
            if not SMODS.has_no_rank(card) and G.GAME.blind.effect.extra.ranks[card.base.id] then card:set_debuff(true); card.debuffed_by_glyph = true end
        end
    end,
    recalc_debuff = function(self, card, from_blind)
        if not SMODS.has_no_rank(card) and G.GAME.blind.effect.extra.ranks[card.base.id] then
            card.debuffed_by_glyph = true
            return true
        else
            card.debuffed_by_glyph = nil
            return false
        end
    end,
    disable = function(self)
        for _, card in pairs(G.playing_cards) do
            if card.debuffed_by_glyph then card:set_debuff(); card.debuffed_by_glyph = nil end
        end
    end,
    defeat = function(self)
        for _, card in pairs(G.playing_cards) do
            if card.debuffed_by_glyph then card:set_debuff(); card.debuffed_by_glyph = nil end
        end
    end
})

SMODS.Blind({
    key = 'reed',
    atlas = 'ortalab_blinds',
    pos = {x = 0, y = 12},
    dollars = 5,
    mult = 2,
    boss = {min = 1, max = 10},
    boss_colour = HEX('6865f3'),
    config = {extra = {ranks = {}, debuff_count = 4}},
    artist_credits = {'flare'},
    loc_vars = function(self, info_queue, card)
        if G.GAME.blind.effect.triggered then
            local ranks = {}
            for k, v in pairs(G.GAME.blind.effect.extra.ranks) do
                table.insert(ranks, k)
            end
            table.sort(ranks, function(a, b) return a < b end)
            return {vars = {ranks[1] or localize('ortalab_blind_no_rank_caps'), ranks[2] or localize('ortalab_blind_no_rank'), ranks[3] or localize('ortalab_blind_no_rank'), ranks[4] or localize('ortalab_blind_no_rank')}}
        else
            return {key = 'bl_ortalab_reed_collection', vars = {self.config.extra.debuff_count}}
        end
    end,
    collection_loc_vars = function(self)
        return {key = 'bl_ortalab_reed_collection', vars = {self.config.extra.debuff_count}}
    end,
    set_blind = function(self)
        local possible_ranks = {}
        for _, card in pairs(G.playing_cards) do
            if not SMODS.has_no_rank(card) and not SMODS.Ranks[card.base.value].face then possible_ranks[card.base.value] = card.base.value end
        end
        if table.size(possible_ranks) > 0 then
            for i=1, math.min(G.GAME.blind.effect.extra.debuff_count, table.size(possible_ranks)) do
                local rank = pseudorandom_element(possible_ranks, pseudoseed('ortalab_reed'))
                G.GAME.blind.effect.extra.ranks[rank] = true
                possible_ranks[rank] = nil
            end
        end
        for _, card in pairs(G.playing_cards) do
            if not SMODS.has_no_rank(card) and G.GAME.blind.effect.extra.ranks[card.base.value] then card:set_debuff(true); card.debuffed_by_reed = true end
        end
        G.GAME.blind.effect.triggered = true
        G.GAME.blind:set_text()
    end,
    recalc_debuff = function(self, card, from_blind)
        if not SMODS.has_no_rank(card) and G.GAME.blind.effect.extra.ranks[card.base.value] then
            card.debuffed_by_reed = true
            return true
        else
            card.debuffed_by_reed = nil
            return false
        end
    end,
    disable = function(self)
        for _, card in pairs(G.playing_cards) do
            if card.debuffed_by_reed then card:set_debuff(); card.debuffed_by_reed = nil end
        end
        G.GAME.blind.effect.triggered = false
    end,
    defeat = function(self)
        for _, card in pairs(G.playing_cards) do
            if card.debuffed_by_reed then card:set_debuff(); card.debuffed_by_reed = nil end
        end
        G.GAME.blind.effect.triggered = false
    end,
    in_pool = function(self)
        local possible_ranks = {}
        for _, card in pairs(G.playing_cards or {}) do
            if not SMODS.has_no_rank(card) and not SMODS.Ranks[card.base.value].face then possible_ranks[card.base.value] = card.base.value end
        end
        if table.size(possible_ranks) > self.config.extra.debuff_count then return true end
        return false
    end
})

SMODS.Blind({
    key = 'ladder',
    atlas = 'ortalab_blinds',
    pos = {x = 0, y = 13},
    dollars = 5,
    mult = 2,
    modifies_draw = true,
    boss = {min = 2, max = 10},
    boss_colour = HEX('439a4f'),
    config = {extra = {hand_size = 2, actions = 2, action_count = 2}},
    artist_credits = {'flare'},
    loc_vars = function(self, info_queue, card)
        return {vars = {self.config.extra.hand_size, self.config.extra.actions}}
    end,
    collection_loc_vars = function(self)
        return {vars = {self.config.extra.hand_size, self.config.extra.actions}}
    end,
    set_blind = function(self)
        G.hand:change_size(self.config.extra.hand_size)
    end,
    defeat = function(self)
        if not G.GAME.blind.disabled then G.hand:change_size(-self.config.extra.hand_size) end
    end,
    disable = function(self)
        G.hand:change_size(-self.config.extra.hand_size)
    end
})

SMODS.Blind({
    key = 'hearth',
    atlas = 'ortalab_blinds',
    pos = {x = 0, y = 15},
    dollars = 5,
    mult = 2,
    boss = {min = 2, max = 10},
    boss_colour = HEX('575757'),
    artist_credits = {'flare'},
    config = {played_ranks = {}},
    set_blind = function(self)
        G.GAME.blind.effect.played_ranks = {}
        for _,card in pairs(G.playing_cards) do
            if card.ability.played_this_ante then
                G.GAME.blind.effect.played_ranks[card.base.id] = true
            end
        end
    end,
    stay_flipped = function(self, area, card)
        if not SMODS.has_no_rank(card) and not G.GAME.blind.effect.played_ranks[card.base.id] and area == G.hand then return true end
    end,
    disable = function(self)
        for i = 1, #G.hand.cards do
            if G.hand.cards[i].facing == 'back' then
                G.hand.cards[i]:flip()
            end
        end
        for k, v in pairs(G.playing_cards) do
            v.ability.wheel_flipped = nil
        end
    end
})

SMODS.Blind({
    key = 'spring',
    atlas = 'ortalab_blinds',
    pos = {x = 0, y = 16},
    dollars = 5,
    mult = 2,
    boss = {min = 1, max = 10},
    boss_colour = HEX('c6e0eb'),
    artist_credits = {'flare'},
    modify_hand = function(self, cards, poker_hands, text, mult, hand_chips)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.5,
            func = function()                
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.5,
                    func = function()                
                        G.GAME.blind:juice_up()
                        play_sound('ortalab_spring')
                        attention_text({
                            scale = 1, text = '-'..localize('$')..G.GAME.hands[text].played, hold = 2, align = 'cm', offset = {x = 0,y = -2.7},major = G.play, colour = G.C.RED
                        })
                        return true
                    end
                }))  
                ease_dollars(-G.GAME.hands[text].played)
                return true
            end
        }))      
        return mult, hand_chips, false
    end
})

SMODS.Sound({
    key = 'spring',
    path = 'spring.ogg'
})

SMODS.Blind({
    key = 'face',
    atlas = 'ortalab_blinds',
    pos = {x = 0, y = 17},
    dollars = 5,
    mult = 1.75,
    boss = {min = 2, max = 10},
    boss_colour = HEX('709284'),
    config = {extra = {suit = 'Hearts'}},
    artist_credits = {'flare'},
    loc_vars = function(self, info_queue, card)
        return {vars = {localize(self.config.extra.suit, 'suits_plural')}}
    end,
    collection_loc_vars = function(self)
        return {vars = {localize(self.config.extra.suit, 'suits_plural')}}
    end,
    debuff_hand = function(self, cards, hands, handname, check)
        for _, card in pairs(hands[handname][1]) do
            if not SMODS.has_no_suit(card) and card:is_suit(self.config.extra.suit) then return false end
        end
        return true
    end,
    in_pool = function(self)
        for _, card in pairs(G.playing_cards or {}) do
            if not SMODS.has_no_suit(card) and card:is_suit(self.config.extra.suit) then return true end
        end
        return false
    end
})

SMODS.Blind({
    key = 'tongs',
    atlas = 'ortalab_blinds',
    pos = {x = 0, y = 18},
    dollars = 5,
    mult = 2,
    boss = {min = 2, max = 10},
    boss_colour = HEX('b95c96'),
    config = {extra = {change = 2}},
    artist_credits = {'flare'},
    loc_vars = function(self, info_queue, card)
        return {vars = {self.config.extra.change}}
    end,
    collection_loc_vars = function(self)
        return {vars = {self.config.extra.change}}
    end,
    modify_hand = function(self, cards, poker_hands, text, mult, hand_chips)
        for _, card in pairs(cards) do
            G.E_MANAGER:add_event(Event({ trigger = 'after', func = function()
                G.GAME.blind.chips = G.GAME.blind.chips * (1 + self.config.extra.change/100)
                G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                card:juice_up()
                return true
            end })) 
            card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('ortalab_tongs')})
        end
        return mult, hand_chips, false
    end
})

SMODS.Blind({
    key = 'beam',
    atlas = 'ortalab_blinds',
    pos = {x = 0, y = 19},
    dollars = 5,
    mult = 2,
    boss = {min = 1, max = 10},
    boss_colour = HEX('b95b08'),
    config = {extra = {ranks = {}, flipped = 5}},
    artist_credits = {'flare'},
    loc_vars = function(self, info_queue, card)
        if G.GAME.blind.effect.triggered then
            local ranks = {}
            for k, v in pairs(G.GAME.blind.effect.extra.ranks) do
                table.insert(ranks, k)
            end
            table.sort(ranks, function(a, b) return a < b end)
            return {vars = {ranks[1] or localize('ortalab_blind_no_rank_caps'), ranks[2] or localize('ortalab_blind_no_rank'), ranks[3] or localize('ortalab_blind_no_rank'), ranks[4] or localize('ortalab_blind_no_rank'), ranks[5] or localize('ortalab_blind_no_rank')}}
        else
            return {key = 'bl_ortalab_beam_collection', vars = {self.config.extra.flipped}}
        end
    end,
    collection_loc_vars = function(self)
        return {key = 'bl_ortalab_beam_collection', vars = {self.config.extra.flipped}}
    end,
    set_blind = function(self)
        local possible_ranks = {}
        for _, card in pairs(G.playing_cards) do
            if not SMODS.has_no_rank(card) and not SMODS.Ranks[card.base.value].face then possible_ranks[card.base.value] = card.base.value end
        end
        if table.size(possible_ranks) > 0 then
            for i=1, math.min(table.size(possible_ranks), G.GAME.blind.effect.extra.flipped) do
                local rank = pseudorandom_element(possible_ranks, pseudoseed('ortalab_beam'))
                G.GAME.blind.effect.extra.ranks[rank] = true
                possible_ranks[rank] = nil
            end
        end
        G.GAME.blind.effect.triggered = true
        G.GAME.blind:set_text()
    end,
    stay_flipped = function(self, area, card)
        if not SMODS.has_no_rank(card) and G.GAME.blind.effect.extra.ranks[card.base.value] and area == G.hand then card.flipped_by_beam = true; return true end
    end,
    disable = function(self)
        for _, card in pairs(G.hand.cards) do
            if card.flipped_by_beam then card:flip() end
        end
        G.GAME.blind.effect.triggered = false
    end,
    defeat = function(self)
        G.GAME.blind.effect.triggered = false
    end,
    in_pool = function(self)
        local possible_ranks = {}
        for _, card in pairs(G.playing_cards or {}) do
            if not SMODS.has_no_rank(card) and not SMODS.Ranks[card.base.value].face then possible_ranks[card.base.value] = card.base.value end
        end
        if table.size(possible_ranks) > self.config.extra.flipped then return true end
        return false
    end
})

SMODS.Blind({
    key = 'sheep',
    atlas = 'ortalab_blinds',
    pos = {x = 0, y = 20},
    dollars = 5,
    mult = 2,
    boss = {min = 2, max = 10},
    boss_colour = HEX('ac9db4'),
    config = {extra = {reset = 5, hand_type = nil}},
    artist_credits = {'flare'},
    loc_vars = function(self, info_queue, card)
        if G.GAME.current_round.most_played_poker_hand then
            return {vars = {localize(G.GAME.current_round.most_played_poker_hand, 'poker_hands'), self.config.extra.reset}}
        else
            return {key = 'bl_ortalab_sheep_collection', vars = {self.config.extra.reset}}

        end
    end,
    collection_loc_vars = function(self)
        return {key = 'bl_ortalab_sheep_collection', vars = {self.config.extra.reset}}
    end,
    set_blind = function(self)
        G.GAME.blind.effect.extra.hand_type = G.GAME.current_round.most_played_poker_hand
        G.GAME.blind:set_text()
    end,
    modify_hand = function(self, cards, poker_hands, text, mult, hand_chips)
        if text ~= G.GAME.blind.effect.extra.hand_type then
            ease_dollars(G.GAME.blind.effect.extra.reset - G.GAME.dollars)
            play_sound('ortalab_sheep', 0.96+math.random()*0.08)
            G.GAME.blind:wiggle()
        end
        return mult, hand_chips, false
    end
})

SMODS.Sound{key = 'sheep', path = 'sheep.ogg'}

SMODS.Blind({
    key = 'lever',
    atlas = 'ortalab_blinds',
    pos = {x = 0, y = 21},
    dollars = 5,
    mult = 2,
    boss = {min = 1, max = 10},
    boss_colour = HEX('8a59a5'),
    config = {extra = {triggered = false}},
    artist_credits = {'flare'},
    drawn_to_hand = function(self)
        if not G.GAME.blind.effect.extra.triggered then
            for _, card in pairs(G.hand.cards) do
                card:set_debuff(true)
                if card.debuff then card.debuffed_by_blind = true end
            end
            G.GAME.blind.effect.extra.triggered = true
        end
    end,
    recalc_debuff = function(self, card, from_blind)
        return card.debuff
    end,
    disable = function(self)
        for _, card in pairs(G.playing_cards) do
            if card.debuff then card:set_debuff() end
        end
    end,
    defeat = function(self)
        for _, card in pairs(G.playing_cards) do
            if card.debuff then card:set_debuff() end
        end
    end
})

SMODS.Blind({
    key = 'steel',
    atlas = 'ortalab_blinds',
    pos = {x = 0, y = 22},
    dollars = 6,
    mult = 0.5,
    boss = {min = 3, max = 7},
    boss_colour = HEX('b52d2d'),
    artist_credits = {'flare'},
    in_pool = function(self)
        if G.GAME.round_resets.ante > 8 or G.GAME.round_resets.ante < 3 then return false end
        return true
    end,
    update_score = function(self, args)
        local min = math.min(args.chips, args.mult)
        args.mult = min
        args.chips = min
        update_hand_text({delay = 0}, {mult = args.mult, chips = args.chips})

        G.E_MANAGER:add_event(Event({
            func = (function()
                local text = localize('ortalab_minimised')
                play_sound('gong', 0.94, 0.3)
                play_sound('gong', 0.94*1.5, 0.2)
                play_sound('tarot1', 1.5)
                ease_colour(G.C.UI_CHIPS, darken(G.C.UI_MULT, 0.5))
                ease_colour(G.C.UI_MULT, darken(G.C.UI_MULT, 0.5))
                attention_text({
                    scale = 1.4, text = text, hold = 2, align = 'cm', offset = {x = 0,y = -2.7},major = G.play
                })
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    blockable = false,
                    blocking = false,
                    delay =  4.3,
                    func = (function() 
                            ease_colour(G.C.UI_CHIPS, G.C.BLUE, 2)
                            ease_colour(G.C.UI_MULT, G.C.RED, 2)
                        return true
                    end)
                }))
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    blockable = false,
                    blocking = false,
                    no_delete = true,
                    delay =  6.3,
                    func = (function() 
                        G.C.UI_CHIPS[1], G.C.UI_CHIPS[2], G.C.UI_CHIPS[3], G.C.UI_CHIPS[4] = G.C.BLUE[1], G.C.BLUE[2], G.C.BLUE[3], G.C.BLUE[4]
                        G.C.UI_MULT[1], G.C.UI_MULT[2], G.C.UI_MULT[3], G.C.UI_MULT[4] = G.C.RED[1], G.C.RED[2], G.C.RED[3], G.C.RED[4]
                        return true
                    end)
                }))
                return true
            end)
        }))

        delay(0.6)

        return min
    end
})

SMODS.Blind({
    key = 'celadon_clubs',
    atlas = 'ortalab_blinds',
    pos = {x = 0, y = 23},
    dollars = 10,
    mult = 2,
    boss = {min = 1, max = 10, showdown = true},
    boss_colour = HEX('22857b'),
    artist_credits = {'flare'},
    set_blind = function(self)
        -- Find most abundant
        G.GAME.ortalab.ranks_in_deck = G.GAME.ortalab.ranks_in_deck or Ortalab.count_ranks()
        local max_amount = G.GAME.ortalab.ranks_in_deck[1].count
        local ranks_to_debuff = {}
        for _, rank in ipairs(G.GAME.ortalab.ranks_in_deck) do
            if rank.count == max_amount then
                ranks_to_debuff[#ranks_to_debuff+1] = rank.rank
            end
        end
        -- Sort table in rank order (highest to lowest)
        table.sort(ranks_to_debuff, function(a,b) return SMODS.Ranks[a].sort_nominal > SMODS.Ranks[b].sort_nominal end)
        -- Debuff cards
        for _, card in pairs(G.playing_cards) do
            if not SMODS.has_no_rank(card) and table.contains(ranks_to_debuff, card.base.value) then
                card:set_debuff(true)
                card.debuffed_by_blind = true
                card.ability.celadon = true
            end
        end
        -- Add notification split over 2 lines
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.7,
            func = function()
                local text = {localize(ranks_to_debuff[1], 'ranks')..localize('ortalab_plural')..(#ranks_to_debuff>2 and localize('ortalab_comma') or ''), ""}
                for i=2, #ranks_to_debuff-2 do
                    text[i<7 and 1 or 2] = text[i<7 and 1 or 2]..localize(ranks_to_debuff[i], 'ranks')..localize('ortalab_plural')..localize('ortalab_comma')
                end
                if #ranks_to_debuff > 1 then
                    text[string.len(text[2])>0 and 2 or 1] = text[string.len(text[2])>0 and 2 or 1] .. (#ranks_to_debuff > 2 and localize(ranks_to_debuff[#ranks_to_debuff-1], 'ranks')..localize('ortalab_plural') or '') .. localize('ortalab_celadon_and') .. localize(ranks_to_debuff[#ranks_to_debuff], 'ranks') .. localize('ortalab_plural')
                end
                text[string.len(text[2])>0 and 2 or 1] = text[string.len(text[2])>0 and 2 or 1] .. localize('ortalab_celadon_notification')
                attention_text({
                    scale = 0.9, text = text[1], hold = 4*math.ceil(#ranks_to_debuff/7), align = 'cm', offset = {x = 0,y = -2.7},major = G.play, colour = G.C.RED
                })         
                attention_text({
                    scale = 0.9, text = text[2], hold = 4*math.ceil(#ranks_to_debuff/7), align = 'cm', offset = {x = 0,y = -1.8},major = G.play, colour = G.C.RED
                })            
                return true
            end
        }))
    end,
    recalc_debuff = function(self, card, from_blind)
        return card.debuff
    end,
    disable = function(self)
        for _, card in pairs(G.playing_cards) do
            if card.ability.celadon then card:set_debuff(); card.ability.celadon = nil; card.debuffed_by_blind = nil end
        end
    end,
    defeat = function(self)
        for _, card in pairs(G.playing_cards) do
            if card.ability.celadon then card:set_debuff(); card.ability.celadon = nil; card.debuffed_by_blind = nil end
        end
    end
})

SMODS.Shader({key = 'celadon', path = 'applied.fs'})

SMODS.DrawStep {
    key = 'celadon',
    order = -1,
    func = function(self)
        if self.celadon then
            self.children.center:draw_shader('ortalab_celadon', nil, self.ARGS.send_to_shader)
        end
    end,
    conditions = { vortex = false, facing = 'front' },
}


SMODS.Blind({
    key = 'caramel_coin',
    atlas = 'ortalab_blinds',
    pos = {x = 0, y = 24},
    dollars = 10,
    mult = 2,
    boss = {min = 1, max = 10, showdown = true},
    boss_colour = HEX('c77a32'),
    config = {extra = {hand_size = 3}},
    artist_credits = {'flare'},
    loc_vars = function(self, info_queue, card)
        return {vars = {self.config.extra.hand_size}}
    end,
    collection_loc_vars = function(self)
        return {vars = {self.config.extra.hand_size}}
    end,
    set_blind = function(self)
        G.hand:change_size(-self.config.extra.hand_size)
    end,
    disable = function(self)
        if not G.GAME.blind.disabled then G.hand:change_size(self.config.extra.hand_size) end
    end,
    defeat = function(self)
        G.hand:change_size(self.config.extra.hand_size)
    end
})

SMODS.Blind({
    key = 'saffron_shield',
    atlas = 'ortalab_blinds',
    pos = {x = 0, y = 25},
    dollars = 10,
    mult = 2,
    boss = {min = 1, max = 10, showdown = true},
    boss_colour = HEX('fdca57'),
    config = {extra = {chance = 2}},
    artist_credits = {'flare'},
    loc_vars = function(self, info_queue, card)
        G.GAME.ortalab.suits_in_deck = G.GAME.ortalab.suits_in_deck or Ortalab.count_suits()
        return {vars = {localize(G.GAME.ortalab.suits_in_deck[#G.GAME.ortalab.suits_in_deck].suit, 'suits_plural'), colours = {G.C.SUITS[G.GAME.ortalab.suits_in_deck[#G.GAME.ortalab.suits_in_deck].suit]}}}
    end,
    collection_loc_vars = function(self)
        return {vars = {localize('ortalab_saffron'), colours = {G.ARGS.LOC_COLOURS.attention}}}
    end,
    set_blind = function(self)
        G.GAME.ortalab.suits_in_deck = G.GAME.ortalab.suits_in_deck or Ortalab.count_suits()
        G.GAME.blind.effect.extra.suit = G.GAME.ortalab.suits_in_deck[#G.GAME.ortalab.suits_in_deck].suit
    end,
    debuff_hand = function(self, cards, hands, handname, check)
        for _, card in pairs(hands[handname][1]) do
            if not SMODS.has_no_suit(card) and card:is_suit(G.GAME.blind.effect.extra.suit) then return false end
        end
        return true
    end,
})

SMODS.Blind({
    key = 'rouge_rose',
    atlas = 'ortalab_blinds',
    pos = {x = 0, y = 26},
    dollars = 10,
    mult = 2,
    boss = {min = 1, max = 10, showdown = true},
    boss_colour = HEX('a85476'),
    artist_credits = {'flare'},
    collection_loc_vars = function(self)
    end,
    set_blind = function(self)
        local card_protos = {}
        local suits = {'S','C','D','H'}
        local ranks = {'2','3','4','5','6','7','8','9','10','J','Q','K','A'}
        for _, suit in ipairs(suits) do
            for _, rank in ipairs(ranks) do
                G.E_MANAGER:add_event(Event({
                    trigger = 'after', delay = 0.05,
                    func = function()
                        local card = SMODS.add_card({set = 'Base', area = G.deck, suit = suit, rank = rank})
                        card.ability.rouge_rose = true
                        return true
                    end
                }))
            end
        end
        self.original_deck_size = G.GAME.starting_deck_size
        G.GAME.starting_deck_size = #G.playing_cards
    end,
    disable = function(self)
        for _, card in pairs(G.hand.cards) do
            if card.ability.rouge_rose then
                if SMODS.shatters(card) then 
                    card:shatter()
                else
                    card:start_dissolve()
                end
            end
        end
        self:defeat()
        G.STATE_COMPLETE = false
        G:update_draw_to_hand()
    end,
    defeat = function(self)
        for _, card in pairs(G.deck.cards) do
            if card.ability.rouge_rose then
                if SMODS.shatters(card) then 
                    card:shatter()
                else
                    card:start_dissolve()
                end
            end
        end
        for _, card in pairs(G.discard.cards) do
            if card.ability.rouge_rose then
                if SMODS.shatters(card) then 
                    card:shatter()
                else
                    card:start_dissolve()
                end
            end
        end
        G.GAME.starting_deck_size = self.original_deck_size
    end
})

SMODS.Atlas({
    key = 'rouge_rose',
    path = 'rouge.png',
    px = 71,
    py = 95
})

SMODS.DrawStep {
    key = 'rouge_rose',
    order = 36,
    func = function(self)
        if self.ability.rouge_rose then
            if not Ortalab.rouge_rose_sprite then Ortalab.rouge_rose_sprite = Sprite(0, 0, G.CARD_W, G.CARD_H, G.ASSET_ATLAS['ortalab_rouge_rose'], {x=0, y=0}) end
            Ortalab.rouge_rose_sprite.role.draw_major = self
            Ortalab.rouge_rose_sprite:draw_shader('dissolve', nil, nil, nil, self.children.center)
        end
    end,
    conditions = { vortex = false, facing = 'front' },
}


SMODS.Blind({
    key = 'silver_sword',
    atlas = 'ortalab_blinds',
    pos = {x = 0, y = 27},
    dollars = 10,
    mult = 2,
    boss = {min = 1, max = 10, showdown = true},
    boss_colour = HEX('9bafcf'),
    config = {extra = {hands = 1}},
    artist_credits = {'flare'},
    loc_vars = function(self, info_queue, card)
        return {vars = {self.config.extra.hands}}
    end,
    collection_loc_vars = function(self)
        return {vars = {self.config.extra.hands}}
    end,
    set_blind = function(self)
        G.GAME.blind.effect.extra.hands_sub = G.GAME.round_resets.hands - G.GAME.blind.effect.extra.hands
        ease_hands_played(-G.GAME.blind.effect.extra.hands_sub)
    end,
    disable = function(self)
        G.GAME.blind.effect.extra.hands_sub = G.GAME.round_resets.hands - G.GAME.blind.effect.extra.hands
        ease_hands_played(G.GAME.blind.effect.extra.hands_sub)
    end
})


local draw_discard = G.FUNCS.draw_from_play_to_discard
G.FUNCS.draw_from_play_to_discard = function(e)
    local obj = G.GAME.blind.config.blind
    if obj.after_scoring and not G.GAME.blind.disabled then
        obj:after_scoring()
    end
    draw_discard(e)
end