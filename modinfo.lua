local function zh_en(zh, en)  -- Other languages don't work
    local chinese_languages =
    {
        zh = "zh", -- Chinese for Steam
        zhr = "zh", -- Chinese for WeGame
        ch = "zh", -- Chinese mod
        chs = "zh", -- Chinese mod
        sc = "zh", -- simple Chinese
        zht = "zh", -- traditional Chinese for Steam
        tc = "zh", -- traditional Chinese
        cht = "zh", -- Chinese mod
    }

    if chinese_languages[locale] ~= nil then
        lang = chinese_languages[locale]
    else
        lang = en
    end

    return lang == "zh" and zh or en
end

name = zh_en("自定义保存间隔&黄昏时人物说台词(like DS)","Custom Save Interval & Character Dialogue at Dusk (like DS)")
version = "1.0.2"
description = zh_en(
[[·现在 自动存档的时间不再是每天早上，而是按你设置的保存间隔来保存，
默认设置是8分钟 效果就像饥荒单机版一样
·现在 黄昏时人物都会说一句台词，就像饥荒单机版一样]],
[[· The automatic save time is no longer every morning; it now saves according to your set interval, with a default setting of 8 minutes, similar to Don't Starve.
· Characters will now say a line of dialogue at dusk, just like in Don't Starve.]]
)
author = "冰冰羊"


api_version = 10
priority = 10

dst_compatible = true

all_clients_require_mod = true
client_only_mod = false
server_only_mod = false

icon_atlas = "images/modicon.xml"
icon = "modicon.tex"

configuration_options  =
{
    {
        name = "lang",
        label = zh_en("语言", "Language"),
        hover = zh_en("选择你想要使用的语言", "Select the language you want to use"),
        options =
        {
            {description = "English(英语)", data = "en", hover = ""},
            {description = "中文(Chinese)", data = "zh", hover = ""},
            {description = zh_en("自动", "Auto"), data = "auto", hover = zh_en("根据游戏语言自动设置", "Automatically set according to the game language")},
        },
        default = "auto",
    },

    {
        name = "save_time",
        label = zh_en("自动保存时间间隔", "Auto Save Interval"),
        hover = zh_en("设置自动保存的时间间隔，单位为分钟，现在不是每天早上准点保存了！", "Set the automatic save interval in minutes. It no longer saves exactly every morning!"),
        options = {
            {description = zh_en("6秒（测试选项）", "6 seconds (test option)"), data = 0.1},
            {description = zh_en("2分钟", "2 minutes"), data = 2},
            {description = zh_en("4分钟", "4 minutes"), data = 4},
            {description = zh_en("8分钟（默认）", "8 minutes (default)"), data = 8},
            {description = zh_en("16分钟", "16 minutes"), data = 16},
            {description = zh_en("30分钟", "30 minutes"), data = 30},
            {description = zh_en("60分钟", "60 minutes"), data = 60},
            {description = zh_en("120分钟", "120 minutes"), data = 120},
            {description = zh_en("180分钟", "180 minutes"), data = 180},
            {description = zh_en("240分钟", "240 minutes"), data = 240},
            {description = zh_en("不保存", "Don't Save"), data = false},
        },
        default = 8
    },

    {
        name = "save_prompt",
        label = zh_en("保存前提示", "Save Prompt"),
        hover = zh_en("在自动保存的多久前进行提示？", "How long before auto-save should a prompt appear?"),
        options =
        {
            {description = zh_en("关闭", "Off"), hover = zh_en("不提示", "No prompt"), data = false},
            {description = zh_en("5秒", "5 seconds"), hover = zh_en("自动保存前5秒进行提示", "Prompt 5 seconds before auto-save"), data = 5},
            {description = zh_en("10秒", "10 seconds"), hover = zh_en("自动保存前10秒进行提示", "Prompt 10 seconds before auto-save"), data = 10},
            {description = zh_en("30秒", "30 seconds"), hover = zh_en("自动保存前30秒进行提示", "Prompt 30 seconds before auto-save"), data = 30},
            {description = zh_en("一分钟", "1 minute"), hover = zh_en("自动保存前一分钟进行提示", "Prompt 1 minute before auto-save"), data = 60},
        },
        default = 5
    },

    {
        name = "dusk_announce",
        label = zh_en("黄昏时人物说台词", "Character Dialogue at Dusk"),
        hover = zh_en("在黄昏时，人物会自动说台词（就像单机版一样）", "Characters will automatically say lines at dusk (like in the \"Don't Starve\")"),
        options =
        {
            {description = zh_en("开启", "Enable"), data = true},
            {description = zh_en("关闭", "Disable"), data = false},
        },
        default = true
    },

}