SMODS.Joker({
    key = "graffiti",
    atlas = "jokers",
    pos = {x = 1, y = 1},
    rarity = 2,
    cost = 6,
    unlocked = true,
    discovered = false,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    config = {extra = {blind_size = 2, vouchers = 1}},
    artist_credits = {'flare','gappie'},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.blind_size}}
    end,
    calculate = function(self, card, context)
        if context.setting_blind and G.GAME.blind.boss then
            return {
                message = 'X2',
                func = function()
                    G.E_MANAGER:add_event(Event({
                        trigger = 'ease',
                        blockable = true,
                        blocking = false,
                        ref_table = G.GAME.blind,
                        ref_value = 'chips',
                        ease_to = G.GAME.blind['chips'] + G.GAME.blind['chips'],
                        delay =  0.6,
                        func = (function(t) G.GAME.blind.chip_text = number_format(t); return t end)
                    }))
                end
            }
        end
        if context.end_of_round and context.main_eval and G.GAME.blind.boss then
            local _pool = get_current_pool('Voucher')
        local voucher = pseudorandom_element(_pool, pseudoseed('ortalab_hooligan'))
        local it = 1
        while voucher == 'UNAVAILABLE' do
            it = it + 1
            voucher = pseudorandom_element(_pool, pseudoseed('ortalab_hooligan'..it))
        end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.5,
            func = function()
                local juice_hooligan = true
                local eval = function() return juice_hooligan end
                juice_card_until(card, eval, true)
                local voucher_card = SMODS.create_card({area = G.play, key = voucher})
                voucher_card:add_to_deck()
                voucher_card:start_materialize()
                voucher_card.cost = 0
                G.play:emplace(voucher_card)
                delay(0.8)
                G.FUNCS.use_card({config = {ref_table = voucher_card}})
                
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.5,
                    func = function()
                        voucher_card:start_dissolve()                
                        juice_hooligan = false
                        return true
                    end
                }))
                return true
            end
        }))
        end
    end    
})