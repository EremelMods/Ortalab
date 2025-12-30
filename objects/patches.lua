SMODS.Atlas({
    key = 'patches',
    path = 'patches.png',
    px = '34',
    py = '34'
})

SMODS.Tag({
    key = 'common',
    atlas = 'patches',
    pos = {x = 2, y = 2},
    discovered = false,
    min_ante = 2,
    config = {type = 'ortalab_shop_add', extra = {amount = 2}},
    artist_credits = {'5381','kosze'},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.config.extra.amount}}
    end,
    apply = function(self, tag, context)
        if context.type == self.config.type then
            G.shop_jokers.config.card_limit = G.shop_jokers.config.card_limit + 2
            G.shop_jokers.T.w = math.min((G.GAME.shop.joker_max + 2)*1.02*G.CARD_W,4.08*G.CARD_W)
            G.shop:recalculate()
            for i=1, tag.config.extra.amount do
                local card = create_card('Joker', context.area, nil, 0, nil, nil, nil, 'uta')
                if not card.edition then
                    card:set_edition(poll_edition('ortalab_common_patch', nil, false, true))
                end
                G.shop_jokers:emplace(card)
                create_shop_card_ui(card, 'Joker', context.area)
                card.states.visible = false
                card:start_materialize()
                card.ability.couponed = true
                card:set_cost()
            end
            tag:yep('+', G.C.GREEN,function() 
                return true
            end)
            tag.triggered = true
        end
    end
})

SMODS.Tag({
    key = 'anaglyphic',
    atlas = 'patches',
    pos = {x = 4, y = 2},
    discovered = false,
    config = {type = 'store_joker_modify', edition = 'e_ortalab_anaglyphic'},
    artist_credits = {'kosze'},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS[self.config.edition]
    end,
    apply = function(self, tag, context)
        if context.type == self.config.type then
            if not context.card.edition and not context.card.temp_edition and context.card.ability.set == 'Joker' then
                context.card.temp_edition = true
                tag:yep('+', G.C.DARK_EDITION,function() 
                    context.card:set_edition(tag.config.edition, true)
                    context.card.ability.couponed = true
                    context.card:set_cost()
                    context.card.temp_edition = nil
                    return true
                end)
                tag.triggered = true
            end
        end
    end
})

SMODS.Tag({
    key = 'fluorescent',
    atlas = 'patches',
    pos = {x = 0, y = 3},
    discovered = false,
    min_ante = 2,
    artist_credits = {'kosze'},
    config = {type = 'store_joker_modify', edition = 'e_ortalab_fluorescent'},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {set = 'Edition', key = self.config.edition..'_joker', config = G.P_CENTERS.e_ortalab_fluorescent.config, vars = {G.P_CENTERS.e_ortalab_fluorescent.config.p_dollars}}
    end,
    apply = function(self, tag, context)
        if context.type == self.config.type then
            if not context.card.edition and not context.card.temp_edition and context.card.ability.set == 'Joker' then
                context.card.temp_edition = true
                tag:yep('+', G.C.DARK_EDITION,function() 
                    context.card:set_edition(tag.config.edition, true)
                    context.card.ability.couponed = true
                    context.card:set_cost()
                    context.card.temp_edition = nil
                    return true
                end)
                tag.triggered = true
            end
        end
    end
})

SMODS.Tag({
    key = 'greyscale',
    atlas = 'patches',
    pos = {x = 1, y = 3},
    discovered = false,
    config = {type = 'store_joker_modify', edition = 'e_ortalab_greyscale'},
    artist_credits = {'coro','kosze'},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS[self.config.edition]
    end,
    apply = function(self, tag, context)
        if context.type == self.config.type then
            if not context.card.edition and not context.card.temp_edition and context.card.ability.set == 'Joker' then
                context.card.temp_edition = true
                tag:yep('+', G.C.DARK_EDITION,function() 
                    context.card:set_edition(tag.config.edition, true)
                    context.card.ability.couponed = true
                    context.card:set_cost()
                    context.card.temp_edition = nil
                    return true
                end)
                tag.triggered = true
            end
        end
    end
})

SMODS.Tag({
    key = 'overexposed',
    atlas = 'patches',
    pos = {x = 3, y = 2},
    discovered = false,
    config = {type = 'store_joker_modify', edition = 'e_ortalab_overexposed'},
    artist_credits = {'kosze'},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS[self.config.edition]
    end,
    apply = function(self, tag, context)
        if context.type == self.config.type then
            if not context.card.edition and not context.card.temp_edition and context.card.ability.set == 'Joker' then
                context.card.temp_edition = true
                tag:yep('+', G.C.DARK_EDITION,function() 
                    context.card:set_edition(tag.config.edition, true)
                    context.card.ability.couponed = true
                    context.card:set_cost()
                    context.card.temp_edition = nil
                    return true
                end)
                tag.triggered = true
            end
        end
    end
})

SMODS.Tag({
    key = 'rewind',
    atlas = 'patches',
    pos = {x = 0, y = 0},
    discovered = false,
    min_ante = 2,
    in_pool = function(self)
        if G.GAME.last_selected_tag and G.GAME.last_selected_tag.key ~= 'tag_ortalab_rewind' then
            return true
        end
        return false
    end,
    config = {type = 'immediate'},
    artist_credits = {'flare','kosze'},
    loc_vars = function(self, info_queue, card)
        return {vars = {G.GAME.last_selected_tag and localize({type = 'name_text', set = 'Tag', key = G.GAME.last_selected_tag.key}) or localize('ortalab_no_tag')}}
    end,
    apply = function(self, tag, context)
        if context.type == self.config.type then
            if G.GAME.last_selected_tag and G.GAME.last_selected_tag.key then
                tag:yep('+', G.C.GREEN,function() 
                    return true
                end)
                local last_tag = G.GAME.last_selected_tag
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        local tag = Tag(last_tag.key, false, last_tag.blind_type)
                        if last_tag.key == 'tag_orbital' then
                            local _poker_hands = {}
                            for k, v in pairs(G.GAME.hands) do
                                if v.visible then _poker_hands[#_poker_hands+1] = k end
                            end
                            tag.ability.orbital_hand = pseudorandom_element(_poker_hands, pseudoseed('rewind_orbital'))
                        end
                        G.E_MANAGER:add_event(Event({
                            trigger = 'immediate',
                            func = function()                
                                add_tag(tag)
                                tag:apply_to_run({type = 'immediate'})
                                return true
                            end
                        }))
                        return true
                end}))
                tag.triggered = true
                return true
            end
            tag:nope()
            return true
        end
    end
})

SMODS.Tag({
    key = 'minion',
    atlas = 'patches',
    pos = {x = 4, y = 0},
    discovered = false,
    config = {type = 'round_start_bonus', modifier = 0.25},
    artist_credits = {'gappie','kosze'},
    apply = function(self, tag, context)
        if context.type == self.config.type then
            if G.GAME.blind:get_type() == 'Boss' then return end
            tag:yep('+', G.C.GREEN ,function() 
                return true
            end)
            G.E_MANAGER:add_event(Event({
                delay = 0.2,
                trigger = 'after',
                func = function()
            G.GAME.blind.chips = G.GAME.blind.chips * tag.config.modifier
            G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
            return true
                end}))
            tag.triggered = true
        end
    end
})

SMODS.Tag({
    key = 'slipup',
    atlas = 'patches',
    pos = {x = 0, y = 1},
    discovered = false,
    config = {type = 'round_start_bonus', discards = 3, hands = 3},
    artist_credits = {'gappie'},
    loc_vars = function(self, info_queue, card)
        return {vars = {self.config.discards, self.config.hands}}
    end,
    apply = function(self, tag, context)
        if context.type == self.config.type then
            tag:yep('+', G.C.RED ,function() 
                return true
            end)
            ease_discard(tag.config.discards)
            ease_hands_played(tag.config.hands)
            tag.triggered = true
        end
    end
})

SMODS.Tag({
    key = 'soul',
    atlas = 'patches',
    pos = {x = 0, y = 2},
    soul_pos = {x = 1, y = 2},
    discovered = false,
    min_ante = 3,
    config = {type = 'store_joker_create'},
    artist_credits = {'kosze'},
    in_pool = function(self)
        local chance = pseudorandom('ortalab_soul_patch')
        if chance < 0.25 then
            return true
        end
        return false
    end,
    loc_vars = function(self, info_queue, card)
        return {vars = {self.config.cost}}
    end,
    apply = function(self, tag, context)
        if context.type == self.config.type then
            local card = create_card('Joker', context.area, true, 1, nil, nil, nil, 'uta')
            create_shop_card_ui(card, 'Joker', context.area)
            card.states.visible = false
            tag:yep('+', G.C.GREEN,function() 
                card:start_materialize()
                card.ability.couponed = true
                card:set_cost()
                return true
            end)
            tag.triggered = true
            return card
        end
    end
})

SMODS.Tag({
    key = 'slayer',
    atlas = 'patches',
    pos = {x = 0, y = 4},
    discovered = false,
    min_ante = 2,
    config = {type = 'immediate', dollars = 3},
    artist_credits = {'kosze'},
    loc_vars = function(self, info_queue, card)
        return {vars = {self.config.dollars, (G.GAME.blinds_defeated or 0)*self.config.dollars}}
    end,
    apply = function(self, tag, context)
        if context.type == self.config.type then
            tag:yep('+', G.C.MONEY,function() 
                G.CONTROLLER.locks[tag.ID] = nil
                return true
            end)
            ease_dollars((G.GAME.blinds_defeated or 0)*tag.config.dollars)
            tag.triggered = true
            return true
        end
    end
})

SMODS.Tag({
    key = 'dandy',
    atlas = 'patches',
    pos = {x = 3, y = 3},
    discovered = false,
    min_ante = 2,
    config = {type = 'immediate', dollars = 1},
    artist_credits = {'kosze'},
    loc_vars = function(self, info_queue, card)
        return {vars = {self.config.dollars, (G.GAME.unused_hands or 0)*self.config.dollars}}
    end,
    apply = function(self, tag, context)
        if context.type == self.config.type then
            tag:yep('+', G.C.MONEY,function() 
                return true
            end)
            ease_dollars((G.GAME.unused_hands or 0)*tag.config.dollars)
            tag.triggered = true
            return true
        end
    end
})

SMODS.Tag({
    key = 'loteria',
    atlas = 'patches',
    pos = {x = 2, y = 4},
    discovered = false,
    config = {type = 'shop_final_pass', packs = 2},
    artist_credits = {'kosze'},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS['p_ortalab_big_loteria_1']
        return {vars = {self.config.packs}}
    end,
    apply = function(self, tag, context)
        if context.type == self.config.type then
            tag:yep('+', G.C.GREEN,function()
                for i=1, tag.config.packs do
                    local pack = Card(G.shop_booster.T.x + G.shop_booster.T.w/2,
                    G.shop_booster.T.y, G.CARD_W*1.27, G.CARD_H*1.27, G.P_CARDS.empty, G.P_CENTERS['p_ortalab_big_loteria_'..i], {bypass_discovery_center = true, bypass_discovery_ui = true})
                    create_shop_card_ui(pack, 'Booster', G.shop_booster)
                    pack.ability.booster_pos = #G.shop_booster.cards + 1
                    pack.ability.couponed = true
                    pack:start_materialize()
                    G.shop_booster:emplace(pack)
                    pack:set_cost()
                end
                return true
            end)
            tag.triggered = true
        end
    end
})

SMODS.Tag({
    key = 'crater',
    atlas = 'patches',
    pos = {x = 2, y = 3},
    discovered = false,
    config = {type = 'shop_final_pass', packs = 2},
    artist_credits = {'heyyou'},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS['p_ortalab_mid_zodiac_1']
        return {vars = {self.config.packs}}
    end,
    apply = function(self, tag, context)
        if context.type == self.config.type then
            tag.triggered = true
            tag:yep('+', G.C.GREEN,function()
                for i=1, tag.config.packs do
                    local pack = Card(G.shop_booster.T.x + G.shop_booster.T.w/2,
                    G.shop_booster.T.y, G.CARD_W*1.27, G.CARD_H*1.27, G.P_CARDS.empty, G.P_CENTERS['p_ortalab_mid_zodiac_'..i], {bypass_discovery_center = true, bypass_discovery_ui = true})
                    create_shop_card_ui(pack, 'Booster', G.shop_booster)
                    pack.ability.booster_pos = #G.shop_booster.cards + 1
                    pack.ability.couponed = true
                    pack:start_materialize()
                    G.shop_booster:emplace(pack)
                    pack:set_cost()
                end
                return true
            end)
        end 
    end
})

local skip_blind = G.FUNCS.skip_blind
G.FUNCS.skip_blind = function(e)
    local _tag = e.UIBox:get_UIE_by_ID('tag_container').config.ref_table
    skip_blind(e)
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.7,
        func = function()
            if _tag.key == 'tag_ortalab_rewind' then return true end
            G.GAME.last_selected_tag = {key = _tag.key, blind_type = _tag.ability.blind_type} or G.GAME.last_selected_tag
            return true
        end
    }))
end

SMODS.Tag({
    key = 'constellation',
    atlas = 'patches',
    pos = {x = 1, y = 4},
    discovered = false,
    config = {type = 'round_start_bonus', extra = {zodiacs = 3}},
    artist_credits = {'kosze'},
    loc_vars = function(self, info_queue, card)
        if card.ability.zodiac_hands and G.ZODIACS[card.ability.zodiac_hands] then
            -- info_queue[#info_queue+1] = G.ZODIACS[card.ability.zodiac_hands]
            return {vars = {
                localize(G.ZODIACS[card.ability.zodiac_hands].config.extra.hand_type, 'poker_hands'), card.config and card.config.extra and card.config.extra.zodiacs or card.ability.extra.zodiacs
            }}
        else
            return {vars = {'['..localize('k_poker_hand')..']', card.config.extra.zodiacs}}
        end
    end,
    apply = function(self, tag, context)
        if context.type == self.config.type then
            tag:yep('+', G.C.GREEN,function()
                return true
            end)
            tag.triggered = true
            local key = tag.ability.zodiac_hands
            G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 1,
                    func = function()
                        if G.zodiacs and G.zodiacs[key] then
                            G.zodiacs[key].config.extra.temp_level = G.zodiacs[key].config.extra.temp_level + (G.ZODIACS[key].config.extra.temp_level * tag.config.extra.zodiacs)
                            zodiac_text(zodiac_upgrade_text(key), key)
                            G.zodiacs[key]:juice_up(1, 1)
                            delay(0.7)
                        else
                            add_zodiac(Zodiac(key), nil, nil, tag.config.extra.zodiacs)
                        end
                        return true
                    end
                }))
            end
    end,
    set_ability = function(self, tag)
        if not tag.ability.blind_type then tag.ability.blind_type = 'Small' end
        if G.zodiac_choices then
            tag.ability.zodiac_hands = G.zodiac_choices
        elseif tag.ability.blind_type then
            if G.GAME.zodiac_choices and G.GAME.zodiac_choices[G.GAME.round_resets.ante] and G.GAME.zodiac_choices[G.GAME.round_resets.ante][tag.ability.blind_type] then
                tag.ability.zodiac_hands = G.GAME.zodiac_choices[G.GAME.round_resets.ante][tag.ability.blind_type]
            else
                local _poker_hands = {}
                for k, _ in pairs(G.ZODIACS) do
                    if k ~= 'zodiac_ortalab_ophiuchus' then
                        _poker_hands[#_poker_hands+1] = k
                    end
                end
            
                local zodiac1 = pseudorandom_element(_poker_hands, pseudoseed('constellation_patch'))
                tag.ability.zodiac_hands = zodiac1
            end
        end
    end
})

SMODS.Tag({
    key = 'stock',
    atlas = 'patches',
    pos = {x = 3, y = 4},
    discovered = false,
    config = {type = 'immediate', vouchers = 1},
    artist_credits = {'eremel'},
    apply = function(self, tag, context)
        if context.type == tag.config.type then
            tag:yep('+', G.C.GREEN,function()
                for i=1, tag.config.vouchers do
                    local _pool = get_current_pool('Voucher')
                    local voucher = pseudorandom_element(_pool, pseudoseed('ortalab_stock_patch'))
                    local it = 1
                    while voucher == 'UNAVAILABLE' do
                        it = it + 1
                        voucher = pseudorandom_element(_pool, pseudoseed('ortalab_stock_patch_resample'..it))
                    end
                    if G.blind_select and not G.blind_select.alignment.offset.py then
                        G.blind_select.alignment.offset.py = G.blind_select.alignment.offset.y
                        G.blind_select.alignment.offset.y = G.ROOM.T.y + 39
                    end
                    G.GAME.used_vouchers[voucher] = true
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.5,
                        func = function()
                            local voucher_card = SMODS.create_card({area = G.play, key = voucher})
                            voucher_card:add_to_deck()
                            voucher_card:start_materialize()
                            voucher_card.cost = 0
                            G.play:emplace(voucher_card)
                            delay(0.8)
                            voucher_card:redeem()
                            
                            G.E_MANAGER:add_event(Event({
                                trigger = 'after',
                                delay = 0.5,
                                func = function()
                                    voucher_card:start_dissolve()              
                                    return true
                                end
                            }))
                            G.E_MANAGER:add_event(Event({
                                trigger = 'after',
                                delay = 0.5,
                                func = function()
                                    G.E_MANAGER:add_event(Event({
                                        trigger = 'after',
                                        delay = 0.5,
                                        func = function()
                                            if G.blind_select and G.blind_select.alignment.offset.py then
                                                G.blind_select.alignment.offset.y = G.blind_select.alignment.offset.py
                                                G.blind_select.alignment.offset.py = nil
                                            end                  
                                            return true
                                        end
                                    }))                 
                                    return true
                                end
                            }))
                            return true
                        end
                    }))
                end
                return true
            end)
            tag.triggered = true
            return true
        end
        
    end
})

SMODS.Tag({
    key = 'recycle',
    atlas = 'patches',
    pos = {x = 1, y = 0},
    discovered = false,
    min_ante = 2,
    config = {type = 'immediate', sell_inc = 2},
    artist_credits = {'kosze'},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.config.sell_inc, card.config.sell_inc * (G.GAME.skips + 1)}}
    end,
    apply = function(self, tag, context)
        if context.type == tag.config.type then
            tag:yep('+', G.C.MONEY,function() 
                local inc_amount = tag.config.sell_inc * G.GAME.skips
                for k=1, #G.jokers.cards + #G.consumeables.cards do
                    local _card = G.jokers.cards[k] or G.consumeables.cards[k - #G.jokers.cards]
                    if _card.config.center.set == 'Joker' then
                        _card.ability.extra_value = _card.ability.extra_value + inc_amount
                        _card:set_cost()
                    end
                end
                return true
            end)
            tag.triggered = true
            return true
        end
    end
})

SMODS.Tag({
    key = 'mythical',
    atlas = 'patches',
    pos = {x = 4, y = 3},
    discovered = false,
    min_ante = 3,
    config = {type = 'shop_final_pass', packs = 2},
    artist_credits = {'kosze'},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS['p_ortalab_big_mythos']
        return {vars = {self.config.packs}}
    end,
    apply = function(self, tag, context)
        if context.type == self.config.type then
            tag:yep('+', G.C.GREEN,function()
                for i=1, tag.config.packs do
                    local pack = Card(G.shop_booster.T.x + G.shop_booster.T.w/2,
                    G.shop_booster.T.y, G.CARD_W*1.27, G.CARD_H*1.27, G.P_CARDS.empty, G.P_CENTERS['p_ortalab_big_mythos'], {bypass_discovery_center = true, bypass_discovery_ui = true})
                    create_shop_card_ui(pack, 'Booster', G.shop_booster)
                    pack.ability.booster_pos = #G.shop_booster.cards + 1
                    pack.ability.couponed = true
                    pack:start_materialize()
                    G.shop_booster:emplace(pack)
                    pack:set_cost()
                end
                return true
            end)
            tag.triggered = true
        end 
    end
})

SMODS.Tag({
    key = 'immolate',
    atlas = 'patches',
    pos = {x = 4, y = 4},
    discovered = false,
    min_ante = 2,
    config = {type = 'immediate', cards = 5, dollars = 5},
    artist_credits = {'crimson','gappie'},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.config.cards, card.config.dollars}}
    end,
    apply = function(self, tag, context)
        if context.type == self.config.type then
            tag:yep('+', G.C.GREEN,function()
                if G.blind_select and not G.blind_select.alignment.offset.py then
                    G.blind_select.alignment.offset.py = G.blind_select.alignment.offset.y
                    G.blind_select.alignment.offset.y = G.ROOM.T.y + 39
                end
                local destroyed = {}
                local start_point = pseudorandom(pseudoseed('ortalab_immolate_patch'), 1, #G.deck.cards)
                for i=1, tag.config.cards do
                    destroyed[i] = G.deck.cards[((start_point + i) % #G.deck.cards)+1]
                    draw_card(G.deck, G.play, nil, nil, nil, destroyed[i])
                end
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.7,
                    func = function()
                        attention_text({
                            scale = 1.4, text = '+$'..tag.config.dollars, hold = 1, align = 'cm', offset = {x = 0,y = -2.7},major = G.play,backdrop_colour = G.C.MONEY
                        })
                        return true
                    end
                }))
                ease_dollars(tag.config.dollars)
                for i=1, #destroyed do
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.4,
                        func = function() 
                            local card = destroyed[i]
                            if SMODS.shatters(card) then
                                card:shatter()
                            else
                                card:start_dissolve(nil, i == #destroyed)
                        end
                        return true 
                    end }))
                end
                SMODS.calculate_context({ remove_playing_cards = true, removed = destroyed })
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.5,
                    func = function()
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.5,
                            func = function()
                                if G.blind_select and G.blind_select.alignment.offset.py then
                                    G.blind_select.alignment.offset.y = G.blind_select.alignment.offset.py
                                    G.blind_select.alignment.offset.py = nil
                                end                  
                                return true
                            end
                        }))              
                        return true
                    end
                }))
                return true
            end)
            tag.triggered = true
            return true
        end 
    end
})

SMODS.Tag({
    key = 'joker_slot',
    atlas = 'patches',
    pos = {x = 1, y = 1},
    discovered = false,
    min_ante = 2,
    config = {type = 'immediate'},
    artist_credits = {'hat','kosze'},
    apply = function(self, tag, context)
        if context.type == tag.config.type then
            if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + G.consumeables.config.card_limit - #G.consumeables.cards
                tag:yep('+', G.C.GREEN,function()
                    local to_fill = G.consumeables.config.card_limit - #G.consumeables.cards
                    local pool = get_current_pool('Joker')
                    local final_pool = {}
                    for _, v in ipairs(pool) do
                        if v ~= 'UNAVAILABLE' then
                            table.insert(final_pool, v)
                        end
                    end
                    for i=1, to_fill do
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.5,
                            func = function()
                                local key, index = pseudorandom_element(final_pool, pseudoseed('ortalab_joker_slot_patch'))
                                if key == nil then
                                    key = 'j_joker'
                                end
                                if index ~= nil then
                                    final_pool[index] = nil
                                end

                                local card = SMODS.add_card({key = key, area = G.consumeables, set='Joker'})
                                card:start_materialize() 
                                return true
                            end
                        }))
                    end
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer - to_fill
                    return true
                end)
                tag.triggered = true
                return true
            else
                return true
            end
        end
    end
})

SMODS.Tag({
    key = 'hand',
    atlas = 'patches',
    pos = {x = 2, y = 0},
    discovered = false,
    min_ante = 2,
    config = {type = 'immediate', hands = 3},
    artist_credits = {'hat','kosze'},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.c_ortalab_lot_hand
        return {vars = {card.config.hands}}
    end,
    apply = function(self, tag, context)
        if context.type == tag.config.type then
            tag:yep('+', G.C.GREEN,function()
                for i=1, tag.config.hands do
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.7,
                        func = function()
                            local card = SMODS.add_card({key = 'c_ortalab_lot_hand', area = G.consumeables, skip_materialize = true, edition = 'e_negative'})
                            card:start_materialize({G.C.SET.ortalab_loteria}) 
                            return true
                        end
                    }))
                end
                return true
            end)
            tag.triggered = true
            return true
        end 
    end
})

SMODS.Tag({
    key = '777',
    atlas = 'patches',
    pos = {x = 4, y = 1},
    discovered = false,
    min_ante = 2,
    config = {type = 'immediate', tags = 3},
    artist_credits = {'5381','kosze'},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.config.tags}}
    end,
    apply = function(self, tag, context)
        if context.type == tag.config.type then
            tag:yep('+', G.C.GREEN,function()
                if G.blind_select and not G.blind_select.alignment.offset.py then
                    G.blind_select.alignment.offset.py = G.blind_select.alignment.offset.y
                    G.blind_select.alignment.offset.y = G.ROOM.T.y + 39
                end
                local pool = get_current_pool('Tag')
                local final_pool = {}
                for _, v in ipairs(pool) do
                    if v ~= 'UNAVAILABLE' and v ~= 'tag_ortalab_777' and v~= 'tag_ortalab_rewind' then
                        table.insert(final_pool, v)
                    end
                end
                local selected = {}
                local cards = {}
                for i=1, tag.config.tags do
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 1.8,
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
                    trigger = 'after',
                    delay = 0.7,
                    func = function()
                        for i=1, tag.config.tags do
                            cards[i]:start_dissolve()
                            add_tag(Tag(selected[i]))               
                        end
                        return true
                    end
                    }))
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.5,
                    func = function()
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.5,
                            func = function()
                                if G.blind_select and G.blind_select.alignment.offset.py then
                                    G.blind_select.alignment.offset.y = G.blind_select.alignment.offset.py
                                    G.blind_select.alignment.offset.py = nil
                                end                  
                                return true
                            end
                        }))                  
                        return true
                    end
                }))
                return true
            end)
            tag.triggered = true
            return true
        end 
    end
})

SMODS.Tag({
    key = 'phantom',
    atlas = 'patches',
    pos = {x = 3, y = 1},
    discovered = false,
    min_ante = 2,
    config = {type = 'ortalab_hand_played'},
    artist_credits = {'hat','kosze'},
    apply = function(self, tag, context)
        if context.type == tag.config.type then
            tag:yep('+', G.C.GREEN ,function() 
                return true
            end)
            local cards = {}
            local _,_,_,scoring_hand,_ = G.FUNCS.get_poker_hand_info(G.play.cards)
            for i=1, #G.play.cards do
                if SMODS.in_scoring(G.play.cards[i], scoring_hand) then
                    G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                    local _card = copy_card(G.play.cards[i], nil, nil, G.playing_card)
                    _card.states.visible = nil
                    table.insert(cards, _card)
                    table.insert(G.playing_cards, _card)
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.5,
                        func = function()                
                            G.play.cards[i]:juice_up()
                            G.deck:emplace(_card)
                            G.deck.config.card_limit = G.deck.config.card_limit + 1
                            _card:add_to_deck()
                            _card:start_materialize({G.C.SET.ortalab_mythos})
                            return true
                        end
                    }))
                end
            end
            playing_card_joker_effects(cards)
            tag.triggered = true
        end
    end
})

SMODS.Tag({
    key = 'singularity',
    atlas = 'patches',
    pos = {x = 2, y = 1},
    discovered = false,
    min_ante = 2,
    config = {type = 'ortalab_first_hand'},
    artist_credits = {'eremel'},
    apply = function(self, tag, context)
        if context.type == tag.config.type then
            tag:yep('+', G.C.GREEN ,function() 
                return true
            end)
            local new_rank = Ortalab.rank_from_deck()
            for i=1, #G.hand.cards do
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.2,
                    func = function()
                        G.hand.cards[i]:flip()   
                        SMODS.change_base(G.hand.cards[i], nil, new_rank)             
                        return true
                    end
                }))
            end
            for i=1, #G.hand.cards do
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.4,
                    func = function()
                        G.hand.cards[i]:juice_up()                
                        return true
                    end
                }))
            end
            for i=1, #G.hand.cards do
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.2,
                    func = function()
                        G.hand.cards[i]:flip()                
                        return true
                    end
                }))
            end
            tag.triggered = true
        end
    end
})

SMODS.Tag({
    key = 'resonance',
    atlas = 'patches',
    pos = {x = 3, y = 0},
    discovered = false,
    config = {type = 'press_play', xmult_change = 0.1},
    artist_credits = {'eremel'},
    loc_vars = function(self, info_queue, card)
        return {vars = {self.config.xmult_change}}
    end,
    apply = function(self, tag, context)
        if context.type == self.config.type then
            tag:yep('+', G.C.GREEN,function()
                local _,_,_,scoring_hand,_ = G.FUNCS.get_poker_hand_info(G.play.cards)
                for _, card in ipairs(G.play.cards) do
                    if SMODS.in_scoring(card, scoring_hand) then
                        card.ability.perma_x_mult = card.ability.perma_x_mult + tag.config.xmult_change
                        SMODS.calculate_effect({message = '+X'..tag.config.xmult_change, colour = G.C.RED}, card)
                    end
                end
                return true
            end)
            tag.triggered = true
        end 
    end
})

local ortalab_press_play = Blind.press_play
function Blind:press_play()
	local ret = ortalab_press_play(self)
    for i = 1, #G.GAME.tags do
        G.GAME.tags[i]:apply_to_run({type = 'press_play'})
    end
	return ret
end