-- This file contains util functions that are used throughout the mod

--- Returns whether a table contains a specific value
function table.contains(table, element)
	for _, value in pairs(table) do
		if value == element then
			return true
		end
	end
	return false
end

-- Returns the size of any table
function table.size(table)
    local size = 0
    for _,_ in pairs(table) do
        size = size + 1
    end
    return size
end

-- Find a single rank that is contained within the current deck
function Ortalab.rank_from_deck(seed)
	local ranks = {}
	local seed = seed or 'ortalab_rank_from_deck'
	for _, card in pairs(G.playing_cards) do
		ranks[card.base.value] = card.base.value
	end
	return pseudorandom_element(ranks, pseudoseed(seed))
end

-- Find a single suit that is contained within the current deck
function Ortalab.suit_from_deck(seed)
	local ranks = {}
	local seed = seed or 'ortalab_rank_from_deck'
	for _, card in pairs(G.playing_cards) do
		ranks[card.base.suit] = card.base.suit
	end
	return pseudorandom_element(ranks, pseudoseed(seed))
end

-- Counts the ranks in the deck and returns an ordered table
function Ortalab.count_ranks()
    -- Count suits
    local ranks = {}
    for _, pcard in ipairs(G.playing_cards) do
        if not SMODS.has_no_rank(pcard) then ranks[pcard.base.value] = (ranks[pcard.base.value] or 0) + 1 end
    end
    local ranks_by_count = {}
    for rank, count in pairs(ranks) do
        table.insert(ranks_by_count, {rank = rank, count = count})
    end
    table.sort(ranks_by_count, function(a, b) return a.count > b.count end)
    return ranks_by_count
end

-- Counts the suits in the deck and returns an ordered table
function Ortalab.count_suits()
    -- Count suits
    local suits = {}
    for _, pcard in ipairs(G.playing_cards) do
        if not SMODS.has_no_suit(pcard) then suits[pcard.base.suit] = (suits[pcard.base.suit] or 0) + 1 end
    end
    local suits_by_count = {}
    for suit, count in pairs(suits) do
        table.insert(suits_by_count, {suit = suit, count = count})
    end
    table.sort(suits_by_count, function(a, b) return a.count > b.count end)
    return suits_by_count
end

-- Count the number of cursed cards currently in the deck
function Ortalab.curses_in_deck()
    local count = 0
    for _, card in pairs(G.playing_cards) do
        if card.curse then count = count + 1 end
    end
    return count
end

-- Check whether a table of cards contains a certain
function Ortalab.hand_contains_rank(hand, rank)
    for _, card in ipairs(hand) do
        if card.base.value == rank then return true end
    end
end

-- Initialise the game object and all necessary values for Ortalab
local igo = Game.init_game_object
function Game:init_game_object()
    local ret = igo(self)
    ret.blind_badge = {
        name = 'temp'
    }
    ret.ortalab = {
        hand_size = 0,
        extra_discard_size = 0,
        blind_rewards = 0,
        alt_boss = nil,
        ranks_in_deck = nil,
        suits_in_deck = nil,
        vouchers = {
            reroll_on_skip = false,
            double_boss = false,
            horoscope = 0,
            cantor = 0,
            tabla = 0,
            leap_year = nil,
            tags_in_shop = 0,
            mythos_shop_slot = false,
            booster_pack_bonus = 0
        },
        zodiacs = {
            reduction = 4,
            temp_level_mod = 1,
            activated = {}
        },
        temp_levels = 0,
        mythos = {
            extra_select = 0,
            tree_of_life_count = 0,
            ya_te_veo_count = 0,
            jackalope_count = 0,
            talaria_count = 0
        },
        secret_hand_list = {}
    }
    for k, v in pairs(ret.hands) do
        if v.visible == false then ret.ortalab.secret_hand_list[k] = k end
    end
    -- Modify default rates
    ret.planet_rate = 2
    ret.tarot_rate = 2
    ret.current_round.current_hand.temporary_level = ''
	return ret
end

-- Function called at the end of each round
function Ortalab.reset_game_globals(first_pass)
    if first_pass then
		G.GAME.current_round["spectral_type_sold"] = {}
		G.GAME.current_round["ortalab_free_rerolls"] = 0
        return
	end
    -- Decay zodiacs
    if G.GAME.ortalab.round_decay then
        local zodiac_joker = SMODS.find_card('j_ortalab_prediction_dice')
        for _, joker_card in pairs(zodiac_joker) do        
            if SMODS.pseudorandom_probability(joker_card, 'zodiac_no_decay', 1, joker_card.ability.extra.chance) then
                SMODS.calculate_effect({message = localize('ortalab_zodiac_no_decay')}, joker_card)
                return
            end
        end
        for _, zodiac in pairs(G.zodiacs) do
            zodiac.config.extra.temp_level = math.max(0, zodiac.config.extra.temp_level - G.GAME.ortalab.round_decay)
            if zodiac.config.extra.temp_level <= 0 then
                zodiac:remove_zodiac('')
            else
                G.E_MANAGER:add_event(Event({
                    delay = 0.4,
                    trigger = 'after',
                    func = (function()
                        attention_text({
                            text = '-'..G.GAME.ortalab.round_decay,
                            colour = G.C.WHITE,
                            scale = 1, 
                            hold = 1/G.SETTINGS.GAMESPEED,
                            cover = zodiac.HUD_zodiac,
                            cover_colour = G.ARGS.LOC_COLOURS.Zodiac,
                            align = 'cm',
                            })
                        play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
                        play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
                        return true
                    end)
                }))
            end
        end
    end

    -- Reset handsize
    if G.GAME.ortalab.hand_size then
        G.hand:change_size(G.GAME.ortalab.hand_size)
        G.GAME.ortalab.hand_size = 0
    end
end

-- Function modify the amount of joker slots with an animation
function modify_joker_slot_count(amount)
    G.CONTROLLER.locks.no_space = true
    G.jokers.config.card_limit = G.jokers.config.card_limit + amount
    attention_text({scale = 0.9, text = (amount>0 and '+' or '') .. amount .. localize((amount > 1 or amount < -1) and 'ortalab_joker_slots' or 'ortalab_joker_slot'), hold = 0.9, align = 'cm',
        cover = G.jokers, cover_padding = 0.1, cover_colour = adjust_alpha(G.C.BLACK, 0.2)})

    for i = 1, #G.jokers.cards do
        G.jokers.cards[i]:juice_up(0.15)
    end
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.06*G.SETTINGS.GAMESPEED,
        blockable = false,
        blocking = false,
        func = function() play_sound('tarot2', 0.76, 0.4); return true end
    }))

    play_sound('tarot2', 1, 0.4)

    G.E_MANAGER:add_event(Event({
        trigger = 'after', 
        delay = 0.5*G.SETTINGS.GAMESPEED, 
        blockable = false, 
        blocking = false,
        func = function() G.CONTROLLER.locks.no_space = nil; return true end
    }))
end

-- Talisman compat jank
to_big = to_big or function(x, y)
    return x
end

-- Check whether a card is a numbered card
function Card:is_numbered(from_boss)
    if self.debuff and not from_boss then return end
    local id = self:get_id()
    local rank = SMODS.Ranks[self.base.value]
    if not id then return end
    if (id > 0 and rank and not rank.face) then
        return true
    end
end

-- Get a new small blind
function get_new_small(current)
    if G.GAME.ortalab.finisher_ante and G.GAME.round_resets.ante == G.GAME.win_ante then
        return get_new_boss()
    end
    G.GAME.perscribed_small = G.GAME.perscribed_small or {
    }
    if G.GAME.perscribed_small and G.GAME.perscribed_small[G.GAME.round_resets.ante] then 
        local ret_boss = G.GAME.perscribed_small[G.GAME.round_resets.ante] 
        G.GAME.perscribed_small[G.GAME.round_resets.ante] = nil
        return ret_boss
    end
    if G.FORCE_SMALL then return G.FORCE_SMALL end

    local eligible_bosses = {bl_small = true}
    for k, v in pairs(G.P_BLINDS) do
        if not v.small then
            -- don't add
        elseif k == current then
            -- don't add
        elseif v.in_pool and type(v.in_pool) == 'function' then
            local res, options = v:in_pool()
            eligible_bosses[k] = res and true or nil
        elseif v.small.min <= math.max(1, G.GAME.round_resets.ante) then
            eligible_bosses[k] = true
        end
    end
    for k, v in pairs(G.GAME.banned_keys) do
        if eligible_bosses[k] then eligible_bosses[k] = nil end
    end

    if G.GAME.modifiers.ortalab_only then
        for k, v in pairs(eligible_bosses) do
            if v and not G.P_BLINDS[k].mod or G.P_BLINDS[k].mod.id ~= 'ortalab' then
                eligible_bosses[k] = nil
            end
        end
    end

    local _, boss = pseudorandom_element(eligible_bosses, pseudoseed('boss'))
    
    return boss
end

-- Get a new big blind
function get_new_big(current)
    if G.GAME.ortalab.finisher_ante and G.GAME.round_resets.ante == G.GAME.win_ante then
        return get_new_boss()
    end
    G.GAME.perscribed_big = G.GAME.perscribed_big or {
    }
    if G.GAME.perscribed_big and G.GAME.perscribed_big[G.GAME.round_resets.ante] then 
        local ret_boss = G.GAME.perscribed_big[G.GAME.round_resets.ante] 
        G.GAME.perscribed_big[G.GAME.round_resets.ante] = nil
        return ret_boss
    end
    if G.FORCE_BIG then return G.FORCE_BIG end

    local eligible_bosses = {bl_big = true}
    for k, v in pairs(G.P_BLINDS) do
        if not v.big then
            -- don't add
        elseif k == current then
            -- don't add
        elseif v.in_pool and type(v.in_pool) == 'function' then
            local res, options = v:in_pool()
            eligible_bosses[k] = res and true or nil
        elseif v.big.min <= math.max(1, G.GAME.round_resets.ante) then
            eligible_bosses[k] = true
        end
    end
    for k, v in pairs(G.GAME.banned_keys) do
        if eligible_bosses[k] then eligible_bosses[k] = nil end
    end

    if G.GAME.modifiers.ortalab_only then
        for k, v in pairs(eligible_bosses) do
            if v and not G.P_BLINDS[k].mod or G.P_BLINDS[k].mod.id ~= 'ortalab' then
                eligible_bosses[k] = nil
            end
        end
    end

    local _, boss = pseudorandom_element(eligible_bosses, pseudoseed('boss'))
    
    return boss
end

-- Hook to allow cards that become no rank to score properly
local chip_bonus = Card.get_chip_bonus
function Card:get_chip_bonus()
    if self.becoming_no_rank then return self.ability.bonus + (self.ability.perma_bonus or 0) end
    return chip_bonus(self)
end

-- Util function to allow cards to change suit for calculations but animation properly
function Ortalab.change_suit_no_anim(card, suit)
    local change = suit and card.base.suit ~= suit
    SMODS.calculate_context({change_suit = true, other_card = card, new_suit = suit, old_suit = card.base.suit})
    card.base.suit = suit
end

local ortalab_generate_card_ui = generate_card_ui
function generate_card_ui(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card)
    local ui = ortalab_generate_card_ui(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card)
    if _c.set == 'ortalab_mythos' and (not card.area.config.collection or _c.discovered) and card.ability.extra.method then 
        local colour = Ortalab.Curses[card.ability.extra.curse] and Ortalab.Curses[card.ability.extra.curse].badge_colour or G.ARGS.LOC_COLOURS.ortalab_mythos
        local mythos_nodes = {background_colour = lighten(colour, 0.75)}
        local vars = {
            card.ability.extra.select + G.GAME.ortalab.mythos.extra_select,
            localize({type = 'name_text', set = 'Curse', key = card.ability.extra.curse}),
            colours = {colour}
        }
        if _c.key == 'c_ortalab_jackalope' then
            vars[1] = vars[1] + G.GAME.ortalab.mythos.jackalope_count
        elseif _c.key == 'c_ortalab_ya_te_veo' then
            vars[3] = vars[1] + card.ability.extra.deck
        elseif _c.key == 'c_ortalab_talaria' then
            vars[1] = vars[1] + G.GAME.ortalab.mythos.talaria_count
        end
        localize{type = 'descriptions', set = _c.set, key = card.ability.extra.method, nodes = mythos_nodes, vars = vars}
        ui.mythos = mythos_nodes
    end
    if ((_c.set == 'ortalab_zodiac' or _c.key == 'c_ortalab_ophiuchus') and (not card.area.config.collection or _c.discovered)) or (_c.set == 'Tag' and G.ZODIACS[_c.key]) then
        local key = _c.set == 'Tag' and _c.key or card.ability.extra.zodiac
        local mythos_nodes = {background_colour = lighten(G.ARGS.LOC_COLOURS.ortalab_zodiac, 0.75)}
        local vars = specific_vars or G.ZODIACS[card.ability.extra.zodiac]:loc_vars({}).vars
        localize{type = 'descriptions', set = 'Tag', key = 'zodiac_heading', nodes = mythos_nodes, vars = vars}
        localize{type = 'descriptions', set = 'Tag', key = key, nodes = mythos_nodes, vars = vars}
        localize{type = 'descriptions', set = 'Tag', key = 'zodiac_loss', nodes = mythos_nodes, vars = {G.GAME.ortalab.zodiacs.reduction}}
        ui[_c.set == 'Tag' and 'main' or 'mythos'] = mythos_nodes
    end
    if _c.key == 'c_ortalab_corpus' and card.area == G.consumeables then
        local mythos_nodes = {background_colour = lighten(G.ARGS.LOC_COLOURS.ortalab_mythos, 0.75)}
        for curse, sacrificed in pairs(card.ability.extra.sacrificed) do
            local curse_name = localize({type = 'name_text', set = 'Curse', key = curse})
            local text_colour =  sacrificed and Ortalab.Curses[curse] and Ortalab.Curses[curse].badge_colour or G.ARGS.LOC_COLOURS.inactive
            localize{type = 'descriptions', set = 'ortalab_mythos', key = 'corpus_curse', nodes = mythos_nodes, vars = {curse_name, colours = {text_colour}}}
        end
        ui.mythos = mythos_nodes
    end
    return ui
end

function Ortalab.context(context, blockers)
    for _, k in ipairs(blockers or {}) do if context[k] then return end end
    local str = ''
    for k, v in pairs(context) do
        str = str .. k .. '/'
    end
    print(str)
end

function Ortalab.suit_smear(card, flush_calc)
    if not flush_calc and (next(SMODS.find_card('j_ortalab_monochrome')) or G.GAME.selected_back.effect.center.key == 'b_ortalab_prismatic' or SMODS.has_enhancement(card, 'm_wild')) then
        return true
    end
    return false
end

Ortalab.Pool_Utils = {}
function Ortalab.Pool_Utils.get_consumeable_type()
    local types = {
        {key = 'ortalab_loteria', weight = G.GAME.ortalab_loteria_rate or 0},
        {key = 'ortalab_zodiac', weight = G.GAME.ortalab_zodiac_rate or 0},
        {key = 'ortalab_mythos', weight = G.GAME.ortalab_mythos_rate or 0}
    }
    local total = 0
    for _, type in ipairs(types) do total = total + type.weight end
    local poll = pseudorandom('ortalab_only_new_type')
    local weight = 0
    for _, type in ipairs(types) do
        weight = weight + type.weight
        if weight/total >= poll then
            return type.key
        end
    end
end

function Ortalab.Pool_Utils.get_consumeable_key(type)
    local pool = get_current_pool(type)
    local key = pseudorandom_element(pool, 'ortalab_only_new_key')
    while key == 'UNAVAILABLE' do
        key = pseudorandom_element(pool, 'ortalab_only_new_key_resample')
    end
    return key
end

function Ortalab.modify_temp_levels(mod, text)
    local current = G.GAME.ortalab.temp_levels
    G.GAME.ortalab.temp_levels = G.GAME.ortalab.temp_levels + mod
    for i=1, math.abs(mod) do
        current = current+(mod/math.abs(mod))
        if current >= 0 then
            mult = mod_mult(math.max(1, mult+((mod/math.abs(mod)) * G.GAME.hands[text].l_mult)))
            hand_chips = mod_chips(math.max(0, hand_chips+((mod/math.abs(mod)) * G.GAME.hands[text].l_chips)))
        end
        update_hand_text({delay = 0.3}, {mult = mult, chips = hand_chips, temp_level = current, temp_colour = G.hand_text_area.temporary_level.config.colour})
    end
end

function Ortalab.check_force_highlight()
    for _, card in ipairs(G.hand.cards) do
        if card.ability.forced_selection then
            G.hand:add_to_highlighted(card)
        end
    end
end

function Ortalab:calculate(context)
    -- Remove Croupier slots
    if context.croupier_reroll or context.ending_shop then
        if Ortalab.croupier_sold then
            change_shop_size(-Ortalab.croupier_sold)
            Ortalab.croupier_sold = nil
        end
    end
    if context.ante_change and context.ante_end then
        G.GAME.ortalab.suits_in_deck = Ortalab.count_suits()
        G.GAME.ortalab.ranks_in_deck = Ortalab.count_ranks()
        -- Kopi remove cards
        for _, joker in ipairs(G.jokers.cards) do
            if joker.ability.kopi then
                SMODS.destroy_cards(joker)
                G.jokers.config.card_limit = G.jokers.config.card_limit - 1
            end
        end
    end
    -- Remove cards from polydactyly/statue triggers
    if context.after then
        Ortalab.polydactyly.cards = {}
    end
end

function Ortalab.consumables_in_area(area)
    local output = {}
    for _, card in ipairs(area.cards) do
        if card.config.center.consumeable then
            output[#output + 1] = card
        end
    end
    return output
end

Ortalab.description_loc_vars = function()
    return {text_colour = G.C.WHITE, background_colour = G.C.L_BLACK, scale = 1.2}
end

Ortalab.custom_ui = function(modNodes)
    table.remove(modNodes, 1)
    modNodes[#modNodes].config.padding = 0.2
    modNodes[#modNodes].config.outline = 1
    modNodes[#modNodes].config.outline_colour = Ortalab.badge_colour
    local credit_nodes = {}
    localize({set = 'Ortalab_Utility', key = 'ortalab_credit', type = 'descriptions', nodes = credit_nodes, scale = 1.2, text_colour = G.C.WHITE})
    credit_nodes = desc_from_rows(credit_nodes)
    credit_nodes.config.colour = G.C.L_BLACK
    credit_nodes.config.emboss = nil
    modNodes[#modNodes+1] = {n=G.UIT.R, config = {align = 'cm', outline_colour = Ortalab.badge_colour, colour = G.C.L_BLACK, outline = 1, r = 0.1, padding = 0.2}, nodes = {
        credit_nodes
    }}
    return modNodes
end