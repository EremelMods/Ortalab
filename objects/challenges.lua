SMODS.Challenge {
    key = 'chaosC',
    vouchers = {
        {id = 'v_overstock_norm'},
        {id = 'v_illusion'},
    },
    rules = {
        custom = {
            {id = 'ortalab_chaosC'}
        },
    },
    restrictions = {
        banned_cards = {
            {id = 'v_ortalab_glamour'},
            {id = 'v_ortalab_hex'},
            {id = 'v_ortalab_arcane_archive'},
            {id = 'v_magic_trick'},
            {id = 'v_tarot_merchant'},
            {id = 'v_tarot_tycoon'},
            {id = 'v_planet_merchant'},
            {id = 'v_planet_tycoon'},
        },
    },
    deck = {
        type = 'b_ortalab_challenge',
        unlocked = function(self)
            return true
        end,
    },
    apply = function(self)
        G.GAME.planet_rate = 4
        G.GAME.tarot_rate = 4
        G.GAME.ortalab_loteria_rate = 4
        G.GAME.ortalab_zodiac_rate = 4
        G.GAME.joker_rate = 4
        G.GAME.ortalab_mythos_rate = 4
        G.GAME.ortalab.vouchers.tags_in_shop = 4
        G.GAME.ortalab_utility_rate = 4
        G.GAME.ortalab_mythos_rate = 4
        G.GAME.playing_card_rate = 4
    end,
    button_colour = Ortalab.badge_colour
}

SMODS.Challenge {
    key = 'rich_kidC',
    jokers = {
        {id = 'j_gift', eternal = true},
        {id = 'j_ortalab_priest', eternal = true},
    },
    vouchers = {
        {id = 'v_hone', eternal = true},
    },
    restrictions = {
        banned_cards = {
            {id = 'c_ortalab_lot_hand'},
            {id = 'c_ortalab_tree_of_life'},
        },
        banned_tags = {
            {id = 'tag_ortalab_hand'},
        },
    },
    deck = {
        type = 'b_ortalab_challenge',
        unlocked = function(self)
            return true
        end,
    },
    button_colour = Ortalab.badge_colour
}

SMODS.Challenge {
    key = 'ambidexrousC',
    jokers = {
      {id = 'j_ortalab_polydactyly', eternal = true},
      {id = 'j_four_fingers', eternal = true},  
    },
    vouchers = {
        {id = 'v_ortalab_statue'},
        {id = 'v_paint_brush'},
    },
    restrictions = {
        banned_cards = {
            {id = 'c_ortalab_lot_hand'},
            {id = 'c_ortalab_tree_of_life'},
        },
        banned_tags = {
            {id = 'tag_ortalab_hand'},
        },
    },
    deck = {
        type = 'b_ortalab_challenge',
        unlocked = function(self)
            return true
        end,
    },
    button_colour = Ortalab.badge_colour
}

SMODS.Challenge {
    key = 'blackC',
    jokers = {
        {id = 'j_ortalab_graffiti', eternal = true, edition = 'ortalab_anaglyphic'},
        {id = 'j_ortalab_grave_digger', eternal = true, edition = 'negative'},
    },
    restrictions = {
        banned_cards = {
            {id = 'c_ortalab_lot_hand'},
            {id = 'c_ortalab_tree_of_life'},
        },
        banned_tags = {
            {id = 'tag_ortalab_hand'},
        },
    },
    deck = {
        type = 'b_ortalab_challenge',
        unlocked = function(self)
            return true
        end,
    },
    button_colour = Ortalab.badge_colour
}

SMODS.Challenge {
    key = 'copyC',
    jokers = {
        {id = 'j_ortalab_pinkprint', eternal = true, edition = 'ortalab_overexposed'},
        {id = 'j_ortalab_pinkprint', eternal = true, edition = 'ortalab_overexposed'},
    },
    restrictions = {
        banned_cards = {
            {id = 'c_ortalab_lot_hand'},
            {id = 'c_ortalab_tree_of_life'},
        },
        banned_tags = {
            {id = 'tag_ortalab_hand'},
        },
    },
    deck = {
        type = 'b_ortalab_challenge',
        unlocked = function(self)
            return true
        end,
    },
    button_colour = Ortalab.badge_colour
}

SMODS.Challenge {
    key = 'evil_upC',
    rules = {
        modifiers = {
            {id = 'hand_size', value = 4},
        },
    },
    jokers = {
        {id = 'j_ortalab_false_phd', eternal = true, edition = 'ortalab_overexposed'},
    },
    restrictions = {
        banned_cards = {
            {id = 'j_ortalab_gloomy_gus'},
            {id = 'j_ortalab_klutz'},
            {id = 'j_ortalab_actor'},
            {id = 'j_turtle_bean'},
            {id = 'j_juggler'},
            {id = 'j_troubadour'},
            {id = 'j_merry_andy'},
            {id = 'c_ortalab_lot_hand'},
            {id = 'c_ortalab_jackalope'},
            {id = 'c_ortalab_tree_of_life'},
            {id = 'v_ortalab_abacus'},
            {id = 'v_paint_brush'},
        },
        banned_tags = {
            {id = 'tag_ortalab_hand'},
        },
    },
    deck = {
        type = 'b_ortalab_challenge',
        unlocked = function(self)
            return true
        end,
    },
    button_colour = Ortalab.badge_colour
}

SMODS.Challenge {
    key = 'lostC',
    rules = {
        custom = {
            {id = 'ortalab_lostC'},
        },
    },
    deck = {
        type = 'b_ortalab_challenge',
        unlocked = function(self)
            return true
        end,
        cards = {
            {s='D',r='2'}, {s='D',r='3'}, {s='D',r='4'}, {s='D',r='5'}, {s='D',r='6'}, {s='D',r='7'}, {s='D',r='8'}, {s='D',r='9'}, {s='D',r='T'}, {s='D',r='A'},
            {s='C',r='2'}, {s='C',r='3'}, {s='C',r='4'}, {s='C',r='5'}, {s='C',r='6'}, {s='C',r='7'}, {s='C',r='8'}, {s='C',r='9'}, {s='C',r='T'}, {s='C',r='A'},
            {s='H',r='2'}, {s='H',r='3'}, {s='H',r='4'}, {s='H',r='5'}, {s='H',r='6'}, {s='H',r='7'}, {s='H',r='8'}, {s='H',r='9'}, {s='H',r='T'}, {s='H',r='A'},
            {s='S',r='2'}, {s='S',r='3'}, {s='S',r='4'}, {s='S',r='5'}, {s='S',r='6'}, {s='S',r='7'}, {s='S',r='8'}, {s='S',r='9'}, {s='S',r='T'}, {s='S',r='A'},
        }
    },
    calculate = function(self, context)
        if context.ante_change and context.ante_end then
            G.E_MANAGER:add_event(Event({
                func = (function()
                    add_tag(Tag('tag_ortalab_immolate'))
                    play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
                    play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
                    return true
                end)
            }))
        end
    end,
    button_colour = Ortalab.badge_colour
}

SMODS.Challenge {
    key = 'diseasedC',
    restrictions = {
        banned_cards = {
            {id = 'c_ortalab_gnome'},
            {id = 'c_ortalab_ya_te_veo'},
            {id = 'c_ortalab_crawler'},
            {id = 'c_ortalab_anubis'},
            {id = 'c_ortalab_wendigo'},
        },
    },
    rules = {
        custom = {
            {id = 'ortalab_diseasedC'},
        },
    },
    deck = {
        type = 'b_ortalab_challenge',
        unlocked = function(self)
            return true
        end,
    },
    button_colour = Ortalab.badge_colour
}

SMODS.Challenge {
    key = 'russianC',
    jokers = {
        {id = 'j_ortalab_revolver', eternal = true, edition = 'negative'},
    },
    restrictions = {
        banned_cards = {
            {id = 'c_ortalab_gnome'},
            {id = 'c_ortalab_ya_te_veo'},
            {id = 'c_ortalab_crawler'},
            {id = 'c_ortalab_anubis'},
            {id = 'c_ortalab_wendigo'},
            {id = 'c_ortalab_lot_hand'},
            {id = 'c_ortalab_tree_of_life'},
        },
        banned_tags = {
            {id = 'tag_ortalab_hand'},
        },
    },
    rules = {
        custom = {
            {id = 'ortalab_russianC'},
        },
    },
    deck = {
        type = 'b_ortalab_challenge',
        unlocked = function(self)
            return true
        end,
    },
    button_colour = Ortalab.badge_colour
}

SMODS.Challenge {
    key = 'ephermeralC',
    rules = {
        custom = {
            {id = 'ortalab_ephermeralC'},
        },
    },
    restrictions = {
        banned_cards = {
            {id = 'c_ortalab_tree_of_life'},
        },
    },
    deck = {
        type = 'b_ortalab_challenge',
        unlocked = function(self)
            return true
        end,
    },
    button_colour = Ortalab.badge_colour
}

SMODS.Challenge {
    key = 'policeC',
    rules = {
        custom = {
            {id = 'ortalab_only'}
        },
    },
    jokers = {
        {id = 'j_ortalab_policeman', eternal = true, edition = 'negative'},
    },
    restrictions = {
        banned_cards = {
            {id = 'j_ortalab_cardist'},
            {id = 'j_ortalab_rockstar'},
            {id = 'v_ortalab_one_mans_trash'},
            {id = 'c_ortalab_lot_hand'},
            {id = 'c_ortalab_jackalope'},
            {id = 'c_ortalab_tree_of_life'},
        },
        banned_tags = {
            {id = 'tag_ortalab_hand'},
        },
        banned_other = {
            {id = 'bl_ortalab_fork', type = "blind"},
        }
    },
    apply = function(self)
        G.GAME.stake = G.P_STAKES.stake_ortalab_one.order
        SMODS.setup_stake(G.P_STAKES.stake_ortalab_one.order)
    end,
    deck = {
        type = 'b_ortalab_challenge',
        unlocked = function(self)
            return true
        end,
    },
    button_colour = Ortalab.badge_colour
}

SMODS.Challenge {
    key = 'cursedC',
    rules = {
        custom = {
            {id = 'ortalab_only'}
        },
    },
    jokers = {
        {id = 'j_ortalab_belmont', eternal = true},
        {id = 'j_ortalab_proletaire', eternal = true},
    },
    vouchers = {
        {id = 'v_ortalab_fates_coin'},
        {id = 'v_ortalab_arcane_archive'},
    },
    restrictions = {
        banned_cards = {
            {id = 'c_ortalab_lot_hand'},
            {id = 'c_ortalab_tree_of_life'},
        },
        banned_tags = {
            {id = 'tag_ortalab_hand'},
        },
    },
    deck = {
        type = 'b_ortalab_challenge',
        unlocked = function(self)
            return true
        end,
    },
    apply = function(self)
        G.GAME.stake = G.P_STAKES.stake_ortalab_one.order
        SMODS.setup_stake(G.P_STAKES.stake_ortalab_one.order)
    end,
    button_colour = Ortalab.badge_colour
}

SMODS.Challenge {
    key = 'starsC',
    rules = {
        custom = {
            {id = 'ortalab_only'}
        },
    },
    jokers = {
        {id = 'j_ortalab_astrologist', eternal = true},
        {id = 'j_ortalab_stargazing', eternal = true},
    },
    restrictions = {
        banned_cards = {
            {id = 'c_ortalab_lot_hand'},
            {id = 'c_ortalab_tree_of_life'},
        },
        banned_tags = {
            {id = 'tag_ortalab_hand'},
        },
    },
    deck = {
        type = 'b_ortalab_challenge',
        unlocked = function(self)
            return true
        end,
    },
    apply = function(self)
        G.GAME.stake = G.P_STAKES.stake_ortalab_one.order
        SMODS.setup_stake(G.P_STAKES.stake_ortalab_one.order)
    end,
    button_colour = Ortalab.badge_colour
}

SMODS.Challenge {
    key = 'shinkuC',
    rules = {
        custom = {
            {id = 'ortalab_only'}
        },
    },
    jokers = {
        {id = 'j_ortalab_shinku', eternal = true, edition = 'ortalab_overexposed'},
    },
    modifiers = {
        {id = 'joker_slots', value = 3},
    },
    restrictions = {
        banned_cards = {
            {id = 'c_ortalab_tree_of_life'},
        },
        banned_tags = {
        },
    },
    deck = {
        type = 'b_ortalab_challenge',
        unlocked = function(self)
            return true
        end,
    },
    apply = function(self)
        G.GAME.stake = G.P_STAKES.stake_ortalab_one.order
        SMODS.setup_stake(G.P_STAKES.stake_ortalab_one.order)
    end,
    button_colour = Ortalab.badge_colour
}

SMODS.Challenge {
    key = 'freezerC',
    rules = {
        custom = {
            {id = 'ortalab_only'}
        },
    },
    jokers = {
        {id = 'j_ortalab_freezer', eternal = true},
        {id = 'j_ortalab_head_honcho', eternal = true},
        
    },
    consumeables = {
        {id = 'c_medium'},
    },
    restrictions = {
        banned_cards = {
            {id = 'c_ortalab_lot_hand'},
            {id = 'c_ortalab_tree_of_life'},
        },
        banned_tags = {
            {id = 'tag_ortalab_hand'},
        },
    },
    deck = {
        type = 'b_ortalab_challenge',
        unlocked = function(self)
            return true
        end,
    },
    apply = function(self)
        G.GAME.stake = G.P_STAKES.stake_ortalab_one.order
        SMODS.setup_stake(G.P_STAKES.stake_ortalab_one.order)
    end,
    button_colour = Ortalab.badge_colour
}

SMODS.Challenge {
    key = 'shrodingerC',
    rules = {
        custom = {
            {id = 'ortalab_only'}
        },
    },
    jokers = {
        {id = 'j_ortalab_black_cat', eternal = true},
        {id = 'j_ortalab_flashback', eternal = true},
    },
    vouchers = {
        {id = 'v_ortalab_abacus'},
        {id = 'v_ortalab_calculator'},
    },
    restrictions = {
        banned_cards = {
            {id = 'c_ortalab_lot_hand'},
            {id = 'c_ortalab_tree_of_life'},
        },
        banned_tags = {
            {id = 'tag_ortalab_hand'},
        },
    },
    deck = {
        type = 'b_ortalab_challenge',
        unlocked = function(self)
            return true
        end,
    },
    apply = function(self)
        G.GAME.stake = G.P_STAKES.stake_ortalab_one.order
        SMODS.setup_stake(G.P_STAKES.stake_ortalab_one.order)
    end,
    button_colour = Ortalab.badge_colour
}

SMODS.Challenge {
    key = 'locked_inC',
    rules = {
        custom = {
            {id = 'ortalab_only'}
        },
    },
    jokers = {
        {id = 'j_ortalab_jester', eternal = true},
        {id = 'j_ortalab_jester', eternal = true},
        {id = 'j_ortalab_crime_scene', eternal = true},
        {id = 'j_ortalab_crime_scene', eternal = true},
        {id = 'j_ortalab_priest', eternal = true},
    },
    vouchers = {
        {id = 'v_tarot_merchant'},
    },
    restrictions = {
        banned_cards = {
            {id = 'c_ortalab_lot_umbrella'},
            {id = 'c_ortalab_lot_melon'},
            {id = 'c_ortalab_lot_mandolin'},
            {id = 'c_ortalab_lot_rose'},
            {id = 'c_ortalab_lot_tree'},
            {id = 'c_ortalab_lot_siren'},
            {id = 'c_ortalab_lot_bird'},
            {id = 'c_ortalab_lot_rooster'},
            {id = 'c_ortalab_lot_parrot'},
            {id = 'c_ortalab_lot_ladder'},
            {id = 'c_ortalab_lot_heron'},
            {id = 'c_ortalab_lot_heart'},
            {id = 'c_ortalab_lot_harp'},
            {id = 'c_ortalab_lot_flag'},
            {id = 'c_ortalab_lot_dandy'},
            {id = 'c_ortalab_lot_bottle'},
            {id = 'c_ortalab_lot_barrel'},
            {id = 'c_ortalab_lot_scorpion'},
            {id = 'c_ortalab_lot_bonnet'},
            {id = 'c_ortalab_lot_boot'},
            {id = 'c_ortalab_tree_of_life'},
        },
        banned_tags = {
            {id = 'tag_ortalab_soul'},
            {id = 'tag_ortalab_common'},
            {id = 'tag_ortalab_fluorescent'},
            {id = 'tag_ortalab_greyscale'},
            {id = 'tag_ortalab_overexposed'},
            {id = 'tag_ortalab_anaglyphic'},
        },
    },
    deck = {
        type = 'b_ortalab_challenge',
        unlocked = function(self)
            return true
        end,
    },
    apply = function(self)
        G.GAME.stake = G.P_STAKES.stake_ortalab_one.order
        SMODS.setup_stake(G.P_STAKES.stake_ortalab_one.order)
    end,
    button_colour = Ortalab.badge_colour
}

SMODS.Challenge {
    key = 'fingersC',
    rules = {
        custom = {
            {id = 'ortalab_only'}
        },
    },
    restrictions = {
        banned_cards = {
            {id = 'j_ortalab_sandstone'},
            {id = 'j_ortalab_false_phd'},
            {id = 'c_ortalab_lot_umbrella'},
            {id = 'c_ortalab_lot_melon'},
            {id = 'c_ortalab_lot_mandolin'},
            {id = 'c_ortalab_lot_rose'},
            {id = 'c_ortalab_lot_siren'},
            {id = 'c_ortalab_lot_bird'},
            {id = 'c_ortalab_lot_ladder'},
            {id = 'c_ortalab_lot_dandy'},
            {id = 'c_ortalab_zod_taurus'},
            {id = 'c_ortalab_zod_scorpio'},
            {id = 'c_ortalab_excalibur'},
            {id = 'c_ortalab_kraken'},
            {id = 'c_ortalab_basilisk'},
            {id = 'c_ortalab_abaia'},
            {id = 'c_ortalab_jormungand'},
        },
        banned_tags = {
        },
        banned_other = {
            {id = 'bl_ortalab_hammer', type = "blind"},
        }
    },
    deck = {
        type = 'b_ortalab_challenge',
        unlocked = function(self)
            return true
        end,
        cards = {
            {s='D',r='2',e='m_ortalab_sand',}, {s='D',r='3',e='m_ortalab_sand',}, {s='D',r='4',e='m_ortalab_sand',}, {s='D',r='5',e='m_ortalab_sand',}, {s='D',r='6',e='m_ortalab_sand',}, {s='D',r='7',e='m_ortalab_sand',},
            {s='D',r='8',e='m_ortalab_sand',}, {s='D',r='9',e='m_ortalab_sand',}, {s='D',r='T',e='m_ortalab_sand',}, {s='D',r='J',e='m_ortalab_sand',}, {s='D',r='Q',e='m_ortalab_sand',}, {s='D',r='K',e='m_ortalab_sand',}, {s='D',r='A',e='m_ortalab_sand',},
            {s='C',r='2',e='m_ortalab_sand',}, {s='C',r='3',e='m_ortalab_sand',}, {s='C',r='4',e='m_ortalab_sand',}, {s='C',r='5',e='m_ortalab_sand',}, {s='C',r='6',e='m_ortalab_sand',}, {s='C',r='7',e='m_ortalab_sand',},
            {s='C',r='8',e='m_ortalab_sand',}, {s='C',r='9',e='m_ortalab_sand',}, {s='C',r='T',e='m_ortalab_sand',}, {s='C',r='J',e='m_ortalab_sand',}, {s='C',r='Q',e='m_ortalab_sand',}, {s='C',r='K',e='m_ortalab_sand',}, {s='C',r='A',e='m_ortalab_sand',},
            {s='H',r='2',e='m_ortalab_sand',}, {s='H',r='3',e='m_ortalab_sand',}, {s='H',r='4',e='m_ortalab_sand',}, {s='H',r='5',e='m_ortalab_sand',}, {s='H',r='6',e='m_ortalab_sand',}, {s='H',r='7',e='m_ortalab_sand',},
            {s='H',r='8',e='m_ortalab_sand',}, {s='H',r='9',e='m_ortalab_sand',}, {s='H',r='T',e='m_ortalab_sand',}, {s='H',r='J',e='m_ortalab_sand',}, {s='H',r='Q',e='m_ortalab_sand',}, {s='H',r='K',e='m_ortalab_sand',}, {s='H',r='A',e='m_ortalab_sand',},
            {s='S',r='2',e='m_ortalab_sand',}, {s='S',r='3',e='m_ortalab_sand',}, {s='S',r='4',e='m_ortalab_sand',}, {s='S',r='5',e='m_ortalab_sand',}, {s='S',r='6',e='m_ortalab_sand',}, {s='S',r='7',e='m_ortalab_sand',},
            {s='S',r='8',e='m_ortalab_sand',}, {s='S',r='9',e='m_ortalab_sand',}, {s='S',r='T',e='m_ortalab_sand',}, {s='S',r='J',e='m_ortalab_sand',}, {s='S',r='Q',e='m_ortalab_sand',}, {s='S',r='K',e='m_ortalab_sand',}, {s='S',r='A',e='m_ortalab_sand',},
        }
    },
    apply = function(self)
        G.GAME.stake = G.P_STAKES.stake_ortalab_one.order
        SMODS.setup_stake(G.P_STAKES.stake_ortalab_one.order)
    end,
    button_colour = Ortalab.badge_colour
}

SMODS.Challenge {
    key = 'rustyC',
    rules = {
        custom = {
            {id = 'ortalab_only'}
        },
        modifiers = {
            {id = 'hand_size', value = 1},
            {id = 'discards', value = 5},
        },
    },
    jokers = {
        {id = 'j_ortalab_jester', edition = 'ortalab_anaglyphic'},
    },
    restrictions = {
        banned_cards = {
            {id = 'j_ortalab_rockstar'},
            {id = 'j_ortalab_gloomy_gus'},
            {id = 'j_ortalab_klutz'},
            {id = 'j_ortalab_actor'},
            {id = 'v_ortalab_abacus'},
            {id = 'v_ortalab_recyclo_inv'},
        },
        banned_other = {
            {id = 'bl_ortalab_caramel_coin', type = "blind"},
            {id = 'bl_ortalab_sinker', type = "blind"},
            {id = 'bl_ortalab_saffron_shield', type = "blind"},
        }
    },
    deck = {
        type = 'b_ortalab_challenge',
        unlocked = function(self)
            return true
        end,
    },
    apply = function(self)
        G.GAME.stake = G.P_STAKES.stake_ortalab_one.order
        SMODS.setup_stake(G.P_STAKES.stake_ortalab_one.order)
    end,
    button_colour = Ortalab.badge_colour
}

SMODS.Challenge {
    key = 'virtuelessC',
    rules = {
        custom = {
            {id = 'no_shop_jokers'},
            {id = 'ortalab_only'}
        },
        modifiers = {
            {id = 'joker_slots', value = 0},
        },
    },
    restrictions = {
        banned_cards = {
            {id = 'v_ortalab_glamour'},
            {id = 'v_ortalab_calculator'},
            {id = 'v_ortalab_pulse_wave'},
            {id = 'v_ortalab_energy_surge'},
            {id = 'c_ortalab_corpus'},
            {id = 'p_buffoon_normal_1', ids = {
                'p_buffoon_normal_1', 'p_buffoon_normal_2',
                'p_buffoon_jumbo_1', 'p_buffoon_mega_1' }
            },
        },
        banned_tags = {
            {id = 'tag_ortalab_soul'},
            {id = 'tag_ortalab_common'},
            {id = 'tag_ortalab_fluorescent'},
            {id = 'tag_ortalab_greyscale'},
            {id = 'tag_ortalab_overexposed'},
            {id = 'tag_ortalab_anaglyphic'},
        },
    },
    deck = {
        type = 'Challenge Deck',
        unlocked = function(self)
            return true
        end,
    },
    apply = function(self)
        G.GAME.stake = G.P_STAKES.stake_ortalab_one.order
        SMODS.setup_stake(G.P_STAKES.stake_ortalab_one.order)
    end,
    button_colour = Ortalab.badge_colour
}

local ortalab_create_card = create_card
function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
    local card = ortalab_create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
    if ((area == G.shop_jokers) or (area == G.pack_cards) or (area == G.jokers)) and card.ability.set == 'Joker' then
        if G.GAME.modifiers.ortalab_ephermeralC then
            card:add_sticker('perishable', true)
        end
        if G.GAME.modifiers.ortalab_diseasedC then
            card:set_curse('ortalab_infected', true, true)
        end
        if G.GAME.modifiers.ortalab_russianC then
            card:set_curse('ortalab_possessed', true, true)
        end
    end
    return card
end