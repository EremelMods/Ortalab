SMODS.Atlas({
    key = 'mythos_cards',
    path = 'mythos.png',
    px = '71',
    py = '95'
})

SMODS.UndiscoveredSprite({
    key = 'ortalab_mythos',
    atlas = "mythos_cards",
    pos = { x = 4, y = 3 },
    no_overlay = true
})

SMODS.Shader({
    key = 'mythos',
    path = 'mythos.fs'
})

G.ARGS.LOC_COLOURS['ortalab_mythos'] = HEX("57405f")
G.ARGS.LOC_COLOURS['ortalab_mythos_alt'] = HEX('ecde33')

SMODS.ConsumableType({
    key = 'ortalab_mythos',
    primary_colour = HEX("57405f"),
    secondary_colour = HEX("57405f"),
    text_colour = HEX('ecde33'),
    collection_rows = {5, 4},
    shop_rate = 0,
    default = 'c_ortalab_excalibur',
    no_buy_and_use = true
})

SMODS.DrawStep {
    key = 'mythos_shine',
    order = 10,
    func = function(self)
        if self.ability.set == 'ortalab_mythos' or self.config.center.group_key == 'ortalab_mythos_pack' then
            self.children.center:draw_shader('ortalab_mythos', nil, self.ARGS.send_to_shader)
        end
    end,
    conditions = { vortex = false, facing = 'front' },
}

SMODS.DrawStep {
    key = 'corpus_shine',
    order = 61,
    func = function(self)
        if self.ability.set == 'ortalab_mythos' and self.children.floating_sprite and self.config.center.discovered then
            local scale_mod = 0.07 + 0.02*math.sin(1.8*G.TIMERS.REAL) + 0.00*math.sin((G.TIMERS.REAL - math.floor(G.TIMERS.REAL))*math.pi*14)*(1 - (G.TIMERS.REAL - math.floor(G.TIMERS.REAL)))^3
            local rotate_mod = 0.05*math.sin(1.219*G.TIMERS.REAL) + 0.00*math.sin((G.TIMERS.REAL)*math.pi*5)*(1 - (G.TIMERS.REAL - math.floor(G.TIMERS.REAL)))^2

            self.children.floating_sprite:draw_shader('ortalab_mythos', nil, nil, nil, self.children.center, scale_mod, rotate_mod)
        end
    end,
    conditions = { vortex = false, facing = 'front' },
}

Ortalab.Mythos_Utils = {}

Ortalab.Mythos_Utils.snakes_modify = {
    function(card, seed) card:set_ability(SMODS.poll_enhancement({guaranteed = true, key = seed..'_enhancement', no_replace = true})) end,
    function(card, seed) card:set_edition(poll_edition(seed..'_edition', nil, false, true), true) end,
    function(card, seed) card:set_seal(SMODS.poll_seal({guaranteed = true, key = seed..'_seal'}), nil, true) end
}

Ortalab.Mythos_Utils.can_curse_in_area = function(area, amount, modifier)
    local uncursed_cards = 0
    for _, card in pairs(area.cards or area) do
        if not card.curse then uncursed_cards = uncursed_cards + 1 end
    end
    if uncursed_cards >= amount + (modifier or 0) + G.GAME.ortalab.mythos.extra_select then
        return true
    end
end

Ortalab.Mythos_Utils.curse_random_hand = function(card, curses, modifier)
    -- unhighlight all cards in hand
    G.E_MANAGER:add_event(Event({
        trigger = 'after', delay = 0.5,
        func = function()
            G.hand:unhighlight_all()
            return true
        end
    }))
    -- apply curse to random cards in hand
    for i=1, card.ability.extra.select + G.GAME.ortalab.mythos.extra_select + (modifier or 0) do
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.5,
            func = function()
                local select = true
                while select do
                    local p_card = pseudorandom_element(G.hand.cards, pseudoseed(card.config.center_key..'_curse'))
                    if not p_card.highlighted and not p_card.curse then 
                        G.hand:add_to_highlighted(p_card)
                        local curse = curses and curses[(i%#curses)+1] or pseudorandom_element(Ortalab.Curses, 'ortalab_curse_default').key
                        p_card:set_curse(curse, false, true)
                        p_card:juice_up()
                        card:juice_up(0.3, 0.5)
                        select = false
                    end
                end
                return true
            end
        }))
    end
    -- unhighlight all cards in hand
    G.E_MANAGER:add_event(Event({
        trigger = 'after', delay = 0.5,
        func = function()
            G.hand:unhighlight_all()
            return true
        end
    }))
end

Ortalab.Mythos_Utils.curse_random_cards = function(card, cards, curses, modifier)
    -- apply curse to random cards in hand
    for i=1, card.ability.extra.select + G.GAME.ortalab.mythos.extra_select + (modifier or 0) do
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.5,
            func = function()
                local select = true
                while select do
                    local p_card = pseudorandom_element(cards, pseudoseed(card.config.center_key..'_curse'))
                    if not p_card.curse then 
                        local curse = curses and curses[(i%#curses)+1] or pseudorandom_element(Ortalab.Curses, 'ortalab_curse_default').key
                        p_card:set_curse(curse, false, true)
                        if p_card.area == G.deck then G.deck.cards[1]:juice_up() else p_card:juice_up() end
                        card:juice_up(0.3, 0.5)
                        select = false
                    end
                end
                return true
            end
        }))
    end
end

-- Excalibur
SMODS.Consumable({
    key = 'excalibur',
    set = 'ortalab_mythos',
    atlas = 'mythos_cards',
    cost = 5,
    pos = {x=0, y=0},
    discovered = false,
    config = {extra = {select = 1, curse = 'ortalab_infected', method = 'c_ortalab_one_deck', multiplier = 1, }},
    artist_credits = {'gappie'},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = {set = 'Curse', key = card.ability.extra.curse}
        return {vars = {localize(G.GAME.last_hand_played or 'High Card', 'poker_hands')}}
    end,
    can_use = function(self, card)
        return G.GAME.last_hand_played and Ortalab.Mythos_Utils.can_curse_in_area(G.deck, card.ability.extra.select)
    end,
    use = function(self, card, area, copier)
        -- Get the name of the last played hand
        local _handname = G.GAME.last_hand_played
        -- Find zodiac key (defaults to High Card if played hand has no zodiac)
        local key = G.P_CENTERS[zodiac_from_hand(_handname) or 'High Card'].config.extra.zodiac
        
        -- Add zodiac for last played hand with that many levels
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 1,
            func = function()
                if G.zodiacs and G.zodiacs[key] then
                    G.zodiacs[key].config.extra.temp_level = G.zodiacs[key].config.extra.temp_level + (G.ZODIACS[key].config.extra.temp_level * card.ability.extra.multiplier) -- double the level
                    zodiac_text(zodiac_upgrade_text(key), key)
                    G.zodiacs[key]:juice_up(1, 1)
                    delay(0.7)
                else
                    add_zodiac(Zodiac(key), nil, nil, card.ability.extra.multiplier)
                end
                return true
            end
        }))

        -- Curse a random card in deck
        Ortalab.Mythos_Utils.curse_random_cards(card, G.deck.cards, {card.ability.extra.curse})
    end
})

-- Tree of Life
SMODS.Consumable({
    key = 'tree_of_life',
    set = 'ortalab_mythos',
    atlas = 'mythos_cards',
    cost = 5,
    pos = {x=1, y=0},
    discovered = false,
    config = {extra = {select = 4, curse = 'ortalab_all_curses', method = 'c_ortalab_mult_random_deck', slots = 1, perish_count = 5}},
    artist_credits = {'gappie'},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.slots, card.ability.extra.perish_count + G.GAME.ortalab.mythos.tree_of_life_count}}
    end,
    can_use = function(self, card)
        local unperish = 0
        for _, joker in pairs(G.jokers.cards) do
            if not joker.ability.perishable then unperish = unperish + 1 end
        end
        for _, joker in pairs(G.consumeables.cards) do
            if joker.ability.set == 'Joker' and not joker.ability.perishable then unperish = unperish + 1 end
        end
        if Ortalab.Mythos_Utils.can_curse_in_area(G.deck.cards, card.ability.extra.select) and unperish >= card.ability.extra.perish_count + G.GAME.ortalab.mythos.tree_of_life_count then
            return true
        end
    end,
    use = function(self, card, area, copier)
        -- Add Joker slots
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.5,
            func = function()
                modify_joker_slot_count(card.ability.extra.slots)
                return true
            end
        }))

        -- Add Perishable to jokers
        local available_jokers = {}    
        for _, joker in pairs(G.jokers.cards) do
            if not joker.ability.perishable then
                available_jokers[#available_jokers + 1] = joker
            end
        end
        for _, joker in pairs(G.consumeables.cards) do
            if joker.ability.set == 'Joker' and not joker.ability.perishable then
                available_jokers[#available_jokers + 1] = joker
            end
        end
        for i=1, card.ability.extra.perish_count + G.GAME.ortalab.mythos.tree_of_life_count do
            G.E_MANAGER:add_event(Event({
                trigger = 'after', delay = 0.7,
                func = function()
                    local joker, pos = pseudorandom_element(available_jokers, pseudoseed('tree_perish'))
                    joker:add_sticker('perishable', true)
                    joker:remove_sticker('eternal')
                    joker:juice_up()
                    play_sound('tarot1')
                    card:juice_up(0.3, 0.5)
                    table.remove(available_jokers, pos)
                    return true
                end
            }))
        end

        -- Increment perishable modifier for future uses
        G.GAME.ortalab.mythos.tree_of_life_count = G.GAME.ortalab.mythos.tree_of_life_count + 1

        -- Curse cards in hand 
        Ortalab.Mythos_Utils.curse_random_cards(card, G.deck.cards, {'ortalab_corroded', 'ortalab_infected', 'ortalab_possessed', 'ortalab_restrained'})
    end
})

-- Genie's Lamp
SMODS.Consumable({
    key = 'genie',
    set = 'ortalab_mythos',
    atlas = 'mythos_cards',
    cost = 5,
    pos = {x=2, y=0},
    discovered = false,
    config = {extra = {select = 2, curse = 'ortalab_corroded', method = 'c_ortalab_mult_random_deck', hands = 3, levels = 2}},
    artist_credits = {'gappie'},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = {set = 'Curse', key = card.ability.extra.curse, specific_vars = {Ortalab.Curses[card.ability.extra.curse].config.extra.base, Ortalab.Curses[card.ability.extra.curse].config.extra.gain}}
        return {vars = {card.ability.extra.hands, card.ability.extra.levels}}
    end,
    can_use = function(self, card)
        return Ortalab.Mythos_Utils.can_curse_in_area(G.deck.cards, card.ability.extra.select)
    end,
    use = function(self, card, area, copier)
        -- Create list of visible hands
        local visible_hands = {}
        for _, v in ipairs(G.handlist) do
            if SMODS.is_poker_hand_visible(v) then
                table.insert(visible_hands, v)
            end
        end
        -- Level up card.ability.extra.hands number of hands
        card.jimbo = true
        for i=1, card.ability.extra.hands do
            local hand, pos = pseudorandom_element(visible_hands, 'ortalab_genie_hand')
            table.remove(visible_hands, pos)
            SMODS.calculate_effect({message = localize(hand, 'poker_hands'), colour = G.ARGS.LOC_COLOURS.ortalab_mythos_alt}, card)
            SMODS.smart_level_up_hand(card, hand, nil, card.ability.extra.levels)
        end

        -- Curse random cards in deck
        Ortalab.Mythos_Utils.curse_random_cards(card, G.deck.cards, {card.ability.extra.curse})
    end
})

-- Pandora's Box
SMODS.Consumable({
    key = 'pandora',
    set = 'ortalab_mythos',
    atlas = 'mythos_cards',
    cost = 5,
    pos = {x=3, y=0},
    discovered = false,
    config = {extra = {select = 4, curse = 'ortalab_all_curses', method = 'c_ortalab_mult_pandora', choose = 1, copies = 4}},
    artist_credits = {'gappie'},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.copies}}
    end,
    can_use = function(self, card)
        return #G.hand.highlighted == card.ability.extra.choose and not G.hand.highlighted[1].curse
    end,
    use = function(self, card, area, copier)
        -- create 4 copies in G.play
        local copies = {}
        for i=1, card.ability.extra.copies do
            G.E_MANAGER:add_event(Event({
                trigger = 'after', delay = 0.7,
                func = function()
                    local new_card = copy_card(G.hand.highlighted[1], nil, nil, G.playing_card)
                    new_card:add_to_deck()
                    G.deck.config.card_limit = G.deck.config.card_limit + 1
                    table.insert(G.playing_cards, new_card)
                    G.play:emplace(new_card)
                    new_card:start_materialize({G.C.SET.ortalab_mythos})
                    card:juice_up(0.3, 0.5)
                    copies[i] = new_card
                    return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.4,
            func = function()        
                playing_card_joker_effects(copies)
                return true
            end
        }))

        -- destroy original card
        SMODS.destroy_cards(G.hand.highlighted[1])

        -- curse each new copy
        Ortalab.Mythos_Utils.curse_random_cards(card, copies, {'ortalab_corroded', 'ortalab_infected', 'ortalab_possessed', 'ortalab_restrained'})

        -- shuffle into deck
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.4,
            func = function()
                for _, copy in ipairs(copies) do
                    draw_card(G.play, G.deck, nil, nil, nil, copy)
                end
                G.deck:shuffle()
                return true
            end
        }))
    end
})

-- Holy Grail
SMODS.Consumable({
    key = 'holy_grail',
    set = 'ortalab_mythos',
    atlas = 'mythos_cards',
    cost = 5,
    pos = {x=4, y=0},
    discovered = false,
    config = {extra = {select = 1, curse = 'ortalab_infected', method = 'c_ortalab_mult_random', cards = 1}},
    artist_credits = {'gappie'},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = {set = 'Curse', key = card.ability.extra.curse}
    end,
    can_use = function(self, card)
        if #G.hand.highlighted == card.ability.extra.cards then
            return Ortalab.Mythos_Utils.can_curse_in_area(G.hand.cards, card.ability.extra.select)
        end
    end,
    use = function(self, card, area, copier)
        -- Add a random seal
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.5,
            func = function()
                G.hand.highlighted[1]:set_seal(SMODS.poll_seal({guaranteed = true, seed = 'ortalab_holy_grail_seal'}), true)
                G.hand.highlighted[1]:juice_up()
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.4,
            func = function()
                G.hand:unhighlight_all()                
                return true
            end
        }))

        -- Curse cards in hand
        Ortalab.Mythos_Utils.curse_random_hand(card, {card.ability.extra.curse})
    end
})

-- Talaria
SMODS.Consumable({
    key = 'talaria',
    set = 'ortalab_mythos',
    atlas = 'mythos_cards',
    cost = 5,
    pos = {x=0, y=3},
    discovered = false,
    config = {extra = {select = 3, curse = 'ortalab_restrained', method = 'c_ortalab_mult_random_deck'}},
    artist_credits = {'gappie'},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = {set = 'Curse', key = card.ability.extra.curse, specific_vars = {Ortalab.Curses[card.ability.extra.curse].config.extra.level_loss}}
    end,
    can_use = function(self, card)
        return Ortalab.Mythos_Utils.can_curse_in_area(G.deck.cards, card.ability.extra.select, G.GAME.ortalab.mythos.talaria_count)
    end,
    use = function(self, card, area, copier)
        -- curse cards
        Ortalab.Mythos_Utils.curse_random_cards(card, G.deck.cards, {card.ability.extra.curse}, G.GAME.ortalab.mythos.talaria_count)
        G.GAME.ortalab.mythos.talaria_count = G.GAME.ortalab.mythos.talaria_count + 1
        
        -- Generate a random voucher
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.5,
            func = function()
                local voucher = get_next_voucher_key(true)
                local voucher_card = SMODS.create_card({area = G.play, key = voucher})
                voucher_card:add_to_deck()
                voucher_card:start_materialize({G.C.SET.ortalab_mythos})
                voucher_card.cost = 0
                G.play:emplace(voucher_card)
                delay(0.8)
                voucher_card:redeem()
                
                G.E_MANAGER:add_event(Event({
                    trigger = 'after', delay = 0.5,
                    func = function()
                        voucher_card:start_dissolve()                
                        return true
                    end
                }))
                return true
            end
        }))
    end
})

-- Basilisk
SMODS.Consumable({
    key = 'basilisk',
    set = 'ortalab_mythos',
    atlas = 'mythos_cards',
    cost = 5,
    pos = {x=0, y=1},
    discovered = false,
    config = {extra = {select = 1, curse = 'ortalab_infected', method = 'c_ortalab_one_selected', cards = 3}},
    artist_credits = {'eremel'},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = {set = 'Curse', key = card.ability.extra.curse}
        return {vars = {card.ability.extra.cards}}
    end,
    can_use = function(self, card)
        return #G.hand.cards > 0 and Ortalab.Mythos_Utils.can_curse_in_area(G.hand, card.ability.extra.select)
    end,
    use = function(self, card, area, copier)
        -- add 3 enhanced/editioned Face cards
        local cards = {}
        local faces = {}
        for _, v in ipairs(SMODS.Rank.obj_buffer) do
            local r = SMODS.Ranks[v]
            if r.face then table.insert(faces, r) end
        end

        for i=1, card.ability.extra.cards do
            G.E_MANAGER:add_event(Event({
                trigger = 'after', delay = 0.7,
                func = function()
                    local _suit = pseudorandom_element(SMODS.Suits, pseudoseed('ortalab_basilisk_suit')).card_key
                    local _rank = pseudorandom_element(faces, pseudoseed('ortalab_basilisk_rank')).card_key
                    local new_card = create_playing_card({front = G.P_CARDS[_suit..'_'.._rank]}, G.hand, nil, i ~= 1, {G.C.SET.ortalab_mythos, darken(G.C.SET.ortalab_mythos, 0.5), G.C.RED, darken(G.C.SET.ortalab_mythos, 0.2), G.ARGS.LOC_COLOURS['ortalab_mythos_alt']})
                    Ortalab.Mythos_Utils.snakes_modify[i](new_card, 'ortalab_basilisk')
                    new_card:add_to_deck()
                    G.deck.config.card_limit = G.deck.config.card_limit + 1
                    new_card:juice_up()
                    card:juice_up(0.3, 0.5)
                    cards[i] = new_card
                    return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.7,
            func = function()                
                playing_card_joker_effects(cards)  
                return true
            end
        }))

        -- set the curse
        Ortalab.Mythos_Utils.curse_random_hand(card, {card.ability.extra.curse})            
    end
})

-- Abaia
SMODS.Consumable({
    key = 'abaia',
    set = 'ortalab_mythos',
    atlas = 'mythos_cards',
    cost = 5,
    pos = {x=4, y=2},
    discovered = false,
    config = {extra = {select = 1, curse = 'ortalab_restrained', method = 'c_ortalab_one_selected', cards = 3, rank = 7}},
    artist_credits = {'kosze'},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = {set = 'Curse', key = card.ability.extra.curse, specific_vars = {Ortalab.Curses[card.ability.extra.curse].config.extra.level_loss}}
        return {vars = {card.ability.extra.cards, card.ability.extra.rank}}
    end,
    can_use = function(self, card)
        return #G.hand.cards > 0 and Ortalab.Mythos_Utils.can_curse_in_area(G.hand, card.ability.extra.select)
    end,
    use = function(self, card, area, copier)
        -- add 3 enhanced/editioned Face cards
        local cards = {}
        for i=1, card.ability.extra.cards do
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.7,
            func = function()
                local _suit = pseudorandom_element(SMODS.Suits, pseudoseed('ortalab_abaia_suit')).card_key
                local new_card = create_playing_card({front = G.P_CARDS[_suit..'_7']}, G.hand, nil, i ~= 1, {G.C.SET.ortalab_mythos, darken(G.C.SET.ortalab_mythos, 0.5), G.C.RED, darken(G.C.SET.ortalab_mythos, 0.2), G.ARGS.LOC_COLOURS['ortalab_mythos_alt']})
                Ortalab.Mythos_Utils.snakes_modify[i](new_card, 'ortalab_abaia')
                new_card:add_to_deck()
                G.deck.config.card_limit = G.deck.config.card_limit + 1
                new_card:juice_up()
                card:juice_up(0.3, 0.5)
                cards[i] = new_card
                return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.7,
            func = function()                
                playing_card_joker_effects(cards)  
                return true
            end
        }))

        -- set the curse
        Ortalab.Mythos_Utils.curse_random_hand(card, {card.ability.extra.curse})              
    end
})

-- Jormungand
SMODS.Consumable({
    key = 'jormungand',
    set = 'ortalab_mythos',
    atlas = 'mythos_cards',
    cost = 5,
    pos = {x=1, y=2},
    discovered = false,
    config = {extra = {select = 1, curse = 'ortalab_corroded', method = 'c_ortalab_one_selected', cards = 3, rank = 'A'}},
    artist_credits = {'kosze'},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = {set = 'Curse', key = card.ability.extra.curse, specific_vars = {Ortalab.Curses[card.ability.extra.curse].config.extra.base, Ortalab.Curses[card.ability.extra.curse].config.extra.gain}}
        return {vars = {card.ability.extra.cards}}
    end,
    can_use = function(self, card)
        return #G.hand.cards > 0 and Ortalab.Mythos_Utils.can_curse_in_area(G.hand, card.ability.extra.select)
    end,
    use = function(self, card, area, copier)
        -- add 3 enhanced/editioned Face cards
        local cards = {}
        for i=1, card.ability.extra.cards do
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.7,
            func = function()
                local _suit = pseudorandom_element(SMODS.Suits, pseudoseed('ortalab_jormungand_suit')).card_key
                local new_card = create_playing_card({front = G.P_CARDS[_suit..'_A']}, G.hand, nil, i ~= 1, {G.C.SET.ortalab_mythos, darken(G.C.SET.ortalab_mythos, 0.5), G.C.RED, darken(G.C.SET.ortalab_mythos, 0.2), G.ARGS.LOC_COLOURS['ortalab_mythos_alt']})
                Ortalab.Mythos_Utils.snakes_modify[i](new_card, 'ortalab_jormungand')
                new_card:add_to_deck()
                G.deck.config.card_limit = G.deck.config.card_limit + 1
                new_card:juice_up()
                card:juice_up(0.3, 0.5)
                cards[i] = new_card
                return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.7,
            func = function()                
                playing_card_joker_effects(cards)  
                return true
            end
        }))
        
        -- set the curse
        Ortalab.Mythos_Utils.curse_random_hand(card, {card.ability.extra.curse})
    end
})

-- Gnome
SMODS.Consumable({
    key = 'gnome',
    set = 'ortalab_mythos',
    atlas = 'mythos_cards',
    cost = 5,
    pos = {x=3, y=2},
    discovered = false,
    config = {extra = {select = 1, money_gain = 2, curse = 'ortalab_corroded', method = 'c_ortalab_mult_random_joker', limit = 100}},
    artist_credits = {'gappie'},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = {set = 'Curse', key = card.ability.extra.curse..'_joker', specific_vars = {Ortalab.Curses[card.ability.extra.curse].config.extra.gain}}
        local total_value = self.total_value(card)
        return {vars = {card.ability.extra.money_gain, total_value}}
    end,
    can_use = function(self, card)
        return Ortalab.Mythos_Utils.can_curse_in_area(G.jokers.cards, card.ability.extra.select)
    end,
    use = function(self, card, area, copier)
        -- Give current sell costs as dollars
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.7,
            func = function()
                ease_dollars(self.total_value(card), true)                
                return true
            end
        }))
        
        -- Increase value of all jokers
        for k=1, #G.jokers.cards + #G.consumeables.cards do
            local _card = G.jokers.cards[k] or G.consumeables.cards[k - #G.jokers.cards]
            if _card.config.center.set == 'Joker' then
                G.E_MANAGER:add_event(Event({
                    trigger = 'after', delay = 0.5,
                    func = function()                
                        card:juice_up(0.3, 0.5)
                        _card.ability.extra_value = _card.ability.extra_value + card.ability.extra.money_gain
                        _card:set_cost()
                        SMODS.calculate_effect({message = '+$'..card.ability.extra.money_gain, colour = G.C.GOLD, instant = true, sound = 'coin1'}, _card)
                        _card:juice_up()
                        return true
                    end
                }))
            end
        end

        -- Curse a random joker
        Ortalab.Mythos_Utils.curse_random_cards(card, G.jokers.cards, {card.ability.extra.curse})
    end,
    total_value = function(card) 
        local temp_total = 0
        local total_value = 0
        if not G.jokers then return total_value end
        for k=1, #G.jokers.cards + #G.consumeables.cards do
            local _card = G.jokers.cards[k] or G.consumeables.cards[k - #G.jokers.cards]
            if _card.config.center.set == 'Joker' then
                total_value = total_value + _card.sell_cost
            end
        end
        return math.min(total_value, card.ability.extra.limit)
    end
})

-- Crawler
SMODS.Consumable({
    key = 'crawler',
    set = 'ortalab_mythos',
    atlas = 'mythos_cards',
    cost = 5,
    pos = {x=3, y=1},
    discovered = false,
    config = {extra = {select = 1, curse = 'ortalab_restrained', method = 'c_ortalab_mult_random_joker'}},
    artist_credits = {'gappie'},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = {set = 'Curse', key = card.ability.extra.curse..'_joker', specific_vars = {Ortalab.Curses[card.ability.extra.curse].config.extra.level_loss}}
    end,
    can_use = function(self, card)
        return Ortalab.Mythos_Utils.can_curse_in_area(G.jokers.cards, card.ability.extra.select) and next(SMODS.Edition:get_edition_cards(G.jokers, true))
    end,
    use = function(self, card, area, copier)
        -- Edition on joker
        local valid_jokers = SMODS.Edition:get_edition_cards(G.jokers, true)
        local selected = pseudorandom_element(valid_jokers, pseudoseed('ortalab_crawler'))
        local edition = poll_edition('ortalab_crawler_edition',nil,false,true)
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.7,
            func = function()
                card:juice_up(0.3, 0.5)
                selected:set_edition(edition, true)
                return true
            end
        }))
        SMODS.calculate_effect({message = localize{type = 'name_text', set = 'Edition', key = edition}, colour = G.C.DARK_EDITION}, selected)
        
        -- Curse random joker
        Ortalab.Mythos_Utils.curse_random_cards(card, G.jokers.cards, {card.ability.extra.curse}) 
    end
})

-- Kraken
SMODS.Consumable({
    key = 'kraken',
    set = 'ortalab_mythos',
    atlas = 'mythos_cards',
    cost = 5,
    pos = {x=2, y=1},
    discovered = false,
    config = {extra = {select = 1, curse = 'ortalab_corroded', method = 'c_ortalab_one_selected', cards = 3}},
    artist_credits = {'gappie'},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = {set = 'Curse', key = card.ability.extra.curse, specific_vars = {Ortalab.Curses[card.ability.extra.curse].config.extra.base, Ortalab.Curses[card.ability.extra.curse].config.extra.gain}}
        return {vars = {card.ability.extra.cards}}
    end,
    can_use = function(self, card)
        return #G.hand.highlighted > 0 and #G.hand.highlighted <= card.ability.extra.cards and Ortalab.Mythos_Utils.can_curse_in_area(G.hand.cards, card.ability.extra.select)
    end,
    use = function(self, card, area, copier)
        -- Give random enhancement
        table.sort(G.hand.highlighted, function (a, b) return a.T.x + a.T.w/2 < b.T.x + b.T.w/2 end)
        for i=1, #G.hand.highlighted do
            G.E_MANAGER:add_event(Event({
                trigger = 'after', delay = 0.5,
                func = function()
                    local enhancement = SMODS.poll_enhancement({key = 'ortalab_kraken', guaranteed = true})
                    card:juice_up(0.3, 0.5)
                    G.hand.highlighted[i]:set_ability(G.P_CENTERS[enhancement])
                    G.hand.highlighted[i]:juice_up()
                    return true
                end
            }))
        end

        -- Unhighlight cards
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.5,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))

        -- Curse random card
        Ortalab.Mythos_Utils.curse_random_hand(card, {card.ability.extra.curse})
    end
})

-- Wendigo
SMODS.Consumable({
    key = 'wendigo',
    set = 'ortalab_mythos',
    atlas = 'mythos_cards',
    cost = 5,
    pos = {x=1, y=1},
    discovered = false,
    config = {extra = {select = 1, curse = 'ortalab_wendigo', method = 'c_ortalab_one_joker', cards = 1}},
    artist_credits = {'gappie'},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = {set = 'Curse', key = 'ortalab_infected_joker', specific_vars = {SMODS.get_probability_vars(card, 1, Ortalab.Curses["ortalab_infected"].config.extra.denom)}}
        info_queue[#info_queue + 1] = {set = 'Curse', key = 'ortalab_possessed_joker'}
        info_queue[#info_queue+1] = G.P_CENTERS.e_ortalab_greyscale
        info_queue[#info_queue+1] = G.P_CENTERS.e_ortalab_overexposed
    end,
    can_use = function(self, card)
        return #G.jokers.highlighted == card.ability.extra.cards and not G.jokers.highlighted[1].curse
    end,
    use = function(self, card, area, copier)
        -- Edition on joker
        local edition = poll_edition('ortalab_crawler_edition',nil,false,true,{'e_ortalab_greyscale','e_ortalab_overexposed'})
        local selected = G.jokers.highlighted[1]
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.7,
            func = function()
                card:juice_up(0.3, 0.5)
                selected:set_edition(edition, true)
                return true
            end
        }))
        SMODS.calculate_effect({message = localize{type = 'name_text', set = 'Edition', key = edition}, colour = G.C.DARK_EDITION}, selected)

        -- Curse the joker
        selected:set_curse(pseudorandom_element({"ortalab_infected", "ortalab_possessed"}, 'ortalab_crawler_curse'), false)
    end
})

-- Jackalope
SMODS.Consumable({
    key = 'jackalope',
    set = 'ortalab_mythos',
    atlas = 'mythos_cards',
    cost = 5,
    pos = {x=2, y=2},
    discovered = false,
    config = {extra = {select = 4, curse = 'ortalab_possessed', method = 'c_ortalab_mult_random', mod = 1, inc = 1}},
    artist_credits = {'kosze'},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = {set = 'Curse', key = card.ability.extra.curse}
        return {vars = {card.ability.extra.mod}}
    end,
    can_use = function(self, card)
        return Ortalab.Mythos_Utils.can_curse_in_area(G.hand.cards, card.ability.extra.select, G.GAME.ortalab.mythos.jackalope_count)
    end,
    use = function(self, card, area, copier)
        -- Choose hand size or discard
        card.jimbo = true
        local positive_effect = pseudorandom_element({'hand','discard'}, 'ortalab_jackalope_choice')
        if positive_effect == 'discard' then
            G.E_MANAGER:add_event(Event({
                trigger = 'after', delay = 0.7,
                func = function()
                    G.GAME.round_resets.discards = G.GAME.round_resets.discards + card.ability.extra.mod  
                    return true
                end
            }))
            SMODS.calculate_effect({message = localize('ortalab_jackalope'), colour = G.C.RED}, card) 
            ease_discard(card.ability.extra.mod)
        else
            SMODS.calculate_effect({message = localize('ortalab_hand_size_gain'), colour = G.C.BLUE}, card)
            G.hand:change_size(card.ability.extra.mod)
            draw_card(G.deck, G.hand)
        end

        -- Curse cards
        Ortalab.Mythos_Utils.curse_random_hand(card, {card.ability.extra.curse}, G.GAME.ortalab.mythos.jackalope_count)
        G.GAME.ortalab.mythos.jackalope_count = G.GAME.ortalab.mythos.jackalope_count + card.ability.extra.inc
    end
})

-- Ya Te Veo
SMODS.Consumable({
    key = 'ya_te_veo',
    set = 'ortalab_mythos',
    atlas = 'mythos_cards',
    cost = 5,
    pos = {x=0, y=2},
    discovered = false,
    config = {extra = {select = 1, deck = 3, scale = 2, curse = 'ortalab_random_curses', method = 'c_ortalab_ya_te_veo_curse', tags = 3}},
    artist_credits = {'gappie'},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.tags}}
    end,
    can_use = function(self, card)
        return Ortalab.Mythos_Utils.can_curse_in_area(G.jokers.cards, card.ability.extra.select) and Ortalab.Mythos_Utils.can_curse_in_area(G.deck.cards, card.ability.extra.select, card.ability.extra.deck)
    end,
    use = function(self, card, area, copier)
        -- Add 3 tags
        local pool = get_current_pool('Tag')
        local final_pool = {}
        for _, v in ipairs(pool) do
            if v ~= 'UNAVAILABLE' and v ~= 'tag_ortalab_777' and v~= 'tag_ortalab_rewind' then
                table.insert(final_pool, v)
            end
        end
        local selected = {}
        local cards = {}
        for i=1, card.ability.extra.tags do
            G.E_MANAGER:add_event(Event({
                trigger = 'after', delay = 1.8,
                func = function()
                    local tag, index = pseudorandom_element(final_pool, pseudoseed('ortalab_tag_patch'))
                    final_pool[index] = nil
                    table.insert(selected, tag)
                    cards[i] = SMODS.add_card({set = 'Tag', key = tag, area = G.play, skip_materialize = true})
                    cards[i]:start_materialize({G.C.SET.ortalab_mythos})
                    SMODS.calculate_effect({message = localize({type = 'name_text', set = 'Tag', key = tag}), instant = true, delay = 1.5}, cards[i])
                    return true
                end
            }))
        end
        delay(1.5)
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.7,
            func = function()
                for i=1, card.ability.extra.tags do
                    cards[i]:start_dissolve()
                    add_tag(Tag(selected[i]))               
                end
                return true
            end
        }))

        -- Curse jokers and deck
        Ortalab.Mythos_Utils.curse_random_cards(card, G.jokers.cards)
        Ortalab.Mythos_Utils.curse_random_cards(card, G.deck.cards, nil, card.ability.extra.select + card.ability.extra.deck)
    end
})

-- Anubis
SMODS.Consumable({
    key = 'anubis',
    set = 'ortalab_mythos',
    atlas = 'mythos_cards',
    cost = 5,
    pos = {x=4, y=1},
    discovered = false,
    config = {extra = {select = 1, curse = 'ortalab_possessed', method = 'c_ortalab_mult_random_joker', cards = 1}},
    artist_credits = {'gappie'},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = {set = 'Curse', key = 'ortalab_infected_joker', specific_vars = {SMODS.get_probability_vars(card, 1, Ortalab.Curses["ortalab_infected"].config.extra.denom)}}
        info_queue[#info_queue + 1] = {set = 'Curse', key = 'ortalab_possessed_joker', specific_vars = {G.GAME.probabilities.normal, Ortalab.Curses[card.ability.extra.curse].config.extra.denom}}
    end,
    can_use = function(self, card)
        return #G.consumeables.cards < G.consumeables.config.card_limit + (card.area == G.consumeables and 1 or 0) and #G.jokers.highlighted == card.ability.extra.cards and not G.jokers.highlighted[1].cursed and Ortalab.Mythos_Utils.can_curse_in_area(G.jokers.cards, card.ability.extra.select + 1)
    end,
    use = function(self, card, area, copier)
        -- Move joker
        G.jokers.highlighted[1]:set_curse('ortalab_infected', false)
        G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = function()
                card:juice_up()                
                return true
            end
        }))
        card:juice_up()
        delay(0.7)
        draw_card(G.jokers, G.consumeables, nil, nil, nil, G.jokers.highlighted[1]) 
        delay(0.4)
        Ortalab.Mythos_Utils.curse_random_cards(card, G.jokers.cards, {card.ability.extra.curse})
    end
})

-- Corpus
SMODS.Consumable({
    key = 'corpus',
    set = 'ortalab_mythos',
    atlas = 'mythos_cards',
    cost = 5,
    pos = {x=1, y=3},
    soul_pos = {x=2, y=3},
    discovered = false,
    config = {extra = {select = 1, sacrificed = {}}},
    artist_credits = {'gappie'},
    set_ability = function(self, card)
        for _, curse in ipairs(G.P_CENTER_POOLS.Curse) do
            card.ability.extra.sacrificed[curse.key] = false
        end
    end,
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.select}}
    end,
    can_use = function(self, card)
        if #G.hand.cards == 0 then return false end
        local sacrificed = 0
        for _, v in pairs(card.ability.extra.sacrificed) do if v then sacrificed = sacrificed + 1 end end
        return sacrificed > 0
    end,
    can_sacrifice = function(self, card)
        if G.STATE == G.STATES.SMODS_BOOSTER_OPENED then return false end
        local target = G.hand.highlighted[1] or G.jokers.highlighted[1]
        return target and target.curse and not card.ability.extra.sacrificed[target.curse]
    end,
    sacrifice = function(self, card)
        local state = G.STATE
        local target = G.hand.highlighted[1] or G.jokers.highlighted[1]
        
        local old_colours = {
            special_colour = copy_table(G.C.BACKGROUND.C),
            tertiary_colour = copy_table(G.C.BACKGROUND.D),
            new_colour = copy_table(G.C.BACKGROUND.L),
        }

        G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = function()
                G.STATE = G.STATES.HAND_PLAYED
                G.STATE_COMPLETE = true
                return true
            end
        }))
        draw_card(target.area, G.play, nil, nil, nil, target)
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.2,
            func = function()            
                ease_background_colour{special_colour = darken(G.C.SET.ortalab_mythos, 0.5), new_colour = G.C.RED, tertiary_colour = G.C.SET.ortalab_mythos, contrast = 1}
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.4,
            blocking = true,
            func = function()
                target.children.particles = Particles(1, 1, 0, 0, {
                    timer = 0.01, scale = 0.3, initialize = true,
                    lifespan = 2, speed = 6, padding = -1,
                    attach = target, fill = true,
                    colours = {G.C.SET.ortalab_mythos, darken(G.C.SET.ortalab_mythos, 0.5), G.C.RED, darken(G.C.SET.ortalab_mythos, 0.2), G.ARGS.LOC_COLOURS['ortalab_mythos_alt']},
                })
                target.children.particles.fade_alpha = 1
                target.children.particles:fade(1, 0)
                local eval = function(target) return target.children.particles end
                juice_card_until(target, eval, true)
                return true
            end
        }))
        delay(1.5)
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 1.5,
            func = function()
                target.destroyed = {colours = {G.C.SET.ortalab_mythos, darken(G.C.SET.ortalab_mythos, 0.5), G.C.RED, darken(G.C.SET.ortalab_mythos, 0.2), G.ARGS.LOC_COLOURS['ortalab_mythos_alt']}}
                SMODS.destroy_cards({target}, true, true)             
                return true
            end
        }))
        delay(1.25)
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 1.5,
            func = function()
                card.ability.extra.sacrificed[target.curse] = true
                target.children.particles:remove()
                target.children.particles = nil
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = function()
                ease_background_colour({special_colour = old_colours.special_colour, tertiary_colour = old_colours.tertiary_colour, new_colour = old_colours.new_colour})       
                G.STATE = state
                G.STATE_COMPLETE = false
                return true
            end
        }))



        G.consumeables:unhighlight_all()
        save_run()
    end,
    use = function(self, card, area, copier)
        local old_colours = {
            special_colour = copy_table(G.C.BACKGROUND.C),
            tertiary_colour = copy_table(G.C.BACKGROUND.D),
            new_colour = copy_table(G.C.BACKGROUND.L),
        }
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.2,
            func = function()            
                ease_background_colour{special_colour = darken(G.C.SET.ortalab_mythos, 0.5), new_colour = G.C.RED, tertiary_colour = G.C.SET.ortalab_mythos, contrast = 1}
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.7,
            blocking = true,
            func = function()
                card.children.particles = Particles(1, 1, 0, 0, {
                    timer = 0.01, scale = 0.3, initialize = true,
                    lifespan = 2, speed = 6, padding = -1,
                    attach = card, fill = true,
                    colours = {G.C.SET.ortalab_mythos, darken(G.C.SET.ortalab_mythos, 0.5), G.C.RED, darken(G.C.SET.ortalab_mythos, 0.2), G.ARGS.LOC_COLOURS['ortalab_mythos_alt']},
                })
                card.children.particles.fade_alpha = 1
                card.children.particles:fade(1, 0)
                local eval = function(card) return card.children.particles end
                juice_card_until(card, eval, true)
                return true
            end
        }))
        delay(1)
        local sacrificed = 0
        card.jimbo = true
        for _, v in pairs(card.ability.extra.sacrificed) do if v then sacrificed = sacrificed + 1 end end
        G.GAME.starting_params.ante_scaling = (G.GAME.starting_params.ante_scaling or 1)
        for i=1, sacrificed do
            pseudorandom_element(Ortalab.Mythos_Utils.Corpus_Effects, 'ortalab_corpus_select')(card)
        end
        G.GAME.starting_params.ante_scaling = G.GAME.starting_params.ante_scaling * 1.25
        SMODS.calculate_effect({message = localize('ortalab_corpus_activated'), colour = G.ARGS.LOC_COLOURS.ortalab_mythos, delay = 6, blocking = false, sound = 'ortalab_gong', pitch = math.random()}, card)
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 2,
            func = function()
                update_blind_amounts()
                card.children.particles:remove()
                card.children.particles = nil
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = function()
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate', delay = 0.7,
                    func = function()                
                        ease_background_colour({special_colour = old_colours.special_colour, tertiary_colour = old_colours.tertiary_colour, new_colour = old_colours.new_colour})       
                        return true
                    end
                }))
                return true
            end
        }))

    end,
    in_pool = function(self, args)
        if pseudorandom('ortalab_corpus_spawn') < 0.3 then
            return true
        end
        return false
    end,
})

local ortalab_card_highlight = Card.highlight
function Card:highlight(is_higlighted)
    self.highlighted = is_higlighted
    if self.config.center_key == 'c_ortalab_corpus' and self.area and self.area == G.consumeables then
        if self.highlighted then
            local x_off = (self.ability.consumeable and -0.1 or 0)
            self.children.use_button = UIBox{
                definition = Ortalab.Mythos_Utils.Corpus_Buttons(self), 
                config = {align=
                        ((self.area == G.jokers) or (self.area == G.consumeables)) and "cr" or
                        "bmi"
                    , offset = 
                        ((self.area == G.jokers) or (self.area == G.consumeables)) and {x=x_off - 0.4,y=0} or
                        {x=0,y=0.65},
                    parent =self}
            }
        elseif self.children.use_button then
            self.children.use_button:remove()
            self.children.use_button = nil
        end
    else
       ortalab_card_highlight(self, is_higlighted) 
    end
end

Ortalab.Mythos_Utils.Corpus_Buttons = function(self)
    local sacrifice = 
    {n=G.UIT.C, config={align = "cr"}, nodes={
      
      {n=G.UIT.C, config={ref_table = self, align = "cr",maxw = 1.25, padding = 0.1, r=0.08, minw = 1.25, minh = (self.area and self.area.config.type == 'joker') and 0 or 1, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, button = 'sacrifice_card', func = 'can_sacrifice_card'}, nodes={
        {n=G.UIT.B, config = {w=0.1,h=0.6}},
        {n=G.UIT.T, config={text = localize('ortalab_corpus_sacrifice'), colour = G.ARGS.LOC_COLOURS.ortalab_mythos_alt, scale = 0.55, shadow = true}}
      }}
    }}

    local use = 
    {n=G.UIT.C, config={align = "cr"}, nodes={
      
      {n=G.UIT.C, config={ref_table = self, align = "cr",maxw = 1.25, padding = 0.1, r=0.08, minw = 1.25, minh = (self.area and self.area.config.type == 'joker') and 0 or 1, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'use_card', func = 'can_use_consumeable'}, nodes={
        {n=G.UIT.B, config = {w=0.1,h=0.6}},
        {n=G.UIT.T, config={text = localize('b_use'),colour = G.C.UI.TEXT_LIGHT, scale = 0.55, shadow = true}}
      }}
    }}
    local t = {
    n=G.UIT.ROOT, config = {padding = 0, colour = G.C.CLEAR}, nodes={
        {n=G.UIT.C, config={padding = 0.15, align = 'cl'}, nodes={
        {n=G.UIT.R, config={align = 'cl'}, nodes={
            sacrifice
        }},
        {n=G.UIT.R, config={align = 'cl'}, nodes={
            use
        }},
        }},
    }}
    return t
end

G.FUNCS.can_sacrifice_card = function(e)
    if e.config.ref_table.config.center:can_sacrifice(e.config.ref_table) then 
        e.config.colour = G.ARGS.LOC_COLOURS.ortalab_mythos
        e.config.button = 'sacrifice_card'
    else
      e.config.colour = G.C.UI.BACKGROUND_INACTIVE
      e.config.button = nil
    end
end

G.FUNCS.sacrifice_card = function(e, mute, nosave)
    e.config.ref_table.config.center:sacrifice(e.config.ref_table)
end

SMODS.Sound({
    key = 'gong',
    path = 'gong.ogg'
})

Ortalab.Mythos_Utils.Corpus_Effects = {}

Ortalab.Mythos_Utils.Corpus_Effects.familiar = function(card)
    SMODS.calculate_effect({message = localize({set = 'Spectral', key = 'c_familiar', type = 'name_text'})..'?', colour = G.ARGS.LOC_COLOURS.ortalab_mythos, sound = 'ortalab_gong', delay = 2, pitch = math.random(), blocking = false}, card)
    local cards = {}
    local faces = {}
    for _, v in ipairs(SMODS.Rank.obj_buffer) do
        local r = SMODS.Ranks[v]
        if r.face then table.insert(faces, r) end
    end

    for i=1, 3 do
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.7,
            func = function()
                local _suit = pseudorandom_element(SMODS.Suits, pseudoseed('corpus_familiar_suit')).card_key
                local _rank = pseudorandom_element(faces, pseudoseed('corpus_familiar_rank')).card_key
                local new_card = create_playing_card({front = G.P_CARDS[_suit..'_'.._rank]}, G.hand, nil, i ~= 1, {G.C.SET.ortalab_mythos, darken(G.C.SET.ortalab_mythos, 0.5), G.C.RED, darken(G.C.SET.ortalab_mythos, 0.2), G.ARGS.LOC_COLOURS['ortalab_mythos_alt']})
                new_card:set_ability(SMODS.poll_enhancement({guaranteed = true, key = 'corpus_familiar_enhancement', no_replace = true}))
                new_card:add_to_deck()
                G.deck.config.card_limit = G.deck.config.card_limit + 1
                new_card:juice_up()
                card:juice_up(0.3, 0.5)
                cards[i] = new_card
                return true
            end
        }))
    end
    G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.7,
            func = function()                
                playing_card_joker_effects(cards)  
                return true
            end
        }))    
    delay(2.5)
end

Ortalab.Mythos_Utils.Corpus_Effects.grim = function(card)
    SMODS.calculate_effect({message = localize({set = 'Spectral', key = 'c_grim', type = 'name_text'})..'?', colour = G.ARGS.LOC_COLOURS.ortalab_mythos, sound = 'ortalab_gong', delay = 2, pitch = math.random(), blocking = false}, card)
    local cards = {}
    

    for i=1, 2 do
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.7,
            func = function()
                local _suit = pseudorandom_element(SMODS.Suits, pseudoseed('corpus_grim_suit')).card_key
                local new_card = create_playing_card({front = G.P_CARDS[_suit..'_A']}, G.hand, nil, i ~= 1, {G.C.SET.ortalab_mythos, darken(G.C.SET.ortalab_mythos, 0.5), G.C.RED, darken(G.C.SET.ortalab_mythos, 0.2), G.ARGS.LOC_COLOURS['ortalab_mythos_alt']})
                new_card:set_ability(SMODS.poll_enhancement({guaranteed = true, key = 'corpus_grim_enhancement', no_replace = true}))
                new_card:add_to_deck()
                G.deck.config.card_limit = G.deck.config.card_limit + 1
                new_card:juice_up()
                card:juice_up(0.3, 0.5)
                cards[i] = new_card
                return true
            end
        }))
    end
    G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.7,
            func = function()                
                playing_card_joker_effects(cards)  
                return true
            end
        }))
    delay(2.5) 
end

Ortalab.Mythos_Utils.Corpus_Effects.incantation = function(card)
    SMODS.calculate_effect({message = localize({set = 'Spectral', key = 'c_incantation', type = 'name_text'})..'?', colour = G.ARGS.LOC_COLOURS.ortalab_mythos, sound = 'ortalab_gong', delay = 2, pitch = math.random(), blocking = false}, card)
    local cards = {}
    local numbers = {}
    for _, rank_key in ipairs(SMODS.Rank.obj_buffer) do
        local rank = SMODS.Ranks[rank_key]
        if rank_key ~= 'Ace' and not rank.face then table.insert(numbers, rank) end
    end

    for i=1, 4 do
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.7,
            func = function()
                local _suit = pseudorandom_element(SMODS.Suits, pseudoseed('corpus_incantation_suit')).card_key
                local _rank = pseudorandom_element(numbers, pseudoseed('corpus_incantation_rank')).card_key
                local new_card = create_playing_card({front = G.P_CARDS[_suit..'_'.._rank]}, G.hand, nil, i ~= 1, {G.C.SET.ortalab_mythos, darken(G.C.SET.ortalab_mythos, 0.5), G.C.RED, darken(G.C.SET.ortalab_mythos, 0.2), G.ARGS.LOC_COLOURS['ortalab_mythos_alt']})
                new_card:set_ability(SMODS.poll_enhancement({guaranteed = true, key = 'corpus_incantation_enhancement', no_replace = true}))
                new_card:add_to_deck()
                G.deck.config.card_limit = G.deck.config.card_limit + 1
                new_card:juice_up()
                card:juice_up(0.3, 0.5)
                cards[i] = new_card
                return true
            end
        }))
    end
    G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.7,
            func = function()                
                playing_card_joker_effects(cards)  
                return true
            end
        }))
    delay(2.5)
end

Ortalab.Mythos_Utils.Corpus_Effects.talisman = function(card)
    SMODS.calculate_effect({message = localize({set = 'Spectral', key = 'c_talisman', type = 'name_text'})..'?', colour = G.ARGS.LOC_COLOURS.ortalab_mythos, sound = 'ortalab_gong', delay = 2, pitch = math.random(), blocking = false}, card)
    local targets = {}
    for _, card in ipairs(G.hand.cards) do
        if not card.seal and not card.getting_sliced then table.insert(targets, card) end
    end
    if #targets == 0 then
        delay(2.5)
        SMODS.calculate_effect({message = localize('ortalab_corpus_no_cards'), colour = G.ARGS.LOC_COLOURS.ortalab_mythos, sound = 'ortalab_gong', delay = 2, pitch = math.random(), blocking = false}, card)
        delay(2.5)
        return
    end
    local target = pseudorandom_element(targets or G.hand.cards, 'corpus_talisman')
    G.E_MANAGER:add_event(Event({
        trigger = 'after', delay = 0.7,
        func = function()                
            target:set_seal('Gold', nil, true)
            return true
        end
    }))
    delay(2.5)
end

Ortalab.Mythos_Utils.Corpus_Effects.aura = function(card)
    SMODS.calculate_effect({message = localize({set = 'Spectral', key = 'c_aura', type = 'name_text'})..'?', colour = G.ARGS.LOC_COLOURS.ortalab_mythos, sound = 'ortalab_gong', delay = 2, pitch = math.random(), blocking = false}, card)
    local targets = SMODS.Edition:get_edition_cards(G.hand, true)
    if #targets == 0 then
        delay(2.5)
        SMODS.calculate_effect({message = localize('ortalab_corpus_no_cards'), colour = G.ARGS.LOC_COLOURS.ortalab_mythos, sound = 'ortalab_gong', delay = 2, pitch = math.random(), blocking = false}, card)
        delay(2.5)
        return
    end
    G.E_MANAGER:add_event(Event({
        trigger = 'after', delay = 0.7,
        func = function()                
            local target = pseudorandom_element(next(targets) and targets or G.hand.cards, 'corpus_aura')
            if target.getting_sliced then target = pseudorandom_element(next(targets) and targets or G.hand.cards, 'corpus_aura_re') end
            target:set_edition(poll_edition('corpus_aura_edition', nil, nil, true, {'e_foil', 'e_holo', 'e_polychrome'}), true, false)
            return true
        end
    }))
    delay(2.5)
end

Ortalab.Mythos_Utils.Corpus_Effects.wraith = function(card)
    SMODS.calculate_effect({message = localize({set = 'Spectral', key = 'c_wraith', type = 'name_text'})..'?', colour = G.ARGS.LOC_COLOURS.ortalab_mythos, sound = 'ortalab_gong', delay = 2, pitch = math.random(), blocking = false}, card)
    G.E_MANAGER:add_event(Event({
        trigger = 'after', delay = 0.7,
        func = function()                
            local card = SMODS.add_card({set = 'Joker', rarity = 3, no_edition = true})
            card:start_materialize({G.C.SET.ortalab_mythos, darken(G.C.SET.ortalab_mythos, 0.5), G.C.RED, darken(G.C.SET.ortalab_mythos, 0.2), G.ARGS.LOC_COLOURS['ortalab_mythos_alt']})
            return true
        end
    }))
    delay(2.5)
end

Ortalab.Mythos_Utils.Corpus_Effects.sigil = function(card)
    SMODS.calculate_effect({message = localize({set = 'Spectral', key = 'c_sigil', type = 'name_text'})..'?', colour = G.ARGS.LOC_COLOURS.ortalab_mythos, sound = 'ortalab_gong', delay = 2, pitch = math.random(), blocking = false}, card)

    local suit = pseudorandom_element(SMODS.Suits, 'corpus_ouija').key

    for _, playing_card in ipairs(G.hand.cards) do
        if not playing_card.getting_sliced then
            G.E_MANAGER:add_event(Event({
                trigger = 'after', delay = 0.7,
                func = function()
                    SMODS.change_base(playing_card, suit)
                    playing_card:juice_up()
                    card:juice_up(0.3, 0.5)
                    return true
                end
            }))
        end
    end
    delay(2.5)
end

Ortalab.Mythos_Utils.Corpus_Effects.ouija = function(card)
    SMODS.calculate_effect({message = localize({set = 'Spectral', key = 'c_ouija', type = 'name_text'})..'?', colour = G.ARGS.LOC_COLOURS.ortalab_mythos, sound = 'ortalab_gong', delay = 2, pitch = math.random(), blocking = false}, card)

    
    local rank = SMODS.Ranks[pseudorandom_element(SMODS.Rank.obj_buffer, 'corpus_sigil')].key

    for _, playing_card in ipairs(G.hand.cards) do
        if not playing_card.getting_sliced then
            G.E_MANAGER:add_event(Event({
                trigger = 'after', delay = 0.7,
                func = function()
                    SMODS.change_base(playing_card, nil, rank)
                    playing_card:juice_up()
                    card:juice_up(0.3, 0.5)
                    return true
                end
            }))
        end
    end
    delay(2.5)
end

Ortalab.Mythos_Utils.Corpus_Effects.ectoplasm = function(card)
    SMODS.calculate_effect({message = localize({set = 'Spectral', key = 'c_ectoplasm', type = 'name_text'})..'?', colour = G.ARGS.LOC_COLOURS.ortalab_mythos, sound = 'ortalab_gong', delay = 2, pitch = math.random(), blocking = false}, card)
    local targets = SMODS.Edition:get_edition_cards(G.jokers, true)
    if #targets == 0 then
        delay(2.5)
        SMODS.calculate_effect({message = localize('ortalab_corpus_no_cards'), colour = G.ARGS.LOC_COLOURS.ortalab_mythos, sound = 'ortalab_gong', delay = 2, pitch = math.random(), blocking = false}, card)
        delay(2.5)
        return
    end
    G.E_MANAGER:add_event(Event({
        trigger = 'after', delay = 0.7,
        func = function()                
            local target = pseudorandom_element(next(targets) and targets or G.jokers.cards, 'corpus_ectoplasm')
            target:set_edition('e_negative', true, false)
            return true
        end
    }))
    delay(2.5)
end

Ortalab.Mythos_Utils.Corpus_Effects.immolate = function(card)
    SMODS.calculate_effect({message = localize({set = 'Spectral', key = 'c_immolate', type = 'name_text'})..'?', colour = G.ARGS.LOC_COLOURS.ortalab_mythos, sound = 'ortalab_gong', delay = 2, pitch = math.random(), blocking = false}, card)
    local removed = {}
    for i=1, math.min(5, #G.hand.cards) do
        local target, pos = pseudorandom_element(G.hand.cards, 'corpus_immolate')
        while table.contains(removed, target) do
            target = pseudorandom_element(G.hand.cards, 'corpus_immolate_re')
        end
        table.insert(removed, target)
    end
    SMODS.destroy_cards(removed)
    ease_dollars(20)
    delay(2.5)
end

Ortalab.Mythos_Utils.Corpus_Effects.ankh = function(card)
    SMODS.calculate_effect({message = localize({set = 'Spectral', key = 'c_ankh', type = 'name_text'})..'?', colour = G.ARGS.LOC_COLOURS.ortalab_mythos, sound = 'ortalab_gong', delay = 2, pitch = math.random(), blocking = false}, card)
    local target = pseudorandom_element(G.jokers.cards, 'corpus_ankh')
    local new_joker = copy_card(target)
    G.E_MANAGER:add_event(Event({
        trigger = 'after', delay = 0.7,
        func = function()                
            G.jokers:emplace(new_joker)
            new_joker:start_materialize({G.C.SET.ortalab_mythos, darken(G.C.SET.ortalab_mythos, 0.5), G.C.RED, darken(G.C.SET.ortalab_mythos, 0.2), G.ARGS.LOC_COLOURS['ortalab_mythos_alt']})
            return true
        end
    }))
    new_joker:add_to_deck()
    delay(2.5)
end

Ortalab.Mythos_Utils.Corpus_Effects.deja_vu = function(card)
    SMODS.calculate_effect({message = localize({set = 'Spectral', key = 'c_deja_vu', type = 'name_text'})..'?', colour = G.ARGS.LOC_COLOURS.ortalab_mythos, sound = 'ortalab_gong', delay = 2, pitch = math.random(), blocking = false}, card)
    local targets = {}
    for _, card in ipairs(G.hand.cards) do
        if not card.seal and not card.getting_sliced then table.insert(targets, card) end
    end
    if #targets == 0 then
        delay(2.5)
        SMODS.calculate_effect({message = localize('ortalab_corpus_no_cards'), colour = G.ARGS.LOC_COLOURS.ortalab_mythos, sound = 'ortalab_gong', delay = 2, pitch = math.random(), blocking = false}, card)
        delay(2.5)
        return
    end
    local target = pseudorandom_element(targets or G.hand.cards, 'corpus_deja_vu')
    G.E_MANAGER:add_event(Event({
        trigger = 'after', delay = 0.7,
        func = function()                
            target:set_seal('Red', nil, true)
            return true
        end
    }))
    delay(2.5)
end

Ortalab.Mythos_Utils.Corpus_Effects.hex = function(card)
    SMODS.calculate_effect({message = localize({set = 'Spectral', key = 'c_hex', type = 'name_text'})..'?', colour = G.ARGS.LOC_COLOURS.ortalab_mythos, sound = 'ortalab_gong', delay = 2, pitch = math.random(), blocking = false}, card)
    local targets = SMODS.Edition:get_edition_cards(G.jokers, true)
    if #targets == 0 then
        delay(2.5)
        SMODS.calculate_effect({message = localize('ortalab_corpus_no_cards'), colour = G.ARGS.LOC_COLOURS.ortalab_mythos, sound = 'ortalab_gong', delay = 2, pitch = math.random(), blocking = false}, card)
        delay(2.5)
        return
    end
    G.E_MANAGER:add_event(Event({
        trigger = 'after', delay = 0.7,
        func = function()                
            local target = pseudorandom_element(next(targets) and targets or G.jokers.cards, 'corpus_hex')
            target:set_edition('e_polychrome', true, false)
            return true
        end
    }))
    delay(2.5)
end

Ortalab.Mythos_Utils.Corpus_Effects.trance = function(card)
    SMODS.calculate_effect({message = localize({set = 'Spectral', key = 'c_trance', type = 'name_text'})..'?', colour = G.ARGS.LOC_COLOURS.ortalab_mythos, sound = 'ortalab_gong', delay = 2, pitch = math.random(), blocking = false}, card)
    local targets = {}
    for _, card in ipairs(G.hand.cards) do
        if not card.seal and not card.getting_sliced then table.insert(targets, card) end
    end
    if #targets == 0 then
        delay(2.5)
        SMODS.calculate_effect({message = localize('ortalab_corpus_no_cards'), colour = G.ARGS.LOC_COLOURS.ortalab_mythos, sound = 'ortalab_gong', delay = 2, pitch = math.random(), blocking = false}, card)
        delay(2.5)
        return
    end
    local target = pseudorandom_element(targets or G.hand.cards, 'corpus_trance')
    G.E_MANAGER:add_event(Event({
        trigger = 'after', delay = 0.7,
        func = function()                
            target:set_seal('ortalab_cyan', nil, true)
            return true
        end
    }))
    delay(2.5)
end

Ortalab.Mythos_Utils.Corpus_Effects.medium = function(card)
    SMODS.calculate_effect({message = localize({set = 'Spectral', key = 'c_medium', type = 'name_text'})..'?', colour = G.ARGS.LOC_COLOURS.ortalab_mythos, sound = 'ortalab_gong', delay = 2, pitch = math.random(), blocking = false}, card)
    local targets = {}
    for _, card in ipairs(G.hand.cards) do
        if not card.seal and not card.getting_sliced then table.insert(targets, card) end
    end
    if #targets == 0 then
        delay(2.5)
        SMODS.calculate_effect({message = localize('ortalab_corpus_no_cards'), colour = G.ARGS.LOC_COLOURS.ortalab_mythos, sound = 'ortalab_gong', delay = 2, pitch = math.random(), blocking = false}, card)
        delay(2.5)
        return
    end
    local target = pseudorandom_element(targets or G.hand.cards, 'corpus_medium')
    G.E_MANAGER:add_event(Event({
        trigger = 'after', delay = 0.7,
        func = function()                
            target:set_seal('ortalab_magenta', nil, true)
            return true
        end
    }))
    delay(2.5)
end

Ortalab.Mythos_Utils.Corpus_Effects.cryptid = function(card)
    SMODS.calculate_effect({message = localize({set = 'Spectral', key = 'c_cryptid', type = 'name_text'})..'?', colour = G.ARGS.LOC_COLOURS.ortalab_mythos, sound = 'ortalab_gong', delay = 2, pitch = math.random(), blocking = false}, card)
    if #G.hand.cards == 0 then
        delay(2.5)
        SMODS.calculate_effect({message = localize('ortalab_corpus_no_cards'), colour = G.ARGS.LOC_COLOURS.ortalab_mythos, sound = 'ortalab_gong', delay = 2, pitch = math.random(), blocking = false}, card)
        delay(2.5)
        return
    end
    local target = pseudorandom_element(G.hand.cards, 'corpus_soul')
    if target.getting_sliced then target = pseudorandom_element(G.hand.cards, 'corpus_soul_re') end
    local copies = {}
    for i=1, 2 do
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.7,
            func = function()                
                local new_card = copy_card(target, nil, nil, G.playing_card)
                new_card:add_to_deck()
                G.deck.config.card_limit = G.deck.config.card_limit + 1
                table.insert(G.playing_cards, new_card)
                G.hand:emplace(new_card)
                new_card:start_materialize({G.C.SET.ortalab_mythos, darken(G.C.SET.ortalab_mythos, 0.5), G.C.RED, darken(G.C.SET.ortalab_mythos, 0.2), G.ARGS.LOC_COLOURS['ortalab_mythos_alt']})
                card:juice_up(0.3, 0.5)
                copies[i] = new_card
                return true
            end
        }))
    end
    G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.4,
            func = function()        
                playing_card_joker_effects(copies)
                return true
            end
        }))
    delay(2.5)
end

Ortalab.Mythos_Utils.Corpus_Effects.soul = function(card)
    SMODS.calculate_effect({message = localize({set = 'Spectral', key = 'c_soul', type = 'name_text'})..'?', colour = G.ARGS.LOC_COLOURS.ortalab_mythos, sound = 'ortalab_gong', delay = 2, pitch = math.random(), blocking = false}, card)
    G.E_MANAGER:add_event(Event({
        trigger = 'after', delay = 0.7,
        func = function()                
            local card = SMODS.add_card({set = 'Joker', rarity = 4, legendary = true, no_edition = true})
            card:start_materialize({G.C.SET.ortalab_mythos, darken(G.C.SET.ortalab_mythos, 0.5), G.C.RED, darken(G.C.SET.ortalab_mythos, 0.2), G.ARGS.LOC_COLOURS['ortalab_mythos_alt']})
            return true
        end
    }))
    delay(2.5)
end

Ortalab.Mythos_Utils.Corpus_Effects.black_hole = function(card)
    SMODS.calculate_effect({message = localize({set = 'Spectral', key = 'c_black_hole', type = 'name_text'})..'?', colour = G.ARGS.LOC_COLOURS.ortalab_mythos, sound = 'ortalab_gong', delay = 2, pitch = math.random(), blocking = false}, card)
    update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize('k_all_hands'),chips = '...', mult = '...', level=''})
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
            play_sound('tarot1')
            card:juice_up(0.8, 0.5)
            G.TAROT_INTERRUPT_PULSE = true
            return true end }))
        update_hand_text({delay = 0}, {mult = '+', StatusText = true})
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.9, func = function()
            play_sound('tarot1')
            card:juice_up(0.8, 0.5)
            return true end }))
        update_hand_text({delay = 0}, {chips = '+', StatusText = true})
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.9, func = function()
            play_sound('tarot1')
            card:juice_up(0.8, 0.5)
            G.TAROT_INTERRUPT_PULSE = nil
            return true end }))
        update_hand_text({sound = 'button', volume = 0.7, pitch = 0.9, delay = 0}, {level='+1'})
        delay(1.3)
        for k, v in pairs(G.GAME.hands) do
            level_up_hand(card, k, true)
        end
        update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
    delay(2.5)
end

-- Ophiuchus
SMODS.Consumable({
    key = 'ophiuchus',
    set = 'ortalab_mythos',
    atlas = 'mythos_cards',
    cost = 5,
    pos = {x=3, y=3},
    discovered = false,
    hidden = true,
    soul_set = 'ortalab_zodiac',
    soul_rate = 0.03,
    config = {extra = {cards = 4, zodiac = 'zodiac_ortalab_ophiuchus'}},
    artist_credits = {'gappie'},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.cards}}
    end,
    can_use = function(self, card)
        return true
    end,
    use = function(self, card, area, copier)
        use_zodiac(card)
    end,
    in_pool = function(self, args)
        if pseudorandom('ortalab_ophiuchus_spawn') < 0.5 then
            return true
        end
        return false
    end,
})

-- Ophiuchus Zodiac
Ortalab.Zodiac{
    key = 'ophiuchus',
    pos = {x=0, y=2},
    colour = HEX('57405f'),
    config = {extra = {temp_level = 8, hand_type = 'Any'}},
    loc_vars = function(self, info_queue, card)
        local zodiac = card or self
        local temp_level = (not zodiac.voucher_check and G.GAME.ortalab.zodiacs.temp_level_mod or 1) * zodiac.config.extra.temp_level
        return {vars = {temp_level, localize(zodiac.config.extra.hand_type, 'poker_hands'), zodiac.config.extra.amount}}
    end,
    pre_trigger = function(self, zodiac, context)
        for i=1, #context.scoring_hand do
            if context.scoring_hand[i].curse then
                SMODS.calculate_effect({message = localize('ortalab_ophiuchus'), colour = G.C.FILTER}, context.scoring_hand[i]) 
                context.scoring_hand[i]:set_curse(nil, nil, nil, nil, nil, true)
            end
        end
        return context.mult, context.chips
    end
}
