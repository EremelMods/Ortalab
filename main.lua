Ortalab = SMODS.current_mod


local load_order = {'jokers', 'enhancements', 'editions', 'loteria', 'zodiac', 'patches', 'decks', 'coupons', 'stakes', 'blinds', 'curses', 'mythos'}
Ortalab.load_table = {
    jokers = true,
    enhancements = true,
    editions = true,
    loteria = true,
    zodiac = true,
    patches = true,
    decks = true,
    coupons = true,
    stakes = true,
    blinds = true,
    curses = true,
    mythos = true
}


loc_colour('red')
G.ARGS.LOC_COLOURS['Ortalab'] = HEX('990000')
G.ARGS.LOC_COLOURS.Ort_menu_colourA = HEX('686868')
G.ARGS.LOC_COLOURS.Ort_menu_colourB = HEX('C9013C')


for _, k in ipairs(load_order) do
    if Ortalab.load_table[k] then assert(SMODS.load_file('objects/'..k..'.lua'))() end
end
assert(SMODS.load_file('objects/loteria_boosters.lua'))() -- load boosters
assert(SMODS.load_file('objects/zodiac_boosters.lua'))() -- load boosters
assert(SMODS.load_file('objects/mythos_boosters.lua'))() -- load boosters

assert(SMODS.load_file('util/artists.lua'))()
assert(SMODS.load_file('util/functions.lua'))()
assert(SMODS.load_file('util/menu.lua'))()

SMODS.Atlas({
    key = 'modicon',
    path = 'modicon.png',
    px = '34',
    py = '34'
})

Ortalab.optional_features = function()
    return {
        retrigger_joker = true,
        quantum_enhancements = true
    }
end

SMODS.Atlas({
    key = 'logo',
    path = 'logo.png',
    px = 333,
    py = 216,
})
SMODS.Shader({
    key = 'background',
    path = 'new_background.fs'
})

if (SMODS.Mods['malverk'] or {}).can_load then
    AltTextures_Utils.default_atlas['ortalab_zodiac'] = 'ortalab_zodiac_cards'
    AltTextures_Utils.loc_keys['ortalab_zodiac'] = 'b_zodiac_cards'
    AltTexture({
        key = 'alt_zodiac',
        set = 'ortalab_zodiac',
        path = 'zodiac_coloured.png',
        display_pos = 'c_ortalab_zod_virgo',
        loc_txt = {
            name = 'Rainbow Zodiac'
        }
    })

    TexturePack{
        key = 'alt_orta',
        textures = {
            'ortalab_alt_zodiac',
        },
        loc_txt = {
            name = 'Full Colour Zodiacs',
            text = {
                'Alternate art for {C:zodiac}Zodiac',
            }
        }
    }
end

Ortalab.ui_config = {
    colour = G.C.L_GREY,
    outline_colour = G.ARGS.LOC_COLOURS.Ortalab,
    tab_button_colour = G.ARGS.LOC_COLOURS.Zodiac,
    author_bg_colour = G.ARGS.LOC_COLOURS.Ortalab
}