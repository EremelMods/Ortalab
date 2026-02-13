SMODS.Atlas({ -- zodiac card atlas
    key = 'zodiac_cards',
    path = 'zodiac.png',
    px = '71',
    py = '95'
})

SMODS.Atlas{ -- zodiac indicators atlas
    key = 'zodiac_tags',
    path = 'zodiac_tags.png',
    px = 34,
    py = 34
}

SMODS.Atlas{
    key = 'zodiac_constellations',
    path = 'zodiac_constellations.png',
    px = 150,
    py = 150
}

SMODS.UndiscoveredSprite({ -- undiscovered sprite
    key = 'ortalab_zodiac',
    atlas = "zodiac_cards",
    pos = { x = 0, y = 3 },
    no_overlay = true
})

G.ARGS.LOC_COLOURS['ortalab_zodiac'] = HEX("7e94ba")

SMODS.ConsumableType({ -- Zodiac Card ConsumableType creation
    key = "ortalab_zodiac",
    primary_colour = HEX("7e94ba"),
    secondary_colour = HEX("7e94ba"),
    collection_rows = {6, 6},
    shop_rate = 1.1,
    default = 'c_ortalab_zod_scorpio' -- High Card zodiac
})

G.ZODIACS = {} -- stores zodiacs
Ortalab.Zodiac = SMODS.Tag:extend { -- Zodiac Indicator Definition
    atlas = 'ortalab_zodiac_tags',
    class_prefix = 'zodiac',
    in_pool = function() return false end,
    inject = function(self)
        G.ZODIACS[self.key] = self
    end,
    triggered = function(self, card)
        if card.triggered then
            self:remove_zodiac(card)
        end
    end
}

-- remove triggered zodiacs
local evaluate_play = G.FUNCS.evaluate_play
function G.FUNCS.evaluate_play(e)
    evaluate_play(e)
    local active_zodiacs = {}
    local ophiuchus = G.zodiacs['zodiac_ortalab_ophiuchus']
    if ophiuchus then table.insert(active_zodiacs, ophiuchus) end
    if zodiac_current ~= G.zodiacs['zodiac_ortalab_ophiuchus'] then table.insert(active_zodiacs, zodiac_current) end

    for _, zodiac in ipairs(active_zodiacs) do
        zodiac_reduce_level(zodiac)
        if zodiac.triggered then
            G.E_MANAGER:add_event(Event({
                trigger = 'after', delay = 0.2,
                func = function()
                    zodiac:remove_zodiac('')
                    return true
                end
            }))
        else
            G.E_MANAGER:add_event(Event({
                delay = 0.4, trigger = 'after',
                func = (function()
                    attention_text({
                        text = '-'..G.GAME.ortalab.zodiacs.reduction,
                        colour = G.C.WHITE,
                        scale = 1, 
                        hold = 1/G.SETTINGS.GAMESPEED,
                        cover = zodiac.HUD_zodiac,
                        cover_colour = G.ARGS.LOC_COLOURS.ortalab_zodiac,
                        align = 'cm',
                        })
                    play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
                    play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
                    return true
                end)
            }))
        end
    end

    G.GAME.ortalab.temp_levels = 0
end

SMODS.Sound({
    key = 'zodiac',
    path = 'zodiac.ogg'
})

function add_zodiac(_tag, silent, from_load, from_patch)
    -- Add a zodiac to the indicator area
    if from_patch then
        _tag.config.extra.temp_level = _tag.config.extra.temp_level * from_patch    
    end 
    if G.GAME.ortalab.zodiacs.temp_level_mod ~= 1 and not from_load and not from_patch then
        _tag.config.extra.temp_level = _tag.config.extra.temp_level * G.GAME.ortalab.zodiacs.temp_level_mod
    end
    local leap_year_proc = false
    if G.GAME.ortalab.vouchers.leap_year and not from_load and not from_patch then
        leap_year_proc = SMODS.pseudorandom_probability(_tag, 'ortalab_leap_year', 1, G.GAME.ortalab.vouchers.leap_year[2])
        _tag.config.extra.temp_level = _tag.config.extra.temp_level + (leap_year_proc and G.GAME.ortalab.vouchers.leap_year[1] or 0)
    end
    _tag.voucher_check = true
    G.HUD_zodiac = G.HUD_zodiac or {}
    G.zodiacs = G.zodiacs or {}
    local tag_sprite_ui = _tag:generate_UI()
    G.HUD_zodiac[#G.HUD_zodiac+1] = UIBox{
        definition = {n=G.UIT.ROOT, config={align = "cl",padding = 0.05, colour = G.C.CLEAR}, nodes={
          tag_sprite_ui
        }},
        config = {
          align = G.HUD_zodiac[1] and 'cm' or 'cr',
          offset = G.HUD_zodiac[1] and {x=0,y=math.min(0.5, 4.5/#G.HUD_zodiac)} or {x=0,y=-1},
          major = G.HUD_zodiac[1] and G.HUD_zodiac[#G.HUD_zodiac] or G.consumeables},
          ref_table = _tag
    }

    for i, v in ipairs(G.HUD_zodiac) do
        if i > 1 then G.HUD_zodiac[i].Mid.alignment.offset = {x=0,y=math.min(0.5, 4.5/#G.HUD_zodiac)}; G.HUD_zodiac[i]:recalculate() end
    end
    G.zodiacs[_tag.key] = _tag

    _tag.HUD_zodiac = G.HUD_zodiac[#G.HUD_zodiac]
    if not silent then zodiac_text(localize({set='Tag', key=_tag.key, type='name_text'})..localize('ortalab_zodiac_added'), _tag.key, leap_year_proc) end
    -- delay(0.7)
end
Zodiac = Object:extend()

function Zodiac:init(_tag, for_collection, _blind_type)
    self.key = _tag
    local proto = G.ZODIACS[_tag]
    self.config = copy_table(proto.config)
    self.pos = proto.pos
    self.soul_pos = proto.soul_pos
    self.name = proto.name
    self.tally = G.GAME.zodiac_tally or 0
    self.triggered = false
    G.zodiacid = G.zodiacid or 0
    self.ID = G.zodiacid
    G.zodiacid = G.zodiacid + 1
    self.ability = {}
    G.GAME.zodiac_tally = G.GAME.zodiac_tally and (G.GAME.zodiac_tally + 1) or 1
end

function Zodiac:generate_UI(_size)
    _size = _size or 0.8

    local tag_sprite_tab = nil
    local tag_sprite = Sprite(0,0,_size*1,_size*1,G.ASSET_ATLAS[(not self.hide_ability) and G.ZODIACS[self.key].atlas or "tags"], (self.hide_ability) and G.tag_undiscovered.pos or self.pos)

    tag_sprite.T.scale = 1
    tag_sprite_tab = {n= G.UIT.C, config={align = "cl", ref_table = self, group = self.tally}, nodes={
        {n=G.UIT.O, config={w=_size*1,h=_size*1, colour = G.C.BLUE, object = tag_sprite, focus_with_object = true}},
        {n=G.UIT.C, config = {align = 'cm'}, nodes = {
            {n=G.UIT.R, config = {colour = G.C.BLACK, align = 'cm', r=1, padding = 0.1}, nodes = {
                {n=G.UIT.O, config={object = DynaText({scale = 0.3, string = {{ref_table = self.config.extra, ref_value = 'temp_level', prefix = '+'}}, colours = {G.ZODIACS[self.key].colour}, shadow = true})}},
            }}
        }}
    }}
    tag_sprite:define_draw_steps({
        {shader = 'dissolve', shadow_height = 0.05},
        {shader = 'dissolve'},
    })
    tag_sprite.float = true
    tag_sprite.states.hover.can = true
    tag_sprite.states.drag.can = false
    tag_sprite.states.collide.can = true
    tag_sprite.config = {tag = self, force_focus = true}

    tag_sprite.hover = function(_self)
        if not G.CONTROLLER.dragging.target or G.CONTROLLER.using_touch then 
            if not _self.hovering and _self.states.visible then
                _self.hovering = true
                if _self == tag_sprite then
                    _self.hover_tilt = 3
                    _self:juice_up(0.05, 0.02)
                    play_sound('paper1', math.random()*0.1 + 0.55, 0.42)
                    play_sound('tarot2', math.random()*0.1 + 0.55, 0.09)
                end

                self:get_uibox_table(tag_sprite)
                _self.config.h_popup =  G.UIDEF.card_h_popup(_self)
                _self.config.h_popup_config = (_self.T.x > G.ROOM.T.w*0.4) and
                    {align =  'bl', offset = {x=-0.1,y=-_self.T.h},parent = _self} or
                    {align =  'cr', offset = {x=0.1,y=0},parent = _self}
                Node.hover(_self)
                if _self.children.alert then 
                    _self.children.alert:remove()
                    _self.children.alert = nil
                    if self.key and G.ZODIACS[self.key] then G.ZODIACS[self.key].alerted = true end
                    G:save_progress()
                end
            end
        end
    end
    tag_sprite.stop_hover = function(_self) _self.hovering = false; Node.stop_hover(_self); _self.hover_tilt = 0 end

    tag_sprite:juice_up()
    self.tag_sprite = tag_sprite

    return tag_sprite_tab, tag_sprite
end

function Zodiac:juice_up(_scale, _rot)
    if self.tag_sprite then self.tag_sprite:juice_up(_scale, _rot) end
end

function Zodiac:get_uibox_table(tag_sprite)
    tag_sprite = tag_sprite or self.tag_sprite
    local name_to_check, loc_vars = self.name, G.ZODIACS[self.key]:loc_vars(nil, G.zodiacs[self.key]).vars
    tag_sprite.ability_UIBox_table = generate_card_ui(G.ZODIACS[self.key], nil, loc_vars, (self.hide_ability) and 'Undiscovered' or 'Tag', nil, (self.hide_ability), nil, nil, self)
    return tag_sprite
end

function Zodiac:remove_from_game()
    local tag_key = nil
    for k, v in pairs(G.zodiacs) do
        if v == self then tag_key = k end
    end
    table.remove(G.zodiacs, tag_key)
end

function Zodiac:remove_zodiac(message, _colour, func) -- Remove a zodiac from the indicator area
    if message then 
        G.E_MANAGER:add_event(Event({
            delay = 0.4,
            trigger = 'after',
            func = (function()
                attention_text({
                    text = message,
                    colour = G.C.WHITE,
                    scale = 1, 
                    hold = 0.6/G.SETTINGS.GAMESPEED,
                    cover = self.HUD_zodiac,
                    cover_colour = G.ARGS.LOC_COLOURS.ortalab_zodiac,
                    align = 'cm',
                    })
                play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
                play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
                return true
            end)
        }))
        G.E_MANAGER:add_event(Event({
            func = (function()
                self.HUD_zodiac.states.visible = false
                return true
            end)
        }))
    end

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.7,
        func = (function()
            self:remove_from_game()
            local HUD_tag_key = nil
            for k, v in pairs(G.HUD_zodiac) do
                if v == self.HUD_zodiac then HUD_tag_key = k end
            end

            if HUD_tag_key then 
                if G.HUD_zodiac and G.HUD_zodiac[HUD_tag_key+1] then
                    if HUD_tag_key == 1 then
                        G.HUD_zodiac[HUD_tag_key+1]:set_alignment({type = 'cr',
                        offset = {x=0,y=-1},
                        xy_bond = 'Weak',
                        major = G.consumeables})
                    else
                        G.HUD_zodiac[HUD_tag_key+1]:set_role({
                        xy_bond = 'Weak',
                        major = G.HUD_zodiac[HUD_tag_key-1]})
                    end
                end
                table.remove(G.HUD_zodiac, HUD_tag_key)
            end

            self.HUD_zodiac:remove()
            return true
        end)
    }))
    if G.zodiacs[self.key] then
        G.zodiacs[self.key] = nil
    end
end

function Zodiac:save()
    return {
        key = self.key,
        tally = self.tally, 
        ability = self.ability,
        config = self.config
    }
end

function Zodiac:load(tag_savetable)
    self.key = tag_savetable.key
    local proto = G.ZODIACS[self.key] or G.tag_undiscovered
    self.config = tag_savetable.config or copy_table(proto.config)
    self.pos = proto.pos
    self.name = proto.name
    self.tally = tag_savetable.tally
    self.ability = tag_savetable.ability
end

function zodiac_tooltip(_c, info_queue, card, desc_nodes, specific_vars, full_UI_table)
    desc_nodes.tag = true
    desc_nodes.title = localize({type = 'name_text', set = 'Tag', key = _c.key})
    local vars = specific_vars or G.ZODIACS[_c.key]:loc_vars(info_queue).vars
    
        localize{type = 'descriptions', set = 'Tag', key = 'zodiac_heading', nodes = desc_nodes, vars = vars}
        localize{type = 'descriptions', set = 'Tag', key = _c.key, nodes = desc_nodes, vars = vars}
        localize{type = 'descriptions', set = 'Tag', key = 'zodiac_loss', nodes = desc_nodes, vars = {G.GAME.ortalab.zodiacs.reduction}}

end

local start = Game.start_run
function Game:start_run(args)
    if self.HUD_zodiacs then
        for k, v in pairs(self.HUD_zodiacs) do
            v:remove()
        end
        self.HUD_zodiacs = nil
    end
    if self.zodiacs then
        for k, v in pairs(self.zodiacs) do
            if (type(v) == "table") and v.is and v:is(Zodiac) then 
                v:remove_zodiac()
            end
        end
    end
    start(self, args)
    self.GAME.zodiacs_activated = {}
end


function zodiac_reduce_level(zodiac)
    local zodiac_joker = SMODS.find_card('j_ortalab_prediction_dice')
    for _, joker_card in pairs(zodiac_joker) do        
        if SMODS.pseudorandom_probability(joker_card, 'zodiac_no_decay', 1, joker_card.ability.extra.chance) then
            -- joker_card:juice_up()
            card_eval_status_text(joker_card, 'extra', nil, nil, nil, {message = localize('ortalab_zodiac_no_decay')})
            return
        end
    end
    G.E_MANAGER:add_event(Event({
        trigger = 'after', delay = '0.4',
        func = function()                
            zodiac.config.extra.temp_level = math.max(0, zodiac.config.extra.temp_level - G.GAME.ortalab.zodiacs.reduction)
            return true
        end
    }))
    if zodiac.config.extra.temp_level <= G.GAME.ortalab.zodiacs.reduction then
        zodiac.triggered = true
    end
end

function use_zodiac(card)
    track_usage(card.config.center.set, card.config.center_key)
    if G.zodiacs and G.zodiacs[card.ability.extra.zodiac] then
        G.zodiacs[card.ability.extra.zodiac].config.extra.temp_level = G.zodiacs[card.ability.extra.zodiac].config.extra.temp_level + (G.ZODIACS[card.ability.extra.zodiac].config.extra.temp_level * G.GAME.ortalab.zodiacs.temp_level_mod)
        local leap_year_proc = false
        if G.GAME.ortalab.vouchers.leap_year then
            leap_year_proc = SMODS.pseudorandom_probability(_tag, 'ortalab_leap_year', 1, G.GAME.ortalab.vouchers.leap_year[2])
            G.zodiacs[card.ability.extra.zodiac].config.extra.temp_level = G.zodiacs[card.ability.extra.zodiac].config.extra.temp_level + (leap_year_proc and G.GAME.ortalab.vouchers.leap_year[1] or 0)
        end
        zodiac_text(zodiac_upgrade_text(card.ability.extra.zodiac), card.ability.extra.zodiac, leap_year_proc)
        G.zodiacs[card.ability.extra.zodiac]:juice_up(1, 1)
        delay(0.7)
    else
        add_zodiac(Zodiac(card.ability.extra.zodiac))
    end
end

function zodiac_upgrade_text(key)
    local zodiac_name = localize({set = 'Tag', key = key, type = 'name_text'})
    return zodiac_name .. localize('ortalab_zodiac_upgraded')
end

function zodiac_text(message, key, leap_year_proc, ophiuchus)
    if Ortalab.config.zodiac_skip then return end
    Ortalab.zodiac_animation = true
    local old_colours = {
        special_colour = copy_table(G.C.BACKGROUND.C),
        tertiary_colour = copy_table(G.C.BACKGROUND.D),
        new_colour = copy_table(G.C.BACKGROUND.L),
    }
    -- Add constellation sprite
    local zodiac_sprite = Sprite(0, 0, 100, 100, G.ASSET_ATLAS['ortalab_zodiac_constellations'], G.ZODIACS[key].pos)
    local ophiuchus_sprite
    if ophiuchus then ophiuchus_sprite = Sprite(0, 0, 100, 100, G.ASSET_ATLAS['ortalab_zodiac_constellations'], G.ZODIACS['zodiac_ortalab_ophiuchus'].pos) end
    local zodiac_UI = UIBox{
        definition = {n=G.UIT.ROOT, config = {align='cm', colour = G.C.CLEAR, minw = 3.4, minh = 3.4}, nodes = {
            {n=G.UIT.R, config = {padding = 0.2}, nodes = {
                {n=G.UIT.O, config = {object = zodiac_sprite, w = 3.4, h = 3.4}},
                ophiuchus and {n=G.UIT.O, config = {object = ophiuchus_sprite, w = 3.4, h = 3.4}} or nil
            }}
        }},
        config = {instance_type = 'UIBOX', major = G.play, align = 'cm', offset = {x=0, y=-2.7}}
    }
    -- Change background colour
    ease_background_colour{special_colour = darken(G.ARGS.LOC_COLOURS['ortalab_zodiac'], 0.5), new_colour = G.ZODIACS[key].colour, tertiary_colour = G.ARGS.LOC_COLOURS.ortalab_zodiac, contrast = 1}
    -- Add text    
    attention_text({scale = 1, text = message, hold = 2, align = 'cm', offset = {x = 0,y = -2.7},major = G.play})
    play_sound('ortalab_zodiac', 0.8+ (0.9 + 0.2*math.random())*0.2, 2)
    if ophiuchus then attention_text({scale = 0.75, text = localize({set='Tag',key='zodiac_ortalab_ophiuchus',type='name_text'})..localize('ortalab_zodiac_active'), hold = 2, align = 'cm', emboss = true, offset = {x = 0,y = -3.5},major = G.play}) end
    if leap_year_proc then attention_text({scale = 0.75, text = localize({set = 'Voucher', key = 'v_ortalab_leap_year', type='name_text'})..'!', hold = 2, align = 'cm', emboss = true, offset = {x = 0,y = -1.9},major = G.play}) end
    delay(0.4)
    
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 1,
        func = function()
            ease_background_colour({special_colour = old_colours.special_colour, tertiary_colour = old_colours.tertiary_colour, new_colour = old_colours.new_colour})
            zodiac_sprite:remove()
            if ophiuchus_sprite then ophiuchus_sprite:remove() end
            zodiac_UI:remove()
            Ortalab.zodiac_animation = false
            return true
    end}))
end

local align_ref = CardArea.align_cards
function CardArea:align_cards()
    if self.config.type == 'joker' and not self.cards then self.cards = {} end
    if not self.children then self.children = {} end
    align_ref(self)
end

------------------------
-- ZODIAC DEFINITIONS --
------------------------

SMODS.Consumable({
    key = 'zod_aries',
    set = 'ortalab_zodiac',
    atlas = 'zodiac_cards',
    cost = 4,
    pos = {x=0, y=0},
    discovered = false,
    config = {extra = {zodiac = 'zodiac_ortalab_aries'}},
    artist_credits = {'gappie'},
    loc_vars = function(self, info_queue, card)
        return {vars = {localize(G.ZODIACS[self.config.extra.zodiac].config.extra.hand_type, 'poker_hands')}}
    end,
    can_use = function(self, card)
        return true
    end,
    use = function(self, card, area, copier)
        use_zodiac(card)
    end
})

Ortalab.Zodiac{
    key = 'aries',
    pos = {x=2, y=0},
    colour = HEX('b64646'),
    config = {extra = {temp_level = 4, hand_type = 'Four of a Kind', count = 2}},
    loc_vars = function(self, info_queue, card)
        local zodiac = card or self
        local temp_level = (not zodiac.voucher_check and G.GAME.ortalab.zodiacs.temp_level_mod or 1) * zodiac.config.extra.temp_level
        return {vars = {temp_level, localize(zodiac.config.extra.hand_type, 'poker_hands'), zodiac.config.extra.count}}
    end,
    pre_trigger = function(self, zodiac, context)
        zodiac.config.extra.destroyed = 0
        local ranks = {}
        for _, card in pairs(context.scoring_hand) do
            ranks[card.base.value] = (ranks[card.base.value] or 0) + 1
        end
        for rank, count in pairs(ranks) do
            if count == 4 then zodiac.config.extra.four_oak_rank = rank end
        end
        return context.mult, context.chips
    end,
    destroy = function(self, zodiac, context)
        if zodiac.config.extra.destroyed == zodiac.config.extra.count then
            return false
        else
            if context.other_card.base.value ~= zodiac.config.extra.four_oak_rank or context.other_card.config.center.always_scores then
                zodiac.config.extra.destroyed = zodiac.config.extra.destroyed + 1
                return true
            end
        end
    end
}

SMODS.Consumable({
    key = 'zod_taurus',
    set = 'ortalab_zodiac',
    atlas = 'zodiac_cards',
    cost = 4,
    pos = {x=1, y=0},
    discovered = false,
    config = {extra = {zodiac = 'zodiac_ortalab_taurus'}},
    artist_credits = {'gappie'},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_ortalab_rusty
        info_queue[#info_queue+1] = G.P_CENTERS.m_ortalab_sand
        info_queue[#info_queue+1] = G.P_CENTERS.m_ortalab_recycled
        return {vars = {localize(G.ZODIACS[self.config.extra.zodiac].config.extra.hand_type, 'poker_hands')}}
    end,
    can_use = function(self, card)
        return true
    end,
    use = function(self, card, area, copier)
        use_zodiac(card)
    end
})

Ortalab.Zodiac{
    key = 'taurus',
    pos = {x=3, y=0},
    colour = HEX('cb703d'),
    config = {extra = {temp_level = 4, hand_type = 'Three of a Kind', amount = 3}},
    loc_vars = function(self, info_queue, card)
        local zodiac = card or self
        if not card and info_queue then
            info_queue[#info_queue+1] = G.P_CENTERS.m_ortalab_rusty
            info_queue[#info_queue+1] = G.P_CENTERS.m_ortalab_sand
            info_queue[#info_queue+1] = G.P_CENTERS.m_ortalab_recycled
        end
        local temp_level = (not zodiac.voucher_check and G.GAME.ortalab.zodiacs.temp_level_mod or 1) * zodiac.config.extra.temp_level
        return {vars = {temp_level, localize(zodiac.config.extra.hand_type, 'poker_hands'), zodiac.config.extra.amount}}
    end,
    pre_trigger = function(self, zodiac, context)
        for i=1, zodiac.config.extra.amount do
            if G.hand.cards[i] then
                G.hand.cards[i]:set_ability(SMODS.poll_enhancement({guaranteed = true, options = {'m_ortalab_rusty','m_ortalab_sand','m_ortalab_recycled', key = 'zodiac_taurus'}}), nil, true)
                G.E_MANAGER:add_event(Event({
                    trigger = 'before', delay = 0.2, func = function()
                        zodiac:juice_up()
                        G.hand.cards[i]:juice_up()
                        return true
                    end}))
            end
        end
        return context.mult, context.chips
    end
}

SMODS.Consumable({
    key = 'zod_gemini',
    set = 'ortalab_zodiac',
    atlas = 'zodiac_cards',
    cost = 4,
    pos = {x=2, y=0},
    discovered = false,
    config = {extra = {zodiac = 'zodiac_ortalab_gemini'}},
    artist_credits = {'gappie'},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_ortalab_post
        info_queue[#info_queue+1] = G.P_CENTERS.m_ortalab_bent
        return {vars = {localize(G.ZODIACS[self.config.extra.zodiac].config.extra.hand_type, 'poker_hands')}}
    end,
    can_use = function(self, card)
        return true
    end,
    use = function(self, card, area, copier)
        use_zodiac(card)
    end
})

Ortalab.Zodiac{
    key = 'gemini',
    pos = {x=4, y=0},
    colour = HEX('d9c270'),
    config = {extra = {temp_level = 4, hand_type = 'Pair'}},
    loc_vars = function(self, info_queue, card)
        if not card and info_queue then
            info_queue[#info_queue+1] = G.P_CENTERS.m_ortalab_post
            info_queue[#info_queue+1] = G.P_CENTERS.m_ortalab_bent
        end
        local zodiac = card or self
        local temp_level = (not zodiac.voucher_check and G.GAME.ortalab.zodiacs.temp_level_mod or 1) * zodiac.config.extra.temp_level
        return {vars = {temp_level, localize(zodiac.config.extra.hand_type, 'poker_hands')}}
    end,
    pre_trigger = function(self, zodiac, context)
        local effects = {'m_ortalab_post', 'm_ortalab_bent'}
        for i=1, 2 do
            if context.scoring_hand[i].config.center.set ~= 'Enhanced' then
                context.scoring_hand[i]:set_ability(G.P_CENTERS[effects[i]], nil, true)
                local name = context.scoring_hand[i].ability.effect
                context.scoring_hand[i].ability.effect = nil
                G.E_MANAGER:add_event(Event({
                    trigger = 'before', delay = 0.2, func = function()
                        zodiac:juice_up()
                        context.scoring_hand[i].ability.effect = name
                        context.scoring_hand[i]:juice_up()
                        return true
                    end}))
            end
        end
        return context.mult, context.chips
    end
}

SMODS.Consumable({
    key = 'zod_cancer',
    set = 'ortalab_zodiac',
    atlas = 'zodiac_cards',
    cost = 4,
    pos = {x=3, y=0},
    discovered = false,
    config = {extra = {zodiac = 'zodiac_ortalab_cancer'}},
    artist_credits = {'gappie'},
    loc_vars = function(self, info_queue, card)
        return {vars = {localize(G.ZODIACS[self.config.extra.zodiac].config.extra.hand_type, 'poker_hands')}}
    end,
    can_use = function(self, card)
        return true
    end,
    use = function(self, card, area, copier)
        use_zodiac(card)
    end
})

Ortalab.Zodiac{
    key = 'cancer',
    pos = {x=5, y=0},
    colour = HEX('878879'),
    config = {extra = {temp_level = 4, hand_type = 'Flush House'}},
    loc_vars = function(self, info_queue, card)
        local zodiac = card or self
        local temp_level = (not zodiac.voucher_check and G.GAME.ortalab.zodiacs.temp_level_mod or 1) * zodiac.config.extra.temp_level
        return {vars = {temp_level, localize(zodiac.config.extra.hand_type, 'poker_hands')}}
    end,
    pre_trigger = function(self, zodiac, context)
        local suits_in_flush = {}
        local new_suit = context.scoring_hand[1].base.suit
        for _, card in pairs(context.scoring_hand) do
            if not card.config.center.no_suit then 
                suits_in_flush[card.base.suit] = suits_in_flush[card.base.suit] and suits_in_flush[card.base.suit] + 1 or 1 
                if suits_in_flush[card.base.suit] > suits_in_flush[new_suit] then new_suit = card.base.suit end
            end
        end

        local ranks = {}
        for _, pcard in ipairs(context.scoring_hand) do
            ranks[pcard.base.value] = (ranks[pcard.base.value] or 0) + 1
        end
        local ranks_by_count = {}
        for rank, count in pairs(ranks) do
            table.insert(ranks_by_count, {rank = rank, count = count})
        end
        table.sort(ranks_by_count, function(a, b) return a.count > b.count end)

        for i, card in ipairs(G.hand.cards) do
            local new_rank = SMODS.Ranks[i % 2 ~= 0 and ranks_by_count[1].rank or ranks_by_count[2].rank]
            Ortalab.change_suit_no_anim(card, new_suit)
            card.base.id = new_rank.id
            card.base.nominal = new_rank.nominal or 0
            card.base.face_nominal = new_rank.face_nominal or 0
            G.E_MANAGER:add_event(Event({
                trigger = 'before', delay = 0.2, func = function()
                    zodiac:juice_up()
                    SMODS.change_base(card, new_suit, i % 2 ~= 0 and ranks_by_count[1].rank or ranks_by_count[2].rank)
                    if card.ability.set ~= 'Enhanced' then card:set_ability(G.P_CENTERS[SMODS.poll_enhancement({guaranteed = true, key = 'zodiac_cancer'})]) end
                    card:juice_up()
                    return true
                end}))
        end
        return context.mult, context.chips
    end
}

SMODS.Consumable({
    key = 'zod_leo',
    set = 'ortalab_zodiac',
    atlas = 'zodiac_cards',
    cost = 4,
    pos = {x=0, y=1},
    discovered = false,
    config = {extra = {zodiac = 'zodiac_ortalab_leo'}},
    artist_credits = {'gappie'},
    loc_vars = function(self, info_queue, card)
        return {vars = {localize(G.ZODIACS[self.config.extra.zodiac].config.extra.hand_type, 'poker_hands')}}
    end,
    can_use = function(self, card)
        return true
    end,
    use = function(self, card, area, copier)
        use_zodiac(card)
    end
})

Ortalab.Zodiac{
    key = 'leo',
    pos = {x=0, y=1},
    colour = HEX('8fb85c'),
    config = {extra = {temp_level = 4, effects = 2, hand_type = 'Flush Five'}},
    loc_vars = function(self, info_queue, card)
        local zodiac = card or self
        local temp_level = (not zodiac.voucher_check and G.GAME.ortalab.zodiacs.temp_level_mod or 1) * zodiac.config.extra.temp_level
        return {vars = {temp_level, localize(zodiac.config.extra.hand_type, 'poker_hands'), zodiac.config.extra.effects}}
    end,
    pre_trigger = function(self, zodiac, context)
        for i=1, zodiac.config.extra.effects do
            if G.hand.cards[i] then
                Ortalab.change_suit_no_anim(G.hand.cards[i], context.scoring_hand[3].base.suit)
                G.hand.cards[i].base.id = context.scoring_hand[3].base.id
                G.hand.cards[i].base.nominal = context.scoring_hand[3].base.nominal
                G.hand.cards[i].base.face_nominal = context.scoring_hand[3].base.face_nominal
                G.hand.cards[i]:set_ability(G.P_CENTERS[context.scoring_hand[3].config.center_key], nil, true)
                G.hand.cards[i]:set_debuff(context.scoring_hand[3].debuff)
                G.E_MANAGER:add_event(Event({
                    func = function()
                        copy_card(context.scoring_hand[3], G.hand.cards[i])
                        G.hand.cards[i]:juice_up()
                        context.scoring_hand[3]:juice_up()
                        return true
                        end
                }))
            end
        end        
        return context.mult, context.chips
    end
}

SMODS.Consumable({
    key = 'zod_virgo',
    set = 'ortalab_zodiac',
    atlas = 'zodiac_cards',
    cost = 4,
    pos = {x=1, y=1},
    discovered = false,
    config = {extra = {zodiac = 'zodiac_ortalab_virgo'}},
    artist_credits = {'gappie'},
    loc_vars = function(self, info_queue, card)
        return {vars = {localize(G.ZODIACS[self.config.extra.zodiac].config.extra.hand_type, 'poker_hands')}}
    end,
    can_use = function(self, card)
        return true
    end,
    use = function(self, card, area, copier)
        use_zodiac(card)
    end
})

Ortalab.Zodiac{
    key = 'virgo',
    pos = {x=1, y=1},
    colour = HEX('299847'),
    config = {extra = {temp_level = 4, hand_type = 'Five of a Kind'}},
    loc_vars = function(self, info_queue, card)
        local zodiac = card or self
        local temp_level = (not zodiac.voucher_check and G.GAME.ortalab.zodiacs.temp_level_mod or 1) * zodiac.config.extra.temp_level
        return {vars = {temp_level, localize(zodiac.config.extra.hand_type, 'poker_hands'), 3}}
    end,
    pre_trigger = function(self, zodiac, context)
        G.E_MANAGER:add_event(Event({
            func = function()
                local cards = {}
                for i=1, 2 do
                    G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                    local _card = copy_card(context.scoring_hand[i == 1 and i or #context.scoring_hand], nil, nil, G.playing_card)
                    table.insert(cards, _card)
                end
                for i, _card in ipairs(cards) do
                    _card:add_to_deck()
                    G.deck.config.card_limit = G.deck.config.card_limit + 1
                    table.insert(G.playing_cards, _card)
                    G.deck:emplace(_card)
                    context.scoring_hand[i==1 and i or #context.scoring_hand]:juice_up()
                    _card:juice_up()
                end
                playing_card_joker_effects(cards)
                G.deck:shuffle('zodiac_virgo')
                return true
            end
        }))
        return context.mult, context.chips
    end
}

SMODS.Consumable({
    key = 'zod_libra',
    set = 'ortalab_zodiac',
    atlas = 'zodiac_cards',
    cost = 4,
    pos = {x=2, y=1},
    discovered = false,
    config = {extra = {zodiac = 'zodiac_ortalab_libra'}},
    artist_credits = {'gappie'},
    loc_vars = function(self, info_queue, card)
        return {vars = {localize(G.ZODIACS[self.config.extra.zodiac].config.extra.hand_type, 'poker_hands')}}
    end,
    can_use = function(self, card)
        return true
    end,
    use = function(self, card, area, copier)
        use_zodiac(card)
    end
})

Ortalab.Zodiac{
    key = 'libra',
    pos = {x=2, y=1},
    colour = HEX('32a18c'),
    config = {extra = {temp_level = 4, hand_type = 'Full House', convert = 1}},
    loc_vars = function(self, info_queue, card)
        local zodiac = card or self
        local temp_level = (not zodiac.voucher_check and G.GAME.ortalab.zodiacs.temp_level_mod or 1) * zodiac.config.extra.temp_level
        return {vars = {temp_level, localize(zodiac.config.extra.hand_type, 'poker_hands'), zodiac.config.extra.convert}}
    end,
    pre_trigger = function(self, zodiac, context)
        for i=1, math.min(zodiac.config.extra.convert, #G.hand.cards) do
            if G.hand.cards[i] then
                G.hand.cards[i].base.suit = context.scoring_hand[1].base.suit
                G.hand.cards[i].base.id = context.scoring_hand[1].base.id
                G.hand.cards[i].base.nominal = context.scoring_hand[1].base.nominal
                G.hand.cards[i].base.face_nominal = context.scoring_hand[1].base.face_nominal
                G.hand.cards[i].delay_edition = context.scoring_hand[1].edition or {}
                G.hand.cards[i]:set_edition(context.scoring_hand[1].edition and context.scoring_hand[1].edition.key, false, true)
                G.hand.cards[i]:set_ability(G.P_CENTERS[context.scoring_hand[1].config.center_key], nil, true)
                G.hand.cards[i]:set_debuff(context.scoring_hand[1].debuff)
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local _card = copy_card(context.scoring_hand[1], G.hand.cards[i], nil, nil, true)
                        G.hand.cards[i].delay_edition = nil
                        _card:juice_up()
                        context.scoring_hand[1]:juice_up()
                        return true
                    end
                }))
            end
        end
        return context.mult, context.chips
    end
}

SMODS.Consumable({
    key = 'zod_scorpio',
    set = 'ortalab_zodiac',
    atlas = 'zodiac_cards',
    cost = 4,
    pos = {x=3, y=1},
    discovered = false,
    config = {extra = {zodiac = 'zodiac_ortalab_scorpio'}},
    artist_credits = {'gappie'},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_stone
        info_queue[#info_queue+1] = G.P_CENTERS.m_ortalab_ore
        return {vars = {localize(G.ZODIACS[self.config.extra.zodiac].config.extra.hand_type, 'poker_hands')}}
    end,
    can_use = function(self, card)
        return true
    end,
    use = function(self, card, area, copier)
        use_zodiac(card)
    end
})

Ortalab.Zodiac{
    key = 'scorpio',
    pos = {x=0, y=0},
    colour = HEX('669ac0'),
    config = {extra = {temp_level = 4, hand_type = 'High Card', amount = 2}},
    loc_vars = function(self, info_queue, card)
        if not card and info_queue then
            info_queue[#info_queue+1] = G.P_CENTERS.m_stone
            info_queue[#info_queue+1] = G.P_CENTERS.m_ortalab_ore
        end
        local zodiac = card or self
        local temp_level = (not zodiac.voucher_check and G.GAME.ortalab.zodiacs.temp_level_mod or 1) * zodiac.config.extra.temp_level
        return {vars = {temp_level, localize(zodiac.config.extra.hand_type, 'poker_hands'), zodiac.config.extra.amount}}
    end,
    pre_trigger = function(self, zodiac, context)
        local amount = 1
        local modifiers = {'m_stone', 'm_ortalab_ore'}
        for _, card in pairs(context.full_hand) do
            if table.contains(context.scoring_hand, card) or amount == zodiac.config.extra.amount + 1 then
                -- do nothing
            else
                local change = modifiers[amount]
                card.add_to_scoring = function()
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.5,
                        func = function()
                            zodiac:juice_up()
                            card:juice_up()
                            card.config.center.replace_base_card = true                
                            card.becoming_no_rank = nil
                            return true
                        end
                    }))
                    card:set_ability(G.P_CENTERS[change], nil, true)
                    local name = card.ability.effect
                    card.becoming_no_rank = true
                    card.config.center.replace_base_card = nil
                end
                
                amount = amount + 1
            end
        end
        return context.mult, context.chips, true
    end
}

local ortalab_should_hide_front = Card.should_hide_front
function Card:should_hide_front()
    if self.becoming_no_rank then return false end
    return ortalab_should_hide_front(self)
end

SMODS.Consumable({
    key = 'zod_sag',
    set = 'ortalab_zodiac',
    atlas = 'zodiac_cards',
    cost = 4,
    pos = {x=0, y=2},
    discovered = false,
    config = {extra = {zodiac = 'zodiac_ortalab_sag'}},
    artist_credits = {'gappie'},
    loc_vars = function(self, info_queue, card)
        return {vars = {localize(G.ZODIACS[self.config.extra.zodiac].config.extra.hand_type, 'poker_hands')}}
    end,
    can_use = function(self, card)
        return true
    end,
    use = function(self, card, area, copier)
        use_zodiac(card)
    end
})

Ortalab.Zodiac{
    key = 'sag',
    pos = {x=3, y=1},
    colour = HEX('4c3ba2'),
    config = {extra = {temp_level = 4, hand_type = 'Flush'}},
    loc_vars = function(self, info_queue, card)
        local zodiac = card or self
        local temp_level = (not zodiac.voucher_check and G.GAME.ortalab.zodiacs.temp_level_mod or 1) * zodiac.config.extra.temp_level
        return {vars = {temp_level, localize(zodiac.config.extra.hand_type, 'poker_hands')}}
    end,
    pre_trigger = function(self, zodiac, context)
        local suits_in_flush = {}
        local new_suit = context.scoring_hand[1].base.suit
        for _, card in pairs(context.scoring_hand) do
            suits_in_flush[card.base.suit] = suits_in_flush[card.base.suit] and suits_in_flush[card.base.suit] + 1 or 1
            if suits_in_flush[card.base.suit] > suits_in_flush[new_suit] then new_suit = card.base.suit end
        end
        for _, card in pairs(G.hand.cards) do
            if not card.base.suit ~= new_suit then
                Ortalab.change_suit_no_anim(card, new_suit)
                G.E_MANAGER:add_event(Event({
                    trigger = 'before', delay = 0.2, func = function()
                        zodiac:juice_up()
                        SMODS.change_base(card, new_suit)
                        card:juice_up()
                        return true
                    end}))
            end
        end     
        return context.mult, context.chips
    end
}

SMODS.Consumable({
    key = 'zod_capr',
    set = 'ortalab_zodiac',
    atlas = 'zodiac_cards',
    cost = 4,
    pos = {x=1, y=2},
    discovered = false,
    config = {extra = {zodiac = 'zodiac_ortalab_capr'}},
    artist_credits = {'gappie'},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_ortalab_index
        return {vars = {localize(G.ZODIACS[self.config.extra.zodiac].config.extra.hand_type, 'poker_hands')}}
    end,
    can_use = function(self, card)
        return true
    end,
    use = function(self, card, area, copier)
        use_zodiac(card)
    end
})

Ortalab.Zodiac{
    key = 'capr',
    pos = {x=4, y=1},
    colour = HEX('8058b6'),
    config = {extra = {temp_level = 4, hand_type = 'Straight', amount = 2}},
    loc_vars = function(self, info_queue, card)
        if not card and info_queue then info_queue[#info_queue + 1] = G.P_CENTERS['m_ortalab_index'] end
        local zodiac = card or self
        local temp_level = (not zodiac.voucher_check and G.GAME.ortalab.zodiacs.temp_level_mod or 1) * zodiac.config.extra.temp_level
        return {vars = {temp_level, localize(zodiac.config.extra.hand_type, 'poker_hands'), zodiac.config.extra.amount}}
    end,
    pre_trigger = function(self, zodiac, context)
        for i=1, zodiac.config.extra.amount do
            if G.hand.cards[i] then
                G.E_MANAGER:add_event(Event({
                    trigger = 'before', delay = 0.2, func = function()
                        zodiac:juice_up()
                        G.hand.cards[i]:set_ability(G.P_CENTERS['m_ortalab_index'])
                        G.hand.cards[i]:juice_up()
                        return true
                    end}))
            end
        end
        return context.mult, context.chips
    end
}

SMODS.Consumable({
    key = 'zod_aquarius',
    set = 'ortalab_zodiac',
    atlas = 'zodiac_cards',
    cost = 4,
    pos = {x=2, y=2},
    discovered = false,
    config = {extra = {zodiac = 'zodiac_ortalab_aquarius'}},
    artist_credits = {'gappie'},
    loc_vars = function(self, info_queue, card)
        return {vars = {localize(G.ZODIACS[self.config.extra.zodiac].config.extra.hand_type, 'poker_hands')}}
    end,
    can_use = function(self, card)
        return true
    end,
    use = function(self, card, area, copier)
        use_zodiac(card)
    end
})

Ortalab.Zodiac{
    key = 'aquarius',
    pos = {x=1, y=0},
    config = {extra = {temp_level = 4, hand_type = 'Two Pair'}},
    colour = HEX('b05ab4'),
    loc_vars = function(self, info_queue, card)
        local zodiac = card or self
        local temp_level = (not zodiac.voucher_check and G.GAME.ortalab.zodiacs.temp_level_mod or 1) * zodiac.config.extra.temp_level
        return {vars = {temp_level, localize(zodiac.config.extra.hand_type, 'poker_hands')}}
    end,
    pre_trigger = function(self, zodiac, context)
        G.E_MANAGER:add_event(Event({
            func = function()
                G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                local _card = copy_card(context.scoring_hand[1], nil, nil, G.playing_card)
                _card:add_to_deck()
                G.deck.config.card_limit = G.deck.config.card_limit + 1
                table.insert(G.playing_cards, _card)
                G.deck:emplace(_card)
                G.deck:shuffle('zodiac_aquarius')
                context.scoring_hand[1]:juice_up()
                _card:juice_up()

                playing_card_joker_effects({_card})
                return true
            end
        }))
        return context.mult, context.chips
    end
}

SMODS.Consumable({
    key = 'zod_pisces',
    set = 'ortalab_zodiac',
    atlas = 'zodiac_cards',
    cost = 4,
    pos = {x=3, y=2},
    discovered = false,
    config = {extra = {zodiac = 'zodiac_ortalab_pisces'}},
    artist_credits = {'gappie'},
    loc_vars = function(self, info_queue, card)
        return {vars = {localize(G.ZODIACS[self.config.extra.zodiac].config.extra.hand_type, 'poker_hands')}}
    end,
    can_use = function(self, card)
        return true
    end,
    use = function(self, card, area, copier)
        use_zodiac(card)
    end
})

Ortalab.Zodiac{
    key = 'pisces',
    pos = {x=5, y=1},
    colour = HEX('ae347f'),
    config = {extra = {temp_level = 4, hand_type = 'Straight Flush'}},
    loc_vars = function(self, info_queue, card)
        local zodiac = card or self
        local temp_level = (not zodiac.voucher_check and G.GAME.ortalab.zodiacs.temp_level_mod or 1) * zodiac.config.extra.temp_level
        return {vars = {temp_level, localize(zodiac.config.extra.hand_type, 'poker_hands')}}
    end,
    pre_trigger = function(self, zodiac, context)
        local suits_in_flush = {}
        local new_suit = context.scoring_hand[1].base.suit
        for _, card in pairs(context.scoring_hand) do
            suits_in_flush[card.base.suit] = suits_in_flush[card.base.suit] and suits_in_flush[card.base.suit] + 1 or 1
            if suits_in_flush[card.base.suit] > suits_in_flush[new_suit] then new_suit = card.base.suit end
        end
        for _, card in pairs(G.hand.cards) do
            if not card.base.suit ~= new_suit then
                Ortalab.change_suit_no_anim(card, new_suit)
                if not card.edition then
                    local new_edition = poll_edition('zodiac_pisces', nil, false, true)
                    card.delay_edition = card.edition or {}
                    card:set_edition(new_edition, false, true)
                end
                G.E_MANAGER:add_event(Event({
                    trigger = 'before', delay = 0.2, func = function()
                        zodiac:juice_up()
                        SMODS.change_base(card, new_suit)
                        card.delay_edition = false
                        card:juice_up()
                        return true
                    end}))
            end
        end
        return context.mult, context.chips
    end
}

local smods_gui_hand_ui = SMODS.GUI.current_hand_ui
function SMODS.GUI.current_hand_ui(scale)
    local ret = smods_gui_hand_ui(scale)
    ret.nodes[#ret.nodes + 1] = {n=G.UIT.T, config={ref_table = G.GAME.current_round.current_hand, ref_value='temporary_level', scale = scale, colour = G.C.UI.TEXT_LIGHT, id = 'temporary_level', shadow = true}}
    return ret
end

local ortalab_update_hand_text = update_hand_text
function update_hand_text(config, vals)
    if vals.level == '' then
        vals.temp_level = ''
    end
    if vals.temp_level == '' and (G.zodiac_sprite or G.ophiuchus_sprite) then
        if G.zodiac_sprite then G.zodiac_sprite:remove() end
        if G.ophiuchus_sprite then G.ophiuchus_sprite:remove() end
        G.zodiac_UI:remove()
        if Ortalab.old_colours then ease_background_colour({special_colour = Ortalab.old_colours.special_colour, tertiary_colour = Ortalab.old_colours.tertiary_colour, new_colour = Ortalab.old_colours.new_colour}) end
        Ortalab.old_colours = nil
    end
    ortalab_update_hand_text(config, vals)
end

local ortalab_level_up_hand = level_up_hand
function level_up_hand(card, hand, instant, amount, ...)
    local temp = G.GAME.ortalab.temp_levels
    if SMODS.displaying_scoring and not (SMODS.displayed_hand == hand) then
        update_hand_text({delay = 0, nopulse = true}, {temp_level = ''})
    end
    ortalab_level_up_hand(card, hand, instant, amount, ...)
    update_hand_text({delay = 0, nopulse = true}, {temp_level = temp, temp_colour = G.hand_text_area.temporary_level.config.colour})
end

local press_play = Blind.press_play
function Blind:press_play()
	local ret = press_play(self)
	if G.zodiac_sprite or G.ophiuchus_sprite then
        if G.zodiac_sprite then G.zodiac_sprite:remove() end
        if G.ophiuchus_sprite then G.ophiuchus_sprite:remove() end
        G.zodiac_UI:remove()
    end
	return ret
end