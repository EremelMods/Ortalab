SMODS.Atlas({
    key = 'stakes',
    path = 'stakes.png',
    px = '29',
    py = '29'
})

SMODS.Atlas({
    key = 'stickers',
    path = 'stake_stickers.png',
    px = 71,
    py = 95
})

SMODS.Stake({
    key = "one",
    applied_stakes = {},
    above_stake = 'gold',
    prefix_config = {above_stake = {false}},
    atlas = 'stakes',
    pos = {x = 0, y = 0},
    shiny = true,
    sticker_pos = {x = 0, y = 0},
    sticker_atlas = 'stickers',
    colour = HEX('b9d0cb'),
    modifiers = function()
        G.GAME.modifiers.ortalab_only = Ortalab.config.ortalab_only
        G.GAME.ortalab.double_blind = true
        -- Modify vanilla shop rates
        if Ortalab.config.ortalab_only then
            G.GAME.planet_rate = 0
            G.GAME.tarot_rate = 0
            G.GAME.ortalab_loteria_rate = 4
            G.GAME.ortalab_zodiac_rate = 2.1
            G.GAME.joker_rate = 20.7
            -- G.GAME.mythos_rate = 1.2
        end
    end,
})

Ortalab.ortalab_only_inclusion = { -- Vanilla objects that are allowed in Ortalab only mode
    'e_negative',
    'Red',
    'Gold'
}

SMODS.Atlas({
    key = 'seals',
    path = 'seals.png',
    px = 71,
    py = 95
})

SMODS.Seal({
    key = 'cyan',
    atlas = 'seals',
    pos = {x=0,y=0},
    config = {extra = {levels = 2}},
    badge_colour = HEX('7e94ba'),
    in_pool = function(self)
        if G.GAME.modifiers.ortalab_only then self.weight = 5 else self.weight = 2.5 end
        return true
    end,
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.seal.extra.levels}}
    end,
    calculate = function(self, card, context)
        if context.playing_card_end_of_round and context.cardarea == G.hand then
            local _poker_hands = {}
            for k, v in pairs(G.GAME.hands) do
                if v.visible then _poker_hands[#_poker_hands+1] = k end
            end
            local hand_to_level = pseudorandom_element(_poker_hands, pseudoseed('cyanseal'))
            return {
                message = localize(hand_to_level, 'poker_hands'),
                colour = G.ARGS.LOC_COLOURS.Zodiac,
                level_up = card.ability.seal.extra.levels,
                level_up_hand = hand_to_level
            }
        end
    end
})

SMODS.Seal({
    key = 'magenta',
    atlas = 'seals',
    pos = {x=1,y=0},
    config = {},
    badge_colour = HEX('A85D7C'),
    in_pool = function(self)
        if G.GAME.modifiers.ortalab_only then self.weight = 5 else self.weight = 2.5 end
        return true
    end,
    calculate = function(self, card, context)
        if context.discard and context.other_card == card and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            return {
                message = localize('ortalab_loteria_add'),
                colour = G.C.SECONDARY_SET.ortalab_loteria,
                func = function()
                    SMODS.add_card({set = 'ortalab_loteria'})
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer - 1
                end
            }
        end
    end
})


SMODS.Stake({
    key = "two",
    applied_stakes = {'one'},
    above_stake = 'one',
    atlas = 'stakes',
    pos = {x = 1, y = 0},
    shiny = true,
    sticker_pos = {x = 1, y = 0},
    sticker_atlas = 'stickers',
    colour = HEX('f77162'),
    modifiers = function()
        G.GAME.ortalab.blind_rewards = G.GAME.ortalab.blind_rewards - 1
    end,
})

SMODS.Stake({
    key = "three",
    applied_stakes = {'two'},
    above_stake = 'two',
    atlas = 'stakes',
    pos = {x = 2, y = 0},
    shiny = true,
    sticker_pos = {x = 2, y = 0},
    sticker_atlas = 'stickers',
    colour = HEX('fc3ee2'),
    loc_vars = function(self, info_queue, card)
        return {vars = {1}}
    end,
    modifiers = function()
        G.GAME.modifiers.scaling = (G.GAME.modifiers.scaling or 1) + 1
        G.GAME.win_ante = G.GAME.win_ante + 1
    end,
})

SMODS.Stake({
    key = "four",
    applied_stakes = {'three'},
    above_stake = 'three',
    atlas = 'stakes',
    pos = {x = 3, y = 0},
    shiny = true,
    sticker_pos = {x = 3, y = 0},
    sticker_atlas = 'stickers',
    colour = HEX('5348e9'),
    loc_vars = function(self, info_queue, card)
        return {vars = {3}}
    end,
    modifiers = function()
        G.GAME.ortalab.skips_required = true
        G.GAME.ortalab.skips = 3
    end,
})

local ortalab_blind_choice_handler = G.FUNCS.blind_choice_handler
G.FUNCS.blind_choice_handler = function(e)
    ortalab_blind_choice_handler(e)
    local _blind_choice_box = e.UIBox:get_UIE_by_ID('select_blind_button')
    if e.config.id ~= 'Boss' and _blind_choice_box and G.GAME.round_resets.blind_states[e.config.id] == 'Select' and G.GAME.ortalab.skips_required and G.GAME.ortalab.skips > 0 and Ortalab.rounds_left(e.config.id) == G.GAME.ortalab.skips then
        G.GAME.round_resets.loc_blind_states[e.config.id] = localize('b_skip_blind')
        _blind_choice_box.config.colour = darken(G.C.RED, 0.2)
        _blind_choice_box.config.outline = 1
        _blind_choice_box.config.outline_colour = G.C.RED
        _blind_choice_box.config.button = 'skip_blind'
    end
end

function Ortalab.rounds_left(blind)
    local antes_left = G.GAME.win_ante - G.GAME.round_resets.ante
    local rounds_left = (antes_left * 2) + (blind == 'Small' and 2 or blind == 'Big' and 1 or 0)
    if G.GAME.ortalab.finisher_ante then rounds_left = rounds_left - 2 end
    return rounds_left
end

SMODS.Stake({
    key = "five",
    applied_stakes = {'four'},
    above_stake = 'four',
    atlas = 'stakes',
    pos = {x = 4, y = 0},
    shiny = true,
    sticker_pos = {x = 0, y = 1},
    sticker_atlas = 'stickers',
    colour = HEX('4ff34d'),
    modifiers = function()
        G.GAME.ortalab.round_decay = 1
        G.GAME.modifiers.scaling = (G.GAME.modifiers.scaling or 1) + 1
    end,
})

SMODS.Stake({
    key = "six",
    applied_stakes = {'five'},
    above_stake = 'five',
    atlas = 'stakes',
    pos = {x = 5, y = 0},
    shiny = true,
    sticker_pos = {x = 1, y = 1},
    sticker_atlas = 'stickers',
    colour = HEX('e2032f'),
    modifiers = function()
        G.GAME.ortalab.shop_curses = true
    end,
})

SMODS.Stake({
    key = "seven",
    applied_stakes = {'six'},
    above_stake = 'six',
    atlas = 'stakes',
    pos = {x = 6, y = 0},
    shiny = true,
    sticker_pos = {x = 2, y = 1},
    sticker_atlas = 'stickers',
    colour = HEX('a9fcf0'),
    modifiers = function()
        G.GAME.ortalab.ante_showdown = true
    end,
})

SMODS.Stake({
    key = "eight",
    applied_stakes = {'seven'},
    above_stake = 'seven',
    atlas = 'stakes',
    pos = {x = 7, y = 0},
    shiny = true,
    sticker_pos = {x = 3, y = 1},
    sticker_atlas = 'stickers',
    colour = HEX('533c5f'),
    modifiers = function()
        G.GAME.ortalab.finisher_ante = true
    end,
})

-- Override get_next_tag_key to disable skipping the final ante blinds
local get_next_tag_key_ortalab_ref = get_next_tag_key
function get_next_tag_key(append)
    if G.GAME.ortalab.finisher_ante and G.GAME.round_resets.ante == G.GAME.win_ante then
        return nil
    end
    return get_next_tag_key_ortalab_ref(append)
end