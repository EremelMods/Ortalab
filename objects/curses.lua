SMODS.Atlas({
    key = 'curses',
    path = 'curses.png',
    px = 71,
    py = 95
})

Ortalab.Curses = {}
Ortalab.curse_sprites = {}
G.P_CENTER_POOLS.Curse = {}
Ortalab.Curse = SMODS.GameObject:extend {
    obj_table = Ortalab.Curses,
    obj_buffer = {},
    badge_to_key = {},
    set = 'Curse',
    atlas = 'curses',
    pos = { x = 0, y = 0 },
    discovered = false,
    badge_colour = HEX('FFFFFF'),
    required_params = {
        'key',
        'pos',
    },
    inject = function(self)
        Ortalab.Curses[self.key] = self
        Ortalab.curse_sprites[self.key] = Sprite(0, 0, G.CARD_W, G.CARD_H, G.ASSET_ATLAS[self.atlas] or G.ASSET_ATLAS['ortalab_curses'], self.pos)
        self.badge_to_key[self.key:lower()] = self.key
        if not G.P_CENTER_POOLS.Curse then G.P_CENTER_POOLS.Curse = {} end
        SMODS.insert_pool(G.P_CENTER_POOLS[self.set], self)
    end,
    process_loc_text = function(self)
        SMODS.process_loc_text(G.localization.descriptions.Curse, self.key:lower(), self.loc_txt)
        SMODS.process_loc_text(G.localization.misc.labels, self.key:lower(), self.loc_txt, 'label')
    end,
    get_obj = function(self, key) return Ortalab.Curses[key] end,    
}

SMODS.DrawStep {
    key = 'curse',
    order = 35,
    func = function(self)
        if self.curse then
            if self.curse == 'ortalab_infected' and ((self.area == G.play or self.config.center.set == 'Joker') and self.ability.no_score_shader and not self.cured) then
                self.children.center:draw_shader('ortalab_celadon', nil, self.ARGS.send_to_shader)
                if self.children.front then
                    self.children.front:draw_shader('ortalab_celadon', nil, self.ARGS.send_to_shader)
                end
            end
            Ortalab.curse_sprites[self.curse].role.draw_major = self
            Ortalab.curse_sprites[self.curse]:draw_shader('dissolve',0, nil, nil, self.children.center,nil,nil,nil, nil,nil, 0.6)
            Ortalab.curse_sprites[self.curse]:draw_shader('dissolve', nil, nil, nil, self.children.center)
        end
    end,
    conditions = { vortex = false, facing = 'front' },
}

SMODS.current_mod.custom_collection_tabs = function()
	return {
		UIBox_button({button = 'your_collection_curses', label = {localize('ortalab_curses')}, count = G.ACTIVE_MOD_UI and modsCollectionTally(Ortalab.Curses) or G.DISCOVER_TALLIES.Curse, minw = 5, minh = 1, id = 'your_collection_curses', focus_args = {snap_to = true}})
	}
end

G.FUNCS.your_collection_curses = function(e)
	G.SETTINGS.paused = true
	G.FUNCS.overlay_menu{
		definition = create_UIBox_your_collection_curses(),
	}
end

function create_UIBox_your_collection_curses(exit)
	local deck_tables = {}
	local curse_pool = SMODS.collection_pool(G.P_CENTER_POOLS.Curse)
	local rows, cols = (#curse_pool > 4 and 2 or 1), 4
	local page = 0

	G.your_collection = {}
	for j = 1, rows do
		G.your_collection[j] = CardArea(G.ROOM.T.x + 0.2 * G.ROOM.T.w / 2, G.ROOM.T.h, 5.3 * G.CARD_W, 1.03 * G.CARD_H,
			{card_limit = cols, type = 'title', highlight_limit = 0, collection = true})
		table.insert(deck_tables, {n = G.UIT.R, config = {align = "cm", padding = 0, no_fill = true}, nodes = {{n = G.UIT.O, config = {object = G.your_collection[j]}}}})
	end

	table.sort(curse_pool, function(a, b) return a.order < b.order end)

	local count = math.min(cols * rows, #curse_pool)
	local index = 1 + (rows * cols * page)
	for j = 1, rows do
		for i = 1, cols do
			local curse = curse_pool[index]

			if not curse then break end
			local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w / 2, G.your_collection[j].T.y, G.CARD_W, G.CARD_H, G.P_CARDS.S_A, G.P_CENTERS.c_base)
			card:set_curse(curse.key, true, true)
			G.your_collection[j]:emplace(card)
			index = index + 1
		end
		if index > count then break end
	end

	local curse_page_options = {}

	local t = create_UIBox_generic_options({
		back_func = G.ACTIVE_MOD_UI and "openModUI_"..G.ACTIVE_MOD_UI.id or exit or 'your_collection',
		snap_back = true,
		contents = { 
			{n = G.UIT.R, config = {align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes = deck_tables}}
	})

	if #curse_pool > rows * cols then
		for i = 1, math.ceil(#curse_pool / (rows * cols)) do
			table.insert(curse_page_options, localize('k_page') .. ' ' .. tostring(i) .. '/' ..
				tostring(math.ceil(#curse_pool / (rows * cols))))
		end
		t = create_UIBox_generic_options({
			back_func = G.ACTIVE_MOD_UI and "openModUI_"..G.ACTIVE_MOD_UI.id or exit or 'your_collection',
			snap_back = true,
			contents = {
				{n = G.UIT.R, config = {align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes = deck_tables},
				{n = G.UIT.R, config = {align = "cm"}, nodes = { 
					create_option_cycle({options = curse_page_options, w = 4.5, cycle_shoulders = true, opt_callback = 'your_collection_curse_page',
						focus_args = { snap_to = true, nav = 'wide' }, current_option = 1, r = rows, c = cols, colour = G.C.RED, no_pips = true})
                }}
			}
		})
	end
	return t
end

G.FUNCS.your_collection_curse_page = function(args)
	if not args or not args.cycle_config then return end
	local curse_pool = SMODS.collection_pool(G.P_CENTER_POOLS.Curse)
	local rows, cols = (#curse_pool > 4 and 2 or 1), 4
	local page = args.cycle_config.current_option
	if page > math.ceil(#curse_pool / (rows * cols)) then
		page = page - math.ceil(#curse_pool / (rows * cols))
	end
	local count = rows * cols
	local offset = (rows * cols) * (page - 1)

	for j = 1, #G.your_collection do
		for i = #G.your_collection[j].cards, 1, -1 do
			if G.your_collection[j] ~= nil then
				local c = G.your_collection[j]:remove_card(G.your_collection[j].cards[i])
				c:remove()
				c = nil
			end
		end
	end

	for j = 1, rows do
		for i = 1, cols do
			if count % rows > 0 and i <= count % rows and j == cols then
				offset = offset - 1
				break
			end
			local idx = i + (j - 1) * cols + offset
			if idx > #curse_pool then return end
			local curse = curse_pool[idx]
			local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w / 2, G.your_collection[j].T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, G.P_CENTERS.c_base)
			card:set_curse(curse.key, true)
			G.your_collection[j]:emplace(card)
		end
	end
end

function Card:set_curse(_curse, silent, immediate, spread, message, delay)
    if self.ability.forced_selection == 'ortalab_possessed' then self.ability.forced_selection = nil end
    if not self.states.drag.can then self.states.drag.can = true end
    if _curse then
        self.ability.curse = {}
        for k, v in pairs(Ortalab.Curses[_curse].config or {}) do
            if type(v) == 'table' then
                self.ability.curse[k] = copy_table(v)
            else
                self.ability.curse[k] = v
            end
        end
        if Ortalab.Curses[_curse].set_ability then
            Ortalab.Curses[_curse]:set_ability(self)
        end

        G.CONTROLLER.locks.seal = true
        local sound = Ortalab.Curses[_curse].sound or {sound = 'gold_seal', per = 1.2, vol = 0.4}
        if immediate then 
            self.curse = nil
            self:juice_up(0.3, 0.3)
            if not silent then play_sound(sound.sound, sound.per, sound.vol) end
            if not silent then card_eval_status_text(self, 'extra', nil, nil, nil, {instant = true, message = message or localize({type = 'name_text', set = 'Curse', key = _curse})..'!', colour = Ortalab.Curses[_curse].badge_colour}) end
            self.curse = _curse
            G.CONTROLLER.locks.seal = false
        else
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.3,
                func = function()
                    self.curse = nil
                    self:juice_up(0.3, 0.3)
                    self.curse = _curse
                    if not silent then
                        play_sound(sound.sound, sound.per, sound.vol)
                        card_eval_status_text(self, 'extra', nil, nil, nil, {instant = true, message = message or localize({type = 'name_text', set = 'Curse', key = _curse})..'!', colour = Ortalab.Curses[_curse].badge_colour})
                    end
                return true
                end
            }))
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.CONTROLLER.locks.seal = false
                return true
                end
            }))
        end
    else
        if delay then
            self.curse_removed = true
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                    self.curse = nil   
                    self.curse_removed = nil    
                    return true
                end
            }))
        else
            self.curse = nil
        end
    end
   
    self:set_cost()
end

function Card:calculate_curse(context)
    if self.debuff or self.cured then return nil end
    local obj = Ortalab.Curses[self.curse] or {}
    if obj.calculate and type(obj.calculate) == 'function' then
    	local o = obj:calculate(self, context)
    	if o then return o end
    end
end

Ortalab.Curse({
    key = 'corroded',
    atlas = 'curses',
    pos = {x = 0, y = 0},
    badge_colour = HEX('dc2e33'),
    config = {extra = {base = 3, gain = 1}},
    artist_credits = {'gappie'},
    loc_vars = function(self, info_queue, card)
        if card and card.config.center.set == 'Joker' then 
            return {vars = {card.ability.curse.extra.gain}, key = 'ortalab_corroded_joker'}
        else
            return {vars = {card.ability.curse.extra.base, card.ability.curse.extra.gain}}
        end
    end,
    calculate = function(self, card, context)
        if context.discard and context.other_card == card then
            card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize({type = 'name_text', set = 'Curse', key = self.key})..'!', colour = self.badge_colour})
            card.ability.curse.extra.base = card.ability.curse.extra.base + card.ability.curse.extra.gain
            card.corroded_discard = true
        end
        if context.cardarea == G.play and context.main_scoring and not context.repetition and not context.individual then
            return {
                p_dollars = -card.ability.curse.extra.base,
            }
        end
        if context.after and card.ability.set == 'Joker' then
            card.ability.extra_value = card.ability.extra_value - card.ability.curse.extra.gain
            card:set_cost()
            return {
                message = '-$'..card.ability.curse.extra.gain,
                colour = G.C.GOLD,
                message_card = card
            }
        end
    end
})

G.ARGS.LOC_COLOURS.possessed = HEX('82b4f4')

Ortalab.Curse({
    key = 'possessed',
    atlas = 'curses',
    pos = {x = 1, y = 0},
    badge_colour = HEX('82b4f4'),
    artist_credits = {'gappie'},
    config = {extra = {force = true}},
    loc_vars = function(self, info_queue, card)
        if card and card.config.center.set == 'Joker' then 
            return {key = 'ortalab_possessed_joker'}
        end
    end,
    set_ability = function(self, card)
        if card.config.center.set == 'Joker' then
            card.states.drag.can = false
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.7,
                func = function()
                    local in_use = {}
                    for _, joker in pairs(G.jokers.cards) do
                        if joker.ability.curse and joker.ability.curse.extra.possessed then
                            in_use[joker.ability.curse.extra.possessed] = true
                        end
                    end
                    if #G.jokers.cards == 1 then in_use[1] = false end
                    local position = pseudorandom(pseudoseed('possessed_joker'), 1, #G.jokers.cards)
                    while in_use[position] do
                        position = pseudorandom(pseudoseed('possessed_joker_reroll'), 1, #G.jokers.cards)
                    end
                    card.ability.curse.extra.possessed = position
                    return true
                end
            }))
        end
    end,
    calculate = function(self, card, context)
        if context.after and card.config.center.set == 'Joker' then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.7,
                func = function()                
                    local in_use = {}
                    for _, joker in pairs(G.jokers.cards) do
                        if joker.ability.curse and joker.ability.curse.extra.possessed then
                            in_use[joker.ability.curse.extra.possessed] = true
                        end
                    end
                    if #G.jokers.cards == 1 then in_use[1] = false end
                    local position = pseudorandom(pseudoseed('possessed_joker'), 1, #G.jokers.cards)
                    while in_use[position] do
                        position = pseudorandom(pseudoseed('possessed_joker_reroll'), 1, #G.jokers.cards)
                    end
                    card.ability.curse.extra.possessed = position
                    card.states.drag.can = false
                    return true
                end
            }))
            return {
                message = localize({type = 'name_text', set = 'Curse', key = self.key})..'!',
                colour = self.badge_colour
            }
        end 
    end
})

Ortalab.Curse({
    key = 'restrained',
    atlas = 'curses',
    pos = {x = 2, y = 0},
    badge_colour = HEX('d78532'),
    config = {extra = {level_loss = 2}},
    artist_credits = {'gappie'},
    loc_vars = function(self, info_queue, card)
        if card and card.config.center.set == 'Joker' then 
            return {vars = {card.ability.curse.extra.level_loss}, key = 'ortalab_restrained_joker'}
        else
            return {vars = {card.ability.curse.extra.level_loss}}
        end
    end,
    calculate = function(self, card, context)
        if context.before and (context.cardarea == G.hand or card.ability.set == 'Joker') then
            Ortalab.modify_temp_levels(-card.ability.curse.extra.level_loss, context.scoring_name)
            return {
                message = localize({type = 'name_text', set = 'Curse', key = self.key})..'!',
                colour = self.badge_colour,
            }
        end
    end
})


G.ARGS.LOC_COLOURS.infected = HEX('849a3f')

SMODS.Sound({
    key = 'infected',
    path = 'infected.ogg'
})

Ortalab.Curse({
    key = 'infected',
    atlas = 'curses',
    pos = {x = 3, y = 0},
    badge_colour = HEX('849a3f'),
    sound = {sound = 'ortalab_infected', per = 1.2, vol = 0.4},
    config = {extra = {denom = 3}},
    artist_credits = {'flare'},
    loc_vars = function(self, info_queue, card)
        if card and card.config.center.set == 'Joker' then 
            return {vars = {SMODS.get_probability_vars(card, 1, card.ability.curse.extra.denom)}, key = 'ortalab_infected_joker'}
        end
    end,
    calculate = function(self, card, context)
        if context.final_scoring_step and card.ability.set == 'Joker' and card.ability.no_score then
            G.E_MANAGER:add_event(Event({func = function()
                card.ability.no_score = false
                card.ability.no_score_shader = false
                card:juice_up()
                return true
            end}))
        end
        if context.discard and context.other_card == card then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    G.E_MANAGER:add_event(Event({func = function()
                        local uncursed_hand_cards = {}
                        for _, card in ipairs(G.hand.cards) do
                            if not card.ability.curse then uncursed_hand_cards[#uncursed_hand_cards + 1] = card end
                        end
                        if #uncursed_hand_cards == 0 then return true end
                        local card_to_spread = pseudorandom_element(uncursed_hand_cards, pseudoseed('ortalab_infected_spread'))
                        card_to_spread:set_curse('ortalab_infected', nil, nil, true)
                        card:set_curse()
                        return true
                    end}))
                    return true
                end
            }))
        end
        if context.press_play and card.ability.set == 'Joker' then
            if SMODS.pseudorandom_probability(card, 'infected_joker_chance', 1, card.ability.curse.extra.denom) then
                G.E_MANAGER:add_event(Event({func = function()
                    card.ability.no_score_shader = true
                    return true
                end}))
                return {
                    message = localize({set = 'Curse', type = 'name_text', key = 'ortalab_infected'})..'!',
                    colour = Ortalab.Curses.ortalab_infected.badge_colour,
                    func = function()
                        card.ability.no_score = true
                        return true
                    end
                }
            else
                return {
                    message = localize('ortalab_infected_safe'),
                    colour = Ortalab.Curses.ortalab_infected.badge_colour
                }
            end
        end
    end
})

local ortalab_card_area_emplace = CardArea.emplace
function CardArea:emplace(card, location, stay_flipped)
    if not card then return end
    ortalab_card_area_emplace(self, card, location, stay_flipped)
    if card.curse == 'ortalab_possessed' and (self == G.jokers or self == G.consumeables) then
        SMODS.calculate_effect({
                message = localize({type = 'name_text', set = 'Curse', key = 'ortalab_possessed'})..'!',
                colour = Ortalab.Curses.ortalab_possessed.badge_colour
            }, card)
        Ortalab.Curses.ortalab_possessed:set_ability(card)
    end
end

local ortalab_card_can_calculate = Card.can_calculate
function Card:can_calculate(ignore_debuff, ignore_sliced)
    if self.ability.set ~= 'Joker' and self.curse == 'ortalab_infected' and not self.curse_removed and not self.cured and not ignore_debuff then
        return false
    end
    return ortalab_card_can_calculate(self, ignore_debuff, ignore_sliced)
end

local ortalab_draw_from_discard_to_deck = G.FUNCS.draw_from_discard_to_deck
G.FUNCS.draw_from_discard_to_deck = function(e)
    for _, card in pairs(G.discard.cards) do
        card.ability.no_score = false
        card.ability.no_score_shader = false
    end
    ortalab_draw_from_discard_to_deck(e)
end

local ortalab_eval_card = eval_card
function eval_card(card, context)
    if card.ability.no_score then
        local cur = {}
        if context.final_scoring_step then
            local curses = card:calculate_curse(context)
            if curses then
                cur.curses = curses
            end
        end
        return cur, {}
    end
    local ret, post = ortalab_eval_card(card, context)
    return ret, post
end