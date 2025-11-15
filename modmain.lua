modimport("strings.lua") -- 加载翻译文件

-- 语言检测
local lang = GetModConfigData("lang") or "auto"
if lang == "auto" then
    lang = GLOBAL.LanguageTranslator.defaultlang
end

local chinese_languages =
{
	zh = "zh", --Chinese for Steam
	zhr = "zh", --Chinese for WeGame
	ch = "zh", --Chinese mod
	chs = "zh", --Chinese mod
	sc = "zh", --simple Chinese
	chinese = "zh", --Chinese mod
	zht = "zh", --traditional Chinese for Steam
	tc = "zh", --traditional Chinese
	cht = "zh", --Chinese mod
}

if chinese_languages[lang] ~= nil then
    lang = chinese_languages[lang]
elseif not GLOBAL.STRINGS.SAVE_ANNOUNCE[lang] then -- 找不到对应语言的翻译才用英文
    lang = "en"
end

local function announce_save(str)
    if GLOBAL.ThePlayer and GLOBAL.ThePlayer.prefab then
        GLOBAL.ThePlayer.components.talker:Say(str)
    end
end

-- 保存前提示
AddClientModRPCHandler("ANNOUNCE", "save", function(str)
    announce_save(str)
end)

AddShardModRPCHandler("ANNOUNCE", "shard", function(shardId,str) -- 多层世界 保存提示数据传输
    if GLOBAL.TheShard:GetShardId() ~= tostring(shardId) then
        SendModRPCToClient(CLIENT_MOD_RPC["ANNOUNCE"]["save"], nil, str)
    end
end)

AddPrefabPostInit("world",function(inst)
    -- 黄昏宣告
    local function player_announce_dusk(world)
        local phase = world.state.phase
        if phase == "dusk" then
            for _,v in pairs(GLOBAL.AllPlayers or {}) do
                if v.prefab == "wes" then
                    v.components.talker:Say("") -- 韦斯不会说话，用空白内容替代
                else
                    v.components.talker:Say(GLOBAL.GetString(v.prefab, "ANNOUNCE_DUSK"))
                end
            end
        end
    end
    if GLOBAL.TheNet:GetIsServer() then
        if not inst:HasTag("cave") and GetModConfigData("dusk_announce") then -- 开启模组设置并且不是洞穴才宣告
            inst:WatchWorldState("phase", player_announce_dusk) -- 监听世界状态
        end
    end

    -- 服务器自动保存部分
    if GLOBAL.TheNet:IsDedicated() and GLOBAL.TheShard:IsMaster() or -- 专用服务器+主世界
        not (GLOBAL.TheNet:IsDedicated() or GLOBAL.TheNet:GetIsClient()) -- 非专用服务器（玩家开的服，可能有独行长路）
    then
        inst:DoTaskInTime(0, function(inst)
            inst:PushEvent("ms_setautosaveenabled", false) -- 关闭DST自动保存功能
        end)

        local min
        if GetModConfigData("save_time") == false then
            return
        else
            min = GetModConfigData("save_time")
        end

        inst:DoPeriodicTask(min * 60, function()
            inst:PushEvent("ms_save") -- 存档！
        end)

        -- 保存前的提示
        local TIME = GetModConfigData("save_prompt")
        local SAVE_ANNOUNCE = GLOBAL.STRINGS.SAVE_ANNOUNCE[lang]:format(TIME) -- 提示内容
        if GetModConfigData("save_time") and
            GetModConfigData("save_prompt") and
            GetModConfigData("save_time") * 60 > GetModConfigData("save_prompt")
        then
            inst:DoTaskInTime(min * 60 - TIME, function(inst) -- 首次执行
                SendModRPCToClient(CLIENT_MOD_RPC["ANNOUNCE"]["save"], nil, SAVE_ANNOUNCE)
                SendModRPCToShard(SHARD_MOD_RPC["ANNOUNCE"]["shard"], nil, SAVE_ANNOUNCE)
                announce_save(SAVE_ANNOUNCE)

                inst:DoPeriodicTask(min*60,function() -- 循环执行
                    SendModRPCToClient(CLIENT_MOD_RPC["ANNOUNCE"]["save"], nil, SAVE_ANNOUNCE)
                    SendModRPCToShard(SHARD_MOD_RPC["ANNOUNCE"]["shard"], nil, SAVE_ANNOUNCE)
                    announce_save(SAVE_ANNOUNCE)
                end)
            end)
        end
    end
end)